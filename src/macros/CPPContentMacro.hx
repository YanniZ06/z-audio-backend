/*package macros;

import haxe.macro.Compiler;
import haxe.macro.TypeTools;
import haxe.macro.Context;
import sys.FileSystem;
import sys.io.File;

class CPPContentMacro {

*/
    /**
     * Used as a build macro, give a file from the cpp folder as an argument to insert
     * 
     * I just wanted to show off with a fancy macro here because native code doesnt quite work and keeping
     * the cpp code in the same file as the MP3Decoder looked messy!!
     * 
     * @param file File in the cpp folder, without the .cpp extension
     */
    /*public static macro function insertFile(file:String):Array<haxe.macro.Expr.Field> {
        var fields = Context.getBuildFields();

        final path = './src/cpp/$file.cpp';
        if(!FileSystem.exists(path)) { trace('Couldnt find file "$file.cpp" in src/cpp!'); return fields; }

        var content = File.getContent(path);
        final contentM = macro content;

        Context.onGenerate((types -> {
            for(type in types) {
                switch(type) { //haxe.macro.Type.ClassType()
                    //case 2:
                }
            }
        }));
        var t_class = Context.getLocalClass();
        t_class.get().meta.add('cppNamespaceCode', [contentM], Context.currentPos()); // We insert the cpp code via cppNameSpaceCode - hopefully

        // Womp womp we dont!
        // Leaving this here for now

        trace(t_class.get().meta);

        return fields;
    }*/
//}