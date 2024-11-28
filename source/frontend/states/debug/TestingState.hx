package frontend.states.debug;

import frontend.objects.tiles.holds.HoldRenderer;
import frontend.objects.Player;

class TestingState extends StateBase {
    var tile1:FlxSprite;
    var tile2:FlxSprite;
    var holdRenderer:HoldRenderer;
    override function create() {
        super.create();
        tile1 = new FlxSprite(0, 0, Assets.image('Gameplay', 'arrow-tile'));
        tile1.screenCenter();
        tile1.setGraphicSize(Player.BOX_SIZE, Player.BOX_SIZE);
        tile1.updateHitbox();
        add(tile1);
        tile2 = new FlxSprite(tile1.x + 200, tile1.y, Assets.image('Gameplay', 'arrow-tile'));
        add(tile2);
        tile2.setGraphicSize(Player.BOX_SIZE, Player.BOX_SIZE);
        tile2.updateHitbox();
        //holdRenderer = new HoldRenderer();
        //add(holdRenderer);
        //holdRenderer.generateHold(tile1, tile2);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        if (FlxG.keys.justPressed.ESCAPE)
            switchState(new frontend.states.MenuState());
    }
}