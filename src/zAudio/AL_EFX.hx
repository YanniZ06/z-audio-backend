package zAudio;

/**
 * Class that handles AL EFX extension functions and documents them.
 * Run "AL_EFX.loadEFX()" on boot lol 
 */
class AL_EFX {
    static var efx_functions:EFX_Container = new EFX_Container();

    public static function loadEFX() {
        var efxExtAvailable:Bool = false;

        if (AL.isExtensionPresent("ALC EXT EFX"))
            efxExtAvailable = true;

        trace(efxExtAvailable);

        if (efxExtAvailable) {
            efx_functions.genEffects = cast(AL.getProcAddress("alGenEffects"), (Int, Int)->Void);
            efx_functions.deleteEffects = cast(AL.getProcAddress("alDeleteEffects"), (Int, Int)->Void);

            efx_functions.effecti = cast(AL.getProcAddress("alEffecti"), (Int, Int, Int)->Void);
            efx_functions.getEffecti = cast(AL.getProcAddress("alGetEffecti"), (Int, Int, Int)->Void);
            efx_functions.effectf = cast(AL.getProcAddress("alEffectf"), (Int, Int, Float)->Void);
            efx_functions.getEffectf = cast(AL.getProcAddress("alGetEffectf"), (Int, Int, Float)->Void);
            efx_functions.effectiv = cast(AL.getProcAddress("alEffectiv"), (Int, Int, Array<Int>)->Void);
            efx_functions.getEffectiv = cast(AL.getProcAddress("alGetEffectiv"), (Int, Int, Array<Int>)->Void);
            efx_functions.effectfv = cast(AL.getProcAddress("alEffectfv"), (Int, Int, Array<Float>)->Void);
            efx_functions.getEffectfv = cast(AL.getProcAddress("alGetEffectfv"), (Int, Int, Array<Float>)->Void);


            efx_functions.genFilters = cast(AL.getProcAddress("alGenFilters"), (Int, Int)->Void);
            efx_functions.deleteFilters = cast(AL.getProcAddress("alDeleteFilters"), (Int, Int)->Void);

            efx_functions.filteri = cast(AL.getProcAddress("alFilteri"), (Int, Int, Int)->Void);
            efx_functions.getFilteri = cast(AL.getProcAddress("alGetFilteri"), (Int, Int, Int)->Void);
            efx_functions.filterf = cast(AL.getProcAddress("alFilterf"), (Int, Int, Float)->Void);
            efx_functions.getFilterf = cast(AL.getProcAddress("alGetFilterf"), (Int, Int, Float)->Void);
            efx_functions.filteriv = cast(AL.getProcAddress("alFilteriv"), (Int, Int, Array<Int>)->Void);
            efx_functions.getFilteriv = cast(AL.getProcAddress("alGetFilteriv"), (Int, Int, Array<Int>)->Void);
            efx_functions.filterfv = cast(AL.getProcAddress("alFilterfv"), (Int, Int, Array<Float>)->Void);
            efx_functions.getFilterfv = cast(AL.getProcAddress("alGetFilterfv"), (Int, Int, Array<Float>)->Void);
        }
    }

    /*
        About the documenting style:
        Effects and Filters are sorted seperately.
        Each category starts with a number in parenthesis and what it contains, like:
        -- (1) TESTING FUNCTIONS --
        If a category has subcategories they're seperated by dots, like: (1.1)
        The end of each category is marked by the number in parenthesis standalone, like:
        -- (1) --
        This should make it easier to navigate the source hopefully, for any questions feel free to DM me anywhere!! :)
    */

    // -- EFFECTS -- //
    // -- (1) CREATION AND DELETION -- //

    /**
     * Creates an AL effect.
     * @return The AL effect ready for usage.
     */
    public static function createEffect():Int {
        var effect:Int;
        efx_functions.genEffects(1, effect);
        return effect;
    }

    /**
     * Deletes the given AL effect.
     * @param effect The effect to delete.
     */
    public static function deleteEffect(effect:Int):Void {
        efx_functions.deleteEffects(1, effect);
        effect = null;
    }

    // -- (1) -- //

    // -- (2) PARAMETER GETTING AND SETTING -- //
    // -- (2.1) SINGULAR VALUES -- //

    /**
     * Sets the integer value of the effect parameter `param` of `effect` to the given `value`.
     * @param effect The effect to modify.
     * @param param The parameter to modify.
     * @param value The value you want to assign to that parameter.
     */
    public static function effecti(effect:Int, param:Int, value:Int):Void
        efx_functions.effecti(effect, param, value);

    /**
     * Sets a float value of the effect parameter `param` of `effect` to the given `value`.
     * @param effect The effect to modify.
     * @param param The parameter to modify.
     * @param value The value you want to assign to that parameter.
     */
    public static function effectf(effect:Int, param:Int, value:Float):Void
        efx_functions.effectf(effect, param, value);

    /**
     * Gets the integer value of the effect parameter `param` of `effect`.
     * @param effect The effect to get the value from.
     * @param param The parameter whichs value you want.
     * @return The value of `param`.
     */
    public static function getEffecti(effect:Int, param:Int):Int {
        var retValue:Int = 0;
        efx_functions.getEffecti(effect, param, retValue);
        return retValue;
    }

    /**
     * Gets the float value of the effect parameter `param` of `effect`.
     * @param effect The effect to get the value from.
     * @param param The parameter whichs value you want.
     * @return The value of `param`.
     */
    public static function getEffectf(effect:Int, param:Int):Float {
        var retValue:Float = 0.0;
        efx_functions.getEffectf(effect, param, retValue);
        return retValue;
    }

    // -- (2.1) -- //
    // -- (2.2) MULTIPLE VALUES [ARRAYS] -- //

    /**
     * Sets multiple integer values of the effect parameter `param` of `effect` to the given `values`.
     * @param effect The effect to modify.
     * @param param The parameter to modify.
     * @param value The values you want to assign to that parameter.
     */
    public static function effectiv(effect:Int, param:Int, values:Array<Int>):Void
        efx_functions.effectiv(effect, param, values);

    /**
     * Sets multiple float values of the effect parameter `param` of `effect` to the given `values`.
     * @param effect The effect to modify.
     * @param param The parameter to modify.
     * @param value The values you want to assign to that parameter.
     */
    public static function effectfv(effect:Int, param:Int, values:Array<Float>):Void
        efx_functions.effectfv(effect, param, values);

    /**
     * Gets the integer values array of the effect parameter `param` of `effect`.
     * @param effect The effect to get the values from.
     * @param param The parameter whichs values you want.
     * @return The values of `param` in an Array.
     */
    public static function getEffectiv(effect:Int, param:Int):Array<Int> {
        var retValues:Array<Int> = [];
        efx_functions.getEffectiv(effect, param, retValues);
        return retValues;
    }

    /**
     * Gets the float values array of the effect parameter `param` of `effect`.
     * @param effect The effect to get the values from.
     * @param param The parameter whichs values you want.
     * @return The values of `param` in an Array.
     */
    public static function getEffectfv(effect:Int, param:Int):Array<Float> {
        var retValues:Array<Float> = [];
        efx_functions.getEffectfv(effect, param, retValues);
        return retValues;
    }

    // -- (2.2) -- //
    // -- (2) -- //
    // -- (END OF EFFECTS) -- //


    // -- FILTERS -- //
    // -- (1) CREATION AND DELETION -- //

    /**
     * Creates an AL filter.
     * @return The AL filter ready for usage.
     */
    public static function createFilter():Int {
        var filter:Int = 0;
        efx_functions.genFilters(1, filter);
        return filter;
    }

    /**
     * Deletes the given AL filter.
     * @param filter The filter to delete.
     */
    public static function deleteFilter(filter:Int):Void {
        efx_functions.deleteFilters(1, filter);
        filter = null;
    }

    // -- (1) -- //

    // -- (2) PARAMETER GETTING AND SETTING -- //
    // -- (2.1) SINGULAR VALUES -- //

    /**
     * Sets the integer value of the filter parameter `param` of `filter` to the given `value`.
     * @param filter The filter to modify.
     * @param param The parameter to modify.
     * @param value The value you want to assign to that parameter.
     */
    public static function filteri(filter:Int, param:Int, value:Int):Void
        efx_functions.filteri(filter, param, value);

    /**
     * Sets a float value of the filter parameter `param` of `filter` to the given `value`.
     * @param filter The filter to modify.
     * @param param The parameter to modify.
     * @param value The value you want to assign to that parameter.
     */
    public static function filterf(filter:Int, param:Int, value:Float):Void
        efx_functions.filterf(filter, param, value);

    /**
     * Gets the integer value of the filter parameter `param` of `filter`.
     * @param filter The filter to get the value from.
     * @param param The parameter whichs value you want.
     * @return The value of `param`.
     */
    public static function getFilteri(filter:Int, param:Int):Int {
        var retValue:Int = 0;
        efx_functions.getFilteri(filter, param, retValue);
        return retValue;
    }

    /**
     * Gets the float value of the filter parameter `param` of `filter`.
     * @param filter The filter to get the value from.
     * @param param The parameter whichs value you want.
     * @return The value of `param`.
     */
    public static function getFilterf(filter:Int, param:Int):Float {
        var retValue:Float = 0.0;
        efx_functions.getFilterf(filter, param, retValue);
        return retValue;
    }

    // -- (2.1) -- //
    // -- (2.2) MULTIPLE VALUES [ARRAYS] -- //

    /**
     * Sets multiple integer values of the filter parameter `param` of `filter` to the given `values`.
     * @param filter The filter to modify.
     * @param param The parameter to modify.
     * @param value The values you want to assign to that parameter.
     */
    public static function filteriv(filter:Int, param:Int, values:Array<Int>):Void
        efx_functions.filteriv(filter, param, values);

    /**
     * Sets multiple float values of the filter parameter `param` of `filter` to the given `values`.
     * @param filter The filter to modify.
     * @param param The parameter to modify.
     * @param value The values you want to assign to that parameter.
     */
    public static function filterfv(filter:Int, param:Int, values:Array<Float>):Void
        efx_functions.filterfv(filter, param, values);

    /**
     * Gets multiple integer values of the filter parameter `param` of `filter`.
     * @param filter The filter to get the values from.
     * @param param The parameter whichs values you want.
     * @return The values of `param` in an Array.
     */
    public static function getFilteriv(filter:Int, param:Int):Array<Int> {
        var retValues:Array<Int> = [];
        efx_functions.getFilteriv(filter, param, retValues);
        return retValues;
    }

    /**
     * Gets multiple float values of the filter parameter `param` of `filter`.
     * @param filter The filter to get the values from.
     * @param param The parameter whichs values you want.
     * @return The values of `param` in an Array.
     */
    public static function getFilterfv(filter:Int, param:Int):Array<Float> {
        var retValues:Array<Float> = [];
        efx_functions.getFilterfv(filter, param, retValues);
        return retValues;
    }

    // -- (2.2) -- //
    // -- (2) -- //
    // -- (END OF FILTERS) -- //
}

class EFX_Container { //storeAddress named params types = return types, return those values after calling function
    public function new() {}

    public var genEffects:Int->Int->Void = (numEffects, effectID) -> {};
    public var deleteEffects:Int->Int->Void = (numEffects, effectID) -> {};

    public var effecti:Int->Int->Int->Void = (effectID, param, value) -> {};
    public var getEffecti:Int->Int->Int->Void = (effectID, param, storeAddress) -> {};
    public var effectiv:Int->Int->Array<Int>->Void = (effectID, param, values) -> {};
    public var getEffectiv:Int->Int->Array<Int>->Void = (effectID, param, storeAddress) -> {};
    public var effectf:Int->Int->Float->Void = (effectID, param, value) -> {};
    public var getEffectf:Int->Int->Float->Void = (effectID, param, storeAddress) -> {};
    public var effectfv:Int->Int->Array<Float>->Void = (effectID, param, values) -> {};
    public var getEffectfv:Int->Int->Array<Float>->Void = (effectID, param, storeAddress) -> {};


    public var genFilters:Int->Int->Void = (numFilters, filterID) -> {};
    public var deleteFilters:Int->Int->Void = (numFilters, filterID) -> {};

    public var filteri:Int->Int->Int->Void = (filterID, param, value) -> {};
    public var getFilteri:Int->Int->Int->Void = (filterID, param, storeAddress) -> {};
    public var filteriv:Int->Int->Array<Int>->Void = (filterID, param, values) -> {};
    public var getFilteriv:Int->Int->Array<Int>->Void = (filterID, param, storeAddress) -> {};
    public var filterf:Int->Int->Float->Void = (filterID, param, value) -> {};
    public var getFilterf:Int->Int->Float->Void = (filterID, param, storeAddress) -> {};
    public var filterfv:Int->Int->Array<Float>->Void = (filterID, param, values) -> {};
    public var getFilterfv:Int->Int->Array<Float>->Void = (filterID, param, storeAddress) -> {};
}
