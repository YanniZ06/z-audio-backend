/*
	* Original file belongs to @starburst997 on github,
	* from repository "https://github.com/notessimo-archive/audio-decoder/tree/master"

	* Under the following license:
	* MIT License

	* Copyright (c) 2017 Notessimo

	* Permission is hereby granted, free of charge, to any person obtaining a copy
	* of this software and associated documentation files (the "Software"), to deal
	* in the Software without restriction, including without limitation the rights
	* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	* copies of the Software, and to permit persons to whom the Software is
	* furnished to do so, subject to the following conditions:

	* The above copyright notice and this permission notice shall be included in all
	* copies or substantial portions of the Software.

	* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	* SOFTWARE.
	* 
	* Modified by @YanniZ06
 */

/*package decoder;

import openfl.utils.ByteArray;
import format.mp3.Data;
import format.mp3.Tools;
import haxe.io.Bytes;
import haxe.io.BytesInput;*/

/**
 * Simple interface to MP3 Decoder
 *
 * Progressively decode the MP3 by requesting range
 * 
 * JS works but sample point are wayyyy off compared to Flash extract()
 *
 * Will need some major cleanup, mostly experimenting right now...
 */
/*class Mp3Decoder extends Decoder
{
	// Constructor
	public function new(bytes:Bytes, delay:Bool = false)
	{
		super(bytes, delay);
	}

	override function create()
	{
		trace("");

		var info = Mp3Utils.getInfo(bytes);
		trace("MP3 Reader finished");

		_process(info.length, info.channels, info.sampleRate);
	}

	// Read samples inside the MP3
	private override function read(start:Int, end:Int):Bool
	{
		// TODO: !!!
		return true;
	}
}

// Modify the MP3 Class a bit so we can get the information a bit more efficiently
typedef Mp3Info =
{
	var sampleRate:Int;
	var bitsPerSample:Int;
	var channels:Int;
	var length:Int;
	var data:Bytes;
};

class Mp3Utils extends format.mp3.Reader
{
	var bi:BytesInput;
	var channels:Int = 1;
	var sampleRate:Int = 44100;

	public function new(i:BytesInput)
	{
		bi = i;

		super(i);
	}

	var lastFrame:MP3Frame = null;
	var bitrate:Int = 0;
	var fullFrameBytes:ByteArray = new ByteArray();
	var frameCount:Int = 0;
	public override function readFrame():MP3Frame
	{
		frameCount++;
		var header = readFrameHeader();

		if (header == null || Tools.isInvalidFrameHeader(header))
			return null;

		trace(frameCount);


		channels = header.channelMode == Mono ? 1 : 2;

		sampleRate = switch (header.samplingRate)
		{
			case SR_48000: 48000;
			case SR_44100: 44100;
			case SR_32000: 32000;
			case SR_24000: 24000;
			case SR_22050: 22050;
			case SR_12000: 12000;
			case SR_11025: 11025;
			case SR_8000: 8000;
			default: 44100;
		};

		try
		{
			var data = i.read(Tools.getSampleDataSizeHdr(header));
			try {
				fullFrameBytes.writeBytes(data, fullFrameBytes.length, data.length); //You don't work!
			}
			catch(e) {
				//trace('Error ($e), could not continue writing to ByteArray.\n\nByteArray info: Length = ${fullFrameBytes.length}, Bytes: $fullFrameBytes\n\nData Info: Length = ${data.length}, Bytes = $data\n\n');
			}
			samples += Tools.getSampleCountHdr(header);
			sampleSize += data.length;

			bi.position += data.length;

			lastFrame = {
				header: header,
				data: data
			};

			return lastFrame;
		}
		catch (e:haxe.io.Eof)
		{
			if (lastFrame != null) //This doesnt do much since bitrate is VARIABLE ffs
				bitrate = Std.parseInt(lastFrame.header.bitrate.getName().split('_')[1]); //E.G: Enum(BR_8) -> ["BR", "8"] -> "8" -> 8
			return null;
		}
	}

	public static function getInfo(bytes:Bytes):Mp3Info
	{
		var reader = new Mp3Utils(new BytesInput(bytes));

		var mp3Info:MP3 = reader.read();
		var bps:Int = 0;
		var fullBytes:Bytes = null;
		@:privateAccess { 
			bps = Decoder.calc_BitsPerSample(reader.sampleRate, reader.bitrate);
			fullBytes = reader.fullFrameBytes;
		}
		return {
			sampleRate: reader.sampleRate,
			channels: reader.channels,
			length: reader.samples,
			bitsPerSample: bps,
			data: fullBytes
		};
	}
}*/
