package backend.utils;

import sys.FileSystem;
import openfl.net.URLRequest;
import openfl.events.IOErrorEvent;
import lime.app.Event;
import openfl.net.URLLoader;
import backend.utils.IniParser.IniManager;

/**
 * Everything in this class is intended to run within a Thread.
 */
class InitUtil {
    public var mapThumbnailProgTotal:Int = 0;
    public var mapThumbnailProg:Int = 0;
    public var thumbnailLoadedEvent:Event<Void -> Void> = new Event<Void -> Void>();
    public var maps:Array<String> = [];

    public function new() {}

    public static function initTheme():Void {
        Common.CURRENT_THEME = IniManager.loadFromFile('themes/${Common.CURRENT_THEME_NAME}/theme.ini');
        Assets._THEME_ASSET_PATH = 'themes/${Common.CURRENT_THEME_NAME}';
    }

    /**
     * This function preloads all map thumbnails.
     * 
     * [REQUIERS INSTANCING FOR PROGRESS]
     */
    public function loadMapThumbnails() {
        for (map in maps)
        {
            if (FileSystem.exists('maps/$map/mapAssets/thumb.png'))
                Assets.graphicFromPath('maps$map/mapAssets/thumb.png');
            else
                trace("Couldn't find thumbnail for map " + map + ' (maps/$map/mapAssets/thumb.png)');
            mapThumbnailProg++;
            thumbnailLoadedEvent.dispatch();
        }
    }

    public function initMapThumbnailLoading()
    {
        maps = FileSystem.readDirectory('maps/');
        mapThumbnailProgTotal = maps.length;
        mapThumbnailProg = 0;
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
            img.addEventListener(openfl.events.Event.COMPLETE, (e:openfl.events.Event) -> {
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