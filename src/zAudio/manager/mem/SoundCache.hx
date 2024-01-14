package zAudio.manager.mem;

/**
 * Represents an entry in the sound cache.
 * 
 * Used for `CacheHandler.soundCache`.
 */
typedef SoundCache = {
    /**
     * Whether the sound is currently marked for removal or not.
     * If true, once all sounds have been gotten rid of, memory will be available for clearing.
     * 
     * This SoundCache entry will disappear as soon as the condition `markedForRemoval == true && sounds.length == 0` is met (exception: manually queried sounds).
     */
    var markedForRemoval:Bool;
    
    /**
     * Whether the sound currently has reverse audio cached or not.
     */
    var hasReverseCache:Bool;

    /**
     * All sound instances currently loaded in.
     */
    var sounds:Array<Sound>;

    /**
     * The buffer for this cache.
     */
    var buffer:BufferHandle;
}