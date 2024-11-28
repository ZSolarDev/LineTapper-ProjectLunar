package frontend.objects.tiles.holds;

import frontend.objects.tiles.holds.HoldSprite.HoldSpriteContainer;

class HoldRendererInstructions
{
    public var spr1:FlxSprite;
    public var spr2:FlxSprite;
    public var renderer:HoldRenderer;

    public function new(spr1:FlxSprite, spr2:FlxSprite, renderer:HoldRenderer) {
        this.spr1 = spr1;
        this.spr2 = spr2;
        this.renderer = renderer;
    }

    public function runInstructionSet(tile:ArrowTile)
    {
        var holdSprite:HoldSpriteContainer = new HoldSpriteContainer();
        var holdMid:HoldSprite = new HoldSprite(tile);
        var holdTop:HoldSprite = new HoldSprite(tile);
        var holdBot:HoldSprite = new HoldSprite(tile);
        
        if (spr1.x != spr2.x){
            if (spr2.x > spr1.x){
                holdMid = new HoldSprite(tile, spr1.x + spr1.width, spr1.y + (spr1.height * (1.5/8)));
                holdMid.makeGraphic(Std.int(spr2.x - holdMid.x), Std.int((spr1.height * (4.5/8))));
                holdTop = new HoldSprite(tile, spr1.x + spr1.width, spr1.y + (spr1.height * (1.5/8)));
                holdTop.makeGraphic(Std.int(spr2.x - holdTop.x), Std.int((spr1.height * (0.5/8))));
                holdBot = new HoldSprite(tile, spr1.x + spr1.width, spr1.y + (spr1.height * (6/8)));
                holdBot.makeGraphic(Std.int(spr2.x - holdBot.x), Std.int((spr1.height * (0.5/8))));
            }
            if (spr2.x < spr1.x){
                holdMid = new HoldSprite(tile, spr2.x + spr2.width, spr2.y + (spr2.height * (1.5/8)));
                holdMid.makeGraphic(Std.int(spr1.x - holdMid.x), Std.int((spr2.height * (4.5/8))));
                holdTop = new HoldSprite(tile, spr2.x + spr2.width, spr2.y + (spr2.height * (1.5/8)));
                holdTop.makeGraphic(Std.int(spr1.x - holdTop.x), Std.int((spr2.height * (0.5/8))));
                holdBot = new HoldSprite(tile, spr2.x + spr2.width, spr2.y + (spr2.height * (6/8)));
                holdBot.makeGraphic(Std.int(spr1.x - holdBot.x), Std.int((spr2.height * (0.5/8))));
            }
        }
        if (spr1.y != spr2.y)
        {
            if (spr1.y > spr2.y)
            {
                holdMid = new HoldSprite(tile, spr1.x + (spr1.width * (1.5/8)), spr1.y);
                holdMid.makeGraphic(Std.int((spr1.width * (5/8))), Std.int(holdMid.y - (spr2.y + spr2.height)));
                holdMid.y = spr2.y + spr2.height;
                holdTop = new HoldSprite(tile, spr1.x + (spr1.width * (1.5/8)), spr1.y);
                holdTop.makeGraphic(Std.int((spr1.width * (0.5/8))), Std.int(holdTop.y - (spr2.y + spr2.height)));
                holdTop.y = spr2.y + spr2.height;
                holdBot = new HoldSprite(tile, spr1.x + (spr1.width * (6/8)), spr1.y);
                holdBot.makeGraphic(Std.int((spr1.width * (0.5/8))), Std.int(holdBot.y - (spr2.y + spr2.height)));
                holdBot.y = spr2.y + spr2.height;
            }
            if (spr1.y < spr2.y)
            {
                holdMid = new HoldSprite(tile, spr2.x + (spr2.width * (1.5/8)), spr2.y);
                holdMid.makeGraphic(Std.int((spr2.width * (5/8))), Std.int(holdMid.y - (spr1.y + spr1.height)));
                holdMid.y = spr1.y + spr1.height;
                holdTop = new HoldSprite(tile, spr2.x + (spr2.width * (1.5/8)), spr2.y);
                holdTop.makeGraphic(Std.int((spr2.width * (0.5/8))), Std.int(holdTop.y - (spr1.y + spr1.height)));
                holdTop.y = spr1.y + spr1.height;
                holdBot = new HoldSprite(tile, spr2.x + (spr2.width * (6/8)), spr2.y);
                holdBot.makeGraphic(Std.int((spr2.width * (0.5/8))), Std.int(holdBot.y - (spr1.y + spr1.height)));
                holdBot.y = spr1.y + spr1.height;
            }
        }
        holdMid.isCenter = true;
        holdSprite.bg = holdMid;
        holdSprite.topBar = holdTop;
        holdSprite.bottomBar = holdBot;
        renderer.holdAssets.push(holdSprite);
    }
}