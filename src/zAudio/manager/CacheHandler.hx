package zAudio.manager;

/**
 * Class responsible for global sound and buffer cache handling aswell as memory management.
 * 
 * To easily get the path a Sound or Buffer is stored at (for functions that require them), use the sounds' `cacheAddress` field.
 */
class CacheHandler {
    /**
     * Current cache and active sounds mapped to their cache-address (names they were created under).
     * 
     * Sounds are stored in the caches "sounds" array.
     * 
     * Information about existing cached buffer data is defined by "cacheExists".
     * 
     * Information about existing reverse sound data is defined by "hasReverseCache".
     */
    public static var activeSounds:Map<String, zAudio.manager.mem.SoundCache> = [];

    /**
     * All preloaded Buffers mapped to their assigned files, to avoid duplicates.
     * 
     * Holds no other relevant cache info.
     */
    public static var existingBufferData:Map<String, BufferHandle> = [];

    /**
     * A map containing all paths to sounds you want to keep cached after a `clear_bufferCache` call.
     * 
     * Every path in this map needs to be removed manually, so keep that in mind.
     *
     * Simply do `keepCacheSounds.set("yourAsset_orWebPath.wav_or_ogg", true)` to keep a sound safe from general buffer cache clearing.
     * 
     * `removeFromCache` will remove a sound from cache regardless of if its kept in here!
     */
    public static var keepCacheSounds:Map<String, Bool> = [];

    /**
     * Simply clears the entire `existingBufferData` cache, with the exception of all paths in `keepCacheSounds`.
     * 
     * The memory for a cache will be cleared once all sounds using the cache have been destroyed.
     * 
     * This function force-calls the garbage collector and does a major collection.
     */
    public static function clear_bufferCache():Void {
        for(n => buf in existingBufferData) {
            if(keepCacheSounds[n] != null) continue;

            if(activeSounds[n].sounds.length < 1) activeSounds.remove(n);
            else activeSounds[n].cacheExists = false;
            
            existingBufferData.remove(n);
            buf.destroy();
            buf = null;
        }
        cpp.vm.Gc.run(true);
        cpp.vm.Gc.compact();
    }

    /**
     * Removes the sound stored at `path` from the cache, clearing memory once no more sounds referencing the cache exist.
     * 
     * If no sound stored at `path` is found in the cache, this function will throw a Null Object Reference.
     * 
     * If you need to check whether this is the case, use `existsInCache`.
     * 
     * This function does not force-call the garbage collector.
     */
    public static function removeFromCache(path:String):Void {
        var buf = existingBufferData[path];
        if(activeSounds[path] != null) activeSounds[path].cacheExists = false;

        if(keepCacheSounds[path] != null) keepCacheSounds.remove(path);
        existingBufferData.remove(path);
        buf.destroy();
        buf = null;
    }

    /**
     * Removes the sound `snd` and its associated cache from the memory entirely.
     * 
     * If other sounds with the same cache-address still exist, the memory will persist until they are destroyed.
     * Use `destroyAll` to get rid of persisting memory.
     * 
     * This function renders the `snd` unuseable as it is destroyed.
     * 
     * This function also force-calls the garbage collector and does a minor collection.
     * @param snd The snd you want to ensure is removed from memory.
     * @param destroyAll If true, `destroys` all other sounds with the same cache address.
     * Use carefully!
     */
    public static function removeFromMemory(snd:Sound, destroyAll:Bool = false) {
        if(destroyAll) {
            final address = snd.cacheAddress;
            var i = 0;
            for(i in 0...activeSounds[address].sounds.length) {
                trace(i);

                var sound = activeSounds[address].sounds[i];
                if(sound == null) {
                    activeSounds[address].sounds.remove(sound);
                    continue;
                }
                activeSounds[address].sounds[i].destroy();
            }
            activeSounds[address].sounds = [];
            activeSounds.remove(address);
            if(existsInCache(address)) removeFromCache(address); //Address removal also happens here on its own

            cpp.vm.Gc.run(false);
            return;
        }

        if(existsInCache(snd.cacheAddress)) removeFromCache(snd.cacheAddress);
        snd.destroy();
        snd = null;

        cpp.vm.Gc.run(false);
    }

    /**
     * Removes and clears the reverse sound cache from all sounds with the cacheAddress of `path`.
     * 
     * If any sound with the cacheAddress is currently reversed, it will be un-reversed before-hand.
     * 
     * This function force calls the garbage collector and does a minor collection.
     */
    public static function removeReverseCacheFrom(path:String) {
        for(snd in activeSounds[path].sounds) {
            snd.reversed = false;
            snd.buffer.reverseData = null;
        }
        var bufCache = existingBufferData[path];
        if(bufCache != null) bufCache.reverseData = null;

        cpp.vm.Gc.run(false);
    }

    /**
     * Returns true if a buffer to a sound stored at `path` is found in the buffer-cache, otherwise false.
     */
    public static function existsInCache(path:String):Bool return existingBufferData[path] != null;
}