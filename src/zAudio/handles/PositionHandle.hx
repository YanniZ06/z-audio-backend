package zAudio.handles;

import lime.math.Vector4;

//What was your point
/*enum abstract PositionReadInfo(String) from String to String {
    var X = "X__";
    var Y = "_Y_";
    var Z = "__Z";
    var XY = "XY_";
    var XZ = "X_Z";
    var YZ = "_YZ";
    var XYZ = "XYZ";
}*/

/**
 * An extremely simple handle for Sound positions formatted like a Vector which calls a function when any of its values is changed.
 */
class PositionHandle {
    /**
     * X position of this sound, default is 0.
     */
    public var x(default, set):Float;
    /**
     * Y position of this sound, default is 0.
     */
    public var y(default, set):Float;
    /**
     * Z position of this sound, default is 0.
     */
    public var z(default, set):Float;

    /**
     * Function to call whenever the x, y or z values have been modified.
     * 
     * Takes in one float and one string-type parameter, representing the new value and which of the fields called it.
     * 
     * For example if you set the z value to 3 - 1, the parameters (2, "z") will be output.
     */
    public var onChange:Float -> String -> Void = null;
    public function new(?x:Float = 0.0, ?y:Float = 0.0, ?z:Float = 0.0) {
        onChange = (val:Float, type:String) -> {};

        this.x = x ?? 0.0;
        this.y = y ?? 0.0;
        this.z = z ?? 0.0;
    }

    @:to public function toVector():Vector4 { return new Vector4(x, y, z, 0); }

    /**
     * Clears this PositionHandle from memory.
     */
    public function destroy():Void {
        onChange = null;
    }
    /*@:noCompletion private inline function disposeDefaults():Void {

    }*/

    function set_x(v:Float):Float {
        x = v;
        onChange(v, "x");
        return v;
    }
    function set_y(v:Float):Float {
        y = v;
        onChange(v, "y");
        return v;
    }
    function set_z(v:Float):Float {
        z = v;
        onChange(v, "z");
        return v;
    }
}