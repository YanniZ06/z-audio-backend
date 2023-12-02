package zAudio;

typedef SoundCache = {
    var cacheExists:Bool;
    var hasReverseCache:Bool;
    var sounds:Array<Sound>;
}

/**
 * Class responsible for initializing the HaxeAL and ZAudio backends.
 * 
 * Call `preInitialize_AL`, then set your SoundManager options and finally call `initialize_ZAudio` to fully initialize the ZAudio library.
 */
class Initializer {
    /**
     * The currently active device on the HaxeAL backend.
     */
    public static var current_Device:ALDevice = null;
    
    /**
     * The currently active context on the HaxeAL backend.
     */
    public static var current_Context:ALContext = null;

    /**
     * Whether the current application supports the EFX extension or not.
     */
    public static var supports_EFX(default, null):Bool = false;

    /**
     * The max number of effects a singular sound can have at once.
     */
    public static var max_sound_efx(default, null):cpp.Int8 = 0;

    // Pre-defines the standard values for all SoundManager Settings.
    @:noDoc @:noCompletion public static inline var foc_lost_def:Bool = false; //!!!! SET TO TRUE

    /**
     * Sets up the HaxeAL backend.
     * 
     * This function `NEEDS` to be called on Main `BEFORE ANY` other part of the ZAudio backend is modified.
     */
    public static function preInitialize_AL() {
        //! IMPORTANT, OPENAL SOFT DRIVERS MUST BE INSTALLED FOR THIS TO WORK AS IT SHOULD!!!!!!
        final deviceName:String = HaxeALC.getString(null, HaxeALC.DEVICE_SPECIFIER);
		current_Device = HaxeALC.openDevice(deviceName);

        if(current_Device == null) throw 'Failed to initialize HaxeAL-Soft backend!\nNo proper playback device could be created!\n\nAre you sure an audio device is connected?';
        
        // Checks if EFX is available and tries to set highest max efx count for sounds if true
        supports_EFX = HaxeALC.isExtensionPresent(current_Device, 'ALC_EXT_EFX');
        final attributes:Null<Array<Int>> = supports_EFX ? [HaxeEFX.MAX_AUXILIARY_SENDS, 6] : null; 
        current_Context = HaxeALC.createContext(current_Device, attributes);

        if(current_Context == null) throw 'Failed to initialize HaxeAL-Soft backend!\nNo proper context could be created!\n\nTry restarting the application.';

        HaxeALC.makeContextCurrent(current_Context);
        max_sound_efx = supports_EFX ? HaxeALC.getIntegers(current_Device, HaxeEFX.MAX_AUXILIARY_SENDS, 1)[0] : 0; // Finally get the actual highest max efx count
        if(supports_EFX) { 
            HaxeEFX.initEFX();
            trace('EFX Support is on!\nMax Auxiliary Sends per Sound: $max_sound_efx');
        }
    }

    /**
     * Sets up the zAudio backend, should be called on Main `after preInitialize_AL()` has been called
     * and all SoundManager options have been set to your preferred choice.
     */
    public static function initialize_ZAudio() {
        if(current_Device == null) throw 'The HaxeAL-Soft backend needs to be initialized before the ZAudio backend';
        HaxeAL.listenerf(HaxeAL.GAIN, SoundManager.globalVolume);

        //Initialize all settings on startup.
        //We dont trigger the setter twice as these are only triggered if the variable has the same value (which doesnt activate the setter)
        @:privateAccess {
            if(SoundManager.unfocus_Pauses_Snd == foc_lost_def) SoundManager.change_unfocus_Pauses_Snd();
        }
    }
}

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
    public static var activeSounds:Map<String, SoundCache> = [];

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

class SoundManager {
    /**
     * If true, audio playback is paused on every unfocused window.
     * 
     * The playback resumes once the window has been focused.
     * 
     * It is highly recommended this is set to true if the rest of your application also pauses when a window is unfocused
     * to prevent audio desyncing.
     * 
     * 
     * (Only relevant if used outside of a premade game engine integrating ZAudio):
     * 
     * This variable works as soon as `onUnfocus__PauseSnd` has been
     * bound to the application windows' unfocus callback and `onFocus__PauseSnd` has been set to the windows' focus callback.
     */
	public static var unfocus_Pauses_Snd(default, set):Bool = Initializer.foc_lost_def;

    /**
     * Function that is executed to pause sound when the windows focus is lost.
     * 
     * See `unfocus_Pauses_Snd` variable for further reference.
     */
    public static var onUnfocus__PauseSnd(default, null):Void -> Void = () -> {};

    /**
     * Function that is executed to unpause sound when the windows focus is gained.
     * 
     * See `unfocus_Pauses_Snd` variable for further reference.
     */
    public static var onFocus__PauseSnd(default, null):Void -> Void = () -> {};

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

    // -- SETTERS FOR OPTIONS THAT REQUIRE THEM -- //
    static function set_globalVolume(vol:Float):Float {
        globalVolume = vol;
        //for(cache in activeSounds) { for(sound in cache.sounds) sound.volume = sound.volume; } //Activate setter
        HaxeAL.listenerf(HaxeAL.GAIN, globalVolume);
        return vol;
    }
    static function set_unfocus_Pauses_Snd(val:Bool):Bool {
		final changed:Bool = unfocus_Pauses_Snd == val;
		if (!changed) return val;
		unfocus_Pauses_Snd = val;

        change_unfocus_Pauses_Snd();
        return val;
    }

    private static function change_unfocus_Pauses_Snd() {
        if(unfocus_Pauses_Snd) {
            onUnfocus__PauseSnd = () -> HaxeALC.suspendContext(Initializer.current_Context);
            onFocus__PauseSnd = () -> HaxeALC.processContext(Initializer.current_Context);
            return;
        }
        onUnfocus__PauseSnd = () -> {};
        onFocus__PauseSnd = () -> {};
        HaxeALC.processContext(Initializer.current_Context);
        /*@:privateAccess {
            switch(unfocus_Pauses_Snd) {
                case true:
					windowEvents.set("unfocus_Pauses_Snd", true);
                    for (window in Application.current.__windows) {
                        var onUnfocus:Void -> Void = () -> AudioManager.suspend();
                        var onFocus:Void -> Void = () -> AudioManager.resume();

                        window.onFocusOut.add(onUnfocus);
                        window.onFocusIn.add(onFocus);
                    }
                case false:
					if (windowEvents["unfocus_Pauses_Snd"] == null) return;
					windowEvents.remove("unfocus_Pauses_Snd");

                    for (window in Application.current.__windows) {
						window.onFocusOut.remove(() -> AudioManager.suspend());
						window.onFocusIn.remove(() -> AudioManager.resume());
                    }
            }
        }*/
    }
}
