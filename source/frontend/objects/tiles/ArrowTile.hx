package frontend.objects.tiles;

import frontend.objects.Player.TileData;
import frontend.states.PlayState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import backend.Conductor;
import backend.utils.Common.wait;
import frontend.objects.Player.Direction;

/**
 * Arrow Tile colors from the map.
 */
 typedef MapTileColorData = {
	var zero:RGB;
	var one:RGB;
	var two:RGB;
	var three:RGB;
	var fallback:RGB;
}

enum abstract TileRating(String) from String to String {
	var PERFECT = "perfect";
	var COOL = "good";
	var MEH = "meh";
	var MISS = "miss";
}

/**
 * Arrow Tile object, a component of the ArrowTile PlayState.instance.
 */
 class ArrowTile extends FlxSprite {
    public var verticalTextOffset:Int = 15;
    public var squareTileEffect:SquareArrowTileEffect;
	/**
	 * Value for the tile color data.
	 */
	public var tileColorData:MapTileColorData = Common.DEFAULT_TILE_COLOR_DATA;

	/**
	 * If this tile updates its color each frame.
	 */
	public var canUpdateColors:Bool = true;

	/**
	 * Arrow direction of this tile points at. (`Direction`)
	 */
	public var direction:Direction = DOWN;

	/**
	 * Variable to assist with miss handling.
	 */
	public var checked:Bool = false;

	/**
	 * This tile's Step time.
	 */
	public var step:Float = 0;

	/**
	 * Indicates whether this tile have been hit.
	 */
	public var hit:Bool = false;

	/**
	 * Indicates whether the player missed this tile.
	 */
	public var missed:Bool = false;

    /**
	 * Rating of this tile after gets hit.
	 */
	public var rating:TileRating = MISS;

    public var isSustainEnd:Bool = false;

    public var isSustain:Bool = false;

    public var dying:Bool = false;

    public var nextTile:ArrowTile;

	/**
	 * Creates a new ArrowTile object.
	 * @param nX X Position
	 * @param nY Y Position
	 * @param dir Arrow direction of this tile points at.
	 * @param curStep This tile's Step time.
	 * @param tileColorData Color Data for this ArrowTile.
	 */
	public function new(nX:Float, nY:Float, dir:Direction, curStep:Float, ?tileColorData:MapTileColorData, isSustain:Bool, isSustainEnd:Bool) {
		super(nX, nY);
		step = curStep;
		direction = dir;
        antialiasing = true;
        this.isSustain = isSustain;
        this.isSustainEnd = isSustainEnd;
		if (tileColorData != null)
			this.tileColorData = tileColorData;

        if (!isSustainEnd)
		    loadGraphic(Assets.image('Gameplay', 'arrow-tile'));
        else
            loadGraphic(Assets.image('Gameplay', 'release-tile'));

		setGraphicSize(Player.BOX_SIZE, Player.BOX_SIZE);
		updateHitbox();
		updateColors();

		switch (dir) {
			case LEFT:
				angle = 90;
			case RIGHT:
				angle = -90;
			case UP:
				angle = 180;
			default:
				angle = 0;
		}
		alpha = 0;

        squareTileEffect = new SquareArrowTileEffect(nX, nY, this, 5);
        PlayState.instance.add(squareTileEffect);
	}

    public static function indexOf(t:TileData, array:Array<TileData>):Int
    {
        var res = -1;
        for (xID in 0...array.length)
        {
            var x = array[xID];
            if (x.step == t.step && x.direction == t.direction){
                res = xID;
                break;
            }
        }
        return res;
    }

    public static function fromTileData(data:TileData):ArrowTile
        return new ArrowTile(data.x, data.y, data.direction, data.step, data.colorData, data.isSustain, data.isSustainEnd);

    public static function toTileData(tile:ArrowTile):TileData
        return {x: tile.x, y: tile.y, direction: tile.direction, step: tile.step, colorData: tile.tileColorData, isSustain: tile.isSustain, isSustainEnd: tile.isSustainEnd};

    public static function tileRatingToString(rating:TileRating):String
        return rating == 'perfect' ? 'Perfect!' : rating == 'cool' ? 'Cool!' : rating == 'meh' ? 'Meh.' : rating == 'miss' ? 'Missed!' : 'Perfect!';

    function updateColors()
    {
        if (isSustain && nextTile != null)
            color = nextTile.color;
        else{
            color = switch (step % 4) {
		    	case 0: FlxColor.fromRGB(tileColorData.zero.red, tileColorData.zero.green, tileColorData.zero.blue, 255);
		    	case 1: FlxColor.fromRGB(tileColorData.one.red, tileColorData.one.green, tileColorData.one.blue, 255);
		    	case 2: FlxColor.fromRGB(tileColorData.two.red, tileColorData.two.green, tileColorData.two.blue, 255);
		    	case 3: FlxColor.fromRGB(tileColorData.three.red, tileColorData.three.green, tileColorData.three.blue, 255);
		    	default: FlxColor.fromRGB(tileColorData.fallback.red, tileColorData.fallback.green, tileColorData.fallback.blue, 255);
		    }
        }
    }

    public function onTileHit(?rating:TileRating = PERFECT)
    {
        hit = true;
        if (!isSustain){
            // Tween based on properties instead of a set value. Just a way to make sure custom things like modcharts won't break.
            dying = true;
            FlxTween.tween(this, {"scale.x": scale.x + scale.x/2.5, "scale.y": scale.y + scale.y/2.5, angle: angle + 70}, 0.5, {ease: FlxEase.quadOut});
        }
        FlxTween.tween(squareTileEffect, {"scale.x": scale.x + 1.7, "scale.y": scale.y + 1.7, alpha: 0}, 0.5, {ease: FlxEase.quadOut});
        new FlxTimer().start(0.5, function(t){
            PlayState.instance.remove(squareTileEffect);
            if (squareTileEffect != null)
                squareTileEffect.kill();
            squareTileEffect = null;
        });
        //PlayState.instance.flickerTextOnPlayer(tileRatingToString(rating), FlxColor.CYAN, 0.35);
    }

    public function onTileMiss()
    {
        missed = true;
        if (!isSustain){
            dying = true;
            FlxTween.tween(this, {"scale.x": scale.x - scale.x/2.5, "scale.y": scale.y - scale.y/2.5, angle: angle - 10}, 0.5, {ease: FlxEase.quadIn});
        } 
        FlxTween.tween(squareTileEffect, {"scale.x": scale.x - scale.x/2.5, "scale.y": scale.y - scale.y/2.5, angle: -10, alpha: 0}, 0.5, {ease: FlxEase.quadIn});
        new FlxTimer().start(0.5, function(t){
            PlayState.instance.remove(squareTileEffect);
            if (squareTileEffect != null)
                squareTileEffect.kill();
            squareTileEffect = null;
        });
        PlayState.instance.flickerTextOnPlayer(tileRatingToString(MISS), 0xFFAA0000, 0.35);
    }

	override function update(elapsed:Float) {
        super.update(elapsed);
		calcAlpha(elapsed);
        if (canUpdateColors)
            updateColors();
	}

    var times:Int = 0;
    var running = false;
    function calcAlpha(elapsed:Float)
    {
        //reElection();
        var val = 2 * elapsed;
        if (Conductor.instance.current_steps + 10 > step && Conductor.instance.current_steps < step && alpha < 1) {
            if (!dying){
                if (!isSustainEnd)
                    alpha += val;
                
                if (alpha == 1 && !running && isSustain){
                    running = true;
                    var stepDiff = nextTile.step - step;
                    var waitTimeMS = stepDiff * Conductor.instance.step_ms;
                    wait(waitTimeMS / (stepDiff * 100), (_) -> {
                        dying = true;
                    });
                }
            }
		}
        if (dying)
            alpha -= val;
    }

    function reElection()
    {
        if (PlayState.instance.player.tileDatas[(ArrowTile.indexOf(ArrowTile.toTileData(this), PlayState.instance.player.tileDatas))+1] != null && isSustain){
            while (nextTile == null){
                var candidate = PlayState.instance.player.tileDatas[(ArrowTile.indexOf(ArrowTile.toTileData(this), PlayState.instance.player.tileDatas))+1];
                PlayState.instance.tile_group.forEach((t:ArrowTile) -> {
                    if (candidate != null){
                        if (candidate.step == t.step && nextTile == null){
                            times++;
                            if (times != 1)
                                trace('re-elected nextTile. ${times}X');
                            else
                                trace('re-elected nextTile.');
                            nextTile = t;
                        }
                    }
                });
            }
        }
    }
}