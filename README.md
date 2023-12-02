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

## Progress and Features
This library isn't finished yet, so here's seperate progress reports and current features!

### General Sound Playback: 100%
- Sounds with full PCM-Data can be played back reguarly, in reverse, with any effect or filter applied etc.

### Sound Decoding: 80%
- WAV and MP3 can be decoded
- OGG awaits re-implementation after getting rid of lime, shouldn't be too difficult however

### Documentation: 64%
- A bunch of stuff still needs to be documented properly
-> Include Code that has yet to be written.

### Sound Effects Porting: 49%
- The main implementation finally works completely as it should
- Filters are completely ported

### Streamed Sound Playback: 4%
- The broad idea is there, implementation following very soon

### Microphone Support: 0%
- Microphone recording and playback support ARE planned, however really low on priority list right now. They will be added eventually that's given!
