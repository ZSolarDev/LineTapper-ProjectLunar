package backend.script;

import frontend.states.playstate.PlayState;
import flixel.FlxBasic;
import hscript.Interp;

class ScriptUtils {
    public static function trace(interp:Interp, fileName:String, data:Dynamic) {
        var posInfo = interp.posInfos();
		posInfo.className = "HScript - "+fileName+".hx";

		var lineNumber = Std.string(posInfo.lineNumber);
		var methodName = posInfo.methodName;
		var className = posInfo.className;
		trace('$fileName:$lineNumber: $data');
    }

    public static function getThemeAsset(section:String, key:String):String {
        if (Common.CURRENT_THEME == null)
            return themeErr("The current theme hasn't been initialized!");

        if (Common.CURRENT_THEME[section] == null)
            throw themeErr("Section " + section + " doesn't exist.");

        if (Common.CURRENT_THEME[section][key] == null)
            throw themeErr("Key " + key + " in section " + section + " doesn't exist.");

        return Common.CURRENT_THEME[section][key];
    }

    static function themeErr(str:String):String {
        trace(str);
        return 'embed/missingTexture.png';
    }

    public static function add(obj:FlxBasic)
    {
        PlayState.instance.add(obj);
    }
}