package states;


import game.backend.utils.InitUtil;
import flixel.math.FlxMath;
import openfl.events.Event;
import sys.thread.Thread;
import openfl.net.URLRequest;
import openfl.events.IOErrorEvent;
import openfl.net.URLLoader;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;

/**
 * That one animation that starts when the game boots up.
 */
class IntroState extends FlxState {
    public static var _boxSize:Int = 72;
    public static var _scaleDec:Float = 0.3;

	var playerBox:FlxSprite;
	var tileBox:FlxSprite;
	var ltText:FlxText;
    
    var playing:Bool = false;
    var finishedIntro:Bool = false;
    
    var doneLoading:Bool = false;
    var loadingStages:Float = 2;
    var curLoadingStage:Float = 0;
    var lerpAngle:Float = 0;
    var lerpProg:Float;
    var progBar:FlxBar;

	override function create():Void
	{
        preLoadGame();
        loadIntro();
        animateIntro();

		super.create();
	}

    function loadIntro():Void {
        // Player Box sprite
        var _centerOffset:Float = 90;
 
        playerBox = new FlxSprite().makeGraphic(_boxSize, _boxSize);
        playerBox.x = ((FlxG.width - playerBox.width) * 0.5) - _centerOffset;
        playerBox.screenCenter(Y);
        add(playerBox);

        // Tile Box sprite
        tileBox = new FlxSprite().loadGraphic(Assets.image("Gameplay", 'arrow-tile'));
        tileBox.setGraphicSize(playerBox.frameWidth, playerBox.frameHeight);
        tileBox.updateHitbox();
        tileBox.x = ((FlxG.width - tileBox.width) * 0.5) + _centerOffset;
        tileBox.screenCenter(Y);
        add(tileBox);

        // Text underneath it
        ltText = new FlxText(0,0,-1,"LINETAPPER",20);
		ltText.setFormat(Assets.font("extenro-bold"), 18, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		ltText.screenCenter(X);
        ltText.y = playerBox.y + playerBox.height + 20;
        add(ltText);

        progBar = new FlxBar(0, FlxG.height * 0.9, FlxBarFillDirection.LEFT_TO_RIGHT, 601, 35, this, 'lerpProg', 0, loadingStages, true);
		progBar.scale.x = 2;
		progBar.scale.y = 1.2;
		progBar.screenCenter(X);
		progBar.scrollFactor.set();
		progBar.createFilledBar(FlxColor.BLACK, FlxColor.WHITE, true, FlxColor.WHITE);
		add(progBar);
        progBar.alpha = 0;
    }

    var _textFlicker:Bool = false;
    function animateIntro() {
        var _tweenXOffset:Float = 30;

        playerBox.x -= _tweenXOffset;
        tileBox.x += _tweenXOffset;
        ltText.y += _tweenXOffset;

        ltText.alpha = playerBox.alpha = tileBox.alpha = 0;

        // Actually animating it (yeah this is horrible.)
        new FlxTimer().start(1,(_)->{ // Make a little wait here
            // LineTapper Sequence
            FlxTween.tween(playerBox, {x: playerBox.x+_tweenXOffset, alpha: 1}, 0.5, {ease:FlxEase.expoOut});
            FlxTween.tween(tileBox, {x: tileBox.x-_tweenXOffset, alpha: 1}, 0.5, {ease:FlxEase.expoOut, onComplete: (_)->{
                _textFlicker = true;
                FlxTween.tween(ltText, {y: ltText.y-_tweenXOffset}, 0.5, {ease:FlxEase.expoOut, onComplete:(_)->{
                    new FlxTimer().start(0.5,(_)->{
                        // Loading Sequence
                        var xTarget:Float = (FlxG.width - playerBox.width) * 0.5;
                        _textFlicker = true;
                        FlxTween.tween(ltText, {y: ltText.y+_tweenXOffset}, 0.5, {ease:FlxEase.expoOut, onComplete:(_)->{
                            ltText.text = "LOADING...";
                            ltText.screenCenter(X);
                            ltText.x += 10;
                            ltText.alpha = 0;
                            FlxTween.tween(ltText, {y: ltText.y-_tweenXOffset, alpha:1}, 0.5, {ease:FlxEase.expoOut});
                            FlxTween.tween(playerBox.scale, {x: playerBox.scale.x - _scaleDec, y: playerBox.scale.y - _scaleDec}, 0.5, {ease:FlxEase.expoOut});
                        }});

                        FlxTween.tween(playerBox, {x: xTarget}, 0.5, {ease:FlxEase.expoOut});
                        FlxTween.tween(tileBox, {x: xTarget}, 0.5, {ease:FlxEase.expoOut, onComplete:(_)->{
                            tileBox.kill();
                            tileBox.destroy();
                            remove(tileBox);
                            finishedIntro = true;
                            FlxTween.tween(progBar, {alpha:1}, 0.5, {ease:FlxEase.circIn});
                            postLoadGame();
                        }});
                    });
                }});
            }});
        });
    }

    function preLoadGame()
    {
        InitUtil.initTheme();
    }

    function postLoadGame()
    {
        // I love threads
        Thread.create(() -> {
            InitUtil.loadUser();
            curLoadingStage++;
            InitUtil.loadProfileImage();
            curLoadingStage++;
            doneLoading = true;
        });
    }

    

    override function update(elapsed:Float) {
        flickerEffectUpdate(elapsed);
        loadingSeqUpdate(elapsed);

        if (FlxG.keys.justPressed.SPACE) 
            FlxG.resetState();
        if (FlxG.keys.justPressed.ESCAPE){
            FlxG.sound.playMusic(Assets.sound('Main Menu', 'menu-music'), 1, false);
            FlxG.sound.pause();
            FlxG.sound.music.time = 6850;
            FlxG.sound.resume();
            FlxG.switchState(new MenuDebugState());
        }
        lerpProg = FlxMath.lerp(curLoadingStage, lerpProg, 0.9);
        if (lerpProg >= curLoadingStage - 1 + 0.9)
            lerpProg = curLoadingStage;
        super.update(elapsed);
    }

    var _rotateTime:Float = 0;
    var progBarTween:FlxTween;
    function loadingSeqUpdate(elapsed:Float) {
        if (!finishedIntro) return;
        if (doneLoading) {
            lerpAngle = FlxMath.lerp(0, lerpAngle, 0.9);
            playerBox.angle = lerpAngle;
            if (progBarTween == null)
                progBar.alpha = 1;
            if (!playing){
                playing = true;
                FlxG.sound.playMusic(Assets.sound('Main Menu', 'menu-music'));
                FlxTween.tween(ltText, {alpha:0}, 2, {ease:FlxEase.circIn, onComplete:(_)->{
                    ltText.destroy();
                    remove(ltText);
                }});
                progBarTween = FlxTween.tween(progBar, {alpha:0}, 2, {ease:FlxEase.circIn, onComplete:(_)->{
                    progBar.destroy();
                    remove(progBar);
                }});
                progBarTween.start();
                new FlxTimer().start(5.5, function(_){
                    FlxG.switchState(new MenuState(true));
                });
            }   
        } else {
            _rotateTime += elapsed;
            playerBox.angle = FlxEase.expoInOut(_rotateTime%1)*(-90);
            lerpAngle = FlxEase.expoInOut(_rotateTime%1)*(-90);
        }
   
    }

    /**
     * Flicker effect thing
     */
     
    var _flickerDelay:Float = 0.03;
    var _curFlickTime:Float = 0;
    var _curFlickPos:Float = 0;
    var _flickerEndTime:Float = 0.3;
    function flickerEffectUpdate(elapsed:Float) {
        if (!_textFlicker) return;

        _curFlickTime += elapsed;
        _curFlickPos += elapsed;
        if (_curFlickTime > _flickerDelay){
            if (_rotateTime < 3)
                ltText.alpha = 1 - ltText.alpha;
            _curFlickTime = 0;
        }

        if (_curFlickPos > _flickerEndTime) {
            _textFlicker = false;
            _curFlickPos = 0;
        }

    }
}