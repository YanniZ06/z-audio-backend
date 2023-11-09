package;

import flixel.FlxGame;
import openfl.display.Sprite;

import zAudio.ZAudioHandler.Initializer;
import zAudio.ZAudioHandler.SoundManager;

import haxeal.*;

class Main extends Sprite
{
	public function new()
	{
		super();
		Initializer.preInitialize_AL();
		SoundManager.globalVolume = 0.5;
		Initializer.initialize_ZAudio();

		flixel.FlxG.autoPause = false;
		addChild(new FlxGame(0, 0, tests.PlayState));
	}
}
