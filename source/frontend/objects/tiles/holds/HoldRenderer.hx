package frontend.objects.tiles.holds;

import frontend.objects.tiles.holds.HoldRendererInstructions;
import frontend.objects.tiles.holds.HoldSprite.HoldSpriteContainer;
import flixel.group.FlxGroup;

class HoldRenderer extends FlxGroup
{
    public var holdAssets:Array<HoldSpriteContainer> = [];
    public var instructionSet:HoldRendererInstructions;

    override public function new() {
        super();
        instructionSet = new HoldRendererInstructions(null, null, this);
    }

    public function generateHold(tile:ArrowTile, spr1:FlxSprite, spr2:FlxSprite, regenHold:Bool = true)
    {
        if (regenHold){
            for (hold in holdAssets){
                holdAssets.remove(hold);
                hold = null;
            }
        }
        instructionSet.spr1 = spr1;
        instructionSet.spr2 = spr2;
        instructionSet.runInstructionSet(tile);
        for (hold in holdAssets)
        {
            if (members.indexOf(hold) == -1){
                add(hold.bg);
                add(hold.topBar);
                add(hold.bottomBar);
            }
        }
    }
}
