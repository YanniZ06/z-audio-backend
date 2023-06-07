package;

import zAudio.SoundHandler;
import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		SoundHandler.init();

		addChild(new FlxGame(0, 0, tests.PlayState));
	}
}
