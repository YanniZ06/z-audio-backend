package zAudio;

import cpp.Native;
import cpp.Pointer;
// import decoder.Mp3Decoder;
import haxe.Timer;
import haxe.http.HttpBase;
import haxe.io.Bytes;
import sys.io.File;
import zAudio.al_handles.BufferHandle;
import zAudio.decoders.MP3Decoder;
import zAudio.decoders.errors.*;

class SoundLoader
{
	static var __eURL:URLError = OK;
	static var __eFILE:FILEError = OK;

	/**
	 * Returns the state of the last `fromURL` operation.
	 * 
	 * Check `zAudio.decoders.errors.URLError` for more info.
	 */
	public static function getURLError():URLError return __eURL;
	/**
	 * Returns the state of the last `fromFile` or `from_x` operation, where `x` is either `wav`, `ogg` or `mp3`.
	 * 
	 * Check `zAudio.decoders.errors.URLError` for more info.
	 */
	public static function getFILEError():FILEError return __eFILE;

	/**
	 * Downloads a sound from the web and generates SoundInfo ready for use.
	 * 
	 * If a sound has been loaded by the same URL, no new Buffer is generated and that one is taken instead.
	 * 
	 * Will return null if the URL could not be accessed or if the path lead to an invalid
	 * @param url The URL to load the sound from, must be of type wav or ogg.
	 * @param preloadReverseData If true, preloads reverse sound data for the sound (unless its already been preloaded).
	 * Check out your sounds' `buffer.preloadReverseData()` method for a way to preload the reverse data later.
	 * This parameter is optional and defaults to the `preloadReverseSounds` value from `SoundSettings`.
	 */
	public static function fromURL(url:String, ?preloadReverseData:Bool = null):Null<BufferHandle>
	{
		__eURL = OK;

		var cached = checkCache(url);
		if(cached != null) return cached;

		var req = new haxe.http.HttpBase(url);
		final pr = preloadReverseData ?? SoundSettings.preloadReverseSounds;

		var retBuffer:BufferHandle = null;
		req.onBytes = bytes -> retBuffer = bufferFromBytes(bytes, url, pr);
		req.onError = err -> { __eURL = BAD_GATEWAY; trace('Error "$err"\nCould not obtain bytes for url "$url"!'); }

		req.request(false);
		return retBuffer;
	}

	/**
	 * Generates all information necessary to load Sound from the given filepath.
	 * 
	 * If a file with the same path has been loaded in already, no new Buffer is generated and that one is taken instead.
	 * @param path Path to the sound you wanna load, must be wav or ogg.
	 * @param preloadReverseData If true, preloads reverse sound data for the sound (unless its already been preloaded).
	 * Check out your sounds' `buffer.preloadReverseData()` method for a way to preload the reverse data later.
	 * This parameter is optional and defaults to the `preloadReverseSounds` value from `SoundSettings`.
	 * @return A Buffer that stores the sound information.
	 */
	public static function fromFile(path:String, ?preloadReverseData:Bool = null):BufferHandle
	{
		__eFILE = OK;
		var cached = checkCache(path);
		if(cached != null) return cached;	

		return bufferFromString(path, preloadReverseData ?? SoundSettings.preloadReverseSounds);
	}

	/**
	 * Generates all information necessary to load Sound from the given `path`.
	 * 
	 * If a file with the same path has been loaded in already, no new Buffer is generated and that one is taken instead.
	 * @param filePath The path of the file the ogg is located at.
	 * @param preloadReverse If true, preloads reverse sound data for the sound (unless its already been preloaded).
	 * Check out your sounds' `buffer.preloadReverseData()` method for a way to preload the reverse data later.
	 * @return A Buffer that stores the sound information.
	 */
	public static function from_ogg(filePath:String, preloadReverse:Bool):BufferHandle {
		__eFILE = OK;
		var cached = checkCache(filePath);
		if(cached != null) return cached;

		return oggLoad(filePath, preloadReverse);
	}

	 /**
	 * Generates all information necessary to load Sound from the given `bytes` input.
	 * 
	 * If a file with the same path has been loaded in already, no new Buffer is generated and that one is taken instead.
	 * @param bytes Raw byte data to generate Sound-data from, bytes must be encoded in wav format!
	 * @param fileName The path of the file these bytes are tied to. Must be set to ensure there is no duplicate data in memory.
	 * @param preloadReverse If true, preloads reverse sound data for the sound (unless its already been preloaded).
	 * Check out your sounds' `buffer.preloadReverseData()` method for a way to preload the reverse data later.
	 * @return A Buffer that stores the byte information.
	 */
	public static function from_wav(bytes:Bytes, filePath:String, preloadReverse:Bool):BufferHandle {
		__eFILE = OK;
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
	 * Check out your sounds' `buffer.preloadReverseData()` method for a way to preload the reverse data later.
	 * @return A Buffer that stores the byte information.
	 */
	public static function from_mp3(bytes:Bytes, filePath:String, preloadReverse:Bool):BufferHandle {
		__eFILE = OK;
		var cached = checkCache(filePath);
		if(cached != null) return cached;

		return mp3Load(bytes, filePath, preloadReverse);
	}

	// Load functions avoid having to check cache twice, do the actual decoding and loading in tasks

	private static function oggLoad(filePath:String, preloadReverse:Bool):BufferHandle {
/*		
		var buffer = new BufferHandle(HaxeAL.createBuffer()).fill(channels, bitsPerSample, rawData, samplingRate, preloadReverse);
		buffer.cacheAddress = filePath;
		CacheHandler.soundCache[filepath].buffer = buffer;
		
		#if (lime_cffi && !macro)
		@:privateAccess {
			var audioBuffer = new AudioBuffer();
			audioBuffer.data = new UInt8Array(Bytes.alloc(0));
			NativeCFFI.lime_audio_load_bytes(bytes, audioBuffer);
			
			// this syntax wont work!! wahahaha
			CacheHandler.soundCache[filePath].buffer = 
				new BufferHandle(HaxeAL.createBuffer()).fill(audioBuffer.channels, audioBuffer.bitsPerSample, cast audioBuffer.data, audioBuffer.sampleRate, preloadReverse);
			
			//Edge-case where address is scheduled for deletion but reassigned before all related sounds are destroyed.
			var addressContainer = CacheHandler.soundCache[filePath];
			if(addressContainer == null) CacheHandler.soundCache.set(filePath, {markedForRemoval: false, hasReverseCache: preloadReverse, sounds: []});
			else addressContainer.markedForRemoval = false;
			
			return getCache(filePath);
		}
		#end*/
		return null;
	}

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

		var buffer = new BufferHandle(HaxeAL.createBuffer()).fill(channels, bitsPerSample, rawData, samplingRate, preloadReverse);
		buffer.cacheAddress = filePath;
		CacheHandler.soundCache.set(filePath, {markedForRemoval: false, hasReverseCache: preloadReverse, sounds: [], buffer: buffer});

		return getCache(filePath);
	}

	//Must i repeat myself
	private static function mp3Load(bytes:Bytes, filePath:String, preloadReverse:Bool) {
		var decoder = new MP3Decoder(bytes);
		decoder.decode();
		final mp3Info = decoder.decodedInfo;
		
		var buffer = new BufferHandle(HaxeAL.createBuffer()).fill(mp3Info.channels, 16, mp3Info.data, mp3Info.sampleRate, preloadReverse);
		buffer.cacheAddress = filePath;
		buffer.onCleanup = () -> { decoder.dispose(); decoder = null; };

		CacheHandler.soundCache.set(filePath, {markedForRemoval: false, hasReverseCache: preloadReverse, sounds: [], buffer: buffer});

		return getCache(filePath);
	}

	// TODO: test this!!
	static inline function checkCache(address:String):Null<BufferHandle> {
		var cache = CacheHandler.soundCache[address];
		if(cache == null) return null;

		var buf:BufferHandle = new BufferHandle(cache.buffer.handle);
		buf.data = cache.buffer.data;
		buf.reverseData = cache.buffer.reverseData;
		buf.cacheAddress = address;		
		buf.fill_Info(cache.buffer.channels, cache.buffer.bitsPerSample, cache.buffer.sampleRate);

		return buf;
	}

	static inline function getCache(address:String):BufferHandle {
		var cache = CacheHandler.soundCache[address];

		var buf:BufferHandle = new BufferHandle(cache.buffer.handle);
		buf.data = cache.buffer.data;
		buf.reverseData = cache.buffer.reverseData;
		buf.cacheAddress = address;		
		buf.fill_Info(cache.buffer.channels, cache.buffer.bitsPerSample, cache.buffer.sampleRate);

		return buf;
	}

	// -- Utility loading functions --
	// Used by WEB Loading
	private static function bufferFromBytes(bytes:Bytes, path:String, preloadReverse:Bool):BufferHandle {
		final fileSignature:String = bytes.getString(0, 4);

		switch (fileSignature) // File Signature
		{
			case "OggS": return oggLoad(path, preloadReverse);
			case "RIFF" if (bytes.getString(8, 4) == "WAVE"): return wavLoad(bytes, path, preloadReverse);
			default:
				switch ([bytes.get(0), bytes.get(1), bytes.get(2)])
				{
					case [73, 68, 51] | [255, 251, _] | [255, 250, _] | [255, 243, _]: return mp3Load(bytes, path, preloadReverse);
					default: __eURL = UNSUPPORTED_FORMAT; trace('Invalid sound format or file-header "$fileSignature"!');
				}
		}
		return null;

		//throw 'Invalid sound format "$type"';
	}

	// Used by per-path loading
	private static function bufferFromString(path:String, preloadReverse:Bool):BufferHandle {
		var bytes:sys.io.FileInput;
		try { bytes = File.read(path); }
		catch(e) {
			__eFILE = FILE_NOT_FOUND;
			return null;
		}

		final fileSignature:String = bytes.readString(4);
		bytes.seek(8, SeekBegin); 

		inline function finish(ret:BufferHandle) { // To make sure we close the fileinput before exiting this function
			bytes.close();

			return ret;
		}
		switch (fileSignature)
		{
			case "OggS": return finish(oggLoad(path, preloadReverse));
			case "RIFF" if (bytes.readString(4) == "WAVE"): return finish(wavLoad(bytes.readAll(), path, preloadReverse));
			default:
				bytes.seek(0, SeekBegin);
				final mp3Signature = [bytes.readByte(), bytes.readByte(), bytes.readByte()];

				switch (mp3Signature)
				{
					case [73, 68, 51] | [255, 251, _] | [255, 250, _] | [255, 243, _]: return finish(mp3Load(bytes.readAll(), path, preloadReverse));
					default: __eFILE = UNSUPPORTED_FORMAT; trace('Invalid sound format or file-header "$fileSignature"!');
				}
		}
		return null;
	}
}