package zAudio;

import lime.app.Application;
import lime.ui.Window;
import lime.media.AudioManager;
import lime._internal.backend.native.NativeApplication;

typedef SoundCache = {
    var cacheExists:Bool;
    var hasReverseCache:Bool;
    var sounds:Array<Sound>;
}
/**
 * Class responsible for global sound handling and memory management.
 * 
 * To easily get the path a Sound or Buffer is stored at (for functions that require them), use the sounds' `cacheAddress` field.
 */
class SoundHandler {
    /**
     * Current cache and active sounds mapped to their cache-address (names they were created under).
     * 
     * Sounds are stored in the caches "sounds" array.
     * 
     * Information about existing cached buffer data is defined by "cacheExists".
     * 
     * Information about existing reverse sound data is defined by "hasReverseCache".
     */
    public static var activeSounds:Map<String, SoundCache> = [];
    /**
     * All preloaded Buffers mapped to their assigned files, to avoid duplicates.
     * 
     * Holds no other relevant cache info.
     */
    public static var existingBufferData:Map<String, BufferHandle> = [];
    /**
     * If true, audio playback is paused on every unfocused window (or just the main window if you only have one).
     * 
     * The playback resumes once the window has been focused.
     * 
     * It is highly recommended this is set to true if the rest of your application also pauses when a window is unfocused
     * to prevent audio desyncing.
     */
    private static inline var foc_lost_def:Bool = false; //!!!!!! SET TO TRUE
	public static var focusLost_pauseSnd(default, set):Bool = foc_lost_def;

    /**
     * If true, reverse audio data is preloaded whenever a new sound is loaded in.
     * Keeping this option on increases first-time audio load times, and doubles the memory each sound uses.
     */
    public static var preloadReverseSounds:Bool = false;

    /**
     * A volume modifier that gets applied to all sounds.
     * 
     * Useful for setting master audio volume in your game!
     */
    public static var globalVolume(default, set):Float = 1;

    private static var windowEvents:Map<String, Bool> = [];

    /**
     * Sets up the zAudio backend, should be called on Main `before` starting your game
	 * and `after` all SoundHandler options have been set to your preferred choice.
     */
    public static function init() {

        //Initialize all settings on startup.
        //We dont trigger the setter twice as these are only triggered if the variable has the same value (which doesnt activate the setter)
		if(focusLost_pauseSnd == foc_lost_def) change_focusLost_pauseSnd();
    }

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
        if(activeSounds[path].sounds.length < 1) activeSounds.remove(path);
        else activeSounds[path].cacheExists = false;

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
            for(snd__ in activeSounds[address].sounds) {
                snd__.destroy();
                snd__ = null;
            }
            activeSounds.remove(address);
            if(existsInCache(address)) removeFromCache(address);

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


    // -- SETTERS FOR OPTIONS THAT REQUIRE THEM --
    static function set_globalVolume(vol:Float):Float {
        globalVolume = vol;
        for(cache in activeSounds) { for(sound in cache.sounds) sound.volume = sound.volume; } //Activate setter
        return vol;
    }
    static function set_focusLost_pauseSnd(val:Bool):Bool {
		final changed:Bool = focusLost_pauseSnd == val;
		if (!changed) return val;
		focusLost_pauseSnd = val;

        change_focusLost_pauseSnd();
        return val;
    }
    private static function change_focusLost_pauseSnd() {
        @:privateAccess {
            switch(focusLost_pauseSnd) {
                case true:
					windowEvents.set("focusLost_pauseSnd", true);
                    for (window in Application.current.__windows) {
                        var onUnfocus:Void -> Void = () -> AudioManager.suspend();
                        var onFocus:Void -> Void = () -> AudioManager.resume();

                        window.onFocusOut.add(onUnfocus);
                        window.onFocusIn.add(onFocus);
                    }
                case false:
					if (windowEvents["focusLost_pauseSnd"] == null) return;
					windowEvents.remove("focusLost_pauseSnd");

                    for (window in Application.current.__windows) {
						window.onFocusOut.remove(() -> AudioManager.suspend());
						window.onFocusIn.remove(() -> AudioManager.resume());
                    }
            }
        }
    }
}