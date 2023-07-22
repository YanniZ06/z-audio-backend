package zAudio;

import zAudio.fx.ReverbFX;

/**
 * The base for all sound effect modifiers.
 */
class EffectBase extends FXBase {	
	/**
	 * Controls whether this Effect should be enabled right now or not.
	 */
	public var enabled(default, set):Bool;

	public var mix(get, set):Float;

	private var effect:ALEffect = null;
	private var aux:AuxSlotHandle = null;

	/**
     * Loads in an ALFilter of type `type` and attaches it to the `sndRef`.
     * @param sndRef The sound to attach the filter to.
	 * @param type The type of ALFilter you want to attach to the sound.
     */
	private function new(sndRef:Sound, type:ALEffectType) {
		super(sndRef);
		effect = makeEffect(type);
		aux = new AuxSlotHandle(effect, type);
	}

	override public function destroy() {
		//if(aux.appliedSrc != null) aux.removeFromSrc();
		super.destroy();

		aux.destroy();
		aux = null;
		if(effect != null) deleteEffect(effect);
		effect = null;
	}

	public static function makeEffect(type:ALEffectType):ALEffect {
		var fx = AL.createEffect();
		AL.effecti(fx, ALEffectTypeParam.EFFECT_TYPE, type);
		
		return fx;
	}

	/**
	 * Deletes the ALEffect `effect`.
	 * @param effect The effect to delete.
	 */
	public static function deleteEffect(effect:ALEffect) {
		#if (lime_cffi && lime_openal && !macro)
		LimeAudioCFFI.lime_al_delete_effect(effect);
		#end
	}

	function changeParam(param:Dynamic, value:Float) {
		trace(AL.getErrorString());
		AL.effectf(effect, 0x0003, value); //why do you suddenly refuse to work??
		AL.effectf(effect, 0x0003, 0);
		AL.effectf(effect, 0x0005, 19);
		if(enabled) reapplyEffect();
		trace(AL.getErrorString());
		trace(effect);
		trace(param);
		trace(value);
	}

	function set_enabled(val:Bool):Bool {
		final oldE = enabled;
		enabled = val;
		if(oldE == enabled) return val;

		if(enabled) reapplyEffect();
		else aux.removeFromSrc();

		return val;
	}

	function reapplyEffect():Void { aux.applyTo(sourceRef); trace("reapplied!"); }

	function get_mix():Float return aux.volume;
	function set_mix(val:Float):Float { aux.volume = val; return val; }
}

/**
 * An abstract representing all the AL effect type params.
*/
enum abstract ALEffectTypeParam(Int) from Int to Int {
	public static inline var EFFECT_FIRST_PARAMETER:ALEffectTypeParam = 0x0000;
	public static inline var EFFECT_LAST_PARAMETER:ALEffectTypeParam = 0x8000;
	public static inline var EFFECT_TYPE:ALEffectTypeParam = 0x8001;
}

/**
 * An abstract representing all the AL effect types to choose from.
*/
enum abstract ALEffectType(Int) from Int to Int {
	/* Effect types, used with the AL_EFFECT_TYPE property */
	public static inline var EFFECT_NULL:ALEffectType = 0x0000;
	public static inline var EFFECT_EAXREVERB:ALEffectType = 0x8000;
	public static inline var EFFECT_REVERB:ALEffectType = 0x0001;
	public static inline var EFFECT_CHORUS:ALEffectType = 0x0002;
	public static inline var EFFECT_DISTORTION:ALEffectType = 0x0003;
	public static inline var EFFECT_ECHO:ALEffectType = 0x0004;
	public static inline var EFFECT_FLANGER:ALEffectType = 0x0005;
	public static inline var EFFECT_FREQUENCY_SHIFTER:ALEffectType = 0x0006;
	public static inline var EFFECT_VOCAL_MORPHER:ALEffectType = 0x0007;
	public static inline var EFFECT_PITCH_SHIFTER:ALEffectType = 0x0008;
	public static inline var EFFECT_RING_MODULATOR:ALEffectType = 0x0009;
	public static inline var EFFECT_AUTOWAH:ALEffectType = 0x000A;
	public static inline var EFFECT_COMPRESSOR:ALEffectType = 0x000B;
	public static inline var EFFECT_EQUALIZER:ALEffectType = 0x000C;
}

/**
 * Strictly assigned Aux Slots for each Effect
 */
enum abstract AssignedAuxSlot_Effect(Int) from Int to Int {
	public static inline var EFFECT_EAXREVERB:AssignedAuxSlot_Effect = 0;
	public static inline var EFFECT_REVERB:AssignedAuxSlot_Effect = 1;
	public static inline var EFFECT_CHORUS:AssignedAuxSlot_Effect = 2;
	public static inline var EFFECT_DISTORTION:AssignedAuxSlot_Effect = 3;
	public static inline var EFFECT_ECHO:AssignedAuxSlot_Effect = 4;
	public static inline var EFFECT_FLANGER:AssignedAuxSlot_Effect = 5;
	public static inline var EFFECT_FREQUENCY_SHIFTER:AssignedAuxSlot_Effect = 6;
	public static inline var EFFECT_VOCAL_MORPHER:AssignedAuxSlot_Effect = 7;
	public static inline var EFFECT_PITCH_SHIFTER:AssignedAuxSlot_Effect = 8;
	public static inline var EFFECT_RING_MODULATOR:AssignedAuxSlot_Effect = 9;
	public static inline var EFFECT_AUTOWAH:AssignedAuxSlot_Effect = 10;
	public static inline var EFFECT_COMPRESSOR:AssignedAuxSlot_Effect = 11;
	public static inline var EFFECT_EQUALIZER:AssignedAuxSlot_Effect = 12;
}

/**
 * An abstract representing all the AL effect parameters, primarily for easy autocompletion.
 * TODO: Put them all into seperate enums in their respective classes.
 */
 enum abstract ALEffectParam(Int) from Int to Int {
	/* EAX Reverb effect parameters */ // Windows only... ? (Possibly not integrating these in favor of regualr reverb)
	public static inline var EAXREVERB_DENSITY:ALEffectParam = 0x0001;
	public static inline var EAXREVERB_DIFFUSION:ALEffectParam = 0x0002;
	public static inline var EAXREVERB_GAIN:ALEffectParam = 0x0003;
	public static inline var EAXREVERB_GAINHF:ALEffectParam = 0x0004;
	public static inline var EAXREVERB_GAINLF:ALEffectParam = 0x0005;
	public static inline var EAXREVERB_DECAY_TIME:ALEffectParam = 0x0006;
	public static inline var EAXREVERB_DECAY_HFRATIO:ALEffectParam = 0x0007;
	public static inline var EAXREVERB_DECAY_LFRATIO:ALEffectParam = 0x0008;
	public static inline var EAXREVERB_REFLECTIONS_GAIN:ALEffectParam = 0x0009;
	public static inline var EAXREVERB_REFLECTIONS_DELAY:ALEffectParam = 0x000A;
	public static inline var EAXREVERB_REFLECTIONS_PAN:ALEffectParam = 0x000B;
	public static inline var EAXREVERB_LATE_REVERB_GAIN:ALEffectParam = 0x000C;
	public static inline var EAXREVERB_LATE_REVERB_DELAY:ALEffectParam = 0x000D;
	public static inline var EAXREVERB_LATE_REVERB_PAN:ALEffectParam = 0x000E;
	public static inline var EAXREVERB_ECHO_TIME:ALEffectParam = 0x000F;
	public static inline var EAXREVERB_ECHO_DEPTH:ALEffectParam = 0x0010;
	public static inline var EAXREVERB_MODULATION_TIME:ALEffectParam = 0x0011;
	public static inline var EAXREVERB_MODULATION_DEPTH:ALEffectParam = 0x0012;
	public static inline var EAXREVERB_AIR_ABSORPTION_GAINHF:ALEffectParam = 0x0013;
	public static inline var EAXREVERB_HFREFERENCE:ALEffectParam = 0x0014;
	public static inline var EAXREVERB_LFREFERENCE:ALEffectParam = 0x0015;
	public static inline var EAXREVERB_ROOM_ROLLOFF_FACTOR:ALEffectParam = 0x0016;
	public static inline var EAXREVERB_DECAY_HFLIMIT:ALEffectParam = 0x0017;
	/* Chorus effect parameters */
	public static inline var CHORUS_WAVEFORM:ALEffectParam = 0x0001;
	public static inline var CHORUS_PHASE:ALEffectParam = 0x0002;
	public static inline var CHORUS_RATE:ALEffectParam = 0x0003;
	public static inline var CHORUS_DEPTH:ALEffectParam = 0x0004;
	public static inline var CHORUS_FEEDBACK:ALEffectParam = 0x0005;
	public static inline var CHORUS_DELAY:ALEffectParam = 0x0006;
	/* Distortion effect parameters */
	public static inline var DISTORTION_EDGE:ALEffectParam = 0x0001;
	public static inline var DISTORTION_GAIN:ALEffectParam = 0x0002;
	public static inline var DISTORTION_LOWPASS_CUTOFF:ALEffectParam = 0x0003;
	public static inline var DISTORTION_EQCENTER:ALEffectParam = 0x0004;
	public static inline var DISTORTION_EQBANDWIDTH:ALEffectParam = 0x0005;
	/* Echo effect parameters */
	public static inline var ECHO_DELAY:ALEffectParam = 0x0001;
	public static inline var ECHO_LRDELAY:ALEffectParam = 0x0002;
	public static inline var ECHO_DAMPING:ALEffectParam = 0x0003;
	public static inline var ECHO_FEEDBACK:ALEffectParam = 0x0004;
	public static inline var ECHO_SPREAD:ALEffectParam = 0x0005;
	/* Flanger effect parameters */
	public static inline var FLANGER_WAVEFORM:ALEffectParam = 0x0001;
	public static inline var FLANGER_PHASE:ALEffectParam = 0x0002;
	public static inline var FLANGER_RATE:ALEffectParam = 0x0003;
	public static inline var FLANGER_DEPTH:ALEffectParam = 0x0004;
	public static inline var FLANGER_FEEDBACK:ALEffectParam = 0x0005;
	public static inline var FLANGER_DELAY:ALEffectParam = 0x0006;
	/* Frequency shifter effect parameters */
	public static inline var FREQUENCY_SHIFTER_FREQUENCY:ALEffectParam = 0x0001;
	public static inline var FREQUENCY_SHIFTER_LEFT_DIRECTION:ALEffectParam = 0x0002;
	public static inline var FREQUENCY_SHIFTER_RIGHT_DIRECTION:ALEffectParam = 0x0003;
	/* Vocal morpher effect parameters */
	public static inline var VOCAL_MORPHER_PHONEMEA:ALEffectParam = 0x0001;
	public static inline var VOCAL_MORPHER_PHONEMEA_COARSE_TUNING:ALEffectParam = 0x0002;
	public static inline var VOCAL_MORPHER_PHONEMEB:ALEffectParam = 0x0003;
	public static inline var VOCAL_MORPHER_PHONEMEB_COARSE_TUNING:ALEffectParam = 0x0004;
	public static inline var VOCAL_MORPHER_WAVEFORM:ALEffectParam = 0x0005;
	public static inline var VOCAL_MORPHER_RATE:ALEffectParam = 0x0006;
	/* Pitchshifter effect parameters */
	public static inline var PITCH_SHIFTER_COARSE_TUNE:ALEffectParam = 0x0001;
	public static inline var PITCH_SHIFTER_FINE_TUNE:ALEffectParam = 0x0002;
	/* Ringmodulator effect parameters */
	public static inline var RING_MODULATOR_FREQUENCY:ALEffectParam = 0x0001;
	public static inline var RING_MODULATOR_HIGHPASS_CUTOFF:ALEffectParam = 0x0002;
	public static inline var RING_MODULATOR_WAVEFORM:ALEffectParam = 0x0003;
	/* Autowah effect parameters */
	public static inline var AUTOWAH_ATTACK_TIME:ALEffectParam = 0x0001;
	public static inline var AUTOWAH_RELEASE_TIME:ALEffectParam = 0x0002;
	public static inline var AUTOWAH_RESONANCE:ALEffectParam = 0x0003;
	public static inline var AUTOWAH_PEAK_GAIN:ALEffectParam = 0x0004;
	/* Compressor effect parameters */
	public static inline var COMPRESSOR_ONOFF:ALEffectParam = 0x0001;
	/* Equalizer effect parameters */
	public static inline var EQUALIZER_LOW_GAIN:ALEffectParam = 0x0001;
	public static inline var EQUALIZER_LOW_CUTOFF:ALEffectParam = 0x0002;
	public static inline var EQUALIZER_MID1_GAIN:ALEffectParam = 0x0003;
	public static inline var EQUALIZER_MID1_CENTER:ALEffectParam = 0x0004;
	public static inline var EQUALIZER_MID1_WIDTH:ALEffectParam = 0x0005;
	public static inline var EQUALIZER_MID2_GAIN:ALEffectParam = 0x0006;
	public static inline var EQUALIZER_MID2_CENTER:ALEffectParam = 0x0007;
	public static inline var EQUALIZER_MID2_WIDTH:ALEffectParam = 0x0008;
	public static inline var EQUALIZER_HIGH_GAIN:ALEffectParam = 0x0009;
	public static inline var EQUALIZER_HIGH_CUTOFF:ALEffectParam = 0x000A;
}