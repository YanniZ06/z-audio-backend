package zAudio.handles;

// ? https://openal-soft.org/misc-downloads/Effects%20Extension%20Guide.pdf (P. 22 AND 32 etc)

/**
 * A handle for an `ALAuxiliaryEffectSlot`, used to contain effects and apply them to sources using the `applyTo` method.
 */
class AuxSlotHandle
{
	public var handle:ALAuxiliaryEffectSlot = null;

	/**
	 * The volume for this auxslot, represents how affected the affected ALSource is by the effect `this` AuxSlotHandle applies.
	 */
	public var volume(default, set):Float = 1;

	public var auxID:Int = 0;
	public var appliedSrc:SourceHandle = null;

	public function new(inputEffect:ALEffect)
	{
		handle = AL.createAux();
		AL.auxi(handle, ALAuxSlotParam.EFFECTSLOT_EFFECT, inputEffect); // Apply effect to the aux
	}

	public function applyTo(src:SourceHandle)
	{
		AL.source3i(src.handle, AL.AUXILIARY_SEND_FILTER, handle, src.auxCount, AL.FILTER_NULL);
		auxID = src.auxCount;
		src.auxCount++;
		appliedSrc = src;

		stFunc = (param:ALAuxSlotParam, value:Float) ->
		{
			AL.auxf(handle, param, value);
			return value;
		}
		stFunc(ALAuxSlotParam.EFFECTSLOT_GAIN, volume);
	}

	public function removeFromSrc(destroy_:Bool = false)
	{
		appliedSrc.onAuxRemove(auxID);
		appliedSrc = null;

		if (destroy_)
			destroy(false);
	}

	/**
	 * Renders this Effect Slot unuseable.
	 * @param srcRemove Whether the applied source needs to be removed or not.
	 */
	public function destroy(srcRemove:Bool = true)
	{
		if (srcRemove && appliedSrc != null)
			removeFromSrc();
		handle = null;
	}

	function set_volume(vol:Float):Float
	{
		volume = stFunc(ALAuxSlotParam.EFFECTSLOT_GAIN, vol);
		return vol;
	}

	private var stFunc:ALAuxSlotParam->Float->Float = (param:ALAuxSlotParam, val:Float) ->
	{
		return val;
	}; // For when handle is not initialized yet.
}

/**
 * An abstract representing all the AL Auxiliary Slot parameters / fields.
 *
 * Used with the AL.auxi function on backend.
 */
enum abstract ALAuxSlotParam(Int) from Int to Int
{
	/* Auxiliary Effect Slot properties.*/
	public static inline var EFFECTSLOT_EFFECT:ALAuxSlotParam = 0x0001; // Effect Type tied to this Aux Slot
	public static inline var EFFECTSLOT_GAIN:ALAuxSlotParam = 0x0002; // The volume of this Aux Slot, sort of like a master volume on how much this effect should be applied overall
	public static inline var EFFECTSLOT_AUXILIARY_SEND_AUTO:ALAuxSlotParam = 0x0003; // ?? Figure this out properly
	/* NULL Auxiliary Slot ID to disable a source send. */
	// public static inline var EFFECTSLOT_NULL:ALAuxSlotParam = 0x0000;		//Use removeSend instead
}
