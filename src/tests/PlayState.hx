package tests;

import lime.media.openal.AL;
import zAudio.handles.BufferHandle;
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
	var snd2:ZSound;
	override public function create()
	{
		super.create();
		var soundInfo = SoundLoader.fromFile("assets/snd/wavTest.wav");
		// trace(soundInfo);
		snd = new ZSound(soundInfo);

		snd2 = new ZSound(SoundLoader.fromFile("assets/snd/never_forgetting.ogg"));
		//snd2.time = snd2.length - 40;
		snd2.reversed = true;
		snd2.time = 6000;
		snd2.play();
		new FlxTimer().start(6, _ -> snd2.destroy());

		/*var buffer = new BufferHandle(AL.createBuffer());

		trace(snd.buffer.reverseData);
		buffer.fill(snd.buffer.channels, snd.buffer.bitsPerSample, snd.buffer.reverseData, snd.buffer.sampleRate, false);
		snd2 = new ZSound(buffer);
		snd2.play();*/
		
		/*new FlxTimer().start(15, (_) -> {
			snd.destroy();
			snd = null;
			SoundHandler.clear_bufferCache();
		});*/

		/*var snd_ = new FlxSound().loadEmbedded(Sound.fromFile("assets/snd/inspected.ogg"));
		snd_.play();

		var tmr:haxe.Timer = new haxe.Timer(100);
		tmr.run = () -> snd_.stop();*/
	}

	//This is scuffy ik but i need to QUICKLY test
	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if(FlxG.keys.justPressed.C) {
			SoundHandler.clear_bufferCache();
			trace("CACHE HAS BEEN CLEARED!");
		}
		if(snd == null) return;
		FlxG.watch.addQuick("Initialized:", snd.initialized);
		if(!snd.initialized) return;

		FlxG.watch.addQuick("Sound Time:", snd.time);
		FlxG.watch.addQuick("Pitch:", snd.pitch);
		FlxG.watch.addQuick("Length:", snd.length);
		@:privateAccess FlxG.watch.addQuick("Done Playing:", snd.finished || snd.finishedReverse);
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
		if(FlxG.keys.justPressed.R) {
			snd.reversed = !snd.reversed;
		}
		if(FlxG.keys.justPressed.K) {
			snd.destroy();
			trace("SOUND HAS BEEN DESTROYED!");
		}
	}
}
