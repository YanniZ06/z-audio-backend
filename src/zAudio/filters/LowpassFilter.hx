package zAudio.filters;

import zAudio.FilterBase.ALFilterType;

class LowpassFilter extends FilterBase {
    /**
     * The overall gain of the lowpass filter.
     * 
     * Must be a number between 0 and 1.
     */
    public var gain(default, set):Float = 1.0;
    /**
     * The gain of the lowpass filter on lower frequencies specifically.
     * 
     * Must be a number between 0 and 1.
     */
    public var gain_lf(default, set):Float = 1.0;

    public function new(sndRef:Sound) {
        super(sndRef, ALFilterType.FILTER_LOWPASS);
    }

    function set_gain(val:Float):Float {
        gain = val;
        AL.filterf(filter, LowpassParams.LOWPASS_GAIN, val);
        return val;
    }

    function set_gain_lf(val:Float):Float {
        gain_lf = val;
        AL.filterf(filter, LowpassParams.LOWPASS_GAINHF, val);
        return val;
    }
}

/**
 * Lowpass filter parameters
 */
enum abstract LowpassParams(Int) from Int to Int {
	public static inline var LOWPASS_GAIN:LowpassParams = 0x0001; /*Not exactly a lowpass. Apparently it's a shelf*/
	public static inline var LOWPASS_GAINHF:LowpassParams = 0x0002;
}