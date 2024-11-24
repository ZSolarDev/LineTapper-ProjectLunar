package states;

import flixel.graphics.FlxGraphic;
import haxe.io.Path;
import sys.FileSystem;

class MapSelectState extends FlxState {
    public var mapNames:Array<Path> = [];
    public var curMapSelected:Int = 0;
    public var hasMaps:Bool = false;
    public var lastBG:FlxSprite;
    public var curBG:FlxSprite;
    override public function create() {
        super.create();
        hasMaps = loadMaps();
        if (hasMaps){
            curBG = new FlxSprite(0, 0);
            var mapThumbGraphic:FlxGraphic = Assets.graphicFromPath('maps/${mapNames[curMapSelected]}/mapAssets/thumb.png');
            if (mapThumbGraphic != null)
                curBG.loadGraphic(mapThumbGraphic);
            else
                curBG.loadGraphic(Assets.image('Map Select Menu', 'fallback-bg'));
            add(curBG);
        }
    }

    public function loadMaps(dir:String = 'maps/'):Bool
    {
        var mapDir = FileSystem.readDirectory('maps/');
        if (mapDir != []){
            for (pathStr in mapDir)
                mapNames.push(new Path(pathStr));
            return true;
        }else
            return false;
    }
}