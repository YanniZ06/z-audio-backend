package zAudio;

import zAudio.filters.*;
import zAudio.fx.*;

/**
 * A simple class that loads all Sound Effects into a sound.
 * 
 * Primarily made so Sound and StreamedSound arent as filled to the brim with the same fields.
 */
class SoundFXLoader {
    //EFFECTS
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

    //FILTERS
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
    private var activeFilter:Dynamic = null;

    public function loadFX(sndParent:Sound) {
        reverb = new ReverbFX(sndParent);
        chorus = new ChorusFX(sndParent);

        lowpass = new LowpassFilter(sndParent);
        highpass = new HighpassFilter(sndParent);
        bandpass = new BandpassFilter(sndParent);
    }

    //Gets rid of all filters and sound effects
    public function destroy() {
        reverb.destroy();
        reverb = null;


        lowpass.destroy();
        lowpass = null;
        highpass.destroy();
        highpass = null;
        bandpass.destroy();
        bandpass = null;
    }
}