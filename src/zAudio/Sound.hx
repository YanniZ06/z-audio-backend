package zAudio;

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
    var device:ALDevice;
    var context:ALContext;
    var sndInfo:SoundInfo;

    /**
     * Loads in a new Sound object from the input `SoundInfo` and returns it.
     * @param sndInfo The `SoundInfo` object to load into the sound. Create one using one of the `zAudio.SoundLoader` functions.
     */
    public function new(sndInfo:SoundInfo) {
        source = new SourceHandle(AL.createSource());

        /*device = ALC.openDevice(null);
        context = ALC.createContext(device, null);
        ALC.makeContextCurrent(context);*/

        //AL.getError();
        buffer = new BufferHandle(AL.createBuffer());
		AL.bufferData(buffer.handle, sndInfo.format, sndInfo.data, sndInfo.data.length, sndInfo.freq); //g_Buffers[0], format, data, size, freq);
		AL.sourcei(source.handle, AL.BUFFER, buffer.handle);
    }

    public function play() {
        AL.sourcePlay(source.handle);
    }

    public function pause() {
        AL.sourcePause(source.handle);
    }

    public function stop() {
        AL.sourceStop(source.handle);
    }
}