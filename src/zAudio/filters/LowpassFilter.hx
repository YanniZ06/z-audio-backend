package zAudio.filters;

import zAudio.FilterBase.ALFilterType;

/**
 * A filter representing a lowpass (or shelf).
 */
class LowpassFilter extends FilterBase {
    /**
     * The overall gain of the source, 1 means its unaffected by the lowpass.
     * 
     * This does practically the same as setting the sounds volume, use `gain_hf` to only filter the lower frequencies.
     * 
     * Must be a number between 0 and 1.
     */
    public var gain(default, set):Float = 1.0;
    /**
     * The gain of higher frequencies on the source specifically, 1 means they're unaffected by the lowpass.
     * 
     * Must be a number between 0 and 1.
     */
    public var gain_hf(default, set):Float = 1.0;

    public function new(sndRef:Sound) {
        super(sndRef, ALFilterType.FILTER_LOWPASS);
    }

    function set_gain(val:Float):Float {
        gain = val;
        AL.filterf(filter, LowpassParam.LOWPASS_GAIN, val);
        if(enabled) reapplyFilter();

        return val;
    }

    function set_gain_hf(val:Float):Float {
        gain_hf = val;
        AL.filterf(filter, LowpassParam.LOWPASS_GAINHF, val);
        if(enabled) reapplyFilter();

        return val;
    }
}

/**
 * Lowpass filter parameters
 */
enum abstract LowpassParam(Int) from Int to Int {
	public static inline var LOWPASS_GAIN:LowpassParam = 0x0001; /*Not exactly a lowpass. Apparently it's a shelf*/
	public static inline var LOWPASS_GAINHF:LowpassParam = 0x0002;
}