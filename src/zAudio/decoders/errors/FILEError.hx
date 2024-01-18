package zAudio.decoders.errors;

/**
 * Represents the error state of file decode operation.
 */
enum abstract FILEError(cpp.Int8) {
    /**
     * File was decoded without error.
     */
    var OK:FILEError = 0;
    /**
     * The file could either not be found on the system, or the permissions to open the file were insufficent.
     */
    var FILE_NOT_FOUND:FILEError = -1;
    /**
     * The bytes of the file do not match with ones that are decoded in RIFF-WAVE, OGG-VORBIS or MP3 format.
     */
    var UNSUPPORTED_FORMAT:FILEError = -2;
    /**
     * Could not setup the decoder for an OGG or streamed file.
     */
    var FAILED_SETUP:FILEError = -3;
}