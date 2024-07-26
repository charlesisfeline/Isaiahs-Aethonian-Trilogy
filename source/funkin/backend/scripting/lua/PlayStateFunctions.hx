package funkin.backend.scripting.lua;
#if ENABLE_LUA
import funkin.backend.system.Conductor;
import funkin.backend.scripting.lua.LuaTools;
import funkin.backend.chart.ChartData.ChartEvent;
import flixel.util.typeLimit.OneOfThree;

import llua.Lua.Lua_helper;
import llua.*;

class PlayStateFunctions {
	public static function getPlayStateFunctions():Map<String, Dynamic> {
		return [
			"callFunction" => function(script:String, func:String, ?args:Array<OneOfThree<Int, Float, Bool>>) {
				if(args == null)
					args = [];

				PlayState.instance.scripts.call(func, args);
				return;
			},
			"executeEvent" => function(event:String, args:Array<String>){
				var event:ChartEvent = {name: event, time: Conductor.songPosition, params: args};
				PlayState.instance.executeEvent(event);
			},
			"shake" => function(camera:String, amount:Float, time:Float) {
				LuaTools.getCamera(camera.toLowerCase()).shake(amount, time);
			},
			"createFunkinSprite" => function(name:String, ?imagePath:String = null, ?x:Float = 0, ?y:Float = 0)
			{
				var theSprite:FunkinSprite = new FunkinSprite(x, y);
				if(imagePath != null && imagePath.length > 0)
					theSprite.loadGraphic(Paths.image(imagePath));
				PlayState.instance.luaSprites.set(name, theSprite);
				theSprite.active = true;
			},
			"addFunkinSprite" => function(name:String, ?camera:String = "camGame") {
				var sprite:FunkinSprite = null;
				if(PlayState.instance.luaSprites.exists(name))
					sprite = PlayState.instance.luaSprites.get(name);

				if(sprite == null) return;
				
				PlayState.instance.add(sprite);
				sprite.cameras = [LuaTools.getCamera(camera.toLowerCase())];
			}
		];
	}

	public static function implement(hehe:LuaScript, functions:Map<String, Dynamic>) {
		var state = hehe.state;
	}
}
#end
