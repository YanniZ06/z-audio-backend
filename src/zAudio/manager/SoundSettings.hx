package zAudio.manager;

/**
 * Class containing global settings for every sound and general settings for 
 * the library such as global volume, optimization options and flow control.
 */
class SoundSettings {
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
     * If true, automatically loads up all effects with information when initialized.
     * 
     * This setting can be disabled to garner more control over memory, allowing you to only seperately load the 
     * effects you need.
     */
    public static var autoLoadFX:Bool = true;

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