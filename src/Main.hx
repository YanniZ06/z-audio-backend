package;

import lime.media.openal.AL;
import zAudio.SoundHandler;
import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		SoundHandler.init();
		trace(AL.getString(AL.VERSION));

		flixel.FlxG.autoPause = false;
		addChild(new FlxGame(0, 0, tests.PlayState));
	}
}
