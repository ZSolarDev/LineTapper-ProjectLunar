package game.backend;

import lime.app.Event;
#if cpp
import haxe.Int64;
import hxvlc.flixel.FlxVideoSprite as VLCVideo;
import hxvlc.util.Location;

class Video extends VLCVideo
{
    public var isPlaying:Bool = false;
    /**
     * Called when the video is started.
     */
    public var onStart(default, null):Event<Void->Void>;

    /**
	 * Event triggered when the format setup is initialized.
	 */
	public var onInit(default, null):Event<Void->Void> = new Event<Void->Void>();

	public var time(get, set):Int;

    public function get_time():Int
        return Int64.toInt(bitmap.time);

    public function set_time(v:Int)
        return Int64.toInt(bitmap.time = v);
    

    override public function new(?x:Float = 0, ?y:Float = 0)
    {
        super(x, y);
        onStart = bitmap.onPlaying;
        onInit = bitmap.onFormatSetup;
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
        isPlaying = bitmap.isPlaying;
    }

    public function loadVideoAsset(location:Location, ?withAudio:Bool = true):Bool
    {
        return super.load(location, withAudio ? [':no-audio'] : null);
    }
}
#else
#if hl

#end
#end