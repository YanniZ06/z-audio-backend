package zAudio.manager;

import zAudio.manager.mem.*;

/**
 * Class responsible for global sound and buffer cache handling aswell as memory management.
 * 
 * To easily get the path a Sound or Buffer is stored at (for functions that require them), use the sounds' `cacheAddress` field.
 */
class CacheHandler {
    /**
     * Storage for all sounds in the cache mapped to their cache-address (names / file paths they were created under).
     * 
     * Sound instances are stored in the caches "sounds" array.
     * 
     * Information about existing buffer data can be found in the "buffer" property.
     * 
     * Information about existing reverse sound data is defined by "hasReverseCache".
     */
    public static var soundCache:Map<String, SoundCache> = [];

    /**
     * A map containing all paths to sounds you want to keep cached after a `markFullCache()` call.
     * 
     * Every path in this map needs to be removed manually (by you), so keep that in mind.
     *
     * Simply do `keepCacheSounds.set("yourAsset_orWebPath.wav_or_ogg", true)` to keep a sound safe from general buffer cache clearing (`markFullCache()`).
     * 
     * `markCacheRemoval()` will remove a sound from cache regardless of if its kept in here!
     */
    public static var keepCacheSounds:Map<String, Bool> = [];

    /**
     * Represents the cache of objects queried for deletion.
     */
    public static var queryCache:QueryCache = new QueryCache();

    /**
     * Simply marks the entire `soundCache` for removal, with the exception of all paths in `keepCacheSounds`.
     * 
     * The memory for a cache will be cleared once all sounds using the cache have been destroyed.
     * 
     * This function will call the garbage collector when the marked caches are ready to be cleared (unless the ZAUDIO_DISALLOW_GC flag is set).
     */
    public static function markFullCache():Void {
        for(n => cache in soundCache) {
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
     * This function will call the garbage collector when the cache is ready to be cleared (unless the ZAUDIO_DISALLOW_GC flag is set).
     * @param path The cacheAddress/path to the sound to mark for removal.
     */
    public static inline function markCacheRemoval(path:String):Void { 
        if(soundCache[path].sounds.length < 1) removeFromCache(path);
        else soundCache[path].markedForRemoval = true;
    }

    /**
     * Unmarks the sound stored at `path` for removal from the cache.
     * 
     * If no sound stored at `path` is found in the cache, this function will throw a Null Object Reference.
     * If you need to check whether this is the case, use `existsInCache`.
     * 
     * This function only makes sense to call for sounds that are marked for removal.
     * @param path The cacheAddress/path to the sound to unmark for removal.
     */
    public static inline function unmarkCacheRemoval(path:String):Void soundCache[path].markedForRemoval = false;

    /**
     * Returns whether the sound stored at `path` is marked for removal from the cache or not.
     * 
     * If no sound stored at `path` is found in the cache, this function will throw a Null Object Reference.
     * If you need to check whether this is the case, use `existsInCache`.
     * @param path The cacheAddress/path to the sound to check.
     */
    public static inline function isCacheMarked(path:String):Bool return soundCache[path].markedForRemoval;

    @:allow(zAudio.Sound)
    static function removeFromCache(path:String):Void {
        var buf = soundCache[path].buffer;
        soundCache.remove(path);

        HaxeAL.deleteBuffer(buf.handle);
        buf.destroy();
        buf = null;

        #if !ZAUDIO_DISALLOW_GC
        cpp.vm.Gc.run(false);
        cpp.vm.Gc.compact();
        #end
    }

    /**
     * Removes all sounds with `path` cache address efficiently, clearing their associated cache from the memory entirely.
     * 
     * If no entry stored at `path` is found in the cache, this function will throw a Null Object Reference.
     * If you need to check whether this is the case, use `existsInCache`.
     * 
     * This function renders all of the sounds unuseable as they are destroyed, so use carefully!
     * 
     * This function also force-calls the garbage collector (unless the ZAUDIO_DISALLOW_GC flag is set).
     * @param path Address to the cache you want to ensure is removed from memory.
     */
    public static function removeFromMemory(path:String) {
        var sounds = soundCache[path].sounds;
        // var cleanManually:Bool = false;

        for(i in 0...sounds.length) {
            var sound = sounds[0];
            sound.queryDestroy();
        }

        queryCache.clearFullQuery(); // Get rid of everything at once
        removeFromCache(path); // Clear cache and call GC
    }

    /**
     * Removes all sounds with a cacheAddress mentioned in the list efficiently, clearing their associated cache from the memory entirely.
     * 
     * If a path in the list has no associated cache-entry, this function will throw a Null Object Reference.
     * If you need to check whether this is the case, use `existsInCache`.
     * 
     * This function renders all of the sounds unuseable as they are destroyed, so use carefully!
     * 
     * This function also force-calls the garbage collector (unless the ZAUDIO_DISALLOW_GC flag is set).
     * @param list Addresses to the caches you want to ensure are removed from memory.
     */
    public static function removeMemoryList(list:Array<String>) {
        for(path in list) {
            var sounds = soundCache[path].sounds;
    
            for(i in 0...sounds.length) {
                var sound = sounds[0];
                sound.queryDestroy();
            }
            var buf = soundCache[path].buffer;
            soundCache.remove(path);
    
            CacheHandler.queryCache.bufferCleanQuery.push(buf.handle);
            buf.destroy();
            buf = null;
        }
        queryCache.clearFullQuery();

        #if !ZAUDIO_DISALLOW_GC
        cpp.vm.Gc.run(false);
        cpp.vm.Gc.compact();
        #end
    }

    /**
     * Removes and clears the reverse sound cache from all sounds with the cacheAddress of `path`.
     * 
     * If no sound stored at `path` is found in the cache, this function will throw a Null Object Reference.
     * If you need to check whether this is the case, use `existsInCache`.
     * 
     * If any sound with the cacheAddress is currently reversed, it will be un-reversed before-hand.
     * 
     * This function force calls the garbage collector (unless the ZAUDIO_DISALLOW_GC flag is set).
     */
    public static function removeReverseCacheFrom(path:String) {
        for(snd in soundCache[path].sounds) { // TODO: overwork this?
            snd.reversed = false;
            snd.buffer.reverseData = null;
        }
        soundCache[path].buffer.reverseData = null;

        #if !ZAUDIO_DISALLOW_GC cpp.vm.Gc.run(false); #end
    }

    /**
     * Returns true if a buffer to a sound stored at `path` is found in the cache, otherwise false.
     *  @param path Address to the cache whichs buffer you want to aquire.
     */
    public static function existsInCache(path:String):Bool return soundCache[path] != null;

    /**
     * Returns the buffer of the cache at cache-address `path`.
     * 
     * If no sound stored at `path` is found in the cache, this function will throw a Null Object Reference.
     * If you need to check whether this is the case, use `existsInCache`.
     * 
     * @param path Address to the cache whichs buffer you want to aquire.
     */
    public static inline function getBuffer(path:String):BufferHandle return soundCache[path].buffer;
}