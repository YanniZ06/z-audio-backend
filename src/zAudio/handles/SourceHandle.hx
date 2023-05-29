package zAudio.handles;

/**
 * A handle for an `ALSource` object, handles aux and filter related properties for the `handle` ALSource type object.
 */
class SourceHandle
{
	public var handle:ALSource = null;
	public var connectedAux:Map<Int, AuxSlotHandle> = [];
	public var auxCount:Int = 0; // To determine which aux_filter to get rid of lol!!
	public var hasFilter:Bool = false;

	public function new(?hndl:ALSource)
	{
		handle = hndl;
	}

	public function onAuxRemove(id:Int)
	{
		connectedAux.remove(id);
		AL.removeSend(handle, id);

		for (id_ => aux in connectedAux)
		{
			if (id_ >= id)
				continue;

			connectedAux.remove(id_);
			aux.auxID = id_;
			connectedAux.set(id_ - 1, aux);
		}
		auxCount--;
	}
}
