package game.backend.script;

class ScriptState extends FlxState {
    public var script:Script;

    override public function new(scriptPath:String) {
        
        script = new Script(scriptPath);
        if (script.interp == null)
            trace('Invalid script path!');
        else{
            script.setVariable('add', add);
            script.setVariable('Parent', this);
            callScriptMethod('new');
        }
        super();
        if (script.interp != null)
            callScriptMethod('newPost');
    }

    override public function create()
    {
        callScriptMethod('create');
        super.create();
        callScriptMethod('createPost');
    }

    override public function update(elapsed:Float)
    {
        callScriptMethod('update', [elapsed]);
        super.update(elapsed);
        callScriptMethod('updatePost', [elapsed]);
    }

    override public function destroy()
    {
        callScriptMethod('destroy');
        script.interp = null;
        script = null;
    }

    function callScriptMethod(name:String, ?args:Array<Any>)
    {
        if (script.interp != null)
            script.executeFunc(name, args);
    }
}