package zAudio.fx;

import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;

using haxe.macro.ExprTools;
using StringTools;

class FXPropertyGenMacro {
    /**
     * Used as a build macro for FX classes.
     * 
     * Will target any variable type field annotated with the @fxParam metadata and automatically generate a setter for that field.
     * 
     * The setter includes changing the effect value the field is tied to by grabbing the fxParam ID from the annotated metadatas first argument.
     * 
     * Example: @fxParam(ReverbParam.REVERB_DENSITY) var density:Float = 0.89;
     */
    public static macro function genFxParams():Array<haxe.macro.Field> {
		var fields:Array<Field> = Context.getBuildFields();
        final cName = Context.getLocalClass().get().name;
		final formattedCName = cName.toUpperCase().replace('FX', '');

		for (field in fields) {
			if (field.kind.getName() != 'FVar')
				continue; // Safety measure against my own stupidity

			var ignoreField:Bool = true;
			var fxID:Int = 0;//String: '${formattedCName}_${field.name.toUpperCase()}'; // examp: REVERB_DIFFUSION

			for (data in field.meta) {
				if (data.name != 'fxParam')
					continue;
				ignoreField = false; // Hooray, our field has the fxParam annotation
                if(data.params == null || data.params.length < 1) 
                    throw 'COMPILING ERROR(NOT ENOUGH ARGUMENTS): fxParam optional parameter "effectIdName" expects singular int fx param type input. (Given Input: ${data.params})'; 
				try { 
					fxID = cast(data.params[0].expr.getParameters()[0], Constant).getParameters()[0];
				} catch (e) {
					throw 'COMPILING ERROR($e): fxParam optional parameter "effectIdName" expects singular int fx param type input. (Given Input: ${data.params})'; 
                    // It appears you can actually input almost anything, keeping this here anyways lol
				}
			}
			if (ignoreField)
				continue;

			final fName:String = 'set_${field.name}';
			final type = cast(field.kind.getParameters()[0], ComplexType).getParameters()[0].name;
			var func = macro function $fName(val : Dynamic):Dynamic {
				$i{field.name} = val;
                $i{'changeParam'}($v{fxID}, val); //Very trippy
				return val;
			};

			// I happened to switch to patterns here just to spare me the constant parameter getting.
			var rawFunction:Function = func.expr.getParameters()[1];
			switch (rawFunction.ret) { // Turn return type to proper type
				case TPath(pth):
					pth.name = type;
				default:
			}
			switch (rawFunction.args[0].type) { // Turn setter argument type to proper type
				case TPath(pth):
					pth.name = type;
				default:
			}

            var setAccess = field.access.copy();
            if(setAccess != null) setAccess.remove(APublic); //Avoid it showing up on vsCode completion
			final funcField:Field = {
				name: fName,
				kind: FFun(rawFunction),
				pos: Context.currentPos(), // This will do
				access: setAccess
			};

			fields.push(funcField);

			final oldkind = field.kind;
			field.kind = FProp('default', 'set', oldkind.getParameters()[0], oldkind.getParameters()[1]);
		}
		return fields;
	}

}