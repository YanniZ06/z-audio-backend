package openal;

#if !cpp
    #error "OpenAL is only available with haxe + hxcpp ( cpp target )."
#end

    /** An OpenAL device pointer */
typedef Device = cpp.Pointer<ALCdevice>;
    /** An OpenAL context pointer */
typedef Context = cpp.Pointer<ALCcontext>;

typedef ALuint = UInt;

@:keep
@:include('linc_openal.h')
#if !display
@:build(linc.Linc.touch())
@:build(linc.Linc.xml('openal'))
#end
    /** The main OpenAL API */
extern class AL {

    // scene configs

            @:native('alDopplerFactor')
        public static function dopplerFactor(value:Float) : Void;
            @:native('alDopplerVelocity')
        public static function dopplerVelocity(value:Float) : Void;
            @:native('alSpeedOfSound')
        public static function speedOfSound(value:Float) : Void;
            @:native('alDistanceModel')
        public static function distanceModel(distanceModel:Int) : Void;

    // scene management

            @:native('alEnable')
        public static function enable(capability:Int) : Void;
            @:native('alDisable')
        public static function disable(capability:Int) : Void;
            @:native('alIsEnabled')
        public static function isEnabled(capability:Int) : Bool;

    // scene state

            @:native('alGetString')
        public static function getString(param:Int) : String;
            @:native('alGetBooleanv')
        public static function getBooleanv(param:Int, ?count:Int = 1 ) : Array<Bool>;
            @:native('alGetIntegerv')
        public static function getIntegerv(param:Int, ?count:Int = 1 ) : Array<Int>;
            @:native('alGetFloatv')
        public static function getFloatv(param:Int, ?count:Int = 1 ) : Array<Float>;
            @:native('alGetDoublev')
        public static function getDoublev(param:Int, ?count:Int = 1 ) : Array<Float>;
            @:native('alGetBoolean')
        public static function getBoolean(param:Int) : Bool;
            @:native('alGetInteger')
        public static function getInteger(param:Int) : Int;
            @:native('alGetFloat')
        public static function getFloat(param:Int) : Float;
            @:native('alGetDouble')
        public static function getDouble(param:Int) : Float;
            @:native('alGetError')
        public static function getError() : Int;


    // extensions

            @:native('alIsExtensionPresent')
        public static function isExtensionPresent(extname:String) : Bool;
            @:native('alGetProcAddress')
        public static function getProcAddress(fname:String) : Dynamic; // :warn: not sure yet
            @:native('alGetEnumValue')
        public static function getEnumValue(ename:String) : Int;

    // listener state

            @:native('alListenerf')
        public static function listenerf(param:Int, value:Float) : Void;
            @:native('alListener3f')
        public static function listener3f(param:Int, value1:Float, value2:Float, value3:Float) : Void;
            @:native('alListenerfv')
        public static function listenerfv(param:Int, values:Array<Float> ) : Void;
            @:native('alListeneri')
        public static function listeneri(param:Int, value:Int) : Void;
            @:native('alListener3i')
        public static function listener3i(param:Int, value1:Int, value2:Int, value3:Int) : Void;
            @:native('alListeneriv')
        public static function listeneriv(param:Int, values:Array<Int> ) : Void;
            @:native('alGetListenerf')
        public static function getListenerf(param:Int) : Float;
            @:native('alGetListener3f')
        public static function getListener3f(param:Int) : Array<Float>;
            @:native('alGetListenerfv')
        public static function getListenerfv(param:Int, ?count:Int = 1) : Array<Float>;
            @:native('alGetListeneri')
        public static function getListeneri(param:Int) : Int;
            @:native('alGetListener3i')
        public static function getListener3i(param:Int) : Array<Int>;
            @:native('alGetListeneriv')
        public static function getListeneriv( param:Int, ?count:Int = 1) : Array<Int>;

    // source management

            @:native('alGenSources') //:todo:
        public static function genSources(n:Int) : Array<Int>;
            @:native('alDeleteSources') //:todo:
        public static function deleteSources(sources:Array<Int>) : Void;
            @:native('alIsSource')
        public static function isSource(source:Int) : Bool;

    // source state

            @:native('alSourcef')
        public static function sourcef(source:Int, param:Int, value:Float) : Void;
            @:native('alSource3f')
        public static function source3f(source:Int, param:Int, value1:Float, value2:Float, value3:Float) : Void;
            @:native('alSourcefv')
        public static function sourcefv(source:Int, param:Int, values:Array<Float> ) : Void;
            @:native('alSourcei')
        public static function sourcei(source:Int, param:Int, value:Int) : Void;
            @:native('alSource3i')
        public static function source3i(source:Int, param:Int, value1:Int, value2:Int, value3:Int) : Void;
            @:native('alSourceiv') //:todo:
        public static function sourceiv(source:Int, param:Int, values:Array<Int> ) : Void;
            @:native('linc::openal::getSourcef')
        public static function getSourcef(source:Int, param:Int) : Float;
            @:native('linc::openal::getSource3f')
        public static function getSource3f(source:Int, param:Int, into:Array<Float>) : Array<Float>;
            @:native('alGetSourcefv') //:todo:
        public static function getSourcefv(source:Int, param:Int) : Array<Float>;
            @:native('linc::openal::getSourcei')
        public static function getSourcei(source:Int,  param:Int) : Int;
            @:native('linc::openal::getSource3i')
        public static function getSource3i(source:Int, param:Int, into:Array<Int>) : Array<Int>;
            @:native('alGetSourceiv') //:todo:
        public static function getSourceiv(source:Int,  param:Int, ?count:Int = 1) : Array<Int>;

    //source states

            @:native('alSourcePlayv')
        public static function sourcePlayv(sources:Array<Int>) : Void;
            @:native('alSourceStopv')
        public static function sourceStopv(sources:Array<Int>) : Void;
            @:native('alSourceRewindv')
        public static function sourceRewindv(sources:Array<Int>) : Void;
            @:native('alSourcePausev')
        public static function sourcePausev(sources:Array<Int>) : Void;
            @:native('alSourcePlay')
        public static function sourcePlay(source:Int) : Void;
            @:native('alSourceStop')
        public static function sourceStop(source:Int) : Void;
            @:native('alSourceRewind')
        public static function sourceRewind(source:Int) : Void;
            @:native('alSourcePause')
        public static function sourcePause(source:Int) : Void;
            @:native('alSourceQueueBuffers') //:todo:
        public static function sourceQueueBuffers(source:Int, nb:Int, buffers:Array<ALuint>) : Void;
            @:native('alSourceUnqueueBuffers') //:todo:
        public static function sourceUnqueueBuffers(source:Int, nb:Int) : Array<ALuint>;

    //buffer management

        public static inline function genBuffers(n:Int, into:Array<ALuint>) : Array<ALuint> {
            var _i = 0;
            while(_i < n) {
                into[_i] = genBuffer();
                ++_i;
            }
            return into;
        }

        public static function deleteBuffers(buffers:Array<ALuint>) : Void {
            var _i = 0;
            while(_i < n) {
                deleteBuffer(buffers[_i]);
                ++_i;
            }
        }

            @:native('alIsBuffer')
        public static function isBuffer(buffer:ALuint) : Bool;

    //buffer data and state

            @:native('linc::openal::bufferData')
        public static function bufferData(buffer:ALuint, format:Int, frequency:Int, bytes:haxe.io.BytesData, byteOffset:Int, byteLength:Int) : Void;
            @:native('alBufferf')
        public static function bufferf(buffer:ALuint, param:Int, value:Float) : Void;
            @:native('alBuffer3f')//:todo:
        public static function buffer3f(buffer:ALuint, param:Int, value1:Float, value2:Float, value3:Float) : Void;
            @:native('alBufferfv')//:todo:
        public static function bufferfv(buffer:ALuint, param:Int, values:Array<Float> ) : Void;
            @:native('alBufferi')
        public static function bufferi(buffer:ALuint, param:Int, value:Int) : Void;
            @:native('alBuffer3i')
        public static function buffer3i(buffer:ALuint, param:Int, value1:Int, value2:Int, value3:Int) : Void;
            @:native('alBufferiv')//:todo:
        public static function bufferiv(buffer:ALuint, param:Int, values:Array<Int> ) : Void;
            @:native('linc::openal::getBufferf')
        public static function getBufferf(buffer:ALuint, param:Int) : Float;
            @:native('alGetBuffer3f')//:todo:
        public static function getBuffer3f(buffer:ALuint, param:Int) : Array<Float>;
            @:native('alGetBufferfv')//:todo:
        public static function getBufferfv(buffer:ALuint, param:Int, ?count:Int = 1) : Array<Float>;
            @:native('linc::openal::getBufferi')
        public static function getBufferi(buffer:ALuint, param:Int) : Int;
            @:native('alGetBuffer3i')//:todo:
        public static function getBuffer3i(buffer:ALuint, param:Int) : Array<Int>;
            @:native('alGetBufferiv')//:todo:
        public static function getBufferiv(buffer:ALuint, param:Int, ?count:Int = 1) : Array<Int>;

    //unofficial API helpers

            @:native('linc::openal::genSource')
        public static function genSource() : Int;
            @:native('linc::openal::deleteSource')
        public static function deleteSource(source:Int) : Void;
            @:native('linc::openal::genBuffer')
        public static function genBuffer() : ALuint;
            @:native('linc::openal::deleteBuffer')
        public static function deleteBuffer(buffer:ALuint) : Void;

            @:native('linc::openal::sourceQueueBuffer')
        public static function sourceQueueBuffer(source:Int, buffer:ALuint) : Void;
            @:native('linc::openal::sourceUnqueueBuffer')
        public static function sourceUnqueueBuffer(source:Int) : ALuint;


    //defines

        public static inline var NONE : Int                                = 0;
        public static inline var FALSE : Int                               = 0;
        public static inline var TRUE : Int                                = 1;

        public static inline var SOURCE_RELATIVE : Int                     = 0x202;
        public static inline var CONE_INNER_ANGLE : Int                    = 0x1001;
        public static inline var CONE_OUTER_ANGLE : Int                    = 0x1002;
        public static inline var PITCH : Int                               = 0x1003;
        public static inline var POSITION : Int                            = 0x1004;
        public static inline var DIRECTION : Int                           = 0x1005;
        public static inline var VELOCITY : Int                            = 0x1006;
        public static inline var LOOPING : Int                             = 0x1007;
        public static inline var BUFFER : Int                              = 0x1009;
        public static inline var GAIN : Int                                = 0x100A;
        public static inline var MIN_GAIN : Int                            = 0x100D;
        public static inline var MAX_GAIN : Int                            = 0x100E;
        public static inline var ORIENTATION : Int                         = 0x100F;
        public static inline var SOURCE_STATE : Int                        = 0x1010;
        public static inline var INITIAL : Int                             = 0x1011;
        public static inline var PLAYING : Int                             = 0x1012;
        public static inline var PAUSED : Int                              = 0x1013;
        public static inline var STOPPED : Int                             = 0x1014;
        public static inline var BUFFERS_QUEUED : Int                      = 0x1015;
        public static inline var BUFFERS_PROCESSED : Int                   = 0x1016;
        public static inline var REFERENCE_DISTANCE : Int                  = 0x1020;
        public static inline var ROLLOFF_FACTOR : Int                      = 0x1021;
        public static inline var CONE_OUTER_GAIN : Int                     = 0x1022;
        public static inline var MAX_DISTANCE : Int                        = 0x1023;
        public static inline var SEC_OFFSET : Int                          = 0x1024;
        public static inline var SAMPLE_OFFSET : Int                       = 0x1025;
        public static inline var BYTE_OFFSET : Int                         = 0x1026;
        public static inline var SOURCE_TYPE : Int                         = 0x1027;
        public static inline var STATIC : Int                              = 0x1028;
        public static inline var STREAMING : Int                           = 0x1029;
        public static inline var UNDETERMINED : Int                        = 0x1030;
        public static inline var FORMAT_MONO8 : Int                        = 0x1100;
        public static inline var FORMAT_MONO16 : Int                       = 0x1101;
        public static inline var FORMAT_STEREO8 : Int                      = 0x1102;
        public static inline var FORMAT_STEREO16 : Int                     = 0x1103;
        public static inline var FREQUENCY : Int                           = 0x2001;
        public static inline var BITS : Int                                = 0x2002;
        public static inline var CHANNELS : Int                            = 0x2003;
        public static inline var SIZE : Int                                = 0x2004;
        public static inline var NO_ERROR : Int                            = 0;
        public static inline var INVALID_NAME : Int                        = 0xA001;
        public static inline var INVALID_ENUM : Int                        = 0xA002;
        public static inline var INVALID_VALUE : Int                       = 0xA003;
        public static inline var INVALID_OPERATION : Int                   = 0xA004;
        public static inline var OUT_OF_MEMORY : Int                       = 0xA005;
        public static inline var VENDOR : Int                              = 0xB001;
        public static inline var VERSION : Int                             = 0xB002;
        public static inline var RENDERER : Int                            = 0xB003;
        public static inline var EXTENSIONS : Int                          = 0xB004;


        public static inline var DOPPLER_FACTOR:Int                        = 0xC000;
        public static inline var SPEED_OF_SOUND:Int                        = 0xC003;
        public static inline var DOPPLER_VELOCITY:Int                      = 0xC001;

        public static inline var DISTANCE_MODEL:Int                        = 0xD000;
        public static inline var INVERSE_DISTANCE:Int                      = 0xD001;
        public static inline var INVERSE_DISTANCE_CLAMPED:Int              = 0xD002;
        public static inline var LINEAR_DISTANCE:Int                       = 0xD003;
        public static inline var LINEAR_DISTANCE_CLAMPED:Int               = 0xD004;
        public static inline var EXPONENT_DISTANCE:Int                     = 0xD005;
        public static inline var EXPONENT_DISTANCE_CLAMPED:Int             = 0xD006;

} //AL


@:include('linc_openal.h')
#if !display
@:build(linc.Linc.touch())
#end
extern class ALC {

// contexts

        @:native('linc::openal::createContext')
    public static function createContext(device:Device, ?attrlist:Array<Int>) : Context;
        @:native('alcMakeContextCurrent')
    public static function makeContextCurrent(context:Context) : Bool;
        @:native('alcProcessContext')
    public static function processContext(context:Context) : Void;
        @:native('alcSuspendContext')
    public static function suspendContext(context:Context) : Void;
        @:native('alcDestroyContext')
    public static function destroyContext(context:Context) : Void;
        @:native('alcGetCurrentContext')
    public static function getCurrentContext() : Context;
        @:native('alcGetContextsDevice')
    public static function getContextsDevice(context:Context) : Device;

// android
#if android

        @:native('linc::openal::androidSuspend')
    public static function androidSuspend() : Void;
        @:native('linc::openal::androidResume')
    public static function androidResume() : Void;

#end

// devices

        @:native('alcOpenDevice')
    public static function openDevice(?devicename:String) : Device;
        @:native('alcCloseDevice')
    public static function closeDevice(device:Device) : Bool;
        @:native('alcGetError')
    public static function getError(device:Device) : Int;
        @:native('alcGetString')
    public static function getString(device:Device, param:Int) : String;
        @:native('alcGetIntegerv')
    public static function getIntegerv(device:Device, param:Int, size:Int) : Array<Int>;

//defines

    public static inline var FALSE : Int                           = 0;
    public static inline var TRUE : Int                            = 1;
    public static inline var FREQUENCY : Int                       = 0x1007;
    public static inline var REFRESH : Int                         = 0x1008;
    public static inline var SYNC : Int                            = 0x1009;
    public static inline var MONO_SOURCES : Int                    = 0x1010;
    public static inline var STEREO_SOURCES : Int                  = 0x1011;
    public static inline var NO_ERROR : Int                        = 0;
    public static inline var INVALID_DEVICE : Int                  = 0xA001;
    public static inline var INVALID_CONTEXT : Int                 = 0xA002;
    public static inline var INVALID_ENUM : Int                    = 0xA003;
    public static inline var INVALID_VALUE : Int                   = 0xA004;
    public static inline var OUT_OF_MEMORY : Int                   = 0xA005;
    public static inline var ATTRIBUTES_SIZE : Int                 = 0x1002;
    public static inline var ALL_ATTRIBUTES : Int                  = 0x1003;
    public static inline var DEFAULT_DEVICE_SPECIFIER : Int        = 0x1004;
    public static inline var DEVICE_SPECIFIER : Int                = 0x1005;
    public static inline var EXTENSIONS : Int                      = 0x1006;

    public static inline var ENUMERATE_ALL_EXT : Int               = 1;
    public static inline var DEFAULT_ALL_DEVICES_SPECIFIER : Int   = 0x1012;
    public static inline var ALL_DEVICES_SPECIFIER : Int           = 0x1013;

} //ALC


//Convenience classes


    /** A convenience class for finding out the value of an AL error code. */
class ALError {

    public static var INVALID_NAME : String             = "AL.INVALID_NAME: Invalid parameter name";
    public static var INVALID_ENUM : String             = "AL.INVALID_ENUM: Invalid enum value";
    public static var INVALID_VALUE : String            = "AL.INVALID_VALUE: Invalid parameter value";
    public static var INVALID_OPERATION : String        = "AL.INVALID_OPERATION: Illegal operation or call";
    public static var OUT_OF_MEMORY : String            = "AL.OUT_OF_MEMORY: OpenAL has run out of memory";

    public static function desc( error:Int ) : String {

        if(error == AL.INVALID_NAME)       {  return INVALID_NAME;  }
        if(error == AL.INVALID_ENUM)       {  return INVALID_ENUM;  }
        if(error == AL.INVALID_VALUE)      {  return INVALID_VALUE;  }
        if(error == AL.INVALID_OPERATION)  {  return INVALID_OPERATION;  }
        if(error == AL.OUT_OF_MEMORY)      {  return OUT_OF_MEMORY;  }

        return "AL.NO_ERROR: No Error";

    } //desc

} //ALError


    /** A convenience class for finding out the value of an ALC error code. */
class ALCError {

    public static var NO_ERROR        = "ALC.NO_ERROR: No Error";
    public static var INVALID_DEVICE  = "ALC.INVALID_DEVICE: Invalid device (or no device?)";
    public static var INVALID_CONTEXT = "ALC.INVALID_CONTEXT: Invalid context (or no context?)";
    public static var INVALID_ENUM    = "ALC.INVALID_ENUM: Invalid enum value";
    public static var INVALID_VALUE   = "ALC.INVALID_VALUE: Invalid param value";
    public static var OUT_OF_MEMORY   = "ALC.OUT_OF_MEMORY: OpenAL has run out of memory";
    public static var UNKNOWN_ERROR   = "ALC.NO_ERROR: Unknown Error";

    public static function desc(error:Int) : String {

        return switch(error) {
            case ALC.INVALID_DEVICE:   INVALID_DEVICE;
            case ALC.INVALID_CONTEXT:  INVALID_CONTEXT;
            case ALC.INVALID_ENUM:     INVALID_ENUM;
            case ALC.INVALID_VALUE:    INVALID_VALUE;
            case ALC.OUT_OF_MEMORY:    OUT_OF_MEMORY;
            case ALC.NO_ERROR:         NO_ERROR;
            case _:                    '$UNKNOWN_ERROR ($error)';
        }

    } //desc

} //ALCError



//Internal

    @:native("ALCdevice")
    @:include('linc_openal.h')
    private extern class ALCdevice { }

    @:native("ALCcontext")
    @:include('linc_openal.h')
    private extern class ALCcontext {}
