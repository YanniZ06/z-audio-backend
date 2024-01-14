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

        EFX.deleteEffects(fxCleanQuery.length, BinderHelper.arrayEffect_ToPtr(fxCleanQuery));
        fxCleanQuery = []; 
    }

    /**
     * Clears all queried filters.
     */
    public inline function clearFilterQuery():Void {
        if(!Initializer.supports_EFX) return;

        EFX.deleteFilters(filterCleanQuery.length, BinderHelper.arrayFilter_ToPtr(filterCleanQuery));
        filterCleanQuery = [];
    }

    /**
    * Clears all queried aux-slots.
    */
    public inline function clearAuxQuery():Void {
        if(!Initializer.supports_EFX) return;

        EFX.deleteAuxiliaryEffectSlots(auxCleanQuery.length, BinderHelper.arrayAuxiliaryEffectSlot_ToPtr(auxCleanQuery));
        auxCleanQuery = [];
    }

    /**
     * Clears all queried buffers.
     */
    public inline function clearBufferQuery():Void {
        AL.deleteBuffers(bufferCleanQuery.length, BinderHelper.arrayBuffer_ToPtr(bufferCleanQuery));
        bufferCleanQuery = [];
    }

    /**
     * Clears all queried sources.
     */
    public inline function clearSrcQuery():Void {
        AL.deleteSources(srcCleanQuery.length, BinderHelper.arraySource_ToPtr(srcCleanQuery));
        srcCleanQuery = [];
    }

    /**
     * Clears all queried objects.
     */
    public inline function clearFullQuery():Void {
        AL.deleteBuffers(bufferCleanQuery.length, BinderHelper.arrayBuffer_ToPtr(bufferCleanQuery));
        AL.deleteSources(srcCleanQuery.length, BinderHelper.arraySource_ToPtr(srcCleanQuery));

        if(!Initializer.supports_EFX) { bufferCleanQuery = srcCleanQuery = []; return; }

        EFX.deleteEffects(fxCleanQuery.length, BinderHelper.arrayEffect_ToPtr(fxCleanQuery));
        EFX.deleteFilters(filterCleanQuery.length, BinderHelper.arrayFilter_ToPtr(filterCleanQuery));
        EFX.deleteAuxiliaryEffectSlots(auxCleanQuery.length, BinderHelper.arrayAuxiliaryEffectSlot_ToPtr(auxCleanQuery));
        bufferCleanQuery = srcCleanQuery =  fxCleanQuery = filterCleanQuery = auxCleanQuery = [];
    }
}