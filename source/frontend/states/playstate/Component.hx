package frontend.states.playstate;

interface Component {
    public var playstate:PlayState;

    public function create():Void;
    public function destroy():Void;
    public function update(elapsed:Float):Void;
}