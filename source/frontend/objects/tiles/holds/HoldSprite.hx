package frontend.objects.tiles.holds;

import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.tweens.FlxTween;
import backend.Conductor;

class HoldSprite extends FlxSprite {
    public var tile:ArrowTile;
    public var targetStepDist:Float = 2;
    public var stepDistSecs:Float = 0;
    public var isCenter:Bool = false;
    var step_sec:Float = 0;
    var called:Bool = false;
    var stepDist:Float = 0;

    override public function new(tile:ArrowTile, ?X:Float = 0, ?Y:Float = 0, ?SimpleGraphic:FlxGraphicAsset)
    {
        super(X, Y, SimpleGraphic);
        this.tile = tile;
        alpha = 0;
        step_sec = Conductor.instance.step_ms / 1000;
        stepDistSecs = step_sec * targetStepDist;
    }
    
    override public function update(elapsed:Float)
    {
        super.update(elapsed);
        color = tile.color;
        stepDist = Math.abs(Conductor.instance.current_steps - tile.step);
        if (isCenter){
            if (tile.alpha < 0.3)
                alpha = tile.alpha;
        }else
            alpha = tile.alpha;
        if (stepDist <= targetStepDist && !called){
            called = true;
            if (isCenter)
                FlxTween.tween(this, {alpha: 0.3}, stepDistSecs);
            else
                FlxTween.tween(this, {alpha: 1}, stepDistSecs);
        }
    }
}

class HoldSpriteContainer extends flixel.FlxBasic
{
    public var bg:HoldSprite;
    public var topBar:HoldSprite;
    public var bottomBar:HoldSprite;

    override public function new() { super(); }
}