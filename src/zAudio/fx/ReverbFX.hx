package zAudio.fx;

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
