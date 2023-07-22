package zAudio.fx;

import zAudio.EffectBase.ALEffectType;

/**
 * The classic reverb effect.
 */
@:build(zAudio.fx.FXPropertyGenMacro.genFxParams())
class ReverbFX extends EffectBase {
	/**
	 * Controls the coloration of the late reverb. Lowering the value adds more coloration to the late reverb.
	 */
	@fxParam(0x0001) public var density:Float = 1.0;

	/**
	 * Controls the echo density in the reverberation decay. 
	 * It’s set by default to 1.0, which provides the highest density.
	 * 
	 * Reducing diffusion gives the reverberation a more “grainy” character that is especially noticeable with percussive sound sources.
	 * 
	 * If you set a diffusion value of 0.0, the later reverberation sounds like a succession of distinct echoes.
	 */
	@fxParam(0x0002) public var diffusion:Float = 1.0;

	/**
	 * The master volume control for the reflected sound (both early reflections and reverberation) that the reverb effect adds to all sound sources. 
	 * It sets the maximum amount of reflections and reverberation added to the final sound mix. 
	 * 
	 * The value of the Gain property ranges from 1.0 (0db) (the maximum amount) to 0.0 (-100db) (no reflected sound at all). 
	 */
	@fxParam(0x0003) public var gain:Float = 0.32;

	/**
	 * Further tweaks reflected sound by attenuating it at high frequencies.
	 * It controls a low-pass filter that applies globally to the reflected sound of all sound sources feeding the particular instance of the reverb effect. 
	 * 
	 * The value of the Gain HF property ranges from 1.0 (0db) (no filter) to 0.0 (-100db) (virtually no reflected sound).
	 */
	@fxParam(0x0004) public var gain_hf:Float = 0.89;

	/**
	 * Sets the reverberation decay time, in seconds.
	 * 
	 * It ranges from 0.1 (typically a small room with very dead surfaces) to 20.0 (typically a large room with very live surfaces). 
	 */
	@fxParam(0x0005) public var decayTime:Float = 1.49;

	/**
	 * The Decay HF Ratio property sets the spectral quality of the Decay Time parameter. 
	 * It is the ratio of high-frequency decay time relative to the time set by Decay Time.
	 * 
	 * The Decay HF Ratio value 1.0 is neutral: the decay time is equal for all frequencies.
	 * As Decay HF Ratio increases above 1.0, the high-frequency decay time increases so it’s longer than the decay time at low frequencies.
	 * You hear a more brilliant reverberation with a longer decay at high frequencies.
	 * 
	 * As 103/144 the Decay HF Ratio value decreases below 1.0, the high-frequency decay time decreases so it’s shorter than the decay time of the low frequencies.
	 * You hear a more natural reverberation.
	 * 
	 * The value ranges from 0.1 to 2.0.
	 */
	@fxParam(0x0006) public var decay_hfRatio:Float = 0.83;


	/**
     * Loads in a new reverb effect and attaches it to the `sndRef`.
     * @param sndRef The sound to attach the effect to.
     */
    public function new(sndRef:Sound) {
        super(sndRef, ALEffectType.EFFECT_REVERB);
    }
}

/**
 * An abstract representing all AL Reverb effect parameters.
 *
 *  ? https://openal-soft.org/misc-downloads/Effects%20Extension%20Guide.pdf [P.66/67 (Param List) | P.101 - 105 (Param Usage)]
 * 
 * ^^ Use for documentation later probably!!
 */
enum abstract ReverbParam(Int) from Int to Int
{
	public static inline var REVERB_DENSITY:ReverbParam = 0x0001;
	public static inline var REVERB_DIFFUSION:ReverbParam = 0x0002;
	public static inline var REVERB_GAIN:ReverbParam = 0x0003;
	public static inline var REVERB_GAINHF:ReverbParam = 0x0004;
	public static inline var REVERB_DECAY_TIME:ReverbParam = 0x0005;
	public static inline var REVERB_DECAY_HFRATIO:ReverbParam = 0x0006;
	public static inline var REVERB_REFLECTIONS_GAIN:ReverbParam = 0x0007;
	public static inline var REVERB_REFLECTIONS_DELAY:ReverbParam = 0x0008;
	public static inline var REVERB_LATE_REVERB_GAIN:ReverbParam = 0x0009;
	public static inline var REVERB_LATE_REVERB_DELAY:ReverbParam = 0x000A;
	public static inline var REVERB_AIR_ABSORPTION_GAINHF:ReverbParam = 0x000B;
	public static inline var REVERB_ROOM_ROLLOFF_FACTOR:ReverbParam = 0x000C;
	public static inline var REVERB_DECAY_HFLIMIT:ReverbParam = 0x000D;
}
