package zAudio.manager.mem;

import haxeal.bindings.AL;
import haxeal.bindings.EFX;
import haxeal.bindings.BinderHelper;

/**
 * Represents the cache of objects queried for deletion.
 * 
 * Accessed over `CacheHandler.queryCache`.
 */
class QueryCache {
    /**
     * List of ALEffects queried for clearing.
     */
    public var fxCleanQuery:Array<ALEffect> = [];

    /**
     * List of ALFilters queried for clearing.
     */
    public var filterCleanQuery:Array<ALFilter> = [];

    /**
     * List of ALBuffers queried for clearing.
     */
    public var bufferCleanQuery:Array<ALBuffer> = [];

    /**
     * List of ALSources queried for clearing.
     */
    public var srcCleanQuery:Array<ALSource> = [];

    /**
     * List of ALAuxSlots queried for clearing.
     */
    public var auxCleanQuery:Array<ALAuxSlot> = [];

    public function new() {}
    
    /**
     * Clears all queried effects.
     */
    public inline function clearFXQuery():Void {
        if(!Initializer.supports_EFX) return;

        HaxeEFX.deleteEffects(fxCleanQuery);
        fxCleanQuery = []; 
    }

    /**
     * Clears all queried filters.
     */
    public inline function clearFilterQuery():Void {
        if(!Initializer.supports_EFX) return;

        HaxeEFX.deleteFilters(filterCleanQuery);
        filterCleanQuery = [];
    }

    /**
    * Clears all queried aux-slots.
    */
    public inline function clearAuxQuery():Void {
        if(!Initializer.supports_EFX) return;

        HaxeEFX.deleteAuxiliaryEffectSlots(auxCleanQuery);
        auxCleanQuery = [];
    }

    /**
     * Clears all queried buffers.
     */
    public inline function clearBufferQuery():Void {
        HaxeAL.deleteBuffers(bufferCleanQuery);
        bufferCleanQuery = [];
    }

    /**
     * Clears all queried sources.
     */
    public inline function clearSrcQuery():Void {
        HaxeAL.deleteSources(srcCleanQuery);
        srcCleanQuery = [];
    }

    /**
     * Clears all queried objects.
     */
    public inline function clearFullQuery():Void {
        HaxeAL.deleteBuffers(bufferCleanQuery);
        HaxeAL.deleteSources(srcCleanQuery);

        if(!Initializer.supports_EFX) { bufferCleanQuery = srcCleanQuery = []; return; }

        HaxeEFX.deleteEffects(fxCleanQuery);
        HaxeEFX.deleteFilters(filterCleanQuery);
        HaxeEFX.deleteAuxiliaryEffectSlots(auxCleanQuery);
        bufferCleanQuery = srcCleanQuery =  fxCleanQuery = filterCleanQuery = auxCleanQuery = [];
    }
}