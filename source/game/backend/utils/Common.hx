package game.backend.utils;

import sys.thread.Thread;
import objects.tiles.ArrowTile;
import sys.thread.Thread;
import sys.io.File;
import sys.FileSystem;
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

    public static final TRANSITION_TIME:Float = 1;
    public static function switchState(state:FlxState, ?transIn){}

    public static function initialize():Void {
        loadUser();
    }

    public static function loadUser():Void {
        if (PLAYER != null) {
            trace("User are already logged in!");
            return;
        }

        // For testing purposes
        PLAYER = {
            id: 1,
            username: "corecathx",
            display: "CoreCat",
            profile_url: 'https://cdn.discordapp.com/avatars/694791036094119996/08795150028fbab041c2cc9359bc5e43.png?size=1024' 
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