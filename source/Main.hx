package;

import backend.utils.NativeUtil;
import lime.app.Application;
import flixel.FlxGame;
import backend.Conductor;
import openfl.display.Sprite;

class Main extends Sprite
{
	public static var _conductor:Conductor;
	public var STARTING_STATE = frontend.states.IntroState;
	public function new()
	{
		super();
		_conductor = new Conductor();

		NativeUtil.setDPIAware();

		addChild(new FlxGame(0, 0, STARTING_STATE, 120,120,true,false));
		//addChild(new objects.SystemInfo(10,10,0xFFFFFF,false));
		FlxG.fixedTimestep = FlxG.autoPause = false;
        FlxSprite.defaultAntialiasing = true;

		NativeUtil.setWindowDarkMode(Application.current.window.title, true);
	}
}
