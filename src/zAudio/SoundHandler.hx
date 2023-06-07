package zAudio;

import lime.app.Application;
import lime.ui.Window;
import lime.media.AudioManager;
import lime._internal.backend.native.NativeApplication;

/**
 * Class responsible for global sound handling.
 */
class SoundHandler {
    //public static var activeSounds:Array<Sound> = [];
    /**
     * All generated Sounds that have not been destroyed mapped to their Pointer-Memory-Adress, only really used on the backend.
     */
    public static var existingSounds:Map<cpp.Pointer<Sound>, Sound> = [];
    /**
     * If true, audio playback is paused on every unfocused window (or just the main window if you only have one).
     * 
     * The playback resumes once the window has been focused.
     * 
     * It is highly recommended this is set to true if the rest of your application also pauses when a window is unfocused
     * to prevent audio desyncing.
     */
    private static inline var foc_lost_def:Bool = true;
	public static var focusLost_pauseSnd(default, set):Bool = foc_lost_def;

    private static var windowEvents:Map<String, Void -> Void> = [];

    /**
     * Sets up the zAudio backend, should be called on Main before starting your game
	 * and after all SoundHandler options have been set to your preferred choice.
     */
    public static function init() {

        //Initialize all settings on startup.
		if(focusLost_pauseSnd == foc_lost_def) change_focusLost_pauseSnd();
    }

    static function set_focusLost_pauseSnd(val:Bool):Bool {
		final changed:Bool = focusLost_pauseSnd == val;
		if (!changed) return val;
		focusLost_pauseSnd = val;

        change_focusLost_pauseSnd();
        return val;
    }
    private static function change_focusLost_pauseSnd() {
        @:privateAccess {
            switch(focusLost_pauseSnd) {
                case true:
                    for (window in Application.current.__windows) {
                        var onUnfocus:Void -> Void = () -> AudioManager.suspend();
                        windowEvents.set("pauseSnd__onUnfocus", onUnfocus);

                        var onFocus:Void -> Void = () -> AudioManager.resume();
                        windowEvents.set("pauseSnd__onFocus", onFocus);

                        window.onFocusOut.add(onUnfocus);
                        window.onFocusIn.add(onFocus);
                    }
                case false:
                    if(windowEvents["pauseSnd__onUnfocus"] == null) return;

                    for (window in Application.current.__windows) {
                        window.onFocusOut.remove(windowEvents["pauseSnd__onUnfocus"]);
                        windowEvents.remove("pauseSnd__onUnfocus");

                        window.onFocusIn.remove(windowEvents["pauseSnd__onFocus"]);
                        windowEvents.remove("pauseSnd__onFocus");
                    }
            }
        }
    }
}