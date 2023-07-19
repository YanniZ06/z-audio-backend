package zAudio;

// import decoder.Mp3Decoder;
import lime.utils.Int8Array;
import lime.media.AudioBuffer;
import haxe.Timer;
import haxe.io.Bytes;
import sys.io.File;
import haxe.http.HttpBase;

import lime.utils.ArrayBufferView;
import lime._internal.backend.native.NativeCFFI;
import lime.utils.UInt8Array;
import zAudio.handles.BufferHandle;

class SoundLoader
{
	/**
	 * Downloads a sound from the web and generates SoundInfo ready for use.
	 * 
	 * If a sound has been loaded by the same URL, no new Buffer is generated and that one is taken instead.
	 * @param url The URL to load the sound from, must be of type wav or ogg.
	 * @param preloadReverseData If true, preloads reverse sound data for the sound (unless its already been preloaded).
	 * Check out your sounds' `buffer.preloadReverseData()` field for a way to preload the reverse data later.
	 * This parameter is optional and defaults to the `preloadReverseSounds` value in `SoundHandler.hx`.
	 */
	public static function fromURL(url:String, ?preloadReverseData:Bool = null):BufferHandle
	{
		var cached = checkCache(url);
		if(cached != null) return cached;

		var req = new haxe.http.HttpBase(url);
		final pr = preloadReverseData ?? SoundHandler.preloadReverseSounds;

		var retBuffer:BufferHandle = null;
		req.onBytes = bytes -> retBuffer = bufferFromBytes(bytes, url, pr);
		req.onError = err -> throw 'Error "$err"\nCould not obtain bytes for url "$url"!';

		req.request(false);
		return retBuffer;
	}

	/**
	 * Generates all information necessary to load Sound from the given filepath.
	 * 
	 * If a file with the same path has been loaded in already, no new Buffer is generated and that one is taken instead.
	 * @param path Path to the sound you wanna load, must be wav or ogg.
	 * @param preloadReverseData If true, preloads reverse sound data for the sound (unless its already been preloaded).
	 * Check out your sounds' `buffer.preloadReverseData()` field for a way to preload the reverse data later.
	 * This parameter is optional and defaults to the `preloadReverseSounds` value in `SoundHandler.hx`.
	 * @return A Buffer that stores the sound information.
	 */
	public static function fromFile(path:String, ?preloadReverseData:Bool = null):BufferHandle
	{
		var cached = checkCache(path);
		if(cached != null) return cached;

		final pr = preloadReverseData ?? SoundHandler.preloadReverseSounds;
		final fileBytes = File.getBytes(path);
		return bufferFromBytes(fileBytes, path, pr);
	}

	/**
	 * Generates all information necessary to load Sound from the given `bytes` input.
	 * 
	 * If a file with the same path has been loaded in already, no new Buffer is generated and that one is taken instead.
	 * @param bytes Raw byte data to generate Sound-data from, bytes must be encoded in ogg vorbis!
	 * @param filePath The path of the file these bytes are tied to. Must be set to ensure there is no duplicate data in memory.
	 * @param preloadReverse If true, preloads reverse sound data for the sound (unless its already been preloaded).
	 * Check out your sounds' `buffer.preloadReverseData()` field for a way to preload the reverse data later.
	 * @return A Buffer that stores the sound information.
	 */
	public static function from_ogg(bytes:Bytes, filePath:String, preloadReverse:Bool = true):BufferHandle {
		#if (lime_cffi && !macro)
		var cached = checkCache(filePath);
		if(cached != null) return cached;

		return oggLoad(bytes, filePath, preloadReverse);
		#end
		return null;
	}

	 /**
	 * Generates all information necessary to load Sound from the given `bytes` input.
	 * 
	 * If a file with the same path has been loaded in already, no new Buffer is generated and that one is taken instead.
	 * @param bytes Raw byte data to generate Sound-data from, bytes must be encoded in wav format!
	 * @param fileName The path of the file these bytes are tied to. Must be set to ensure there is no duplicate data in memory.
	 * @param preloadReverse If true, preloads reverse sound data for the sound (unless its already been preloaded).
	 * Check out your sounds' `buffer.preloadReverseData()` field for a way to preload the reverse data later.
	 * @return A Buffer that stores the byte information.
	 */
	public static function from_wav(bytes:Bytes, filePath:String, preloadReverse:Bool = true):BufferHandle {
		var cached = checkCache(filePath);
		if(cached != null) return cached;

		return wavLoad(bytes, filePath, preloadReverse);
	}

	/**
	 * Generates all information necessary to load Sound from the given `bytes` input.
	 * 
	 * If a file with the same path has been loaded in already, no new Buffer is generated and that one is taken instead.
	 * @param bytes Raw byte data to generate Sound-data from, bytes must be encoded in mp3 format!
	 * @param fileName The path of the file these bytes are tied to. Must be set to ensure there is no duplicate data in memory.
	 * @param preloadReverse If true, preloads reverse sound data for the sound (unless its already been preloaded).
	 * Check out your sounds' `buffer.preloadReverseData()` field for a way to preload the reverse data later.
	 * @return A Buffer that stores the byte information.
	 */
	public static function from_mp3(bytes:Bytes, filePath:String, preloadReverse:Bool = true):BufferHandle {
		var cached = checkCache(filePath);
		if(cached != null) return cached;

		return mp3Load(bytes, filePath, preloadReverse);
	}

	//Avoid checking cache twice lol
	private static function oggLoad(bytes:Bytes, filePath:String, preloadReverse:Bool):BufferHandle {
		#if (lime_cffi && !macro)
		@:privateAccess {
			var audioBuffer = new AudioBuffer();
			audioBuffer.data = new UInt8Array(Bytes.alloc(0));
			NativeCFFI.lime_audio_load_bytes(bytes, audioBuffer);
			
			SoundHandler.existingBufferData.set(filePath, 
				new BufferHandle(AL.createBuffer()).fill(audioBuffer.channels, audioBuffer.bitsPerSample, cast audioBuffer.data, audioBuffer.sampleRate, preloadReverse));
			
			//Edge-case where address is scheduled for deletion but reassigned before all related sounds are destroyed.
			var addressContainer = SoundHandler.activeSounds[filePath];
			if(addressContainer == null) SoundHandler.activeSounds.set(filePath, {cacheExists: true, hasReverseCache: preloadReverse, sounds: []});
			else addressContainer.cacheExists = true;
			
			return getCache(filePath);
		}
		#end
		return null;
	}

	//Same thing as for ogg
	private static function wavLoad(bytes:Bytes, filePath:String, preloadReverse:Bool) {
		var input = new haxe.io.BytesInput(bytes);
		// Get all our infos from the WAV file (rapper gf got me onto a good start so if you see this, thank you :) )
		// All position skips are skipping over values we dont need, refer to this site as to what we're reading (and skipping): https://docs.fileformat.com/audio/wav/
		input.position += 22;

		final channels = input.readInt16();
		final samplingRate = input.readInt32();

		input.position += 6;

		final bitsPerSample = input.readInt16();
		input.position += 4; // should be data marker
		final len = input.readInt32();
		final rawData = input.read(len);
		SoundHandler.existingBufferData.set(filePath, new BufferHandle(AL.createBuffer()).fill(channels, bitsPerSample, resolveDataFromBytes(rawData), samplingRate, preloadReverse));

		//Edge-case where address is scheduled for deletion but reassigned before all related sounds are destroyed.
		var addressContainer = SoundHandler.activeSounds[filePath];
		if(addressContainer == null) SoundHandler.activeSounds.set(filePath, {cacheExists: true, hasReverseCache: preloadReverse, sounds: []});
		else addressContainer.cacheExists = true;

		return getCache(filePath);
	}

	//Must i repeat myself
	private static function mp3Load(bytes:Bytes, filePath:String, preloadReverse:Bool) {
		final mp3Info = MiniMP3.decodeMP3(bytes);
		
		SoundHandler.existingBufferData.set(filePath, new BufferHandle(AL.createBuffer()).fill(mp3Info.channels, 16, resolveDataFromBytes(mp3Info.data), mp3Info.sampleRate, preloadReverse));

		//Edge-case where address is scheduled for deletion but reassigned before all related sounds are destroyed.
		var addressContainer = SoundHandler.activeSounds[filePath];
		if(addressContainer == null) SoundHandler.activeSounds.set(filePath, {cacheExists: true, hasReverseCache: preloadReverse, sounds: []});
		else addressContainer.cacheExists = true;

		return getCache(filePath);
	}

	static function checkCache(address:String):BufferHandle {
		var duplicate:BufferHandle = SoundHandler.existingBufferData[address];
		if(duplicate != null) {
			var buf = BufferHandle.copyFrom(duplicate);
			@:privateAccess buf.cacheAddress = address;
			return buf;
		}
		return null;
	}

	static function getCache(address:String):BufferHandle {
		var buf = BufferHandle.copyFrom(SoundHandler.existingBufferData[address]);
		@:privateAccess buf.cacheAddress = address;
		return buf;
	}

	// -- Utility loading functions --

	//This took stupidly long to figure out, sincerely fuck you lime for making ArrayBufferViews so hard to create
	private static inline function resolveDataFromBytes(bytes:Bytes):ArrayBufferView return cast UInt8Array.fromBytes(bytes);

	private static function bufferFromBytes(bytes:Bytes, path:String, preloadReverse:Bool):BufferHandle {
		final fileSignature:String = bytes.getString(0, 4);
		switch (fileSignature) // File Signature
		{
			case "OggS": return oggLoad(bytes, path, preloadReverse);
			case "RIFF" if (bytes.getString(8, 4) == "WAVE"): return wavLoad(bytes, path, preloadReverse);
			default:
				switch ([bytes.get(0), bytes.get(1), bytes.get(2)])
				{
					case [73, 68, 51] | [255, 251, _] | [255, 250, _] | [255, 243, _]: return mp3Load(bytes, path, preloadReverse);
					default: throw 'Invalid sound format or file-header "$fileSignature"!';
				}
		}
		return null;

		//throw 'Invalid sound format "$type"';
	}
}