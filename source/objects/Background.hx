package objects;

import flixel.util.FlxTimer;
import openfl.display.BitmapData;
import flixel.group.FlxGroup;
import game.backend.Video;

enum BackgroundType {
    VIDEO;
    IMAGE;
    NONE;
}

class Background extends FlxGroup
{
    public var type:BackgroundType;
    public var asset:String;
    public var scaleX:Float;
    public var scaleY:Float;
    public var image:FlxSprite;
    public var overlay:FlxSprite;
    #if cpp
    public var video:Video;
    #end
    public var alpha:Float = 0.45;
    public var setVideoTime:Bool = false;
    public var time:Float = 0;

    override public function new(type:BackgroundType, asset:String, ?scaleX:Float = 1, ?scaleY:Float = 1, ?alpha:Float = 0.45)
    {
        super();
        this.type = type;
        this.asset = asset;
        this.alpha = alpha;
        this.scaleX = scaleX;
        this.scaleY = scaleY;

        loadAssets();
    }

    public static function typeFromString(v:String):BackgroundType
    {
        return v == 'VIDEO' ? VIDEO : v == 'IMAGE' ? IMAGE : v == 'NONE' ? NONE : NONE;
    }

    public static function typeToString(v:BackgroundType):String
    {
        return v == VIDEO ? 'VIDEO' : v == IMAGE ? 'IMAGE' : v == NONE ? 'NONE' : 'NONE';
    }

    public function updateVideo()
    {
        #if cpp
        if (video != null){
            if (type == VIDEO && setVideoTime && video.isPlaying){
                video.time = Std.int(time);
            }
        }
        #else
        trace('This is not a cpp build!');
        #end
    }

    public function stopVideo()
    {
        #if cpp
        if (video != null){
            remove(video);
            video.stop();
            video.visible = false;
        }
        #else
            trace('This is not a cpp build!');
        #end
    }
    
    public function playVideo()
    {
        #if cpp
        if (video != null){
            video.play();
            updateVideo();
        }
        #else
        trace('This is not a cpp build!');
        #end
    }

    public function loadAssets()
    {
        if (type == VIDEO)
        {
            #if cpp
            video = new Video();
            video.alpha = alpha;
            video.antialiasing = true;
            video.scrollFactor.set();
            video.onStart.add(function():Void
            {
                updateVideo();
            });
            video.onInit.add(function():Void
            {
                #if cpp
                if (video.bitmap != null)
                { #end
                    video.setGraphicSize(1280, 720);
                    video.updateHitbox();
                    video.screenCenter();
                #if cpp } #end
            });
            video.loadVideoAsset(asset, false);
            add(video);
            #else
            trace('This is not a cpp build!');
            #end
        }
        if (type == IMAGE)
        {
            image = new FlxSprite(0, 0, asset);
            image.alpha = alpha;
            image.scrollFactor.set();
            image.scale.set(scaleX, scaleY);
            image.screenCenter();
            add(image);
        }
    }
}