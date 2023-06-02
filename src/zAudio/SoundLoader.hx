package zAudio;

// import decoder.Mp3Decoder;
import haxe.Timer;
import haxe.io.Bytes;
import sys.io.File;
import haxe.http.HttpBase;

import decoder.Decoder;
import decoder.OggDecoder;
import lime.utils.ArrayBufferView;
import lime.utils.Int32Array;

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
			case 'ogg' | 'wav' | 'mp3': // All good :)
			default:
				throw 'Error, url "$url" does not point to a valid ogg or mp3 file!\nThe url should end with one of the given three extension names!';
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
				//case 'mp3': return fromMp3(bytes);
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
				throw 'Error, path "$path" does not point to a valid ogg or mp3 file!\nThe path should end with one of the given three extension names!';
		}
		final fileBytes = File.getBytes(path);
		switch (type)
		{
			//case 'mp3': return fromMp3(fileBytes);
			case 'ogg':
				var decoder:OggDecoder = new OggDecoder(fileBytes, false);
				function wait() { if(!decoder.processed) { Timer.delay(wait, 5); trace("Waited!"); } } //If somehow not processed and program continues execution, wait 5 ms
				wait();

				File.saveBytes("assets/snd/decodedSnd.wav", decoder.getWAV());
				@:privateAccess
				return {
					format: resolveFormat(decoder.bps * 4/*Decoder.calc_BitsPerSample(decoder.sampleRate, decoder.bitrate)*/, decoder.channels),
					data: #if audio16 resolveDataFromBytes(decoder.decoded.getData().bytes) #else decoder.decoded #end,//.get_view().getData().bytes),
					freq: decoder.sampleRate
				}
			case 'wav': throw "UNIMPLEMENTED!! (wav)";
		}

		return null;
	}

	/*public static function fromMp3(bytes:haxe.io.Bytes):SoundInfo {
		var info = Mp3Utils.getInfo(bytes);
        return {
			format: resolveFormat(info, MP3),
			data: resolveDataFromBytes(info.data),
			freq: info.sampleRate
        };
    }*/

	static final formats8 = [AL.FORMAT_MONO8, AL.FORMAT_STEREO8]; // ,4354
	static final formats16 = [AL.FORMAT_MONO16, AL.FORMAT_STEREO16];
	private static inline function resolveFormat(bitsPerSample:Int, channels:Int):Int
		return bitsPerSample <= 8 ? formats8[channels - 1] : formats16[channels - 1];

	//This took stupidly long to figure out, sincerely fuck you lime for making ArrayBufferViews so hard to create
	private static inline function resolveDataFromBytes(bytes:Bytes):ArrayBufferView return Int32Array.fromBytes(bytes);
}