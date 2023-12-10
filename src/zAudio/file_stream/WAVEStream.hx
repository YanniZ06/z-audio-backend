package zAudio.file_stream;

import haxe.ds.Vector;
import sys.io.File;
import sys.io.FileInput;
import sys.io.FileSeek;

/**
 * Class that creates a WAVE-file(.wav) streaming interface
 * 
 * https://api.haxe.org/haxe/io/Input.html#readBytes
 */
class WAVEStream implements IStreamBase {
    public var fileInput:FileInput;

    public var processedData:Vector<StreamChunk>;

    // Will define the maximum number of processedData to be stored at once, into one direction (same number is used for other direction aswell)
    public var processLimit(default, set):cpp.UInt8;

    private var _processLimitFull:cpp.UInt8 = 0;

    // Specify size of processed chunks, shouldnt be larger than like 2 seconds of audio I think (value is defined in bytes i think)
    // Value can only be set once upon stream creation
    public var proccessLength(default, null):Int;

    //TODO FOR EVERYTHING BELOW ACTUALLY 

    
    //TODO
    public function new(file:String, chunkLimit:cpp.UInt8) {
        fileInput = File.read(file);

        //_processLimitFull = chunkLimit; // Make first calc 100% accurate and not copy anything
        processLimit = chunkLimit;
    }
    //public function seek():

    //TODO
    function set_processLimit(l:cpp.UInt8):cpp.UInt8 {
        if(l % 2 != 0) throw 'Processed Data Limit must be an even number!';

        final old_limit = _processLimitFull;
        _processLimitFull = Std.int(l*2);
        processLimit = l;

        var newData:Vector<StreamChunk> = new Vector(_processLimitFull);
        /*for(i in (_processLimitFull - old_limit)...Std.int(_processLimitFull/2)) {
            newData[i] = processedData[i]; // ! second i 
        }*/
        processedData = newData; //? AFTER rearranging
        return l;
    }
}