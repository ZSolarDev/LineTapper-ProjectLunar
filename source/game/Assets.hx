package game;

import game.backend.Lyrics;
import game.MapData.MapAsset;
import flixel.graphics.FlxGraphic;
import lime.graphics.Image;
import openfl.display.BitmapData;
import openfl.media.Sound;
import sys.FileSystem;
import sys.io.File;

/**
 * Helper class for this game's assets.
 */
class Assets
{
    /** Gets initialized in Common. **/
    public static var _THEME_ASSET_PATH:String = "/themes/Default";

	/** Trackers for loaded assets. **/
	public static var loaded_images:Map<String, Bool> = new Map();

	public static var loaded_sounds:Map<String, Sound> = new Map();

	/**
	 * Unloads all loaded images.
	 */
	public static function unloadImages()
	{
		for (key in loaded_images.keys())
		{
			var graphic:FlxGraphic = FlxG.bitmap.get(key);
			if (graphic == null)
				continue;

			if (graphic.bitmap != null)
				graphic.bitmap.dispose();

			graphic.destroy();
			FlxG.bitmap.removeByKey(key);
		}

		loaded_images.clear();
		openfl.utils.Assets.cache.clear();
	}

	/**
	 * Loads a font file.
	 * @param name Your font's file name (without .ttf extension)
	 * @return Font
	 */
	public static function font(key:String)
	{
		var path:String = '$_THEME_ASSET_PATH/${Common.CURRENT_THEME['Fonts'][key]}';

		if (!FileSystem.exists(path))
			return null;

		return path;
	}

	/**
	 * Returns an image file from `./assets/images/`, Returns null if the `path` does not exist.
	 * @param file Image file name
	 * @return FlxGraphic (Warning: might return null)
	 */
	public static function image(?section:String = 'Main Menu', ?key:String = 'logo'):FlxGraphic
	{
        if (Common.CURRENT_THEME == null)
            throw "The current theme hasn't been initialized!";

        if (Common.CURRENT_THEME[section] == null)
            throw "Section " + section + " doesn't exist.";

        if (Common.CURRENT_THEME[section][key] == null)
            throw "Key " + key + " in section " + section + " doesn't exist.";

		var path:String = '$_THEME_ASSET_PATH/${Common.CURRENT_THEME[section][key]}';
        var iniAssetPath = '$section/$key';

		if (!FileSystem.exists(path))
			return null;

		if (loaded_images.exists(iniAssetPath))
			return FlxG.bitmap.get(iniAssetPath);

		var data:Image = Image.fromFile(path);
		var newBitmap:BitmapData = BitmapData.fromImage(data);

		// Send to GPU

		var newGraphic:FlxGraphic = FlxGraphic.fromBitmapData(newBitmap, false, iniAssetPath);
		newGraphic.persist = true;

		var n:FlxGraphic = FlxG.bitmap.addGraphic(newGraphic);
		loaded_images.set(iniAssetPath, true);

		return n;
	}

    public static function graphicFromPath(path:String):FlxGraphic
    {
        if (loaded_images.exists(path))
			return FlxG.bitmap.get(path);

        var newGraphic:FlxGraphic = FlxG.bitmap.addGraphic(FlxGraphic.fromBitmapData(cast BitmapData.loadFromFile(path), false));
        loaded_images.set(path, true);
        newGraphic.persist = true;
        return newGraphic;
    }

	/**
	 * Returns MapAsset containing audio and map data.
	 * Returns null if the map folder does not exist.
	 * @param song Song's name.
	 * @return MapAsset (Warning: might return null)
	 */
	public static function map(song:String):MapAsset
	{
		var path:String = 'maps/$song';

		if (!FileSystem.exists(path))
			return null;

		var soundPath:String = '$path/audio.ogg';
		var mapPath:String = '$path/map.json';
		var lyricsPath:String = '$path/lyrics.txt';

		var mAsset:MapAsset = {
			audio: null,
			map: null,
			lyrics: null
		};

		mAsset.audio = _sound_file(soundPath);

		if (FileSystem.exists(mapPath))
			mAsset.map = MapData.loadMap(File.getContent(mapPath));

		if (FileSystem.exists(lyricsPath))
			mAsset.lyrics = new Lyrics(File.getContent(lyricsPath));

		return mAsset;
	}

	/**
	 * Returns a sound file
	 * @param path Sound's file name (without extension)
	 * @return Sound
	 */
	inline public static function sound(?section:String = 'Global Assets', ?key:String = 'key-press'):Sound
		return _sound_file('$_THEME_ASSET_PATH/${Common.CURRENT_THEME[section][key]}');

	/**
	 * [INTERNAL] Loads a sound file
	 * @param soundPath Path to the sound file
	 * @return Sound
	 */
	public static function _sound_file(soundPath:String):Sound
	{
		if (!FileSystem.exists(soundPath))
			return null;

		if (!loaded_sounds.exists(soundPath))
			loaded_sounds.set(soundPath, Sound.fromFile(soundPath));

		return loaded_sounds.get(soundPath);
	}
}