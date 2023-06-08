package zAudio;

// import decoder.Mp3Decoder;
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
	 * Make sure the URL points to the raw sound data and ends with .ogg or .wav, otherwise this function will throw!
	 * @param url The URL to load the sound from
	 */
	public static function fromURL(url:String):BufferHandle
	{
		var req = new haxe.http.HttpBase(url);

		var retBuffer:BufferHandle = null;
		req.onBytes = bytes -> retBuffer = bufferFromBytes(bytes, url);
		req.onError = err -> throw 'Error "$err"\nCould not obtain bytes for url "$url"!';

		req.request(false);
		return retBuffer;
	}

	public static function fromFile(path:String):BufferHandle
	{
		final fileBytes = File.getBytes(path);
		return bufferFromBytes(fileBytes, path);
	}

	/**
	 * Generates all information necessary to load Sound from the given `bytes` input.
	 * 
	 * If a file with the same path has been loaded in already, no new Buffer is generated and that one is taken instead.
	 * @param bytes Raw byte data to generate Sound-data from, bytes must be encoded in ogg vorbis!
	 * @param filePath The path of the file these bytes are tied to. Must be set to ensure there is no duplicate data in memory.
	 * @return A Buffer that stores the byte information.
	 */
	public static function from_ogg(bytes:Bytes, filePath:String):BufferHandle {
		#if (lime_cffi && !macro)
		var duplicate:BufferHandle = SoundHandler.existingBufferData[filePath];
		if(duplicate != null) return BufferHandle.copyFrom(duplicate);

		@:privateAccess {
			var audioBuffer = new AudioBuffer();
			audioBuffer.data = new UInt8Array(Bytes.alloc(0));

			NativeCFFI.lime_audio_load_bytes(bytes, audioBuffer);
			
			SoundHandler.existingBufferData.set(filePath, 
				new BufferHandle(AL.createBuffer()).fill(audioBuffer.channels, audioBuffer.bitsPerSample, cast audioBuffer.data, audioBuffer.sampleRate));
			return BufferHandle.copyFrom(SoundHandler.existingBufferData[filePath]); 
		}
		#end
	}

	/**
	 * Generates all information necessary to load Sound from the given `bytes` input.
	 * 
	 * If a file with the same path has been loaded in already, no new Buffer is generated and that one is taken instead.
	 * @param bytes Raw byte data to generate Sound-data from, bytes must be encoded in wav format!
	 * @param fileName The path of the file these bytes are tied to. Must be set to ensure there is no duplicate data in memory.
	 * @return A Buffer that stores the byte information.
	 */
	public static function from_wav(bytes:Bytes, filePath:String):BufferHandle {
		var duplicate:BufferHandle = SoundHandler.existingBufferData[filePath];
		if(duplicate != null) return BufferHandle.copyFrom(duplicate);

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

		SoundHandler.existingBufferData.set(filePath, new BufferHandle(AL.createBuffer()).fill(channels, bitsPerSample, resolveDataFromBytes(rawData), samplingRate));
		return BufferHandle.copyFrom(SoundHandler.existingBufferData[filePath]);
	}

	// -- Utility loading functions --

	//This took stupidly long to figure out, sincerely fuck you lime for making ArrayBufferViews so hard to create
	private static inline function resolveDataFromBytes(bytes:Bytes):ArrayBufferView return cast UInt8Array.fromBytes(bytes);

	private static function bufferFromBytes(bytes:Bytes, path:String):BufferHandle {
		final fileSignature:String = bytes.getString(0, 4);
		switch (fileSignature) // File Signature
		{
			case "OggS": return from_ogg(bytes, path);
			case "RIFF" if (bytes.getString(8, 4) == "WAVE"): return from_wav(bytes, path);
			default:
				switch ([bytes.get(0), bytes.get(1), bytes.get(2)])
				{
					case [73, 68, 51] | [255, 251, _] | [255, 250, _] | [255, 243, _]: throw 'MP3 audio is not supported on this backend!';
					default: throw 'Invalid sound format or file-header "$fileSignature"!';
				}
		}
		return null;

		//throw 'Invalid sound format "$type"';
	}
}