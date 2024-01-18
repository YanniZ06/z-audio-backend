# ZAudio Backend
An audio backend for Haxe Applications with support for various effects and methods of audio manipulation.
Offers semi-decent memory control and is able to decode WAVE, OGG-Vorbis and MP3 files.

## Installation
For this library to work, the user must have openal-soft-1.23.1 installed on their PC.

First you need to install OpenAL from this site (https://www.openal.org/downloads/), using the provided installer.
This will put a file named "OpenAL32.dll" into your system directory (on 64-Bit windows thats usually system32).

Then Grab the dll from this site (https://github.com/YanniZ06/HaxeAL-Soft/blob/initial-release/source/openal/libs/x64/OpenAL32.dll) and drag it into whichever folder the installer placed the original OpenAL32.dll file in, to replace said OpenAL32.dll file with the one provided in the link above.

If you've done everything correctly the library should now work fine.
Of course this is quite a hassle, so it's best you write a quick installer that takes care of this process for the user.

## Additional Compiling Instructions
The "linc_ogg" library must be installed to compile. You can do so via "haxelib git linc_ogg https://github.com/snowkit/linc_ogg.git". (Will be added as a req later aswell)
For testing in its current state you also need to install flixel 5.2.2, lime 8.0.1 and openfl 9.2.1 (along with haxe 4.3.0)

## Progress and Features
This library isn't finished yet, so here's seperate progress reports and current features!

### General Sound Playback: 100%
- Sounds with full PCM-Data can be played back reguarly, in reverse, with any effect or filter applied etc.

### Sound Decoding: 90%
- WAV and MP3 can be decoded
- OGG is being implemented

### Documentation: 86%
- A bunch of stuff still needs to be documented properly
-> Include Code that has yet to be written.

### Sound Effects Porting: 51%
- The main implementation finally works completely as it should
- Filters are completely ported

### Streamed Sound Playback: 6%
- The broad idea is there, implementation following very VERY soon

### Microphone Support: 0%
- Microphone recording and playback support ARE planned, however really low on priority list right now. They will be added eventually that's given!
