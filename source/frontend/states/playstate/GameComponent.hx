package frontend.states.playstate;

import frontend.objects.tiles.holds.HoldRenderer;
import frontend.objects.tiles.TextTileEffect;
import flixel.ui.FlxBar;
import frontend.objects.Background;
import backend.Lyrics;
import flixel.effects.FlxFlicker;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import backend.script.ScriptGroup;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.util.FlxGradient;
import backend.Conductor;
import backend.MapData;
import frontend.objects.tiles.ArrowTile;
import frontend.objects.Player;
import frontend.states.playstate.SongComponent;

class GameComponent implements Component {
    public var playstate:PlayState;
    public var songComponent:SongComponent;

    public var tile_group:FlxTypedGroup<ArrowTile>;
    public var holdRenderer:HoldRenderer;
    public var scripts:ScriptGroup;
    public var playerTxt:TextTileEffect;
	public var player:Player;

    public var bg_gradient:FlxSprite;
	public var backdrop:FlxBackdrop;
    public var gameBG:Background;
    public var bgAsset:String;
    public var hasCustomBG:Bool = false;

    public var gameCamera:FlxCamera;
	public var hudCamera:FlxCamera;
	public var camFollow:FlxObject;

    public function new(instance:PlayState, songComponent:SongComponent) {
        playstate = instance;
        this.songComponent = songComponent;
    }

    public function initCameras()
    {
        gameCamera = new FlxCamera();
        FlxG.cameras.reset(gameCamera);

        hudCamera = new FlxCamera();
        hudCamera.bgColor = FlxColor.TRANSPARENT;
        FlxG.cameras.add(hudCamera, false);
    }

	public function update(elapsed:Float)
	{
        FlxG.camera.zoom = FlxMath.lerp(1, FlxG.camera.zoom, 1 - (elapsed * 12));

		camFollow.x = FlxMath.lerp(player.getMidpoint().x, camFollow.x, 1 - (elapsed * 12));
		camFollow.y = FlxMath.lerp(player.getMidpoint().y, camFollow.y, 1 - (elapsed * 12));

        #if cpp
        if (playstate.linemap.theme.bgData.bgType == 'VIDEO')
            gameBG.time = Conductor.instance.time;
        #end
		if (FlxG.keys.justPressed.SPACE && !songComponent.mapStarted)
		{
            songComponent.mapStarted = true;
            #if cpp
            if (playstate.linemap.version == ALPHA1){
                if (playstate.hasCustomBG && Background.typeFromString(playstate.linemap.theme.bgData.bgType) == VIDEO)
                    gameBG.playVideo();
            }
            #end
			FlxG.sound.music.play();
			//player.setPosition();
			player.started = true;
		}

		if (FlxG.keys.justPressed.ESCAPE) {
			songComponent.endSong();
		}

		if (FlxG.keys.justPressed.TAB) {
			songComponent.using_autoplay = !songComponent.using_autoplay;
		}

		if (FlxG.sound.music != null && !songComponent.mapEnded)
		{
			if (songComponent.using_autoplay)
			{
				tile_group.forEachAlive((tile:ArrowTile) ->
				{
					if (Conductor.instance.current_steps > tile.step - 1 && !tile.hit)
						onTileHit(tile);
				});
			} else {
				player.checkTiles(tile_group);

				tile_group.forEachAlive((tile:ArrowTile) ->
				{
                    if (Conductor.instance.current_steps > tile.step - 1 && !tile.checked){
                        tile.checked = true;
						//updatePlayerPosition(tile);
                    }
				});
			}
		}
	}

    public function onTileMiss(tile:ArrowTile)
    {
        if (tile != null && tile.squareTileEffect != null){
            playstate.scripts.executeFunc("onTileMiss", [tile]);
			playstate.hitStatus = "Missed!";
            tile.onTileMiss();
            playstate.scoreBoard.scale.x -= 0.3;
            songComponent.misses++;
            playstate.score -= 100;
            playstate.combo = 0;
            var rating = playstate.ratings.get(MISS);
            rating.count++;
            rating.arrowTiles.push(tile);
            playstate.scripts.executeFunc("postTileMiss", [tile]);
        }
    }

    public function flickerTextOnPlayer(text:String, color:FlxColor, length:Float){
        var splitLength:Float = length/2;
        playerTxt.visible = true;
        playerTxt.text = text;
        playerTxt.color = color;
        new FlxTimer().start(splitLength, function(t){
            FlxFlicker.flicker(playerTxt, splitLength, 0.02, false, true);
        });
    }

    public function onSustainHit(tile:ArrowTile)
    {
        playstate.scripts.executeFunc("onSustainHit", []);
        playstate.score += 1;
        playstate.scoreBoard.scale.x += 0.05;
        player.glowBG.color = tile.color;
        player.glowBG.alpha = 1;
        playstate.scripts.executeFunc("postSustainHit", []);
    }

    public function onSustainMiss(tile:ArrowTile)
    {
        playstate.scripts.executeFunc("onSustainMiss", []);
        playstate.score -= 1;
        playstate.scoreBoard.scale.x -= 0.05;
        playstate.scripts.executeFunc("postSustainMiss", []);
    }
    
	public function onTileHit(tile:ArrowTile, ?ratingName:TileRating = PERFECT)
    {
        if (tile != null && tile.squareTileEffect != null){
            playstate.hitStatus = ArrowTile.tileRatingToString(ratingName);
            playstate.scripts.executeFunc("onTileHit", [tile]);
            FlxG.sound.play(Assets.sound('Gameplay', 'hit-sound'), 0.7);
            tile.onTileHit();
            if (songComponent.using_autoplay)
                updatePlayerPosition(tile);
            playstate.combo++;
            playstate.scoreBoard.scale.x += 0.3;
            playstate.score += 100;
            FlxG.camera.zoom += 0.05;
            var rating = playstate.ratings.get(ratingName);
            rating.count++;
            rating.arrowTiles.push(tile);
            playstate.scripts.executeFunc("postTileHit", [tile]);
        }
    }

    public function updatePlayerPosition(tile:ArrowTile){
        player.direction = tile.direction;
		player.targetX = tile.x;
        player.targetY = tile.y;
    }

	public function beatTick(beat:Int) {
		if (player != null)
			player.scale.x = player.scale.y += 0.3;
        #if cpp
        if (songComponent.mapStarted && playstate.linemap.theme.bgData.bgType == 'VIDEO'){
            if (Conductor.instance.current_beats % 34 == 0 || Conductor.instance.current_beats == 1 || Conductor.instance.current_beats == 2)
                gameBG.updateVideo();
        }
        #end
	}

    public function create() {
        playstate.bg_gradient = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, [FlxColor.BLACK, FlxColor.BLUE], 1, 90, true);
		playstate.bg_gradient.scale.set(1, 1);
		playstate.bg_gradient.scrollFactor.set();
		playstate.bg_gradient.alpha = 0.1;
		playstate.add(playstate.bg_gradient);

		backdrop = new FlxBackdrop(FlxGridOverlay.createGrid(50, 50, 100, 100, true, 0xFF000F30, 0xFF002763), XY);
		backdrop.alpha = 0;
		playstate.add(backdrop);

        if (!songComponent.legacyMode){
            if (playstate.linemap.version == ALPHA1){
                var bgType = Background.typeFromString(playstate.linemap.theme.bgData.bgType);
                if (bgType != NONE){
                    playstate.hasCustomBG = true;
                    playstate.bg_gradient.visible = false;
                    backdrop.visible = false;
                
                    #if !cpp
                        if (bgType == VIDEO){
                            trace("This build isn't compiled to cpp, Video Backgrounds are not supported!");
                            playstate.bg_gradient.visible = true;
                            backdrop.visible = true;
                            playstate.hasCustomBG = false;
                        }
                    #else
                        gameBG = new Background(bgType, 'maps/$mapName/mapAssets/${playstate.linemap.theme.bgData.bg}${bgType == IMAGE ? '.png' : bgType == VIDEO ? '.mp4' : '.png'}', playstate.linemap.theme.bgData.scaleX, playstate.linemap.theme.bgData.scaleY, playstate.linemap.theme.bgData.alpha);
                        gameBG.setVideoTime = true;
                        playstate.playstate.add(gameBG);
                    #end
                }
            }
        }

		tile_group = new FlxTypedGroup<ArrowTile>();
		playstate.add(tile_group);

        player = new Player(0, 0);
        playstate.add(player);
        camFollow = new FlxObject(player.x, player.y - 100, 1, 1);
		playstate.add(camFollow);

        playerTxt = new TextTileEffect(player.x, player.y - 100, 0, '');
        playerTxt.target = player;
        playerTxt.yOffset = -50;
        playerTxt.xOffset = -40;
        playerTxt.setFormat(Assets.font("extenro-bold"), 15, FlxColor.CYAN, CENTER, OUTLINE, FlxColor.WHITE);
        playerTxt.borderSize = 0.5;
        playerTxt.updateHitbox();
        playstate.add(playerTxt);

        holdRenderer = new HoldRenderer();
        playstate.add(holdRenderer);
    }
    public function destroy() {};
}