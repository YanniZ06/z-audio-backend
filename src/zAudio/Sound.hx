package zAudio;

class Sound {
    /**
     * Handle for the connected ALSource and its various properties
     */
    var source:SourceHandle;
    var buffer:BufferHandle;
    var device:ALDevice;
    var context:ALContext;

    /**
     * Loads in a new Sound object and returns it.
     * TODO: Add parameter for quickloading???
     */
    public function new() {
        source = new SourceHandle(AL.createSource());

        /*device = ALC.openDevice(null);
        context = ALC.createContext(device, null);
        ALC.makeContextCurrent(context);*/

        AL.getError();
        AL.createBuffer();
    }
}