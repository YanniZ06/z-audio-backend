/*
 * THE CODE BELOW 100% BELONGS TO GITHUB USER DATEE (https://github.com/datee)
 * AND LOGICINTERACTIVE
 * IT HAS BEEN RETRIEVED FROM THE MINIMP3.HX GITHUB WHICH CAN BE FOUND HERE:
 * (https://github.com/LogicInteractive/MiniMP3.hx/tree/main)
 */

package zAudio.decoders;

import cpp.Int8;
import cpp.Char;
import haxe.io.BytesData;
import haxe.io.BytesOutput;
import cpp.Native;
import cpp.NativeSys;
import cpp.CastCharStar;
import cpp.UInt8;
import cpp.RawPointer;
import cpp.UInt32;
import cpp.ConstCharStar;
import cpp.Int16;
import cpp.Star;
import haxe.io.Bytes;
import sys.io.File;
import cpp.NativeString;

//None of these below work
//inline final mp3File:String = macros.CPPContentMacro.getFile('MiniMP3');
//@:cppNamespaceCode(mp3File) //pleaseworkpleaseworkpleasework
//@:build(macros.CPPContentMacro.insertFile('MiniMP3'))


class MP3Decoder extends cpp.MiniMP3 {
    static public function decodeMP3(file:Bytes)
    {
		var totSampleCount:Int = 0;
		var sampleRate:Int = 0;
		var channels:Int= 0;

        var raw:Star<Int8> = decodeMP3ToBuffer(
                                cast RawPointer.addressOf(file.getData())[0],
                                file.length,
                                cast RawPointer.addressOf(sampleRate),
                                cast RawPointer.addressOf(totSampleCount),
                                cast RawPointer.addressOf(channels)
                            );

        var mp3Bytes:Bytes = rawBufferToBytes(raw,totSampleCount);

        trace("Generated new mp3.");
        return
        {
            data:mp3Bytes,
            sampleCount:totSampleCount,
            sampleRate:sampleRate,
            channels:channels
        };
    }

    static public function encodeWav(buffer:Bytes,sampleCount:Int,sampleRate:Int,channels:Int):Bytes
    {
        var nbit:Int = 16;
        var FORMAT_PCM:Int = 1;
        var nbyte:Int = Std.int(nbit / 8);

        var bo = new BytesOutput();
        bo.writeString("RIFF");
        bo.writeInt32(36+(sampleCount));
        bo.writeString("WAVE");
        bo.writeString("fmt ");
        bo.writeInt32(16);
        bo.writeInt16(FORMAT_PCM);
        bo.writeInt16(channels);
        bo.writeInt32(sampleRate);
        bo.writeInt32(sampleRate*nbyte);
        bo.writeInt16(nbyte);
        bo.writeInt16(nbit);
        bo.writeString("data");
        bo.writeInt32(sampleCount);
        bo.writeBytes(buffer,0,sampleCount);
        return bo.getBytes();
    }

    static function rawBufferToBytes(raw:Star<Int8>,length:Int):Bytes
    {
        var data = new BytesData();
        cpp.NativeArray.setUnmanagedData(data, cast raw, length);
        return Bytes.ofData(data);
    }

	@:native("DecodeMp3ToBuffer")
	extern static function decodeMP3ToBuffer(buf:Star<UInt8>,music_size:Int,sampleRate:Star<UInt32>,totalSampleCount:Star<UInt32>,channels:Star<UInt32>):Star<Int8>;
}