package zAudio.fx;

import zAudio.EffectBase.ALEffectType;

/**
 * An Effect representing a chorus by playing back delayed doubled versions of the input audio.
 */
@:build(macros.FXPropertyGenMacro.genFxParams())
class ChorusFX extends EffectBase {
	/**
     * Loads in a new chorus effect and attaches it to the `sndRef`.
     * @param sndRef The sound to attach the effect to.
     */
	public function new(sndRef:Sound) {
        super(sndRef, ALEffectType.EFFECT_CHORUS);
    }

    /**
     * Sets the waveform shape of the LFO that controls the delay time of the delayed signals.
     * 
     * Only accepts ChorusWaveform Values.
     */
    @fxParam(0x0001) public var waveform:ChorusWaveform = ChorusWaveform.triangle;

    /**
     * Controls the phase difference between the left and right LFO’s. 
     * At zero degrees the two LFOs are synchronized. Use this parameter to create the illusion of an expanded stereo field of the output signal. 
     * 
     * Accepts values ranging from -180 to 180.
     */
    @fxParam(0x0002) public var phase:Int = 90;

    /**
     * Sets the modulation rate of the LFO that controls the delay time of the delayed signals. 
     * 
     * Accepts values ranging from 0.0 to 10.0.
     */
    @fxParam(0x0003) public var rate:Float = 1.1;

    /**
     * Controls the amount by which the delay time is modulated by the LFO. 
     * 
     * Accepts values ranging from 0.0 to 1.0.
     */
    @fxParam(0x0004) public var depth:Float = 0.1;

    /**
     * Controls the amount of processed signal that is fed back to the input of the chorus effect. 
     * Negative values will reverse the phase of the feedback signal. 
     * 
     * At full magnitude the identical sample will repeat endlessly. At lower magnitudes the sample will repeat and fade out over time. 
     * Use this parameter to create a “cascading” chorus effect.
     * 
     * Accepts values ranging from -1.0 to 1.0.
     */
    @fxParam(0x0005) public var feedback:Float = 0.25;

    /**
     * Controls the average amount of time the sample is delayed before it is played back,
     * and with feedback, the amount of time between iterations of the sample. 
     * 
     * Larger values lower the pitch. Smaller values make the chorus sound like a flanger, but with different frequency characteristics. 
     * 
     * Accepts values ranging from 0.0 to 0.016.
     */
    @fxParam(0x0006) public var delay:Float = 0.016;
}