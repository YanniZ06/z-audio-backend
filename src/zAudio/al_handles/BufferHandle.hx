package zAudio.al_handles;

import haxe.io.Bytes;
import haxe.io.Int32Array;

class BufferHandle
{
	public var handle:ALBuffer = 0;
	public var data:Bytes = null;
	public var reverseData:Bytes = null;
	public var dataLength(get, never):Int;
    function get_dataLength():Int { return data?.length ?? 0;}
	public var samples:Int = 0;
	public var channels:Int = 0;
	public var bitsPerSample:Int = 0;
	public var sampleRate:Int = 0;
	public var format:Int = HaxeAL.FORMAT_MONO8;
	public var parentSource:SourceHandle = null;

	/**
	 * Called after destroy is completed, to clean up any other related variables (for mp3's to name an example)
	 */
	public var onCleanup:Void->Void = null;

	public function new(buffer:ALBuffer) {
		handle = buffer;
	}

	@:allow(zAudio.SoundLoader)
	@:noCompletion private var cacheAddress:String = "";
	/**
	 * Fills the buffer with informations about the sound. Can only be used once per handle and is only really used on the `SoundLoader`.
	 * @param channels Channel Information
	 * @param bitsPerSample Amount of bits per sample
	 * @param data A Bytes object consisting of the decoded sound-data bytes
	 * @param sampleRate Sample Rate Information
	 * @param doPreloadReverseData If true, preloads the reverse sound information. Otherwise reverse sound data can be loaded using `preloadReverseData`
	 * @return This buffer, for chaining purposes.
	 */
	public function fill(channels:Int, bitsPerSample:Int, data:Bytes, sampleRate:Int, doPreloadReverseData:Bool = true):BufferHandle {
		this.data = data;
		if(doPreloadReverseData) preloadReverseData();
		fill_Info(channels, bitsPerSample, sampleRate);

		HaxeAL.bufferData(handle, format, data, dataLength, sampleRate);

		/*if(parentSource != null) {
			parentSource.parentSound.changeLength(Std.int(samples / sampleRate * 1000));
			parentSource.parentSound.initialized = true;
		}*/

		return this;
	}

	@:allow(zAudio.SoundLoader)
	private inline function fill_Info(channels:Int, bitsPerSample:Int, sampleRate:Int) {
		this.channels = channels;
		this.bitsPerSample = bitsPerSample;
		this.sampleRate = sampleRate;
		format = resolveFormat(bitsPerSample, channels);
		samples = Std.int((dataLength * 8) / (channels * bitsPerSample));
	}

	/**
	 * If the reverse data for this buffer has not been loaded yet, you can load it using this function.
	 * 
	 * If it has already been loaded regardless this function will be skipped automatically.
	 */
	public function preloadReverseData() {
		if(reverseData != null) return;

		var dataArr:Int32Array = Int32Array.fromBytes(data);
		var reversed:Int32Array = new Int32Array(dataArr.length);
		for(byteI in 0...dataArr.length) { reversed[byteI] = dataArr[dataArr.length - byteI]; } //Set byte from back of data array to front of reversed array
		reverseData = reversed.getData().bytes;

		var curCache = CacheHandler.soundCache[cacheAddress];
		//if(curCache == null) return;

		curCache.hasReverseCache = true;
		for(snd in curCache.sounds)
			snd.buffer.reverseData = reverseData;
		
		curCache.buffer.reverseData = reverseData;
	}

	/**
	 * Destroys this Buffer and renders it unuseable.
	 * Memory will be cleared the next time the garbage collector is activated.
	 */
	public function destroy() {
		if(parentSource != null) parentSource.detachBuffer();
		parentSource = null;

		HaxeAL.deleteBuffer(handle);
		data = null;
		reverseData = null;
		cacheAddress = null;

		if(onCleanup != null) onCleanup();
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
	public static function copyFrom(b2:BufferHandle):BufferHandle { // TODO: get rid of this
		var b:BufferHandle = new BufferHandle(HaxeAL.createBuffer());
		if(b2.data != null) b.fill(b2.channels, b2.bitsPerSample, b2.data, b2.sampleRate, false);
		if(b2.reverseData != null) b.reverseData = b2.reverseData;
		//b.onCleanup = b2.onCleanup; //gotta make sure its copied over to the clones aswell

		return b;
	}

	public function toString():String return 'BufferHandle(file: ${cacheAddress ?? 'unknown'} | parentSource: $parentSource)';

	static final formats8 = [HaxeAL.FORMAT_MONO8, HaxeAL.FORMAT_STEREO8];
	static final formats16 = [HaxeAL.FORMAT_MONO16, HaxeAL.FORMAT_STEREO16];
	private static inline function resolveFormat(bitsPerSample:Int, channels:Int):Int
		return bitsPerSample <= 8 ? formats8[channels - 1] : formats16[channels - 1];
}
