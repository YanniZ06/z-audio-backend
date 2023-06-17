package zAudio.filters;

import zAudio.FilterBase.ALFilterType;

class HighpassFilter extends FilterBase {
    /**
     * The overall gain of the source, 1 means its unaffected by the highpass.
     * 
     * This does practically the same as setting the sounds volume, use `gain_lf` to only filter the lower frequencies.
     * 
     * Must be a number between 0 and 1.
     */
    public var gain(default, set):Float = 1.0;
    /**
     * The gain of lower frequencies on the source specifically, 1 means they're unaffected by the highpass.
     * 
     * Must be a number between 0 and 1.
     */
    public var gain_lf(default, set):Float = 1.0;

    public function new(sndRef:Sound) {
        super(sndRef, ALFilterType.FILTER_HIGHPASS);
    }

    function set_gain(val:Float):Float {
        gain = val;
        AL.filterf(filter, HighpassParam.HIGHPASS_GAIN, val);
        if(enabled) reapplyFilter();

        return val;
    }

    function set_gain_lf(val:Float):Float {
        gain_lf = val;
        AL.filterf(filter, HighpassParam.HIGHPASS_GAINLF, val);
        if(enabled) reapplyFilter();

        return val;
    }
}

/**
 * Highpass filter parameters
 */
enum abstract HighpassParam(Int) from Int to Int {
	public static inline var HIGHPASS_GAIN:HighpassParam = 0x0001;
	public static inline var HIGHPASS_GAINLF:HighpassParam = 0x0002;
}