package frontend.objects;

import frontend.objects.tiles.ArrowTile;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import backend.Conductor;
import frontend.states.PlayState;

enum abstract Direction(Int) {
	var LEFT = 0;
	var DOWN = 1;
	var UP = 2;
	var RIGHT = 3;
}

typedef TileData = {
    var x:Float;
    var y:Float;
    var step:Float;
    var isSustainEnd:Bool;
    var instance:PlayState;
    var direction:Direction;
    var colorData:MapTileColorData;
}

enum abstract PlayerMovementState(Int) {
	var MOVING = 0;
	var WAITING = 1;
}

class Player extends FlxSprite {
	public static var BOX_SIZE:Int = 50;
	public var direction:Direction = DOWN;
	public var nextDirection:Direction = DOWN;

    public var curState:PlayerMovementState = WAITING;

    /** A progress from previous tile to the next tile from 0 to 1. **/
	public var tileProgress:Float = 0;

    /** Defines next hittable tile. **/
    public var tileDatas:Array<TileData> = [];

    /** Defines current tile data. **/
	public var curTileDataIndex:Int = -1;


	public var speed:Float = 1;
	public var pixelMovement:Float = 5;

	public var currentStep:Float = 0;
	public var nextStep:Float = 0;

	public var trails:Array<FlxSprite> = [];
	public var trail_length:Int = 5;
	public var trail_time:Float = 0;
	public var trail_delay:Float = 0.05;
	public var started:Bool = false;

    /**
     * Modify this X variable if you want the player to move smoothly.
     */
    public var targetX:Float = 0;
    /**
     * Modify this Y variable if you want the player to move smoothly.
     */
    public var targetY:Float = 0;
    /**
     * If you want to set the x and y values to interpolate with targetX and targetY, enable this. (enabled by default)
     */
    public var interpPosition:Bool = true;

	public function new(nX:Float, nY:Float) {
		super(nX, nY);
        targetX = nX;
        targetY = nY;
		makeGraphic(BOX_SIZE, BOX_SIZE, 0xFFFFFFFF);
	}

    var oldInterpPosition:Null<Bool> = null;
	override function update(elapsed:Float) {
		updateProperties();
        if (!PlayState.instance.mapEnded)
		    updateMovement(elapsed);

		handleTrails(elapsed);
		updateScale(elapsed);
        if (oldInterpPosition != null){
            if (interpPosition != oldInterpPosition)
            {
                targetX = x;
                targetY = Y;
            }
        }
        if (interpPosition){
            x = FlxMath.lerp(x, targetX, 0.2);
            y = FlxMath.lerp(y, targetY, 0.2);
        }
        oldInterpPosition = interpPosition;
		super.update(elapsed);
	}

	function updateProperties() {
		if (Conductor.instance != null)
			currentStep = Conductor.instance.current_steps;
	}

	public function updateScale(e:Float) {
		var _scale:Float = FlxMath.lerp(1, scale.x, 1 - (e * 12));
		scale.set(_scale, _scale);
	}

	override function draw() {
		for (i in trails) {
			if (i.visible && i.alpha > 0)
				i.draw();
		}
		super.draw();
	}

	private var _curTime:Float = 0;

	public function handleTrails(elapsed:Float) {
		if (!started)
			return;
		_curTime += elapsed;

		if (_curTime > trail_delay) {
			var n:FlxSprite = new FlxSprite(x, y).makeGraphic(BOX_SIZE, BOX_SIZE, 0xFFFFFFFF);
			n.alpha = 0.8;
			n.active = false;
			n.blend = ADD;
			trails.push(n);
			_curTime = 0;
		}

		for (i in trails) {
			if (i.alpha > 0) {
				i.alpha -= 0.8 * elapsed;
				i.color = FlxColor.interpolate(FlxColor.BLUE, FlxColor.CYAN, i.alpha - 0.2);
				i.scale.set(i.alpha, i.alpha);
			} else {
				i.kill();
				i.destroy();
				trails.remove(i);
			}
		}
	}
	// remind me to rewrite this soon please
	public function checkTiles(tile_group:FlxTypedGroup<ArrowTile>) {
		if (!started)
			return;
		if (tile_group == null)
			return;

		var keys:Array<Array<Dynamic>> = [
			[FlxKey.A, FlxKey.LEFT],
			[FlxKey.S, FlxKey.DOWN],
			[FlxKey.W, FlxKey.UP],
			[FlxKey.D, FlxKey.RIGHT]
		];
		var pressArray:Array<Bool> = [false, false, false, false];

		for (index => keyList in keys) {
			var pressed:Bool = false;
			for (key in keyList) {
				if (FlxG.keys.checkStatus(key, JUST_PRESSED)) {
					pressed = true;
					break;
				}
			}
			pressArray[index] = pressed;
		}

		var nextTile:ArrowTile = null;
		tile_group.forEachAlive((tile:ArrowTile) -> {
			if (tile == null || tile.hit || tile.missed)
				return;

			if (nextTile == null)
				nextTile = tile;
			else if (tile.step > currentStep && tile.step < nextTile.step)
				nextTile = tile;
		});

        var anyPressed:Bool = false;
        for (e in pressArray) { if (e){ anyPressed = true; } }
        if (anyPressed) {
            if (Conductor.instance.current_steps > tile.step && Conductor.instance.current_steps < lastTile.step + (nextTile.step-lastTile.step))
        }

		if (nextTile != null) {
            if (nextTile.isSustainEnd)
			nextStep = nextTile.step;
			nextDirection = nextTile.direction;

            
			var tileTime:Float = nextTile.step * Conductor.instance.step_ms;
			var hitable:Bool = tileTime > Conductor.instance.time - (Conductor.instance.safe_zone_offset * 1.2)
				&& tileTime < Conductor.instance.time + (Conductor.instance.safe_zone_offset * 0.4);
            

			var timeDiff:Float = tileTime - Conductor.instance.time; // + is early, - is late.
			// i want to die :sob:
			var tOffset:Float = timeDiff * (BOX_SIZE / Conductor.instance.step_ms) * PlayState.instance.speedRate;

            if (Conductor.instance.current_steps > nextTile.step - 1 && !nextTile.hit)
                direction = nextTile.direction;
			if (hitable) {
				if (pressArray[cast nextTile.direction] && !nextTile.hit) {
					PlayState.instance.onTileHit(nextTile);
				}
			} else if (!nextTile.missed && tileTime < Conductor.instance.time - (Conductor.instance.safe_zone_offset * 0.4)) {
				PlayState.instance.onTileMiss(nextTile);
			}
		}
	}

	private function updateMovement(elapsed:Float) {
		if (!started)
			return;

        switch (curState){
		    case MOVING:
                movePlayer(elapsed);
            case WAITING:
                wait(elapsed);
        }
	}

    function wait(elapsed:Float)
    {
        curTileDataIndex++;
        curState = MOVING;
    }

    function movePlayer(elapsed:Float) {
        var nextTileData = null;
        if (curTileDataIndex + 1 >= 0)
            nextTileData = tileDatas[curTileDataIndex + 1];
        var lastTileData = null;
        if (curTileDataIndex - 1 >= 0)
            lastTileData = tileDatas[curTileDataIndex - 1];
        
        var validCheck:Bool = nextTileData != null;
        FlxG.watch.addQuick("Using new method?", validCheck);
        FlxG.watch.addQuick("Tiles", (nextTileData == null ? 'null' : '$nextTileData') + " // " + (lastTileData == null ? 'null' : '$lastTileData'));
        if (validCheck) {
            conductorBasedMovement(elapsed);
        } else { // Use non-conductor based movement method
            velocityBasedMovement(elapsed);
        }
    }

    function conductorBasedMovement(elapsed:Float)
    {
        var lastTileData = tileDatas[curTileDataIndex - 1];
        var curTileData = tileDatas[curTileDataIndex];
        if (lastTileData != null) {
            var targetTime:Float = curTileData.step * Conductor.instance.step_ms;
		    var lastTime:Float = lastTileData.step * Conductor.instance.step_ms;
		    var curTime:Float = Conductor.instance.time;

            var candidateX:Float = -1;
            var candidateY:Float = -1;

		    FlxG.watch.addQuick("Times", targetTime + " // " + lastTime);

            if (Conductor.instance.current_steps < curTileData.step){
		        if (targetTime != lastTime) {
		        	tileProgress = (curTime - lastTime) / (targetTime - lastTime);

		        	candidateX = lastTileData.x + (curTileData.x - lastTileData.x) * tileProgress;
		        	candidateY = lastTileData.y + (curTileData.y - lastTileData.y) * tileProgress;

                    targetX = candidateX;
                    targetY = candidateY;
                    FlxG.watch.addQuick("Player Progress", tileProgress);
		        }
            } else {
                curState = WAITING;
            }
        } else {
            curState = WAITING;
            velocityBasedMovement(elapsed);
        }
    }

    function velocityBasedMovement(elapsed:Float)
    {
        var addX:Float = 0;
        var addY:Float = 0;

        elapsed *= 1000;

        var moveVel:Float = ((BOX_SIZE / Conductor.instance.step_ms) * PlayState.instance.speedRate) * elapsed;

        switch (direction) {
            case Direction.LEFT:
                addX -= moveVel;
            case Direction.DOWN:
                addY += moveVel;
            case Direction.UP:
                addY -= moveVel;
            case Direction.RIGHT:
                addX += moveVel;
        }

        targetX += addX;
        targetY += addY;

        if (direction == Direction.LEFT || direction == Direction.RIGHT) {
            targetY = Math.round(targetY / BOX_SIZE) * BOX_SIZE;
        } else if (direction == Direction.UP || direction == Direction.DOWN) {
            targetX = Math.round(targetX / BOX_SIZE) * BOX_SIZE;
        }
    }
}
