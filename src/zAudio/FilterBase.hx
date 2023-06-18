package zAudio;

/**
 * The base for all sound filter modifiers.
 */
class FilterBase extends FXBase {
	/**
	 * Controls whether this Filter should be enabled right now or not.
	 */
	public var enabled(get, set):Bool;
	@:noCompletion private var enabled_:Bool = false; //To prevent calling the setter and using unnecessary time to call an AL operation when disabling another filter

	private var filter:ALFilter = null;

	/**
     * Loads in an ALFilter of type `type` and attaches it to the `sndRef`.
     * @param sndRef The sound to attach the filter to.
	 * @param type The type of ALFilter you want to attach to the sound.
     */
	private function new(sndRef:Sound, type:ALFilterType) {
		super(sndRef);
		filter = makeFilter(type);
	}

	/**
	 * Destroys this Filter and its auxSlot and renders them unuseable, also freeing their allocated memory.
	 */
	override public function destroy() {
		enabled = false;
		super.destroy();

		if(filter != null) deleteFilter(filter);
		filter = null;
	}

	function set_enabled(val:Bool):Bool {
		final oldE = enabled_;
		enabled_ = val;
		if(oldE == enabled_) return val;

		if(enabled_) { 
			reapplyFilter();
			@:privateAccess {
				if(_snd.activeFilter != null) _snd.activeFilter.enabled_ = false;
				_snd.activeFilter = this;
			}
		}
		else {
			AL.removeDirectFilter(sourceRef.handle);
			@:privateAccess _snd.activeFilter = null;
		}
		sourceRef.hasFilter = enabled;

		return val;
	}

	function get_enabled():Bool return enabled_;

	function reapplyFilter():Void AL.sourcei(sourceRef.handle, AL.DIRECT_FILTER, filter);

	public static function makeFilter(type:ALFilterType):ALFilter {
		var fl = AL.createFilter();
		AL.filteri(fl, ALFilterTypeParam.FILTER_TYPE, type);

		return fl;
	}

	/**
	 * Deletes the ALFilter `filter`.
	 * @param filter The filter to delete.
	 */
	public static function deleteFilter(filter:ALFilter) {
		#if (lime_cffi && lime_openal && !macro)
		LimeAudioCFFI.lime_al_delete_filter(filter);
		#end
	}
}

/**
 * An abstract representing all the AL filter type params.
*/
enum abstract ALFilterTypeParam(Int) from Int to Int {
	/* Filter type */
	public static inline var FILTER_FIRST_PARAMETER:ALFilterTypeParam = 0x0000; /*This is not even in the documentation*/
	public static inline var FILTER_LAST_PARAMETER:ALFilterTypeParam = 0x8000; /*This one neither*/
	public static inline var FILTER_TYPE:ALFilterTypeParam = 0x8001;
}

/**
 * An abstract representing all the AL filter types to choose from.
*/
enum abstract ALFilterType(Int) from Int to Int {
	/* Filter types, used with the AL_FILTER_TYPE property */
	public static inline var FILTER_NULL:ALFilterType = 0x0000;
	public static inline var FILTER_LOWPASS:ALFilterType = 0x0001;
	public static inline var FILTER_HIGHPASS:ALFilterType = 0x0002;
	public static inline var FILTER_BANDPASS:ALFilterType = 0x0003;
}

/**
 * Strictly assigned Aux Slots for each Filter, starting from 13.
 */
enum abstract AssignedAuxSlot_Filter(Int) from Int to Int {
	public static inline var FILTER_LOWPASS:AssignedAuxSlot_Filter = 13;
	public static inline var FILTER_HIGHPASS:AssignedAuxSlot_Filter = 14;
	public static inline var FILTER_BANDPASS:AssignedAuxSlot_Filter = 15;
}