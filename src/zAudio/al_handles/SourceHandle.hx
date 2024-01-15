package zAudio.al_handles;

/**
 * A handle for an `ALSource` object, al_handles aux and filter related properties for the `handle` ALSource type object.
 */
class SourceHandle
{
	public var handle:ALSource = 0; // TODO: DOCUMENT THIS
	public var buffer:BufferHandle = null;
	public var parentSound:Sound = null;
	public var hasFilter:Bool = false;

	public function new(?hndl:ALSource, parentSound:Sound)
	{
		handle = hndl;
		this.parentSound = parentSound;
	}

	/**
	 * Effect Utility Function to get rid of an Auxiliary Effect Slot connected to the source
	 * @param id The ID of the auxiliary slot to remove
	 */
	public function onAuxRemove(id:Int)
		HaxeAL.source3i(handle, HaxeEFX.AUXILIARY_SEND_FILTER, HaxeEFX.EFFECTSLOT_NULL, id, /*cast(castedFilter.get(), Int) ??*/ HaxeEFX.FILTER_NULL);

	/**
	 * Attaches a buffer to this `source`.
	 * If the buffer is already attached to another source, it is detached from its old source rendering its sound uninitialized.
	 * 
	 * (Might just give buffers the ability to have multiple parent sources as I don't see why that WOULDNT work??)
	 * @param buffer The buffer to attach to this `source`.
	 */
	public function attachBuffer(buffer:BufferHandle) {
		if(buffer.parentSource != null) buffer.parentSource.detachBuffer();

		HaxeAL.sourcei(handle, HaxeAL.BUFFER, buffer.handle);
		parentSound.buffer = buffer;
		this.buffer = buffer;
		buffer.parentSource = this;

		@:privateAccess if(buffer.data != null) {
			parentSound.changeLength(Std.int(buffer.samples / buffer.sampleRate * 1000)/*- offset*/);
			parentSound.initialized = true;
		}
	}

	/**
	 * Detaches the buffer connected to this source and automatically stops the sound associated with it.
	 * 
	 * If no buffer has been connected via `attachBuffer`, this function will most likely fail.
	 */
	public function detachBuffer() {
		if(HaxeAL.getSourcei(handle, HaxeAL.SOURCE_STATE) != HaxeAL.STOPPED) //Gotta make sure we reset everything, cant just check for the sound playing
			parentSound.stop();
		
		HaxeAL.sourcei(handle, HaxeAL.BUFFER, null);
		buffer.parentSource = null;
		
		trace(buffer);
		//buffer.destroy(); // We cannot safely destroy this buffer because it's not a copy
		buffer = null;

		parentSound.buffer = null;
		parentSound.initialized = false;
	}

	/**
	 * Gets rid of `this` SourceHandle and renders it unuseable.
	 * 
	 * Memory will be cleared the next time the garbage collector is activated.
	 */
	public function destroy() {
		if(buffer != null) detachBuffer();
		HaxeAL.deleteSource(handle);
		
		parentSound.source = null;
		parentSound.initialized = false;
		parentSound = null;
	}


	/**
	 * Gets rid of `this` SourceHandle and renders it unuseable, querying it for deletion.
	 * The query-list can be cleared using `CacheHandler.queryCache.clearSrcQuery()`.
	 * 
	 * Memory will be cleared when the source has been deleted and the garbage collector has been activated.
	 */
	public function queryDestroy() {
		if(buffer != null) detachBuffer();
		CacheHandler.queryCache.srcCleanQuery.push(handle);

		parentSound.source = null;
		parentSound.initialized = false;
		parentSound = null;
	}
}
