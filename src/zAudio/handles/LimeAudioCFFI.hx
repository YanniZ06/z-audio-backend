package zAudio.handles;

import haxe.io.Bytes;
import lime.graphics.opengl.GLBuffer;
import lime.graphics.opengl.GLFramebuffer;
import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLRenderbuffer;
import lime.graphics.opengl.GLShader;
import lime.graphics.opengl.GLTexture;
import lime.graphics.Image;
import lime.graphics.ImageBuffer;
import lime.math.Rectangle;
import lime.media.openal.ALAuxiliaryEffectSlot;
import lime.utils.DataPointer;
#if (!lime_doc_gen || lime_cffi)
import lime.system.CFFI;
import lime.system.CFFIPointer;
#end
#if (cpp && !cppia)
import cpp.Float32;
#else
typedef Float32 = Float;
#end
#if (lime_doc_gen && !lime_cffi)
typedef CFFI = Dynamic;
typedef CFFIPointer = Dynamic;
#end

/**
 * Native Lime AL Bindings that are not present in NativeCFFI for odd reasons, just adds in efx deletion/cleanup capabilities
 */
#if !lime_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
#if (!macro && !lime_doc_gen)
#if (disable_cffi || haxe_ver < "3.4.0")
@:build(lime.system.CFFI.build())
#end
#end
class LimeAudioCFFI {
    //Structure:
    //#if (disable_cffi || haxe_ver < "3.4.0")
    //@:cffi private static function lime_al_func(param:Float):T;
    //#else
    //private static var lime_al_func = new cpp.Callable<cpp.Float->cpp.T>(cpp.Prime._loadPrime("lime", "lime_al_func", "ft", false));

    #if (lime_cffi && !macro && lime_openal)
	#if (cpp && !cppia)
	/*#if (disable_cffi || haxe_ver < "3.4.0")
    @:cffi private static function lime_al_delete_effect(effect:CFFIPointer):Void;
    #else*/
    public static var lime_al_delete_effect = new cpp.Callable<cpp.Object->cpp.Void>(cpp.Prime._loadPrime("lime", "lime_al_delete_effect", "ov", false));
    public static var lime_al_delete_filter = new cpp.Callable<cpp.Object->cpp.Void>(cpp.Prime._loadPrime("lime", "lime_al_delete_filter", "ov", false));
    public static var lime_al_delete_auxiliary_effect_slot = new cpp.Callable<cpp.Object->cpp.Void>(cpp.Prime._loadPrime("lime", "lime_al_delete_auxiliary_effect_slot", "ov", false));
    //#end
    #end
    #end
}