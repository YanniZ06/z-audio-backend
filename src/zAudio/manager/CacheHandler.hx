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
     * Information about existing cached buffer data is defined by "markedForRemoval".
     * 
     * Information about existing reverse sound data is defined by "hasReverseCache".
     */
    public static var activeSounds:Map<String, zAudio.manager.mem.SoundCache> = [];

    /**
     * All preloaded Buffers mapped to their assigned files, to avoid duplicates.
     * 
     * Holds no other relevant cache info.
     */
    public static var cachedBuffers:Map<String, BufferHandle> = [];

    /**
     * A map containing all paths to sounds you want to keep cached after a `clearBufferCache()` call.
     * 
     * Every path in this map needs to be removed manually, so keep that in mind.
     *
     * Simply do `keepCacheSounds.set("yourAsset_orWebPath.wav_or_ogg", true)` to keep a sound safe from general buffer cache clearing.
     * 
     * `markCacheRemoval()` will remove a sound from cache regardless of if its kept in here!
     */
    public static var keepCacheSounds:Map<String, Bool> = [];

    /**
     * Simply marks the entire `cachedBuffers` cache for removal, with the exception of all paths in `keepCacheSounds`.
     * 
     * The memory for a cache will be cleared once all sounds using the cache have been destroyed.
     * 
     * This function will call the garbage collector when the marked caches are ready to be cleared.
     */
    public static function markFullCache():Void {
        for(n => buf in cachedBuffers) {
            if(keepCacheSounds[n] != null) continue;
            markCacheRemoval(n);
        }
    }

    /**
     * Marks the sound stored at `path` for removal from the cache, clearing memory once no more sounds referencing the cache exist.
     * 
     * If no sound stored at `path` is found in the cache, this function will throw a Null Object Reference.
     * If you need to check whether this is the case, use `existsInCache`.
     * 
     * This function will call the garbage collector when the cache is ready to be cleared.
     * @param path The cacheAddress/path to the sound to mark for removal.
     */
    public static inline function markCacheRemoval(path:String):Void { 
        if(activeSounds[path].sounds.length < 1) removeFromCache(path);
        else activeSounds[path].markedForRemoval = true;
    }

    /**
     * Unmarks the sound stored at `path` for removal from the cache.
     * 
     * If no sound stored at `path` is found in the cache, this function will throw a Null Object Reference.
     * If you need to check whether this is the case, use `existsInCache`.
     * 
     * This function only makes sense to call for sounds that are marked for removal.
     * @param path The cacheAddress/path to the sound to mark for removal.
     */
    public static inline function unmarkCacheRemoval(path:String):Void activeSounds[path].markedForRemoval = false;

    /**
     * Returns whether the sound stored at `path` is marked for removal from the cache or not.
     * 
     * If no sound stored at `path` is found in the cache, this function will throw a Null Object Reference.
     * If you need to check whether this is the case, use `existsInCache`.
     * @param path 
     * @return Void return activeSounds[path].markedForRemoval
     */
    public static inline function isCacheMarked(path:String):Void return activeSounds[path].markedForRemoval;

    @:allow(zAudio.Sound)
    static function removeFromCache(path:String):Void {
        var buf = cachedBuffers[path];
        activeSounds.remove(path);

        cachedBuffers.remove(path);
        buf.destroy();
        buf = null;

        cpp.vm.Gc.run(false);
        cpp.vm.Gc.compact();
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
            markCacheRemoval(address);
            for(i in 0...activeSounds[address].sounds.length) {
                trace(i);

                var sound = activeSounds[address].sounds[i];
                if(sound == null) {
                    activeSounds[address].sounds.remove(sound);
                    continue;
                }
                activeSounds[address].sounds[i].destroy();
            }

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
        cachedBuffers[path].reverseData = null;

        cpp.vm.Gc.run(false);
    }

    /**
     * Returns true if a buffer to a sound stored at `path` is found in the cache, otherwise false.
     */
    public static function existsInCache(path:String):Bool return cachedBuffers[path] != null;
}