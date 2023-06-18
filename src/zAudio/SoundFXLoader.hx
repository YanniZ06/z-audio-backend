package zAudio;

import zAudio.filters.*;

/**
 * A simple class that loads all Sound Effects into a sound.
 * 
 * Primarily made so Sound and StreamedSound arent as filled to the brim with the same fields.
 */
class SoundFXLoader {
    //EFFECTS
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
        lowpass = new LowpassFilter(sndParent);
        highpass = new HighpassFilter(sndParent);
        bandpass = new BandpassFilter(sndParent);
    }
}