package zAudio;

//import cpp.vm.Gc;
import cpp.Pointer;
import haxe.Timer;

class Sound {
    var finishTimer:Timer;
    /**
     * Handle for the connected ALSource and its various properties.
     * 
     * Should not be touched if you're not 100% certain what you're doing.
     */
    public var source:SourceHandle;
    /**
     * Handle for the connected Buffer and its various properties
     * 
     * Should not be touched if you're not 100% certain what you're doing.
     */
    public var buffer:BufferHandle;

    /**
     * Automatically set to true if this sound is safe to play.
     * 
     * Conditions for this are a valid source object alongside a buffer filled with sound information.
     */
    public var initialized:Bool = false;
    /**
     * Function to call when this sound has finished playing
     */
    public var onComplete:Void -> Void = null;
    /**
     * If true, this sound is destroyed when `finished` switches to true.
     * 
     * Note that this does not happen if `looping` is set to true.
     */
    public var autoDestroy:Bool = false;
    /**
     * True if the sound is currently playing.
     */
    public var playing(default, null):Bool = false;
    /**
     * True if the sound was paused using `pause()`.
     */
    public var paused(default, null):Bool = false;
    /**
     * True if the sound has finished playing by reaching its end.
     */
    public var finished(default, null):Bool = false;
    /**
     * The length of this sound, in milliseconds.
     */
    public var length(default, null):Int = 0;
    @:noCompletion private function changeLength(val:Int) length = val;
    /**
     * The pitch of this sound, should be a positive value to avoid errors.
     * Modifies playback speed aswell.
     */
    public var pitch(get, set):Float;

    /**
     * The current gain/volume of the sound, should be positive to avoid errors.
     */
    public var volume(get, set):Float;
    /**
     * Whether this sound should loop or not.
     */
    public var looping(get, set):Bool;
    /**
     * How often this sound has been looped.
     * Only useful if looping is set to true.
     * 
     * This value will reset if the sound is stopped.
     */
    public var timesLooped(default, null):Int = 0;
    public var time(get, set):Int;
    //public var id(default, null):Pointer<Sound> = null;

    /**
     * Loads in a new Sound object from the input buffer and returns it.
     * @param inputBuffer The `BufferHandle` object to load into the sound. Create one using one of the `zAudio.SoundLoader` functions.
     */
    public function new(inputBuffer:BufferHandle) {
		//id = Pointer.addressOf(this);
        source = new SourceHandle(AL.createSource(), this);
		source.attachBuffer(inputBuffer);
    }

    /**
     * Attaches a different buffer with different sound information to `this` sound object.
     * The general properties of this sound will be kept and load-times will potentially be faster, so this can be recommended instead of creating a new sound.
     * 
     * If initialized is `false`, this function will most likely fail.
     * A check is not necessary however, as this will only be the case if the buffer has been manually detached from the source before.
     * @param inputBuffer The new buffer to attach to `this` sound object.
     */
    public function changeBuffer(inputBuffer:BufferHandle) {
        source.detachBuffer();
        source.attachBuffer(inputBuffer);
    }

    /**
     * Attaches a different source with different playback information ()
     * @param inputSource 
     */
    public function changeSource(inputSource:SourceHandle) {
        source.destroy();
        source = inputSource;
        source.attachBuffer(buffer);
    }

    /**
     * Plays the sound from its current time.
     * 
     * If the sound has finished, this forces a replay.
     */
    public function play() {
        if(playing) return;

        playing = true;

        var setTime = finished ? 0 : time;
        time = setTime;
    }

    /**
     * Pauses the sound at the current time value.
     * Use the `play` function to unpause it.
     * 
     * If the time value has been changed before unpausing the sound, it is played from the new time value instead.
     */
    public function pause() {
        if(!playing) return;

        finishTimer.stop();
        AL.sourcePause(source.handle);
        playing = false;
        paused = true;
    }

    /**
     * Stops the sound entirely and sets its time to 0, also resets the amount of times the sound has been looped.
     * 
     * The `onComplete` callback will not called.
     * 
     * If the sound was paused it will be stopped regardless.
     */
    public function stop() {
        if(time <= 0) return;

        AL.sourceStop(source.handle);
        finishTimer.stop();
        timesLooped = 0;
        playing = paused = false;
        time = 0;
    }

    function get_looping():Bool return AL.getSourcei(source.handle, AL.LOOPING) == AL.TRUE ? true : false;
    function set_looping(val:Bool):Bool {
        AL.sourcei(source.handle, AL.LOOPING, val ? AL.TRUE : AL.FALSE);
        return val;
    }
    function get_pitch():Float return AL.getSourcef(source.handle, AL.PITCH);
    function set_pitch(val:Float):Float {
        AL.sourcef(source.handle, AL.PITCH, val);

        var timeRemaining = Std.int((length - time) / pitch);
        setTimer(timeRemaining);
        return val;
    }
    function get_volume():Float return AL.getSourcef(source.handle, AL.GAIN);
    function set_volume(val:Float):Float {
        AL.sourcef(source.handle, AL.GAIN, val);
        return val;
    }

    function setTimer(val:Float) {
        if(finishTimer != null) finishTimer.stop();

        if (val <= 30) {
			finishSound();
			return;
		}
        finished = false;       
        finishTimer = new Timer(val);
        finishTimer.run = finishSound;
    }

    function finishSound() {
        var timeRemaining = Std.int((length - time) / pitch);
		if(timeRemaining > 100 && AL.getSourcei(source.handle, AL.SOURCE_STATE) == AL.PLAYING)
		{
			setTimer(timeRemaining);
			return;
		}

        if(onComplete != null) onComplete();

        if(!looping) {
            finished = true;
            if(autoDestroy) destroy(); 
            else stop();
            return;
        }
        timesLooped++;
        time = 0;
    }

    function get_time():Int {
        if(finished) return length;

        var offset = AL.getSourcei(source.handle, AL.BYTE_OFFSET);
        var ratio = (offset / buffer.dataLength);
        var totalSeconds = buffer.samples / buffer.sampleRate;

        var time = Std.int(totalSeconds * ratio * 1000);// - parent.offset;
        return time;
    }
    
    //Plays back the sound from its current time if playing is true, also handles the completion callback timer.
    function set_time(val:Int):Int {
        AL.sourceRewind(source.handle);

        if(val < length - 10) {
            var secondOffset = (val/*+ offset*/) / 1000;
            var totalSeconds = buffer.samples / buffer.sampleRate;

            if (secondOffset < 0) secondOffset = 0;
            if (secondOffset > totalSeconds) secondOffset = totalSeconds;

            var ratio = (secondOffset / totalSeconds);
            var totalOffset = Std.int(buffer.dataLength * ratio);

            AL.sourcei(source.handle, AL.BYTE_OFFSET, totalOffset);
            if (playing) {
                AL.sourcePlay(source.handle);
                trace("ERMM???");

                var timeRemaining = Std.int((length - val) / pitch);
                setTimer(timeRemaining);
            }
        }
        else finishSound();

        return val;
    }

    public function destroy() {
        buffer.destroy();
        source.destroy();
        if(finishTimer != null) {
            finishTimer.stop();
            finishTimer = null;
        }
        //id = null;
		buffer = null;
		source = null;
    }
}