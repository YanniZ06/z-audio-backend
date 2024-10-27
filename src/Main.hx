package;

import flixel.FlxGame;
import haxeal.*;
import openfl.display.Sprite;
import zAudio.manager.Initializer;
import zAudio.manager.SoundSettings;

class Main extends Sprite
{
	public function new()
	{
		super();
		Initializer.preInitialize_AL();
		SoundSettings.globalVolume = 0.5;
		Initializer.initialize_ZAudio();

		flixel.FlxG.autoPause = false;
		addChild(new FlxGame(0, 0, tests.PlayState, 120, 120));
	}

}
