package zAudio;

class AL_EFX extends AL {
    //this probably extends AL or someshit i dont know
    static var efx_functions:EFX_Container = new EFX_Container();

    public static function loadEFX() {
        var efxExtAvailable:Bool = false;

        if (al.isExtensionPresent("ALC EXT EFX"))
            efxExtAvailable = true;

        trace(efxExtAvailable);

        if (efxExtAvailable) {
            efx_functions.genEffects = cast(AL.getProcAddress("alGenEffects"), (Int, Int)->Void);
            efx_functions.deleteEffects = cast(al.getProcAddress("alDeleteEffects"), (Int, Int)->Void);
            efx_functions.genFilters = cast(al.getProcAddress("alGenFilters"), (Int, Int)->Void);
            efx_functions.deleteFilters = cast(al.getProcAddress("alDeleteFilters"), (Int, Int)->Void);
        }
    }

    public static function createEffect():AL_Identifier {
        var effect:Int;
        efx_functions.genEffects(1, effect);
        return new AL_Identifier(effect);
    }

    public static function deleteEffect(effect:AL_Identifier):Void {
        efx_functions.deleteEffects(1, effect.value);
        effect = null;
    }
}

class EFX_Container {
    public function new() {}

    public var genEffects:Int->Int->Void = (numEffects, effectID) -> {};
    public var deleteEffects:Int->Int->Void = (numEffects, effectID) -> {};
    public var genFilters:Int->Int->Void = (numFilters, filterID) -> {};
    public var deleteFilters:Int->Int->Void = (numFilters, filterID) -> {};
}

/**
 * An AL ID, used for Effects, Filters and more to prevent accidentally using wrong
 */
class AL_Identifier {
    /**
     * The actual integer value representation of this ID.
     */
    public var value:Int;

    public function new(id:Int) value = id;
}