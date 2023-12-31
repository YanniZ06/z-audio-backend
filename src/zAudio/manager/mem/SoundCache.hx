package zAudio.manager.mem;

typedef SoundCache = {
    /**
     * Whether the sound is currently in cache or not.
     * If false, once all sounds have been gotten rid of, memory will be available for clearing.
     * 
     * This SoundCache entry will also disappear as soon as the condition `cacheExists == false && sounds.length == 0` is met.
     */
    var cacheExists:Bool;
    
    /**
     * Whether the sound currently has reverse audio cached or not.
     */
    var hasReverseCache:Bool;

    /**
     * All Sound instances currently loaded in.
     */
    var sounds:Array<Sound>;
}