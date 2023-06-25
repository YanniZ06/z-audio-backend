package zAudio;

interface SoundBaseI {
    //Important
    public var source:SourceHandle;
    public var initialized:Bool;
    public var cacheAddress:String;

    //Playing States
    public var playing(default, null):Bool;
    public var paused(default, null):Bool;
    public var reversed(default, set):Bool;
    public var finished(default, null):Bool;

    //General Values
    public var volume(default, set):Float;
    public var maxVolume(get, set):Float;
    public var pitch(get, set):Float;
    public var time(get, set):Float;
    public var looping(get, set):Bool;
    public var onComplete:Void -> Void;
    public var autoDestroy:Bool;
    public var position:PositionHandle;

    //Sound Constants
    public var length(default, null):Float;
    public var timesLooped(default, null):Int;

    //General purpose functions
    public function play():Void;
    public function pause():Void;
    public function stop():Void;

    public function destroy():Void;
}