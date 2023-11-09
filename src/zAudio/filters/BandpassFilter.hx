package zAudio.filters;

import zAudio.FilterBase.ALFilterType;

/**
 * A filter representing a bandpass.
 * 
 * Basically a combination of Lowpass and Highpass.
 * 
 * Lower values strengthen the bandpass filter.
 */
class BandpassFilter extends FilterBase {
    /**
     * The overall gain of the source, 1 means its unaffected by the bandpass.
     * 
     * This does practically the same as setting the sounds volume, use `gain_lf` or `gain_hf` to only filter specific frequencies.
     * 
     * Must be a number between 0 and 1.
     */
    public var gain(default, set):Float = 1.0;
    /**
     * The gain of lower frequencies on the source specifically, 1 means they're unaffected by the bandpass.
     * 
     * Must be a number between 0 and 1.
     */
    public var gain_lf(default, set):Float = 1.0;
    /**
     * The gain of higher frequencies on the source specifically, 1 means they're unaffected by the bandpass.
     * 
     * Must be a number between 0 and 1.
     */
    public var gain_hf(default, set):Float = 1.0;

    /**
     * Loads in a new bandpass filter and attaches it to the `sndRef`.
     * @param sndRef The sound to attach the filter to.
     */
    public function new(sndRef:Sound) {
        super(sndRef, ALFilterType.FILTER_BANDPASS);
    }

    function set_gain(val:Float):Float {
        gain = val;
        HaxeEFX.filterf(filter, BandpassParam.BANDPASS_GAIN, val);
        if(enabled) reapplyFilter();

        return val;
    }

    function set_gain_lf(val:Float):Float {
        gain_lf = val;
        HaxeEFX.filterf(filter, BandpassParam.BANDPASS_GAINLF, val);
        if(enabled) reapplyFilter();

        return val;
    }

    function set_gain_hf(val:Float):Float {
        gain_hf = val;
        HaxeEFX.filterf(filter, BandpassParam.BANDPASS_GAINHF, val);
        if(enabled) reapplyFilter();

        return val;
    }
}

/**
 * Bandpass Filter params
 */
enum abstract BandpassParam(Int) from Int to Int {
	public static inline var BANDPASS_GAIN:BandpassParam = 0x0001;
	public static inline var BANDPASS_GAINLF:BandpassParam = 0x0002;
	public static inline var BANDPASS_GAINHF:BandpassParam = 0x0003;
}