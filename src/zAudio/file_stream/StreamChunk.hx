package zAudio.file_stream;

import haxe.ds.Vector;
//import StdTypes.Single;

class StreamChunk {
    /**
     * A vector storing the start- and end-position of this chunk in the streamed files' compressed bytes.
     */
    public var filePos:Vector<Int>;

    /**
     * A vector storing the beginning and end timestamps this chunk represents, in MS.
     */
    public var soundBounds:Vector<Single>;

    /**
     * The buffer containing the decompressed data this chunk represents.
     */
    public var data_buffer:ALBuffer;


    // Reverse Specific //
    /**
     * A vector storing the start- and end-position of this chunk in the streamed files' compressed bytes when its reversed.
     * 
     * Null as long as no reversed data has been requested for the sound.
     */
    public var reversed_filePos:Null<Vector<Int>> = null;

    /**
     * The buffer containing the decompressed data this chunk represents when its reversed.
     * 
     * Null as long as no reversed data has been requested for the sound.
     */
    public var reversed_buffer:Null<ALBuffer> = null;

    /**
     * Creates a new StreamChunk object with the given information.
     * @param fileStart Start position of this chunk in the streamed files' compressed bytes.
     * @param fileEnd End position of this chunk in the streamed files' compressed bytes.
     * @param timeStart Beginning timestamp this chunk represents, in MS.
     * @param timeEnd End timestamp this chunk represents, in MS.
     * @param buffer The buffer containing the decompressed data this chunk represents.
     */
    public function new(fileStart:Int, fileEnd:Int, timeStart:Single, timeEnd:Single, buffer:ALBuffer) {
        filePos = new Vector(2);
        filePos[0] = fileStart;
        filePos[1] = fileEnd;

        soundBounds = new Vector(2);
        soundBounds[0] = timeStart;
        soundBounds[1] = timeEnd;

        data_buffer = buffer;

        return this;
    }

    /**
     * Loads in reverse data for this StreamChunk.
     * 
     * Returns this StreamChunk, for chaining.
     * @param fileStart Start position of this chunk in the streamed files' compressed bytes when its reversed.
     * @param fileEnd End position of this chunk in the streamed files' compressed bytes when its reversed.
     * @param buffer The buffer containing the decompressed data this chunk represents when its reversed.
     */
    public function fillReverse(fileStart:Int, fileEnd:Int, buffer:ALBuffer):StreamChunk {
        reversed_filePos = new Vector(2);
        reversed_filePos[0] = fileStart;
        reversed_filePos[1] = fileEnd;

        reversed_buffer = buffer;

        return this;
    }
}