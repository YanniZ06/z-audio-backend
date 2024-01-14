package zAudio;

import zAudio.efx.*;
import zAudio.efx.fx.*;
import zAudio.efx.filters.*;

/**
 * A simple class that loads all Sound Effects into a sound.
 * 
 * Primarily made so Sound and StreamedSound arent as filled to the brim with the same fields.
 */
class Sound_FxBackend {
    // EFFECTS //
    /**
     * The reverb on this sound.
     * 
     * Check `ReverbFX` for more precise documentation
     */
    public var reverb:ReverbFX;
    /**
     * The chorus on this sound.
     * 
     * Check `ChorusFX` for more precise documentation
     */
    public var chorus:ChorusFX;

    // FILTERS //
    /**
     * The lowpass on this sound.
     * 
     * Check `LowpassFilter` for more precise documentation
     */
    public var lowpass:LowpassFilter;
    /**
     * The highpass on this sound.
     * 
     * Check `HighpassFilter` for more precise documentation
     */
    public var highpass:HighpassFilter;
    /**
     * A bandpass filter, practically a combination of `highpass` and `lowpass`.
     * 
     * Check `BandpassFilter` for more precise documentation
     */
    public var bandpass:BandpassFilter;

    /**
     * All effects that are currently loaded onto this sound.
     * 
     * (Does not include attached but unloaded sounds!)
     */
    public var loadedEffects:Array<EffectBase> = [];

    /**
     * All effects that are currently loaded onto this sound AND enabled.
     * 
     * First from the list is always thrown out when max storage is reached.
     */
    public var enabledEffects:Array<EffectBase> = [];

    /**
     * Whether all effects and filters have been initialized or not.
     */
    public var efx_init(default, null):Bool = false;

    private var activeFilter:Dynamic = null; // Since sounds can only have one filter at a time we need to keep track of the current one

    /**
     * Initializes all existing effects and filters but doesn't fill them with information yet (unless `SoundSettings.autoLoadFX` is true).
     * @param sndParent `This` sound parent to attach the effects and filters to.
     */
    public function init_EFX(sndParent:Sound) {
        if(!Initializer.supports_EFX) return; // Can be done since by default we load EFX so now we can just prevent this whole blunder

        reverb = new ReverbFX(sndParent);
        chorus = new ChorusFX(sndParent);

        lowpass = new LowpassFilter(sndParent);
        highpass = new HighpassFilter(sndParent);
        bandpass = new BandpassFilter(sndParent);

        efx_init = true;
    }

    //Gets rid of all filters and sound effects

    /**
     * Cleans up all effects and filters completely.
     * 
     * Only gets called on sounds when efx_init is true
     */
    public function cleanup_EFX() {
        reverb.queryDestroy();
        reverb = null;
        chorus.queryDestroy();
        chorus = null;

        lowpass.queryDestroy();
        lowpass = null;
        highpass.queryDestroy();
        highpass = null;
        bandpass.queryDestroy();
        bandpass = null;
    }
}