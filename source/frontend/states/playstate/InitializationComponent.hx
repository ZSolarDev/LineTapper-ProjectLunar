package frontend.states.playstate;

import backend.script.ScriptGroup;
import frontend.objects.tiles.ArrowTile;

import frontend.states.playstate.GameComponent;
import frontend.states.playstate.HudComponent;
import frontend.states.playstate.SongComponent;

class InitializationComponent implements Component {
    public var playstate:PlayState;
    public var gameComponent:GameComponent;
    public var hudComponent:HudComponent;
    public var songComponent:SongComponent;

    public function new(instance:PlayState, gameComponent:GameComponent, hudComponent:HudComponent, songComponent:SongComponent) {
        playstate = instance;
        this.gameComponent = gameComponent;
        this.hudComponent = hudComponent;
        this.songComponent = songComponent;
    }

    public function create() {
        songComponent.initSong();
		playstate.scripts = new ScriptGroup('maps/${songComponent.mapName}/scripts/');
		playstate.scripts.executeFunc("create");
        
        gameComponent.songComponent = songComponent;
		gameComponent.initCameras();
		gameComponent.create();
        songComponent.gameComponent = gameComponent;
		hudComponent.create();

        songComponent.ratings = new Map<TileRating, Rating>();
        songComponent.ratings = [
            PERFECT => {count: 0, arrowTiles: []},
            COOL => {count: 0, arrowTiles: []},
            MEH => {count: 0, arrowTiles: []},
            MISS => {count: 0, arrowTiles: []},
        ];

		songComponent.loadSong();
		FlxG.camera.follow(gameComponent.camFollow, LOCKON);
		playstate.scripts.executeFunc("postCreate");
    }
    public function destroy() {};
    public function update(elapsed:Float) {};
}