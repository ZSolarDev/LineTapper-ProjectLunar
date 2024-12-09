package frontend.states.playstate;

import frontend.objects.Background;
import backend.Lyrics;
import flixel.effects.FlxFlicker;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import backend.Conductor;
import backend.MapData;
import frontend.objects.tiles.ArrowTile;
import frontend.objects.Player;
import frontend.states.playstate.GameComponent;
import frontend.states.playstate.HudComponent;
typedef Rating = {
    var count:Int;
    var arrowTiles:Array<ArrowTile>;
}

class SongComponent implements Component {
    public var playstate:PlayState;
    public var gameComponent:GameComponent;
    public var hudComponent:HudComponent;

    public var using_autoplay:Bool = false;
    public var mapName:String = "Tutorial";
    public var mapStarted:Bool = false;
    public var mapEnded:Bool = false;
    public var misses:Int = 0;
    public var score:Int = 0;
    public var hits:Int = 0;
    public var combo:Int = 0;
    public var lyrics:Lyrics;
    public var ratings:Map<TileRating, Rating>;

    public var linemap:LineMap;
	public var speedRate:Float = 1;
    public var legacyMode:Bool = false;

    public function new(instance:PlayState, gameComponent:GameComponent, hudComponent:HudComponent) {
        playstate = instance;
        this.gameComponent = gameComponent;
        this.hudComponent = hudComponent;
    }

    public function initRatings()
    {
        ratings = new Map<TileRating, Rating>();
        ratings = [
            PERFECT => {count: 0, arrowTiles: []},
            COOL => {count: 0, arrowTiles: []},
            MEH => {count: 0, arrowTiles: []},
            MISS => {count: 0, arrowTiles: []},
        ];
    }

    public function endSong(?targetState:FlxState)
    {
        #if cpp
        if (linemap.version == ALPHA1){
            if (gameComponent.hasCustomBG && Background.typeFromString(linemap.theme.bgData.bgType) == VIDEO)
                gameComponent.gameBG.stopVideo();
        }
        #end
        if (targetState == null)
            targetState = new MenuState();
        gameComponent.tile_group.forEachAlive((tile:ArrowTile) ->
		{
            if (tile != null)
                tile.visible = false;
            if (tile.squareTileEffect != null)
                tile.squareTileEffect.visible = false;
		});
        FlxG.camera.follow(new FlxObject(gameComponent.player.getMidpoint().x, gameComponent.player.getMidpoint().y, 1, 1), LOCKON);
        FlxG.sound.music.fadeOut(0.5,0, function(t){
            FlxG.sound.music.stop();
            FlxG.sound.music.destroy();
            FlxG.sound.music = null;
        });
        mapEnded = true;
        Conductor.instance.time = 0;
        Conductor.instance.current_beats = 0;
        Conductor.instance.current_steps = 0;
        if (PlayState.instance.hasEndTransition){
            FlxTween.tween(gameComponent.bg_gradient, {alpha: 0}, 1);
            FlxTween.tween(hudComponent.scoreBoard, {alpha: 0}, 1);
            FlxTween.tween(gameComponent.backdrop, {alpha: 0}, 1);
            FlxTween.tween(hudComponent.timeBar, {alpha: 0}, 1);
            FlxTween.tween(hudComponent.timeTextLeft, {alpha: 0}, 1);
            FlxTween.tween(hudComponent.timeTextRight, {alpha: 0}, 1);
            new FlxTimer().start(1, function(tmr:FlxTimer)
            {
                FlxFlicker.flicker(gameComponent.player, 0.5, 0.02, true);
            });
            new FlxTimer().start(1.5, function(tmr:FlxTimer)
            {
                PlayState.instance.exitToState(targetState);
            });
        }else{
            PlayState.instance.exitToState(targetState);
        }
    }

    public function initSong() {
        var mapAsset:MapAsset = Assets.map(mapName);
		lyrics = mapAsset.lyrics == null ? new Lyrics() : mapAsset.lyrics;
		FlxG.sound.playMusic(mapAsset.audio, 1, false);
		FlxG.sound.music.onComplete = ()->{
			endSong();
		}
		FlxG.sound.music.time = 0;
		FlxG.sound.music.pitch = speedRate;
		FlxG.sound.music.pause();

		linemap = mapAsset.map;
        linemap.version;

        if (linemap.version == LEGACY){
            legacyMode = true;
        }
    }

	public function loadSong()
	{
		var current_direction:Direction = Direction.DOWN;
		var tileData:Array<Int> = [0, 0]; // Current Tile, rounded from 50px, 0,0 is the first tile.
		var curStep:Int = 0;

		for (tileID in 0...linemap.tiles.length)
		{
            var tile = linemap.tiles[tileID];
			// Calculate step difference
			var stepDifference:Int = tile.step - curStep;
			curStep = tile.step; // Update curStep to the instance tile step

			var direction:Direction = cast tile.direction;

			switch (current_direction)
			{
				case Direction.LEFT:
					tileData[0] -= stepDifference;
				case Direction.RIGHT:
					tileData[0] += stepDifference;
				case Direction.UP:
					tileData[1] -= stepDifference;
				case Direction.DOWN:
					tileData[1] += stepDifference;
				default:
					trace("Invalid direction type in step " + tile.step);
			}

			// Debugging to ensure we are creating ArrowTiles
			var posX = tileData[0] * 50;
			var posY = tileData[1] * 50;

			var _theme:MapTheme = linemap.theme;
			var arrowTile = new ArrowTile(posX, posY, direction, curStep, _theme.tileColorData, tile.isSustain, tile.isSustainEnd);
			gameComponent.tile_group.add(arrowTile);
            gameComponent.player.tileDatas.push({x: posX, y: posY, step: curStep, direction: direction, isSustain: tile.isSustain, isSustainEnd: tile.isSustainEnd, colorData: _theme.tileColorData});
            gameComponent.player.tileDatas.sort((a:TileData, b:TileData) -> {
                var res:Int = 0;

                if (a.step < b.step)
                    res = -1
                else if (a.step > b.step)
                    res = 1;

                return res;
            });
            if (gameComponent.player.tileDatas[tileID-1] != null){
                if (tile.isSustainEnd){
                    var assumedLastTile:ArrowTile = ArrowTile.fromTileData(gameComponent.player.tileDatas[tileID-1]);
                    gameComponent.tile_group.forEachAlive((t:ArrowTile) -> {
                        if (t.step == assumedLastTile.step && t.direction == assumedLastTile.direction){
                            t.nextTile = arrowTile;
                        }
                    });
                    gameComponent.holdRenderer.generateHold(arrowTile, ArrowTile.fromTileData(gameComponent.player.tileDatas[tileID-1]), arrowTile, false);
                }
            }

			current_direction = direction;
		}

		Conductor.instance.updateBPM(linemap.bpm);
		Conductor.instance.onBeatTick.add(beatTick);

		// trace("Tile group length: " + gameComponent.tile_group.length);
	}

    public function beatTick(beat:Int) {
		if (gameComponent.player != null)
			gameComponent.player.scale.x = gameComponent.player.scale.y += 0.3;
        #if cpp
        if (mapStarted && linemap.theme.bgData.bgType == 'VIDEO'){
            if (Conductor.instance.current_beats % 34 == 0 || Conductor.instance.current_beats == 1 || Conductor.instance.current_beats == 2)
                gameComponent.gameBG.updateVideo();
        }
        #end
	}

    public function create():Void {};
    public function destroy():Void {};
    public function update(elapsed:Float):Void {};
}