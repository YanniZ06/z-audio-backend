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

typedef SoundInfo = {
    var format:Int;
	var data:ArrayBufferView;
    //var size:Int; //We get it from the data length already :)
    var freq:Int;
}

enum abstract FileType(String) from String to String
{
	//var MP3 = "mp3";
	var OGG = "ogg";
	var WAV = "wav";
}


class SoundLoader
{
	/**
	 * Not exactly a stream per-say, downloads a sound and generates SoundInfo ready for use!
	 * @param url 
	 */
	public static function fromStream(url:String):SoundInfo
	{
		var urlSplit:Array<String> = url.split('.');
		final type:String = urlSplit[urlSplit.length - 1];
		switch (type)
		{
			case 'ogg' | 'wav': // All good :)
			default:
				throw 'Error, url "$url" does not point to a valid ogg or wav file!\nThe url should end with one of the given two extension names!';
		}
		var req = new haxe.http.HttpBase(url);

		var bytes:haxe.io.Bytes = null;
		req.onBytes = ret -> bytes = ret; // we successfully got the bytes
		req.onError = err -> trace('Error "$err"\nCould not obtain bytes for url "$url"!');

		req.request(false);

		if (bytes != null)
		{
			switch (type)
			{
				case 'ogg': throw "UNIMPLEMENTED!! (ogg)";
				case 'wav': throw "UNIMPLEMENTED!! (wav)";
			}
		}

		return null;
	}

	public static function fromFile(path:String):SoundInfo
	{
		var pathSplit:Array<String> = path.split('.');
		final type:String = pathSplit[pathSplit.length - 1]; 
		switch (type)
		{
			case 'ogg' | 'wav': // All good :)
			default:
				throw 'Error, path "$path" does not point to a valid ogg or wav file!\nThe path should end with one of the given two extension names!';
		}
		final fileBytes = File.getBytes(path);
		lastPath = path;

		return Reflect.callMethod(SoundLoader, Reflect.field(SoundLoader, 'from_$type'), [fileBytes]);
		//return null;
	}
	@:noPrivateAccess static var lastPath:String = "";

	public static function from_ogg(bytes:Bytes):SoundInfo {
		#if (lime_cffi && !macro)
		@:privateAccess {
			var audioBuffer = new AudioBuffer();
			audioBuffer.data = new UInt8Array(Bytes.alloc(0));

			NativeCFFI.lime_audio_load_bytes(bytes, audioBuffer);
			lastPath = "";
			return {
				format: resolveFormat(audioBuffer.bitsPerSample, audioBuffer.channels),
				data: cast audioBuffer.data,
				freq: audioBuffer.sampleRate
			}
		}
		#end
	}

	public static function from_wav(bytes:Bytes):SoundInfo {
		var input = new haxe.io.BytesInput(bytes);
		final formatting:String = input.readString(4);
		if (formatting != "RIFF") { //Would be funny
			trace(formatting);
			if (lastPath != "") throw 'INPUT DATA FROM PATH "$lastPath" IS NOT A VALID WAV SOUND!';
			else throw 'INPUT BYTES HEADER DOES NOT INDICATE VALID TYPE "RIFF" (wav sound)!';
		}
		lastPath = "";
		// Get all our infos from the WAV file (rapper gf got me onto a good start so if you see this, thank you :) )
		// All input functions whichs values are kept unassigned are ones that we do not need, refer to this site as to what we're reading: https://docs.fileformat.com/audio/wav/
		input.readInt32(); // size
		input.readString(4); // "WAVE"
		input.readString(4); // "fmt " (we read 4 because theres a trailing null)
		input.readInt32(); // format data length
		input.readInt16(); // format type

		var channels = input.readInt16();
		var samplingRate = input.readInt32();

		input.readInt32(); // (Sample Rate * BitsPerSample * Channels) / 8. ???? what are you
		input.readInt16(); // (BitsPerSample * Channels) / 8.1 - 8 bit mono2 - 8 bit stereo/16 bit mono4 - 16 bit stereo

		var bitsPerSample = input.readInt16();
		input.readString(4); // "data" marker
		var len = input.readInt32();
		var rawData = input.read(len);

		@:privateAccess
		return {
			format: resolveFormat(bitsPerSample, channels),
			data: resolveDataFromBytes(rawData),
			freq: samplingRate
		}
	}

	static final formats8 = [AL.FORMAT_MONO8, AL.FORMAT_STEREO8]; // ,4354
	static final formats16 = [AL.FORMAT_MONO16, AL.FORMAT_STEREO16];
	private static inline function resolveFormat(bitsPerSample:Int, channels:Int):Int
		return bitsPerSample <= 8 ? formats8[channels - 1] : formats16[channels - 1];

	//This took stupidly long to figure out, sincerely fuck you lime for making ArrayBufferViews so hard to create
	private static inline function resolveDataFromBytes(bytes:Bytes):ArrayBufferView return cast UInt8Array.fromBytes(bytes);
}