package zAudio.al_handles;

import zAudio.efx.EffectBase.ALEffectType;
import zAudio.efx.EffectBase;
import zAudio.efx.FilterBase.ALFilterType;
import zAudio.efx.FilterBase.AssignedAuxSlot_Filter;

// ? https://openal-soft.org/misc-downloads/Effects%20Extension%20Guide.pdf (P. 22 AND 32 etc)

/**
 * A handle for an `ALAuxSlot`, used to contain effects and filters to apply them to sources using the `applyTo` method.
 */
class AuxSlotHandle
{
	public var handle:ALAuxSlot = 0;

	/**
	 * The volume for this auxslot, represents how affected the affected ALSource is by the effect or `this` AuxSlotHandle applies.
	 */
	public var volume(default, set):Float = 1;

	public var auxID(default, null):Int = 0;
	public var appliedSrc:SourceHandle = null;

	public var appliedFX:ALEffect = 0;

	public function new(inputFX:ALEffect, type:Int)
	{
		appliedFX = cast inputFX;
		auxID = getAuxID_FX(type);

		handle = HaxeEFX.createAuxiliaryEffectSlot();
		reapplyEffect(); // Apply effect to the aux
		HaxeEFX.auxiliaryEffectSloti(handle, ALAuxSlotParam.EFFECTSLOT_AUXILIARY_SEND_AUTO, HaxeAL.FALSE);
	}

	public function detachEffect() HaxeEFX.auxiliaryEffectSloti(handle, ALAuxSlotParam.EFFECTSLOT_EFFECT, HaxeEFX.EFFECTSLOT_NULL);
	public function reapplyEffect() HaxeEFX.auxiliaryEffectSloti(handle, ALAuxSlotParam.EFFECTSLOT_EFFECT, appliedFX);

	/**
	 * Applies this AuxSlot to the source `src`, layering its effect/filter over the source output
	 * @param src The source you want to apply the AuxSlot to
	 */
	public function applyTo(src:SourceHandle)
	{
		//var castedFilter:CFFIPointer = cast appliedFilter;
		HaxeAL.source3i(src.handle, HaxeEFX.AUXILIARY_SEND_FILTER, handle, auxID, /*cast(castedFilter.get(), Int) ??*/ HaxeEFX.FILTER_NULL);
		appliedSrc = src;
	}

	/**
	 * Detaches the AuxSlot from the applied source.
	 */
	public function removeFromSrc()
	{
		appliedSrc.onAuxRemove(auxID);
		appliedSrc = null;
	}

	/**
	 * Renders this Effect Slot unuseable and marks it for garbage collection, freeing memory.
	 */
	public function destroy() //TODO: delete filter and fx??? yes?? | aux slots are tied to effects, not effects to aux slots, we shouldnt do this, the fuck was i thinking
	{
		if(appliedSrc != null)
			removeFromSrc();

		HaxeEFX.deleteAuxiliaryEffectSlot(handle);
	}

	public function queryDestroy() {
		if(appliedSrc != null)
			removeFromSrc();
		
		CacheHandler.queryCache.auxCleanQuery.push(handle);
	}

	/**
	 * Gets the predetermined auxid from the `input` effect type
	 * @param input The Effect Type the Aux Slot is tied to.
	 */
	private static function getAuxID_FX(input:ALEffectType) {
		return switch(input) {
			case ALEffectType.EFFECT_AUTOWAH: AssignedAuxSlot_Effect.EFFECT_AUTOWAH;
			case ALEffectType.EFFECT_CHORUS: AssignedAuxSlot_Effect.EFFECT_CHORUS;
			case ALEffectType.EFFECT_COMPRESSOR: AssignedAuxSlot_Effect.EFFECT_COMPRESSOR;
			case ALEffectType.EFFECT_DISTORTION: AssignedAuxSlot_Effect.EFFECT_DISTORTION;
			case ALEffectType.EFFECT_EAXREVERB: AssignedAuxSlot_Effect.EFFECT_EAXREVERB;
			case ALEffectType.EFFECT_ECHO: AssignedAuxSlot_Effect.EFFECT_ECHO;
			case ALEffectType.EFFECT_EQUALIZER: AssignedAuxSlot_Effect.EFFECT_EQUALIZER;
			case ALEffectType.EFFECT_FLANGER: AssignedAuxSlot_Effect.EFFECT_FLANGER;
			case ALEffectType.EFFECT_FREQUENCY_SHIFTER: AssignedAuxSlot_Effect.EFFECT_FREQUENCY_SHIFTER;
			case ALEffectType.EFFECT_PITCH_SHIFTER: AssignedAuxSlot_Effect.EFFECT_PITCH_SHIFTER;
			case ALEffectType.EFFECT_REVERB: AssignedAuxSlot_Effect.EFFECT_REVERB;
			case ALEffectType.EFFECT_RING_MODULATOR: AssignedAuxSlot_Effect.EFFECT_RING_MODULATOR;
			case ALEffectType.EFFECT_VOCAL_MORPHER: AssignedAuxSlot_Effect.EFFECT_VOCAL_MORPHER;
			default: -1;
		}
	}

	function set_volume(vol:Float):Float
	{
		HaxeEFX.auxiliaryEffectSlotf(handle, ALAuxSlotParam.EFFECTSLOT_GAIN, vol);
		volume = vol;
		return vol;
	}
}

/**
 * An abstract representing all the AL Auxiliary Slot parameters / fields.
 *
 * Used with the HaxeAL.auxi function on backend.
 */
enum abstract ALAuxSlotParam(Int) from Int to Int
{
	/* Auxiliary Effect Slot properties.*/
	public static inline var EFFECTSLOT_EFFECT:ALAuxSlotParam = 0x0001; // Effect Type tied to this Aux Slot
	public static inline var EFFECTSLOT_GAIN:ALAuxSlotParam = 0x0002; // The volume of this Aux Slot, sort of like a master volume on how much this effect should be applied overall
	public static inline var EFFECTSLOT_AUXILIARY_SEND_AUTO:ALAuxSlotParam = 0x0003; // ?? Figure this out properly
	/* NULL Auxiliary Slot ID to disable a source send. */
	// public static inline var EFFECTSLOT_NULL:ALAuxSlotParam = 0x0000;		//Use removeSend instead | NAWWWW
}