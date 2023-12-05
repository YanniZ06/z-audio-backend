package zAudio.manager;

/**
 * Class responsible for initializing the HaxeAL and ZAudio backends.
 * 
 * Call `preInitialize_AL`, then set your SoundSettings options and finally call `initialize_ZAudio` to fully initialize the ZAudio library.
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

    // Pre-defines the standard values for all SoundSettings Settings.
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
     * and all SoundSettings options have been set to your preferred choice.
     */
    public static function initialize_ZAudio() {
        if(current_Device == null) throw 'The HaxeAL-Soft backend needs to be initialized before the ZAudio backend';
        HaxeAL.listenerf(HaxeAL.GAIN, SoundSettings.globalVolume);

        //Initialize all settings on startup.
        //We dont trigger the setter twice as these are only triggered if the variable has the same value (which doesnt activate the setter)
        @:privateAccess {
            if(SoundSettings.unfocus_Pauses_Snd == foc_lost_def) SoundSettings.change_unfocus_Pauses_Snd();
        }
    }
}