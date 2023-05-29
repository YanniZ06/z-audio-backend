package zAudio.handles;

class BufferHandle
{
	public var handle:ALBuffer = null;

	public function new(buffer:ALBuffer) {
		handle = buffer;
	}
}
