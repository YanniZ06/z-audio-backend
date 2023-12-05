package tests;

import cpp.vm.Gc;
import flixel.FlxG;
import flixel.FlxState;
import flixel.system.FlxAssets.FlxSoundAsset;
// import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import openfl.media.Sound;
import zAudio.Sound as ZSound;
import zAudio.SoundLoader;
import zAudio.al_handles.BufferHandle;
import zAudio.manager.*;

class PlayState extends FlxState
{
	var snd:ZSound;
	var snd2:ZSound;
	override public function create()
	{

		super.create();
		/*var soundInfo = SoundLoader.fromFile("assets/snd/wavTest.wav", true);
		// trace(soundInfo);
		snd2 = new ZSound(soundInfo);
		snd2.time = 6000;
		//snd2.play();
		new FlxTimer().start(6, _ -> CacheHandler.removeFromMemory(snd2));*/

		snd = new ZSound(SoundLoader.fromFile("assets/snd/michealMp3.mp3"));
		snd.bandpass.enabled = false;
		snd.bandpass.gain_lf = 0.1;
		snd.maxVolume = 10;
		snd.looping = true;
		snd.reverb.enabled = true;

		//snd.position.x = 80;

		function loop_low() { //loops bandpass filter weewooo
			var twn:FlxTween;
			twn = FlxTween.tween(snd, {"bandpass.gain_hf": 0.1, "bandpass.gain_lf": 1}, 2, {onComplete: (_) -> {
				twn = FlxTween.tween(snd, {"bandpass.gain_hf": 1, "bandpass.gain_lf": 0.1}, 2, {onComplete: (_) -> loop_low()});
			}});
		}
		//loop_low();

		//snd.time = snd.length - (10000);
		//snd2.time = snd2.length - 40;

		/*var buffer = new BufferHandle(HaxeAL.createBuffer());

		trace(snd.buffer.reverseData);
		buffer.fill(snd.buffer.channels, snd.buffer.bitsPerSample, snd.buffer.reverseData, snd.buffer.sampleRate, false);
		snd2 = new ZSound(buffer);
		snd2.play();*/
		
		/*new FlxTimer().start(15, (_) -> {
			snd.destroy();
			snd = null;
			CacheHandler.clear_bufferCache();
		});*/

		/*var snd_ = new FlxSound().loadEmbedded(Sound.fromFile("assets/snd/inspected.ogg"));
		snd_.play();*/

		/*var tmr:haxe.Timer = new haxe.Timer(100);
		tmr.run = () -> snd_.stop();*/
	}

	var gcActive:Bool = false;
	//This is scuffy ik but i need to QUICKLY test
	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if(FlxG.keys.justPressed.C) {
			CacheHandler.clear_bufferCache();
			trace("CACHE HAS BEEN CLEARED!");
		}
		if(FlxG.keys.justPressed.M) {
			trace("GC CALLED!!!");
			Gc.enable(!gcActive);
			Gc.run(true);
			Gc.compact();
			gcActive = !gcActive;
			trace("GC ACTIVE: " + gcActive);
			trace('CURRENT MEMORY INFO:\n\nACTIVE SOUNDS: { ${CacheHandler.activeSounds} }\n\nEXISTING BUFFERS: { ${CacheHandler.existingBufferData} }');
		}
		if(snd == null) return;
		FlxG.watch.addQuick("Initialized:", snd.initialized);
		if(!snd.initialized) return;

		FlxG.watch.addQuick("Sound Time:", snd.time);
		FlxG.watch.addQuick("Pitch:", snd.pitch);
		FlxG.watch.addQuick("Length:", snd.length);
		@:privateAccess FlxG.watch.addQuick("Done Playing:", snd.finished || snd.finishedReverse);
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
			snd.buffer.preloadReverseData();
			snd.reversed = !snd.reversed;
		}
		if(FlxG.keys.justPressed.L) {
			//snd.lowpass.gain_hf = Math.min(1, Math.max(0, snd.lowpass.gain_hf + ((0.033 * negMod) * mod)));
			//snd.reverb.enabled = !snd.reverb.enabled;
			//trace(SoundSettings.globalVolume);
			trace("GC INFO ZSOUND:");
			trace(Gc.trace(Type.getClass(snd)));
			trace("\n\nCURRENT FULL MEMORY: " + Gc.memInfo(Gc.MEM_INFO_CURRENT) + "\nRESERVED MEMORY: " + Gc.memInfo(Gc.MEM_INFO_RESERVED) + "\nNEEDED MEMORY: " + Gc.memInfo(Gc.MEM_INFO_USAGE));
		}
		if(FlxG.keys.justPressed.B) {
			//SoundSettings.globalVolume = Math.min(1, SoundSettings.globalVolume + 0.1);
			snd.reverb.decayTime = Math.min(5, Math.max(0, snd.reverb.decayTime + ((0.1 * negMod) * mod)));
			FlxG.watch.addQuick("Reverbed DecayTime:", snd.reverb.decayTime);
		}
		if(FlxG.keys.justPressed.NUMPADMINUS) {
			//SoundSettings.globalVolume = Math.max(0, SoundSettings.globalVolume - 0.1);
		}
		if(FlxG.keys.justPressed.K) {
			FlxTween.cancelTweensOf(snd);
			CacheHandler.removeFromMemory(snd, true);
			snd = null;
			//CacheHandler.removeReverseCacheFrom(snd.cacheAddress);
			trace("SOUND HAS BEEN DESTROYED!");
		}
	}
}
