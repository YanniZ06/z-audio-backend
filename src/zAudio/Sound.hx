package zAudio;

// import cpp.Pointer;
// import cpp.vm.Gc;
import haxe.Timer;

/**
 * The primary zAudio Sound object, coming with all sorts of useful properties.
 * 
 * To use the raw OpenAL source make use of the `source` and `buffer` variables aswell as some of the buffer
 * and source changing functions this class provides.
 * 
 * Both filters and effects need to be enabled manually using the `enabled` field they all come with.
 * 
 * You may only have `one` filter applied to the sound at once, if you enable another one while one is already enabled,
 * that one is overwritten by the newly enabled filter.
 * 
 * You may use as many sound effects at once as you want.
 * 
 * To find out more about filter and effect properties, visit the `API Documentation`.
 */
class Sound extends Sound_FxBackend implements SoundBaseI {
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
     * Function to call when this sound has finished playing.
     * 
     * Also gets called when a sound is looping and finishes a loop.
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
     * Setting this to true will give unexpected results if the Buffer hasnt been allowed to load reverse data yet.
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
    @:isVar public var pitch(get, set):Float;

    /**
     * The current gain/volume of the sound, should be positive to avoid errors.
     * 
     * The maximum applyable volume is defined by `maxVolume`.
     */
    public var volume(default, set):Float;

    /**
     * The highest value `volume` can have until it doesnt affect the actual gain of the sound anymore.
     *
     * Should be positive to avoid errors.
     * 
     * This feature might not always work as intended if set to decently high values.
     */
    @:isVar public var maxVolume(get, set):Float;

    //private var actualVolume:Float = 1;
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
    @:isVar public var time(get, set):Float;
    /**
     * The `soundCache` Map adress this sound is contained in.
     */
    public var cacheAddress:String = "";
    /**
     * The current position of this sound.
     * Useful for panning.
     */
    public var position:PositionHandle;

    /**
     * Loads in a new Sound object from the filled input buffer and returns it.
     * @param inputBuffer The `BufferHandle` object to load into the sound. Create one using one of the `zAudio.SoundLoader` functions.
     * @param initializeEFX If true, initializes all sound EFX. It can be smart to set this to false for sounds that only play shortly and never need effects.
     * If `SoundSettings.autoLoadFX` is false, you need to load in the effects you want to use yourself after initialization is done!! (See `Sound_FxBackend`)
     */
    public function new(inputBuffer:BufferHandle, initializeEFX:Bool = true) {
		//id = Pointer.addressOf(this);
        source = new SourceHandle(HaxeAL.createSource(), this);
		source.attachBuffer(inputBuffer);

        position = new PositionHandle();

        position.onChange = (val:Float, type:String) -> {
            //HaxeAL.distanceModel(HaxeAL.EXPONENT_DISTANCE);
            HaxeAL.source3f(source.handle, HaxeAL.POSITION, position.x, position.y, position.z);
           // trace(HaxeAL.getSource3f(source.handle, HaxeAL.POSITION));
        };

        timeGetter = timeGetRegular;
        timeSetter = timeSetRegular;
        onFinish = finishRegular;
        byteOffsetGetter = getByteOffset_Paused;
        byteOffsetSetter = setByteOffset_Paused;

        @:privateAccess cacheAddress = inputBuffer.cacheAddress;
        if(initializeEFX) init_EFX(this);

        CacheHandler.soundCache[cacheAddress].sounds.push(this);

        finishTimer = new Timer(500); //Avoid a null ref when destroying sound that hasnt been played once (whyever you'd do that)
        finishTimer.stop();

        totalSeconds = buffer.samples / buffer.sampleRate;
    }

    @:noCompletion var reverseChange:Bool = false;
    /**
     * Attaches a different buffer with different sound information to `this` sound object.
     * 
     * The general properties of this sound (such as pitch) 
     * will be kept and load-times will potentially be faster, so this can be recommended instead of creating a new sound.
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

    private function changeCacheAddress(newAddress:String) {
        var curAddressPtr = CacheHandler.soundCache[cacheAddress];
        curAddressPtr.sounds.remove(this);
        if(curAddressPtr.sounds.length < 1 && curAddressPtr.markedForRemoval) CacheHandler.removeFromCache(cacheAddress);
        
        cacheAddress = newAddress;
        CacheHandler.soundCache[newAddress].sounds.push(this);
        totalSeconds = buffer.samples / buffer.sampleRate;
    }

    /**
     * Attaches a different source with different playback information (such as pitch, position data etc) to `this` sound object.
     * 
     * This stops the currently playing sound, destroys the source along with its attached buffer and will throw if there currently is no source attached to this sound.
     * 
     * If you intend to keep the sound playing, store the time value before calling this function, then after calling
     * the function use `source.attachBuffer` with the buffer that holds the info of the current sound and finally call `play`.
     * @param inputSource The source to replace `this` sounds old source with.
     */
    public function changeSource(inputSource:SourceHandle) {
        source.destroy();
        source = inputSource;
        source.attachBuffer(buffer);
    }

    var allowPlay:Bool = true;
    var _preventPlay(get,never):Bool;
    function get__preventPlay():Bool return (reversed && time == 0);
    /**
     * Plays the sound from its current time.
     * 
     * If the sound has finished, this forces a replay.
     * 
     * If the sound was reversed and the current time is 0, this function does nothing
     * until the time value is higher than 0 or the sound is un-reversed.
     */
    public function play() {
        if(!allowPlay) return;

        playing = true;
        allowPlay = false;

        var setTime = finished ? 0 : time;
        byteOffsetSetter = setByteOffset_Playing;
        time = setTime;

        byteOffsetGetter = getByteOffset_Playing; //Make sure first time set gets paused byteOffset
        paused = false;
    }

    /**
     * Pauses the sound at the current time value.
     * Use the `play` function to unpause it.
     * 
     * If the time value has been changed before unpausing the sound, it is played from the new time value instead.
     */
    public function pause() {
        if(!playing) return;

        if(!_preventPlay) allowPlay = true;
        setByteOffset_Paused(getByteOffset_Playing());

        finishTimer.stop();
        HaxeAL.sourcePause(source.handle);
        playing = false;

        byteOffsetSetter = setByteOffset_Paused;
        byteOffsetGetter = getByteOffset_Paused;
        paused = true;
    }

    /**
	 * Destroys this Sound and renders it unuseable.
	 * Memory will be cleared the next time the garbage collector is activated.
	 */
    public function destroy() {        
        var curAddressPtr = CacheHandler.soundCache[cacheAddress];
        curAddressPtr.sounds.remove(this);
        if(curAddressPtr.sounds.length < 1 && curAddressPtr.markedForRemoval) CacheHandler.removeFromCache(cacheAddress);
        cacheAddress = null;
        curAddressPtr = null;

        if(efx_init) cleanup_EFX(); //Get rid of / unload all fx -> if available

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
    
    /**
     * Destroys this sound and renders it unuseable, querying the attached sources, effect related objects and buffer for deletion.
     * 
     * This function is only meant to be used when querying multiple sounds for deletion. 
     * Sounds will not be removed from Cache until `CacheHandler.markCacheRemoval()` is called, even if the cache was already marked for removal
     * If this function is called directly, queried objects will not be deleted until instructed to do so via `CacheHandler.clearFullQuery()`.
     */
    public function queryDestroy() {
        CacheHandler.soundCache[cacheAddress].sounds.remove(this);
        cacheAddress = null;

        if(efx_init) cleanup_EFX(); //Get rid of / unload all fx -> if available

        buffer.destroy();
        source.queryDestroy();
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

    // ? Why do you exist youre not even used
    // ! removed soon
    function switchPlaying() {
        if(!playing) { byteOffsetGetter = getByteOffset_Paused; byteOffsetSetter = setByteOffset_Paused; }
        else { byteOffsetGetter = getByteOffset_Playing; byteOffsetSetter = setByteOffset_Playing; }

        /*if(playing) { //Uncomment if all else fails
            HaxeAL.sourcePlay(source.handle);
            setByteOffset_Playing(getByteOffset_Paused()); //Cannot set the byte offset on non-playing sources, I hate this
            HaxeAL.sourcePause(source.handle);
        }*/
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

        HaxeAL.sourceStop(source.handle);
        finishTimer.stop();
        timesLooped = 0;
        playing = paused = false;
        allowPlay = true;
        time = 0;

        byteOffsetSetter = setByteOffset_Paused;
        byteOffsetGetter = getByteOffset_Paused;
        setByteOffset_Paused(1);
    }

    // Looping
    function get_looping():Bool return HaxeAL.getSourcei(source.handle, HaxeAL.LOOPING) == HaxeAL.TRUE ? true : false;
    function set_looping(val:Bool):Bool {
        HaxeAL.sourcei(source.handle, HaxeAL.LOOPING, val ? HaxeAL.TRUE : HaxeAL.FALSE);
        return val;
    }

    // Pitch
    function get_pitch():Float return HaxeAL.getSourcef(source.handle, HaxeAL.PITCH);
    function set_pitch(val:Float):Float {
        HaxeAL.sourcef(source.handle, HaxeAL.PITCH, val);

        var timeRemaining = Std.int((length - time) / pitch);
        setTimer(timeRemaining);
        return val;
    }

    // Volume
    //function get_volume():Float return actualVolume;
    function set_volume(val:Float):Float {
        /*actualVolume*/ volume = val;
        HaxeAL.sourcef(source.handle, HaxeAL.GAIN, val); //* SoundSettings.globalVolume);
        return val;
    }

    function get_maxVolume():Float return HaxeAL.getSourcef(source.handle, HaxeAL.MAX_GAIN);
    function set_maxVolume(val:Float):Float {
        HaxeAL.sourcef(source.handle, HaxeAL.MAX_GAIN, val);
        return val;
    }

    // Reversal
    var regularWasFinished:Bool = false;
    function set_reversed(b:Bool):Bool {
        final oldR = reversed;
        reversed = b;
        if(oldR == reversed) return b;

        final wasPlaying = playing;
        final oldTime = time;

        var buf:BufferHandle = BufferHandle.copyFrom(buffer); //AL forced my hand, im so sorry. Nothing else worked. Really, I tried.
        var data = b ? buf.reverseData : buf.data;
        HaxeAL.bufferData(buf.handle, buf.format, data, buf.dataLength, buf.sampleRate);

        reverseChange = true; //Ensures we dont try changing the cache address
        changeBuffer(buf);
        reverseChange = false;

        if(b) {
            timeGetter = timeGetReverse;
            timeSetter = timeSetReverse;
            onFinish = finishReverse;
            regularWasFinished = finished;
            finished = false;
        }
        else {
            timeGetter = timeGetRegular;
            timeSetter = timeSetRegular;
            onFinish = finishRegular;
            allowPlay = !wasPlaying;
            finishedReverse = false;
            finished = regularWasFinished;
        }
        
        playing = wasPlaying;

        // Setter
        byteOffsetSetter = playing ? setByteOffset_Playing : setByteOffset_Paused;
        time = oldTime;

        // Getter (why are we doing this after setting the time?)
        byteOffsetGetter = playing ? getByteOffset_Playing : getByteOffset_Paused;

        return b;
    }

    var onFinish:Void -> Void;
    function setTimer(msLeft:Float) {
        if(finishTimer != null) finishTimer.stop();

        if (msLeft <= 30) {
			onFinish();
			return;
		}
        finished = finishedReverse = false;       
        finishTimer = new Timer(msLeft);
        finishTimer.run = onFinish;
    }

    function finishRegular() {
        var timeRemaining = Std.int((length - time) / pitch); // THIS ENSURES SOUND DOESNT STOP WHEN THE APP AUTOPAUSES
		if(timeRemaining > 100 && HaxeAL.getSourcei(source.handle, HaxeAL.SOURCE_STATE) == HaxeAL.PLAYING)
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

    //Name is kind of a lie, this just prevents regular finishing and stops the sound, seperate function incase we need to adjust things
    function finishReverse() {
        var timeRemaining = Std.int(time / pitch); // THIS ENSURES IT DOESNT STOP WHEN THE APP AUTOPAUSES
		if(timeRemaining > 100 && HaxeAL.getSourcei(source.handle, HaxeAL.SOURCE_STATE) == HaxeAL.PLAYING)
		{
			setTimer(timeRemaining);
			return;
		}

        finishedReverse = true;
        stop();
        allowPlay = false; //Avoid reverse audio glitch :)
    }

    // Time
    var timeGetter:Void -> Float;
    function get_time():Float
        return timeGetter();

    function timeGetRegular():Float {
        if(finished) return length;

        var offset = byteOffsetGetter();
        var ratio = (offset / buffer.dataLength);
        var totalSeconds = buffer.samples / buffer.sampleRate;

        var time_ = Std.int(totalSeconds * ratio * 1000);
        return time_;
    }

    function timeGetReverse():Float {
        if(finishedReverse) return 0;
        return (length - timeGetRegular());
    }
    
    var timeSetter:Float -> Void;
    //Plays back the sound from its current time if playing is true, also handles the completion callback timer.
    function set_time(val:Float):Float {
        HaxeAL.sourceRewind(source.handle);
        timeSetter(val);

        return val;
    }

    var pause_offset:Int = 1;
    var byteOffsetSetter:Int -> Void;
    var byteOffsetGetter:Void -> Int;
    inline function setByteOffset(val:Int) {
        
    }
    function setByteOffset_Playing(val:Int) {
        HaxeAL.sourcei(source.handle, HaxeAL.BYTE_OFFSET, val);
        pause_offset = val;
    }
    function setByteOffset_Paused(val:Int) pause_offset = val;
    function getByteOffset_Playing() return HaxeAL.getSourcei(source.handle, HaxeAL.BYTE_OFFSET);
    function getByteOffset_Paused() return pause_offset;


    var totalSeconds:Float;
    function timeSetRegular(val:Float) {
        if(val > length - 10) {
            onFinish();
            return;
        }

        var secondOffset = (val/*+ offset*/) / 1000;
        if (secondOffset < 0) secondOffset = 0;
        if (secondOffset > totalSeconds) secondOffset = totalSeconds;

        final ratio = (secondOffset / totalSeconds);
        final totalOffset = Std.int(buffer.dataLength * ratio);

        byteOffsetSetter(totalOffset);
        if (playing) {
            HaxeAL.sourcePlay(source.handle);

            var timeRemaining = Std.int((length - val) / pitch);
            setTimer(timeRemaining);
        }
    }

    function timeSetReverse(val_:Float) {
        if(val_ > length - 10) val_ = length - 10;

        final val = length - val_;
        var secondOffset = (val/*+ offset*/) / 1000;

        if (secondOffset < 0) secondOffset = 0;
        if (secondOffset > totalSeconds) secondOffset = totalSeconds;

        final ratio = (secondOffset / totalSeconds);
        final totalOffset = Std.int(buffer.dataLength * ratio);

        byteOffsetSetter(totalOffset);
        if (playing) {
            HaxeAL.sourcePlay(source.handle);

            var timeRemaining = Std.int((val_) / pitch);
            setTimer(timeRemaining);
        }
    }
}