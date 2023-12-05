package zAudio.efx.fx;

/**
 * Represents the Chorus Waveform Types.
 */
enum abstract ChorusWaveform(Int) from Int to Int {
    public static inline var sin:ChorusWaveform = 0;
    public static inline var triangle:ChorusWaveform = 1;
}