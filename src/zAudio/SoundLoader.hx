package zAudio;

// import decoder.Mp3Decoder;
import lime.media.AudioBuffer;
import haxe.Timer;
import haxe.io.Bytes;
import sys.io.File;
import haxe.http.HttpBase;

import decoder.Decoder;
import decoder.WavDecoder;
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
		switch (type)
		{
			case 'ogg': //Lime already has an audio decoder so we might aswell use that and spare ourselves the ogg headache
				#if (lime_cffi && !macro)
				@:privateAccess {
					var audioBuffer = new AudioBuffer();
					audioBuffer.data = new UInt8Array(Bytes.alloc(0));

					NativeCFFI.lime_audio_load_bytes(fileBytes, audioBuffer);
					return {
						format: resolveFormat(audioBuffer.bitsPerSample, audioBuffer.channels),
						data: cast audioBuffer.data,
						freq: audioBuffer.sampleRate
					}
				}
				#end
			case 'wav':
				var decoder:WavDecoder = new WavDecoder(fileBytes, false);
				@:privateAccess decoder.readAll();
				function wait() { if(!decoder.processed) { Timer.delay(wait, 5); trace("Waited!"); } } //If somehow not processed and program continues execution, wait 5 ms
				wait();

				@:privateAccess
				return {
					format: resolveFormat(decoder.bps * 4 /*Decoder.calc_BitsPerSample(decoder.sampleRate, decoder.bitrate)*/, decoder.channels),
					data: #if audio16 resolveDataFromBytes(decoder.decoded.getData().bytes) #else resolveDataFromBytes(decoder.decoded.getData().bytes) #end,
					freq: decoder.sampleRate
				}
		}

		return null;
	}

	static final formats8 = [AL.FORMAT_MONO8, AL.FORMAT_STEREO8]; // ,4354
	static final formats16 = [AL.FORMAT_MONO16, AL.FORMAT_STEREO16];
	private static inline function resolveFormat(bitsPerSample:Int, channels:Int):Int
		return bitsPerSample <= 8 ? formats8[channels - 1] : formats16[channels - 1];

	//This took stupidly long to figure out, sincerely fuck you lime for making ArrayBufferViews so hard to create
	private static inline function resolveDataFromBytes(bytes:Bytes):ArrayBufferView return cast UInt8Array.fromBytes(bytes);
}