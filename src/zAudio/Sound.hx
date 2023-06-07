package zAudio;

import cpp.Pointer;
import haxe.Timer;
import zAudio.SoundLoader.SoundInfo;

class Sound {

    //Backend
    /**
     * Handle for the connected ALSource and its various properties
     */
    var source:SourceHandle;
    /**
     * Handle for the connected Buffer and its various properties
     */
    var buffer:BufferHandle;
    var sndInfo:SoundInfo;

    //public var playing(default, set):Bool = false;
    public var length(default, null):Int = 0;
	public var id(default, null):Pointer<Sound> = null;

    /**
     * Loads in a new Sound object from the input `SoundInfo` and returns it.
     * @param sndInfo The `SoundInfo` object to load into the sound. Create one using one of the `zAudio.SoundLoader` functions.
     */
    public function new(sndInfo:SoundInfo) {
		id = Pointer.addressOf(this);
        source = new SourceHandle(AL.createSource());

        //AL.getError();
        buffer = new BufferHandle(AL.createBuffer());
		AL.bufferData(buffer.handle, sndInfo.format, sndInfo.data, sndInfo.data.length, sndInfo.freq); //g_Buffers[0], format, data, size, freq);
		AL.sourcei(source.handle, AL.BUFFER, buffer.handle);
    }

    public function play() {
        AL.sourcePlay(source.handle);
    }

    public function isSourcePlaying() {
		return (AL.getSourcei(source.handle, AL.SOURCE_STATE) != AL.STOPPED);
    }

    public function pause() {
        AL.sourcePause(source.handle);
    }

    public function stop() {
        AL.sourceStop(source.handle);
    }

    public function destroy() {
		id = null;
		sndInfo = null;
		buffer = null;
		source = null;
    }
}