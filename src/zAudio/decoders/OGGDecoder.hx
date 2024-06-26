package zAudio.decoders;

// Uses VorbisFile decoder
// Documentation here: https://xiph.org/vorbis/doc/vorbisfile/

import haxe.io.Bytes;
import ogg.Ogg;

class VorbisFile {
    /**
     * Handler for the OggVorbisFile, used by various functions
     */
    public var fVorbis:OggVorbisFile;

    /**
     * Path to the file this VorbisFile object represents
     */
    public var fPath:String;

    /**
     * Dictates whether this VorbisFile is useable (points to a valid ogg-vorbis file) or not
     */
    public var valid:Bool = true;

    /**
     * Represents this VorbisFiles' current error code.
     * 
     * Can be checked after an operation to ensure everything is going smoothly.
     */
    public var errorCode:Int = 0;

    /**
     * Amount of channels this VorbisFile has.
     * 
     * Call `readInfo()` to properly initialize this value.
     */
    public var channels:cpp.Int8 = 0;

    /**
     * Sampling-rate this VorbisFile has.
     * 
     * Call `readInfo()` to properly initialize this value.
     */
    public var sampleRate:Int = 0;

    /**
     * BPS this VorbisFile has.
     * 
     * Call `readInfo()` to properly initialize this value.
     */
    public var bitsPerSample:Int = 0;

    /**
     * Size this VorbisFile has.
     * 
     * Call `readInfo()` to properly initialize this value.
     */
    public var fSize:Int = 0;
    /**
     * Creates a new VorbisFile handler for the vorbis file located at `filePath`.
     * 
     * Shouldn't be used manually but through `makeVorbisFileFrom(path)`.
     * @param filePath Path to the ogg-vorbis file you want to load
     * @param container A handler for an `OggVorbisFile`.
     */
    public function new(filePath:String, container:OggVorbisFile) {
        fVorbis = container;
        fPath = filePath;

        final fileRes = Ogg.ov_fopen(fPath, fVorbis);
        if(fileRes != 0) {
            #if ZAUDIO_DEBUG trace('Error loading sound from path "$fPath": ${code(fileRes)}'); #end
            valid = false;
            return;
        }
    }

    /**
     * Reads the info header of this VorbisFile.
     * Fills channel and sampleRate information, aswell as fileSize
     */
    public function readInfoHeader() {
        final info:VorbisInfo = Ogg.ov_info(fVorbis, -1);
        sampleRate = info.rate;
        channels = info.channels;
        fSize = sys.FileSystem.stat(fPath).size;
        bitsPerSample = info.bitrate_nominal / sampleRate > 12 ? 16 : 8;

        trace(sampleRate);
        trace(info.bitrate_nominal);
        trace(info.bitrate_nominal / sampleRate);
    }

    /**
     * Reads the entire VorbisFile and returns its decompressed Bytes.
     */
    public function readFullFile():Bytes {
        var bytes:Bytes = Bytes.alloc(fSize);
        var i = 0;
        while(true) {
            i++;
            final res = Ogg.ov_read(fVorbis, bytes.getData(), 0, 4096, OggEndian.TYPICAL, OggWord.TYPICAL, OggSigned.TYPICAL);
            if(res == 0) break; // EOF
        }
        trace(i);
        for(i=>byte in bytes.getData()) {
            if(i < 200) continue;
            // trace(byte);
            if(i > 400) break;
        }
        return bytes;
    }

    /**
     * Clears this VorbisFile along with all its contents and returns true if successful, otherwise false.
     */
    public function dispose():Bool {
        fPath = null;
        return Ogg.ov_clear(fVorbis) == 0 ? true : false;
    }

    public static function makeVorbisFileFrom(path:String):VorbisFile {
        return new VorbisFile(path, Ogg.newOggVorbisFile());
    }

    //converts return code to string
    static function code(_code:OggCode):String {
        return switch(_code){
            case OggCode.OV_EBADHEADER:'OV_EBADHEADER';
            case OggCode.OV_EBADLINK:'OV_EBADLINK';
            case OggCode.OV_EBADPACKET:'OV_EBADPACKET';
            case OggCode.OV_EFAULT:'OV_EFAULT';
            case OggCode.OV_EIMPL:'OV_EIMPL';
            case OggCode.OV_EINVAL:'OV_EINVAL';
            case OggCode.OV_ENOSEEK:'OV_ENOSEEK';
            case OggCode.OV_ENOTAUDIO:'OV_ENOTAUDIO';
            case OggCode.OV_ENOTVORBIS:'OV_ENOTVORBIS';
            case OggCode.OV_EOF:'OV_EOF';
            case OggCode.OV_EREAD:'OV_EREAD';
            case OggCode.OV_EVERSION:'OV_EVERSION';
            case OggCode.OV_FALSE:'OV_FALSE';
            case OggCode.OV_HOLE: 'OV_HOLE';
            case _:'$_code';
        }
    }
}