package zAudio.fx;

import zAudio.EffectBase.ALEffectType;

/**
 * An Effect representing a standard reverb.
 */
@:build(macros.FXPropertyGenMacro.genFxParams())
class ReverbFX extends EffectBase {
	/**
     * Loads in a new reverb effect and attaches it to the `sndRef`.
     * @param sndRef The sound to attach the effect to.
     */
	public function new(sndRef:Sound) {
        super(sndRef, ALEffectType.EFFECT_REVERB);
    }

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
	 * Sets the spectral quality of the Decay Time parameter. 
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
	 * Controls the overall amount of initial reflections relative to the Gain property. 
	 * (The Gain property sets the overall amount of reflected sound: both initial reflections
	 * and later reverberation.) 
	 * 
	 * The value of Reflections Gain ranges from a maximum of 3.16 (+10 dB)
	 * to a minimum of 0.0 (-100 dB) (no initial reflections at all), and is corrected by the value of the
	 * Gain property. 
	 * 
	 * The Reflections Gain property does not affect the subsequent reverberation decay. 
	 */
	@fxParam(0x0007) public var reflections_gain:Float = 0.05;

	/**
	 * The amount of delay between the arrival time of the direct path
	 * from the source to the first reflection from the source. 
	 * 
	 * It ranges from 0 to 300 milliseconds (0.0 -> 0.3). 
	 * 
	 * You can reduce or increase Reflections Delay to simulate closer or more distant reflective surfaces—
	 * and therefore control the perceived size of the room.
	 */
	@fxParam(0x0008) public var reflections_delay:Float = 0.007;

	/**
	 * Controls the overall amount of later reverberation relative to the Gain property. 
	 * (The Gain property sets the overall amount of both initial reflections and later reverberation.) 
	 * 
	 * The value of Late Reverb Gain ranges from a maximum of 10.0 (+20 dB) to a minimum of 0.0 (-100 dB) (no late reverberation at all).
	 */
	@fxParam(0x0009) public var late_gain:Float = 1.26;

	/**
	 * Defines the begin time of the late reverberation relative to the time of the initial reflection (the first of the early reflections). 
	 * 
	 * It ranges from 0 to 100 milliseconds (0.0 -> 0.1).
	 * 
	 * Reducing or increasing Late Reverb Delay is useful for simulating a smaller or larger room. 
	 */
	@fxParam(0x000A) public var late_delay:Float = 0.011 ;

	/**
	 * Controls the distance-dependent attenuation at high
	 * frequencies caused by the propagation medium. It applies to reflected sound only. 
	 * 
	 * You can use
	 * Air Absorption Gain HF to simulate sound transmission through foggy air, dry air, smoky
	 * atmosphere, and so on. 
	 * 
	 * The default value is 0.994 (-0.05 dB) per meter, which roughly
	 * corresponds to typical condition of atmospheric humidity, temperature, and so on. 
	 * 
	 * Lowering the
	 * value simulates a more absorbent medium (more humidity in the air, for example); raising the
	 * value simulates a less absorbent medium (dry desert air, for example). 
	 */
	@fxParam(0x000B) public var air_absorb_gainHf:Float = 0;

	/**
	 * One of two methods available to attenuate the reflected
	 * sound (containing both reflections and reverberation) according to source-listener distance. It’s
	 * defined the same way as OpenAL’s Rolloff Factor, but operates on reverb sound instead of
	 * direct-path sound. Setting the Room Rolloff Factor value to 1.0 specifies that the reflected sound
	 * will decay by 6 dB every time the distance doubles. Any value other than 1.0 is equivalent to a
	 * scaling factor applied to the quantity specified by ((Source listener distance) - (Reference
	 * Distance)). 
	 * 
	 * Reference Distance is an OpenAL source parameter that specifies the inner border
	 * for distance rolloff effects: if the source comes closer to the listener than the reference distance,
	 * the direct-path sound isn’t increased as the source comes closer to the listener, and neither is the
	 * reflected sound.
	 * 
	 * The default value of Room Rolloff Factor is 0.0 because, by default, the Effects Extension reverb
	 * effect naturally manages the reflected sound level automatically for each sound source to
	 * simulate the natural rolloff of reflected sound vs. distance in typical rooms (Note that this isn’t
	 * the case if the source property flag AL_AUXILIARY_SEND_FILTER_GAIN_AUTO is set to
	 * AL_FALSE).
	 * 
	 * You can use Room Rolloff Factor as an option to automatic control so you can
	 * exaggerate or replace the default automatically-controlled rolloff. 
	 */
	@fxParam(0x000C) public var room_rolloff:Float = 0;

	/**
	 * When this flag is set, the high-frequency decay time automatically stays below a limit value that’s
	 * derived from the setting of the property Air Absorption HF. This limit applies regardless of the
	 * setting of the property Decay HF Ratio, and the limit doesn’t affect the value of Decay HF Ratio.
	 * 
	 * This limit, when on, maintains a natural sounding reverberation decay by allowing you to increase
	 * the value of Decay Time without the risk of getting an unnaturally long decay time at high
	 * frequencies. If this flag is set to false, high-frequency decay time isn’t automatically limited. 
	 */
	public var decay_hfLimit(default, set):Bool = true;

	// This is faster than chaining two calls using the fxParam annotation here
	private function set_decay_hfLimit(inBool:Bool):Bool {
		decay_hfLimit = inBool;
		changeParam_Int(0x000D, inBool ? 1 : 0);
		return inBool;
	}
}

/**
 *  ? https://openal-soft.org/misc-downloads/Effects%20Extension%20Guide.pdf [P.66/67 (Param List) | P.101 - 105 (Param Usage)]
 * ^^ Use for documentation later probably!!
 */
