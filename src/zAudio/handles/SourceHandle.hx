package zAudio.handles;

/**
 * A handle for an `ALSource` object, handles aux and filter related properties for the `handle` ALSource type object.
 */
class SourceHandle
{
	public var handle:Int = null;
	public var buffer:BufferHandle = null;
	public var parentSound:Sound = null;
	public var hasFilter:Bool = false;

	public function new(?hndl:Int, parentSound:Sound)
	{
		handle = hndl;
		this.parentSound = parentSound;
	}

	/**
	 * Effect Utility Function to get rid of an Auxilary Effect Slot connected to the source
	 * @param id The ID of the auxilary slot to remove
	 */
	//public function onAuxRemove(id:Int) //openal.AL.getProcAddress("")
		//AL.removeSend(handle, id);

	/**
	 * Attaches a buffer to this `source`.
	 * If the buffer is already attached to another source, it is detached from its old source rendering its sound uninitialized.
	 * 
	 * (Might just give buffers the ability to have multiple parent sources as I don't see why that WOULDNT work??)
	 * @param buffer The buffer to attach to this `source`.
	 */
	public function attachBuffer(buffer:BufferHandle) {
		if(buffer.parentSource != null) buffer.parentSource.detachBuffer();

		AL.sourcei(handle, AL.BUFFER, buffer.handle);
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
		if(AL.getSourcei(handle, AL.SOURCE_STATE) != AL.STOPPED) //Gotta make sure we reset everything, cant just check for the sound playing
			parentSound.stop();
		
		AL.sourcei(handle, AL.BUFFER, null);
		buffer.parentSource = null;
		
		buffer.destroy();
		buffer = null;

		parentSound.buffer = null;
		parentSound.initialized = false;
	}

	/**
	 * Gets rid of `this` SourceHandle and renders it unuseable.
	 * Also destroys the connected buffer in the process.
	 * 
	 * Memory will be cleared the next time the garbage collector is activated.
	 */
	public function destroy() {
		if(buffer != null) detachBuffer();
		AL.deleteSource(handle);
		
		parentSound.source = null;
		parentSound.initialized = false; //Should be false eitherway but just making sure
		parentSound = null;
	}
}
