package tests;

import openfl.media.Sound;
import flixel.system.ui.FlxSoundTray;
import flixel.system.FlxAssets.FlxSoundAsset;
import flixel.system.FlxSound;
import flixel.FlxState;
import zAudio.SoundLoader;
import zAudio.Sound as ZSound;

class PlayState extends FlxState
{
	override public function create()
	{
		super.create();
		var soundInfo = SoundLoader.fromFile("assets/snd/inspected.ogg");
		// trace(soundInfo);
		var snd = new ZSound(soundInfo);
		snd.play();

		//TODO: IMPORTANT, MAKE A TIMER FOR SOUND THAT GOES THE EXACT LENGTH AMOUNT OF TIME TO PREVENT THE SOURCE FROM RANDOMLY STOPPING PLAYBACK???? THIS SHIT IS SO WEIRD
		var timr:haxe.Timer = new haxe.Timer(80000);
		timr.run = () -> {
			trace("finished 80 second timer");
			timr.stop();

			if (!snd.isSourcePlaying()) { 
				snd.play();
				trace("WTFFF!!!");
			}
		};

		/*var snd_ = new FlxSound().loadEmbedded(Sound.fromFile("assets/snd/inspected.ogg"));
		snd_.play();

		var tmr:haxe.Timer = new haxe.Timer(100);
		tmr.run = () -> snd_.stop();*/
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
