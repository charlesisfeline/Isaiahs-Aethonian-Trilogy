package funkin.backend.system;

import flixel.FlxGame;

class FunkinGame extends FlxGame {
	var skipNextTickUpdate:Bool = false;
	public override function switchState() {
		super.switchState();
		// draw once to put all images in gpu then put the last update time to now to prevent lag spikes or whatever
		draw();
		_total = ticks = getTicks();
		skipNextTickUpdate = true;
	}

	override function create(_:Event)
    {
        try
        {
            super.create(_);
        }
        catch (e:Exception)
        {
            return onCrash(e);
        }
    }
    
    override function update()
    {
        try
        {
            super.update();
        }
        catch (e:Exception)
        {
            return onCrash(e);
        }
    }
    
    override function draw()
    {
        try
        {
            super.draw();
        }
        catch (e:Exception)
        {
            return onCrash(e);
        }
    }
    
    public override function onEnterFrame(_:Event)
    {
        try
        {
			if (skipNextTickUpdate != (skipNextTickUpdate = false))
				_total = ticks = getTicks();

            super.onEnterFrame(_);
        }
        catch (e:Exception)
        {
            return onCrash(e);
        }
    }
    
    override function onFocus(_:Event)
    {
        try
        {
            super.onFocus(_);
        }
        catch (e:Exception)
        {
            return onCrash(e);
        }
    }
    
    override function onFocusLost(event:flash.events.Event)
    {
        try
        {
            super.onFocusLost(event);
        }
        catch (e:Exception)
        {
            return onCrash(e);
        }
    }
    
    override function onResize(_:Event)
    {
        try
        {
            super.onResize(_);
        }
        catch (e:Exception)
        {
            return onCrash(e);
        }
    }

    private function onCrash<T:Exception>(e:T)
    {
        var errorStack:Array<StackItem> = CallStack.exceptionStack(true);
        
        var fileStack:String = '';
        var controlsText:String = '';
        controlsText += '\nRestarting game...';
        
        trace("an error occured: " + e.toString());
        for (item in errorStack)
        {
            switch (item)
            {
                case FilePos(s, file, line, column):
                    fileStack += '${file} (line ${line})\n';
                    Sys.println('${file} (line ${line})');
                default:
                    #if sys
                    Sys.println(item);
                    #end
            }
        }
        trace("get restarted bitch");
        
        // we need to switch to the state instantly
        // otherwise it won't actually do it sometimes
        FlxTransitionableState.skipNextTransIn = true;
        FlxTransitionableState.skipNextTransOut = true;
        
        return FlxG.switchState(Type.createInstance(OopsState, []));
    }
}