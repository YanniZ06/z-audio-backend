package zAudio.efx;

/**
 * The (currently barebones) base for all sound effect & filter modifiers.
 */
class FXBase {
	public function destroy() { 
		sourceRef = null;
		_snd = null;
	}

	public function new(sndRef:Sound) {
		_snd = sndRef;
		sourceRef = sndRef.source;
	}

	private var _snd:Sound = null;

	private var sourceRef:SourceHandle = null;
	//? https://openal-soft.org/misc-downloads/Effects%20Extension%20Guide.pdf
}