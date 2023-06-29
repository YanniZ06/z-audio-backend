package zAudio.handles;

import haxe.io.UInt8Array;
import haxe.io.Bytes;
import openal.AL.ALuint;

class BufferHandle
{
	public var handle:Null<ALuint> = null;
	public var data:Bytes = null;
	public var reverseData:Bytes = null;
	public var dataLength(get, never):Int;
    function get_dataLength():Int { if(data == null) return 0; else return data.length;}
	public var samples:Int = 0;
	public var channels:Int = 0;
	public var bitsPerSample:Int = 0;
	public var sampleRate:Int = 0;
	public var format:Int = AL.FORMAT_MONO8;
	public var parentSource:SourceHandle = null;

	public function new(buffer:ALuint) {
		handle = buffer;
	}

	@:noCompletion private var cacheAddress:String = "";
	/**
	 * Fills the buffer with informations about the sound. Can only be used once per handle and is only really used on the `SoundLoader`.
	 * @param channels Channel Information
	 * @param bitsPerSample Amount of bits per sample
	 * @param data Bytes consisting of the decoded sound-data
	 * @param sampleRate Samplerate Information
	 * @param doPreloadReverseData If true, preloads the reverse sound information. Otherwise reverse sound data can be loaded using `preloadReverseData`
	 * @return This buffer, for chaining purposes.
	 */
	public function fill(channels:Int, bitsPerSample:Int, data:Bytes, sampleRate:Int, doPreloadReverseData:Bool = true):BufferHandle {
		this.channels = channels;
		this.bitsPerSample = bitsPerSample;
		this.data = data;
		if(doPreloadReverseData) preloadReverseData();
		this.sampleRate = sampleRate;

		format = resolveFormat(bitsPerSample, channels);
		AL.bufferData(handle, format, data, dataLength, sampleRate);
		samples = Std.int((dataLength * 8) / (channels * bitsPerSample));

		@:privateAccess if(parentSource != null) {
			parentSource.parentSound.changeLength(Std.int(samples / sampleRate * 1000)/*- offset*/);
			parentSource.parentSound.initialized = true;
		}

		return this;
	}

	/**
	 * If the reverse data for this buffer has not been loaded yet, you can load it using this function.
	 * 
	 * If it has already been loaded regardless this function will be skipped automatically.
	 */
	public function preloadReverseData() {
		if(reverseData != null) return;

		var data_:UInt8Array = UInt8Array.fromBytes(data);
		var reversed:UInt8Array = new UInt8Array();
		for(byteI in 0...data_.length)
			reversed.set(byteI, data_.get(data_.length - byteI)); //Set byte from back of data array to front of reversed array
		reverseData = reversed.getData().bytes; //cast reversed;

		var curCache = SoundHandler.activeSounds[cacheAddress];
		if(curCache == null) return;

		curCache.hasReverseCache = true;
		for(snd in curCache.sounds)
			snd.buffer.reverseData = reverseData;
		
		var bufCache = SoundHandler.existingBufferData[cacheAddress];
		if(bufCache != null) bufCache.reverseData = reverseData;
	}

	/**
	 * Destroys this Buffer and renders it unuseable.
	 * Memory will be cleared the next time the garbage collector is activated.
	 */
	public function destroy() {
		if(parentSource != null) parentSource.detachBuffer();
		parentSource = null;

		AL.deleteBuffer(handle);
		handle = null;
		data = null;
		reverseData = null;
		cacheAddress = null;
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
		var b:BufferHandle = new BufferHandle(AL.genBuffer());
		if(b2.data != null) b.fill(b2.channels, b2.bitsPerSample, b2.data, b2.sampleRate, false);
		if(b2.reverseData != null) b.reverseData = b2.reverseData;

		return b;
	}

	public function toString():String return 'BufferHandle(data: $data, parentSource: $parentSource)';

	static final formats8 = [AL.FORMAT_MONO8, AL.FORMAT_STEREO8];
	static final formats16 = [AL.FORMAT_MONO16, AL.FORMAT_STEREO16];
	private static inline function resolveFormat(bitsPerSample:Int, channels:Int):Int
		return bitsPerSample <= 8 ? formats8[channels - 1] : formats16[channels - 1];
}
