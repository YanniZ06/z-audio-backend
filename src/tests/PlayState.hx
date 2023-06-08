package tests;

import zAudio.SoundHandler;
import flixel.util.FlxTimer;
import openfl.media.Sound;
import flixel.system.ui.FlxSoundTray;
import flixel.system.FlxAssets.FlxSoundAsset;
import flixel.system.FlxSound;
import flixel.FlxState;
import zAudio.SoundLoader;
import zAudio.Sound as ZSound;
import flixel.FlxG;

class PlayState extends FlxState
{
	var snd:ZSound;
	override public function create()
	{
		super.create();
		var soundInfo = SoundLoader.fromFile("assets/snd/wavTest.wav");
		// trace(soundInfo);
		snd = new ZSound(soundInfo);

		new FlxTimer().start(15, (_) -> {
			snd.destroy();
			snd = null;
			SoundHandler.clear_bufferCache();
		});

		/*var snd_ = new FlxSound().loadEmbedded(Sound.fromFile("assets/snd/inspected.ogg"));
		snd_.play();

		var tmr:haxe.Timer = new haxe.Timer(100);
		tmr.run = () -> snd_.stop();*/
	}

	//This is scuffy ik but i need to QUICKLY test
	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if(snd == null) return;
		FlxG.watch.addQuick("Initialized:", snd.initialized);
		if(!snd.initialized) return;

		FlxG.watch.addQuick("Sound Time:", snd.time);
		FlxG.watch.addQuick("Pitch:", snd.pitch);
		FlxG.watch.addQuick("Length:", snd.length);
		FlxG.watch.addQuick("Done Playing:", snd.finished);
		FlxG.watch.addQuick("Playing:", snd.playing);
		FlxG.watch.addQuick("Volume:", snd.volume);
		if(FlxG.keys.justPressed.S) snd.stop();
		if(FlxG.keys.justPressed.P) snd.pause();
		if(FlxG.keys.justPressed.SPACE) snd.play();

		var mod = FlxG.keys.pressed.SHIFT ? 3 : 1;
		var negMod = FlxG.keys.pressed.CONTROL ? -1 : 1;

		if(FlxG.keys.justPressed.A) {
			snd.time = snd.time + (1000 * (mod * negMod));
		}
		if(FlxG.keys.justPressed.D) {
			snd.pitch = Math.max(0, snd.pitch + (0.1 * (mod * negMod)));
		}
		if(FlxG.keys.justPressed.V) {
			snd.volume = Math.max(0, snd.volume + (0.1 * (mod * negMod)));
		}
	}
}
