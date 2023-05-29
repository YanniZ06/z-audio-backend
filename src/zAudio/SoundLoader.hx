package zAudio;
import decoder.Mp3Decoder;
import haxe.http.HttpBase;

typedef SoundInfo = {
    var format:Int;
	var data:lime.utils.ArrayBufferView;
    var size:Int;
    var freq:Int;
}

enum abstract FileType(String) from String to String
{
	var MP3 = "mp3";
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
				throw 'Error, url "$url" does not point to a valid ogg, wav or mp3 file!\nThe url should end with one of the given three extension names!';
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
				case 'mp3': return fromMp3(bytes);
				case 'ogg': throw "UNIMPLEMENTED!! (ogg)";
				case 'wav': throw "UNIMPLEMENTED!! (wav)";
			}
		}

		return null;
	}

	public static function fromFile(path:String)
	{
		var pathSplit:Array<String> = path.split('.');
		final type:String = pathSplit[path.length - 1];
		switch (type)
		{
			case 'ogg' | 'wav' | 'mp3': // All good :)
			default:
				throw 'Error, path "$path" does not point to a valid ogg, wav or mp3 file!\nThe path should end with one of the given three extension names!';
		}
	}

	public static function fromMp3(bytes:haxe.io.Bytes):SoundInfo {
		var info = Mp3Utils.getInfo(bytes);
        return {
			format: resolveFormat(info, MP3),
            data: null,
            size: null,
			freq: info.sampleRate
        };
    }

	private static function resolveFormat(audioInfo:Any, fileType:FileType):Int
	{
		final formats8 = [AL.FORMAT_MONO8, AL.FORMAT_STEREO8];
		final formats16 = [AL.FORMAT_MONO16, AL.FORMAT_STEREO16];

		switch (fileType)
		{
			case MP3:
				final info:Mp3Info = cast audioInfo;

				return info.bitsPerSample <= 8 ? formats8[info.channels - 1] : formats16[info.channels - 1];
			case OGG: throw "UNIMPLEMENTED!! (ogg)";
			case WAV: throw "UNIMPLEMENTED!! (wav)";
		}
		return 0;
	}
}