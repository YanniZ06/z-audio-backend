package zAudio.file_stream;

import haxe.ds.Vector;
import haxe.io.Bytes;
/**
 * Interface that defines shared functions between multiple different file-streams
 */
interface IStreamBase {
    // Processed chunks stored, older data indexed lower than "processLimit", current running chunk being indexed at "processLimit" and newer data indexed over "processLimit"
    public var processedData:Vector<StreamChunk>;

     // Will define the maximum number of processedData to be stored at once, into one direction (same number is used for other direction aswell)
    public var processLimit(default, set):cpp.UInt8;

    // Specify size of processed chunks, shouldnt be larger than like 2 seconds of audio I think (value is defined in bytes i think)
    // Value can only be set once upon stream creation
    public var proccessLength(default, null):Int;

    // Heavily WIP
    //public function seek(pos:Int):Void;
}