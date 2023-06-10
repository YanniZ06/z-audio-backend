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
     * If true, reverses sound playback.
     * 
     * Setting this to true will throw if the Buffer hasnt been allowed to load reverse data yet.
     * 
     * If this is the case, call `buffer.preloadReverseData()`!
     */
    public var reversed(default, set):Bool = false;
    /**
     * True if the sound has finished playing by reaching its end.
     */
    public var finished(default, null):Bool = false;
    var finishedReverse:Bool = false;
    /**
     * The length of this sound, in milliseconds.
     */
    public var length(default, null):Float = 0;
    @:noCompletion private function changeLength(val:Float) length = val;
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
    /**
     * The current position of the song, in milliseconds.
     */
    public var time(get, set):Float;
    //public var id(default, null):Pointer<Sound> = null;
    /**
     * The `activeSounds` Map adress this sound is contained in.
     */
    public var cacheAddress:String = "";

    /**
     * Loads in a new Sound object from the filled input buffer and returns it.
     * @param inputBuffer The `BufferHandle` object to load into the sound. Create one using one of the `zAudio.SoundLoader` functions.
     */
    public function new(inputBuffer:BufferHandle) {
		//id = Pointer.addressOf(this);
        source = new SourceHandle(AL.createSource(), this);
		source.attachBuffer(inputBuffer);

        timeGetter = timeGetRegular;
        timeSetter = timeSetRegular;
        onFinish = finishRegular;

        @:privateAccess cacheAddress = inputBuffer.cacheAddress;
        SoundHandler.activeSounds[cacheAddress].sounds.push(this);
    }

    @:noCompletion var reverseChange:Bool = false;
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
        if(!reverseChange) @:privateAccess changeCacheAddress(inputBuffer.cacheAddress);
    }

    function changeCacheAddress(newAddress:String) {
        var curAddressPtr = SoundHandler.activeSounds[cacheAddress];
        curAddressPtr.sounds.remove(this);
        if(curAddressPtr.sounds.length < 1 && !curAddressPtr.cacheExists) SoundHandler.activeSounds.remove(cacheAddress);
        
        cacheAddress = newAddress;
        SoundHandler.activeSounds[newAddress].sounds.push(this);
    }

    /**
     * Attaches a different source with different playback information ()
     * TODO: CONTINUE THIS DOCUMENTATION
     * !
     * !
     * !
     * !
     * !
     * !
     * !
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
     * 
     * If the sound was reversed and the current time is 0, this function does nothing
     * until the time value is higher than 0 or the sound is un-reversed.
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

    function set_reversed(b:Bool):Bool {
        final oldR = reversed;
        reversed = b;
        if(oldR == reversed) return b;

        final wasPlaying = playing;
        final oldTime = time;
        var buf:BufferHandle = BufferHandle.copyFrom(buffer); //AL forced my hand, im so sorry. Nothing else worked. Really, I tried.
        AL.bufferData(buf.handle, buf.format, b ? buf.reverseData : buf.data, buf.dataLength, buf.sampleRate);

        reverseChange = true; //Ensures we dont try changing the cache address
        changeBuffer(buf);
        reverseChange = false;

        if(b) {
            timeGetter = timeGetReverse;
            timeSetter = timeSetReverse;
            onFinish = finishReverse;
        }
        else {
            timeGetter = timeGetRegular;
            timeSetter = timeSetRegular;
            onFinish = finishRegular;
        }
        
        playing = wasPlaying;
        time = oldTime;

        return b;
    }

    function setTimer(val:Float) {
        if(finishTimer != null) finishTimer.stop();

        if (val <= 30) {
			finishSound();
			return;
		}
        finished = finishedReverse = false;       
        finishTimer = new Timer(val);
        finishTimer.run = finishSound;
    }

    var onFinish:Void -> Void;
    function finishSound()
        onFinish();

    function finishRegular() {
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

    //Name is kind of a lie, this just prevents regular finishing and stops the soun, seperate function incase we need to adjust things
    function finishReverse() {
        finishedReverse = true;
        stop();
    }

    var timeGetter:Void -> Float;
    function get_time():Float
        return timeGetter();

    function timeGetRegular():Float {
        if(finished) return length;

        var offset = AL.getSourcei(source.handle, AL.BYTE_OFFSET);
        var ratio = (offset / buffer.dataLength);
        var totalSeconds = buffer.samples / buffer.sampleRate;

        var time_ = Std.int(totalSeconds * ratio * 1000);// - parent.offset;
        return time_;
    }

    function timeGetReverse():Float {
        if(finishedReverse) return 0;
        return (length - timeGetRegular());
    }
    
    var timeSetter:Float -> Void;
    //Plays back the sound from its current time if playing is true, also handles the completion callback timer.
    function set_time(val:Float):Float {
        AL.sourceRewind(source.handle);
        timeSetter(val);

        return val;
    }

    function timeSetRegular(val:Float) {
        if(val > length - 10) {
            finishSound();
            return;
        }

        var secondOffset = (val/*+ offset*/) / 1000;
        var totalSeconds = buffer.samples / buffer.sampleRate;

        if (secondOffset < 0) secondOffset = 0;
        if (secondOffset > totalSeconds) secondOffset = totalSeconds;

        final ratio = (secondOffset / totalSeconds);
        final totalOffset = Std.int(buffer.dataLength * ratio);

        AL.sourcei(source.handle, AL.BYTE_OFFSET, totalOffset);
        if (playing) {
            AL.sourcePlay(source.handle);

            var timeRemaining = Std.int((length - val) / pitch);
            setTimer(timeRemaining);
        }
    }

    function timeSetReverse(val_:Float) {
        if(val_ > length - 10) val_ = length - 10;

        final val = length - val_;
        var secondOffset = (val/*+ offset*/) / 1000;
        var totalSeconds = buffer.samples / buffer.sampleRate;

        if (secondOffset < 0) secondOffset = 0;
        if (secondOffset > totalSeconds) secondOffset = totalSeconds;

        final ratio = (secondOffset / totalSeconds);
        final totalOffset = Std.int(buffer.dataLength * ratio);

        AL.sourcei(source.handle, AL.BYTE_OFFSET, totalOffset);
        if (playing) {
            AL.sourcePlay(source.handle);

            var timeRemaining = Std.int((val_) / pitch);
            setTimer(timeRemaining);
        }
    }

    /**
	 * Destroys this Sound and renders it unuseable.
	 * Memory will be cleared the next time the garbage collector is activated.
	 */
    public function destroy() {
        var curAddressPtr = SoundHandler.activeSounds[cacheAddress];
        curAddressPtr.sounds.remove(this);
        if(curAddressPtr.sounds.length < 1 && !curAddressPtr.cacheExists) SoundHandler.activeSounds.remove(cacheAddress);
        cacheAddress = null;
        curAddressPtr = null;

        buffer.destroy();
        source.destroy();
        if(finishTimer != null) {
            finishTimer.stop();
            finishTimer = null;
        }
        //id = null;
		buffer = null;
		source = null;
        timeGetter = null;
        timeSetter = null;
        onFinish = null;
    }
}