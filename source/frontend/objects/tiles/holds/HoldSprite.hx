package frontend.objects.tiles.holds;

import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.tweens.FlxTween;
import backend.Conductor;

class HoldSprite extends FlxSprite {
    public var tile:ArrowTile;
    public var fadeSteps:Float = 2;
    public var targetStepDist:Float = 15;
    public var stepDistSecs:Float = 0;
    public var isCenter:Bool = false;
    var step_sec:Float = 0;
    var called:Bool = false;
    var stepDist:Float = 0;
    var dying:Bool = false;

    override public function new(tile:ArrowTile, ?X:Float = 0, ?Y:Float = 0, ?SimpleGraphic:FlxGraphicAsset)
    {
        super(X, Y, SimpleGraphic);
        this.tile = tile;
        alpha = 0;
        step_sec = Conductor.instance.step_ms / 1000;
        stepDistSecs = step_sec * fadeSteps;
    }
    
    override public function update(elapsed:Float)
    {
        super.update(elapsed);
        color = tile.color;
        stepDist = Math.abs(Conductor.instance.current_steps - tile.step);
        dying = tile.dying;
        if (stepDist <= targetStepDist && !called && !dying){
            alpha += 2 * elapsed;
            tile.alpha = alpha;
        }
        if (alpha > 0.3 && isCenter)
            alpha = 0.3;
        if (dying)
            alpha -= 2 * elapsed;
    }
}

class HoldSpriteContainer extends flixel.FlxBasic
{
    public var bg:HoldSprite;
    public var topBar:HoldSprite;
    public var bottomBar:HoldSprite;

    override public function new() { super(); }
}