package game.backend.utils;

import states.IntroState;
import flixel.util.typeLimit.OneOfTwo;
import game.backend.script.ScriptState;
import game.backend.utils.IniParser.Ini;
import openfl.utils.ByteArray;
import objects.tiles.ArrowTile;
import objects.menu.Profile.User;

using StringTools;

typedef RGB = {
	var red:Int;
	var green:Int;
	var blue:Int;
}

class Common {
    /**
     * Default LineTapper Tile Color Data.
     */
    public static var DEFAULT_TILE_COLOR_DATA(get, null):MapTileColorData;
    static function get_DEFAULT_TILE_COLOR_DATA() {
        return {
            zero: {
                red: 255,
                green: 136,
                blue: 0
            },
            one: {
                red: 251,
                green: 255,
                blue: 0
            },
            two: {
                red: 0,
                green: 238,
                blue: 255
            },
            three: {
                red: 255,
                green: 0,
                blue: 255
            },
            fallback: {
                red: 255,
                green: 255,
                blue: 255
            }
        };
    }
    public static var PLAYER_PFP_DATA:ByteArray;
    /**
     * Converts a Boolean to an Integer.
     * 
     * Default return: 0 = false, 1 = true.
     * 
     * Flipped return: 1 = false, 0 = true.
     * 
     * @param v The bool that is converted.
     * @param f If the return value will be flipped.
     * @return Int
     */
    public static function intFromBool(v:Bool, f:Bool):Int
        return v ? f ? 0 : 1 : f ? 1 : 0;

    /**
     * Converts an Integer to a Floating Point Value.
     * @param v The int that is converted.
     * @return Float
     */
    public static function float(v:Int):Float
        return Std.parseFloat(Std.string(v));

    /**
     * Every supported Haxe file extensions (Used for Scripting.)
     */
    public static var HAXE_EXT:Array<String> = ["hx","hxs","hscript"];
    public static function checkHXS(filename:String) {
        for (i in HAXE_EXT)
            if (filename.endsWith(i)) return true;
        return false;
    }

    /**
     * Player's data.
     */
    public static var PLAYER:User = null;

    /**
	 * The name of the current theme.
	 */
    public static var CURRENT_THEME_NAME:String = 'Default';

    /**
	 * The .ini of the current theme.
	 */
    public static var CURRENT_THEME:Ini;

    public static final TRANSITION_TIME:Float = 1;
    public static function switchState(targetSectionOrState:OneOfTwo<String, FlxState>, ?arg:Dynamic = null, ?transIn:Bool = true)
    {
        if (Std.isOfType(targetSectionOrState, String)){
            if (CURRENT_THEME[targetSectionOrState] != null)
            {
                if (CURRENT_THEME[targetSectionOrState]['HX'] != 'default')
                {
                    var hxPath = '${Assets._THEME_ASSET_PATH}/${CURRENT_THEME[targetSectionOrState]['HX']}';
                    if (checkHXS(hxPath))
                    {
                        FlxG.switchState(new ScriptState(hxPath));
                    }else
                        trace('The script ($hxPath) was not a valid HScript extension, failed to switch states.');
                }else
                    targetSectionOrState == 'Main Menu' ? FlxG.switchState(new states.MenuState(cast arg)) : targetSectionOrState == 'Gameplay' ? FlxG.switchState(new states.PlayState()) : FlxG.switchState(new states.IntroState());
            }else
                trace('Section $targetSectionOrState does not exist, failed to switch states.');
        }else{
            if (Std.isOfType(targetSectionOrState, states.MenuState)){
                FlxG.switchState(new states.MenuState(cast arg));
                return;
            }

            var state:FlxState = cast targetSectionOrState;
            FlxG.switchState(state);
        }
    }

    /**
     * Get HH:MM:SS formatted time from miliseconds.
     * @param time The miliseconds to convert.
     * @return String
     */
    public static function formatMS(time:Float):String
    {
        var seconds:Int = Math.floor(time / 1000);
        var secs:String = '' + seconds % 60;
        var mins:String = "" + Math.floor(seconds / 60)%60;
        var hour:String = '' + Math.floor((seconds / 3600))%24; 
        if (seconds < 0)
            seconds = 0;
        if (time < 0)
            time = 0;

        if (secs.length < 2)
            secs = '0' + secs;

        var res:String = mins + ":" + secs;
        if (hour != "0"){
            if (mins.length < 2) mins = "0"+ mins;
            res = hour+":"+mins + ":" + secs;
        }
        return res;
    }
}