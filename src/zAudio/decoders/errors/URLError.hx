package zAudio.decoders.errors;

/**
 * Represents the error state of an URL content decode operation.
 */
enum abstract URLError(cpp.Int8) {
    /**
     * URL was resolved and contents were decoded without error.
     */
    var OK:URLError = 0;
    /**
     * Failed to resolve URL or connection.
     * 
     * The given URL does not point to a valid site, did not respond or could not be connected to due to a lack of internet connection.
     */
    var BAD_GATEWAY:URLError = -1;
    /**
     * The bytes of the content do not match with ones that are decoded in RIFF-WAVE, OGG-VORBIS or MP3 format.
     * 
     * Ensure that the URL points to a file directly (for example a discord link).
     */
    var UNSUPPORTED_FORMAT:URLError = -2;
}