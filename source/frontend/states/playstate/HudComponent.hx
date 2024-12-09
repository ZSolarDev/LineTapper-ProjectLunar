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

class HudComponent implements Component {
    public var playstate:PlayState;
    public var songComponent:SongComponent;

    public var scoreBoard:FlxText;
	
	public var lyricText:FlxText;
    public var timeBar:FlxBar;
	public var timeTextLeft:FlxText;
	public var timeTextRight:FlxText;

    public function new(instance:PlayState, songComponent:SongComponent) {
        playstate = instance;
        this.songComponent = songComponent;
    }
    
    public function update(elapsed:Float) {
        if (!songComponent.mapEnded){
		    if (FlxG.sound.music != null && FlxG.sound.music.playing){
                Conductor.instance.time = FlxG.sound.music.time;
                var strBuf:StringBuf = new StringBuf();
                if (songComponent.using_autoplay) strBuf.add('Autoplay Mode\n');
                strBuf.add(playstate.hitStatus);
                strBuf.add('\nCombo: ${songComponent.combo}X');
                strBuf.add('\nScore: ${songComponent.score}');
                scoreBoard.text = strBuf.toString();
		    } else {
		    	scoreBoard.text = "[ PRESS SPACE TO START ]\nControls: WASD / Arrow Keys";
		    }
		    scoreBoard.scale.y = scoreBoard.scale.x = FlxMath.lerp(1, scoreBoard.scale.x, 1 - (elapsed * 24));
		    scoreBoard.setPosition(20 + (scoreBoard.width - scoreBoard.frameWidth), FlxG.height - (scoreBoard.height + 20));
		    scoreBoard.screenCenter(X);
        
		    lyricText.text = songComponent.lyrics.getLyric(Conductor.instance.time);
		    lyricText.setPosition(0,FlxG.height - (scoreBoard.height + 80));
		    lyricText.screenCenter(X);
        
		    timeBar.percent = (Conductor.instance.time / FlxG.sound.music.length)*100;
		    timeTextLeft.text = Common.formatMS(Conductor.instance.time);
		    timeTextRight.text =  Common.formatMS(FlxG.sound.music.length);
		    timeTextRight.x = FlxG.width - (timeTextRight.width+10);
        }
	}

    public function create() {
        inline function makeText(nX:Float,nY:Float,label:String, size:Int, ?bold:Bool = false, ?align:FlxTextAlign):FlxText {
			var obj:FlxText = new FlxText(nX, nY, -1, label);
			obj.setFormat(Assets.font("extenro"+(bold?"-bold":"")), size, FlxColor.WHITE, align, OUTLINE, FlxColor.BLACK);
			obj.cameras = [songComponent.gameComponent.hudCamera];
			obj.active = false;
			return obj;
		}
		// HUD Text Objects. //
		scoreBoard = makeText(20, 20, "", 14, true, LEFT);
		playstate.add(scoreBoard);

		lyricText = makeText(20, 20, "", 14, false, CENTER);
		playstate.add(lyricText);

		// Time Bar Objects. //
		timeBar = new FlxBar(0,0,LEFT_TO_RIGHT, FlxG.width,5,null,"",0,1,false);
		timeBar.numDivisions = 2000; // uhhh
		timeBar.createFilledBar(0x00000000, 0xFFFFFFFF);
		timeBar.cameras = [songComponent.gameComponent.hudCamera];
		playstate.add(timeBar);
		
		var startY:Float = timeBar.y + timeBar.height + 5;

		timeTextLeft = makeText(10, startY, "", 12, false, LEFT);
		playstate.add(timeTextLeft);

		timeTextRight = makeText(FlxG.width, startY, "", 12, false, LEFT);
		timeTextRight.x -= timeTextRight.width;
		playstate.add(timeTextRight);
    }
    public function destroy():Void {};
}