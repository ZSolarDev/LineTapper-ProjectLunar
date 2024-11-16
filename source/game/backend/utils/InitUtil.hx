package game.backend.utils;

import openfl.net.URLRequest;
import openfl.events.IOErrorEvent;
import openfl.events.Event;
import openfl.net.URLLoader;
import game.backend.utils.IniParser.IniManager;

class InitUtil {
    public static function initTheme():Void {
        Common.CURRENT_THEME = IniManager.loadFromFile('themes/${Common.CURRENT_THEME_NAME}/theme.ini');
        Assets._THEME_ASSET_PATH = 'themes/${Common.CURRENT_THEME_NAME}';
    }

    public static function loadUser():Void {
        if (Common.PLAYER != null) {
            trace("User are already logged in!");
            return;
        }

        // For testing purposes
        Common.PLAYER = {
            id: 1,
            username: "corecathx",
            display: "CoreCat",
            profile_url: 'https://cdn.discordapp.com/avatars/694791036094119996/08795150028fbab041c2cc9359bc5e43.png?size=1024' 
        }
    }

    public static function loadProfileImage()
    {
        var img:URLLoader;
        try{
            img = new URLLoader();
            img.dataFormat = BINARY;
            img.addEventListener(Event.COMPLETE, (e:Event) -> {
                Common.PLAYER_PFP_DATA = img.data;
            });
            img.addEventListener(IOErrorEvent.IO_ERROR, (e:IOErrorEvent) -> {
                trace("Error loading profile image: " + e.text);
                // Handle the error (e.g., fallback, retry, notify the user, etc.)
            });
            
            img.load(new URLRequest(Common.PLAYER.profile_url));
        } catch (e) {
            trace("Error loading profile image: " + e.message);
        }
    }
}