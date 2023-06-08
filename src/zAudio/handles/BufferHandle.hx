package zAudio.handles;

class BufferHandle
{
	public var handle:ALBuffer = null;
	public var data:lime.utils.ArrayBufferView = null;
	public var dataLength(get, never):Int;
    function get_dataLength():Int { if(data == null) return 0; else return data.length;}
	public var samples:Int = 0;
	public var channels:Int = 0;
	public var bitsPerSample:Int = 0;
	public var sampleRate:Int = 0;
	public var parentSource:SourceHandle = null;

	public function new(buffer:ALBuffer) {
		handle = buffer;
	}

	public function fill(channels:Int, bitsPerSample:Int, data:lime.utils.ArrayBufferView, sampleRate:Int):BufferHandle {
		this.channels = channels;
		this.bitsPerSample = bitsPerSample;
		this.data = data;
		this.sampleRate = sampleRate;

		AL.bufferData(handle, resolveFormat(bitsPerSample, channels), data, dataLength, sampleRate);
		samples = Std.int((dataLength * 8) / (channels * bitsPerSample));

		@:privateAccess if(parentSource != null) {
			parentSource.parentSound.changeLength(Std.int(samples / sampleRate * 1000)/*- offset*/);
			parentSource.parentSound.initialized = true;
		}

		return this;
	}

	public function destroy() {
		if(parentSource != null) parentSource.detachBuffer();
		parentSource = null;

		AL.deleteBuffer(handle);
		handle = null;
		data = null;
	}
	
	/**
	 * Creates a seperate Buffer from the info of the argument buffer, only works on filled buffers though!
	 * 
	 * Use this function if you want to take the buffer info from the argument buffer without creating a reference to it.
	 * 
	 * This is soely done to avoid haxes pass-by-reference destruction.
	 * @param b2 The buffer to copy all the data from.
	 * @return A buffer with the same data.
	 */
	public static function copyFrom(b2:BufferHandle):BufferHandle {
		var b:BufferHandle = new BufferHandle(AL.createBuffer());
		if(b2.data != null) b.fill(b2.channels, b2.bitsPerSample, b2.data, b2.sampleRate);

		return b;
	}

	public function toString():String return 'BufferHandle(data: $data, parentSource: $parentSource)';

	static final formats8 = [AL.FORMAT_MONO8, AL.FORMAT_STEREO8];
	static final formats16 = [AL.FORMAT_MONO16, AL.FORMAT_STEREO16];
	private static inline function resolveFormat(bitsPerSample:Int, channels:Int):Int
		return bitsPerSample <= 8 ? formats8[channels - 1] : formats16[channels - 1];
}
