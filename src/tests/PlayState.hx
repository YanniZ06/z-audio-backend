package tests;

import flixel.FlxState;
import zAudio.SoundLoader;
import zAudio.Sound;

class PlayState extends FlxState
{
	override public function create()
	{
		super.create();
		trace(SoundLoader.fromFile("assets/snd/inspected.ogg"));
		var snd = new Sound(SoundLoader.fromFile("assets/snd/inspected.ogg"));
		snd.play();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
