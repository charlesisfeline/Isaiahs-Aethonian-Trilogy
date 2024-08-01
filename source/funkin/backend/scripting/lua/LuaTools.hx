package funkin.backend.scripting.lua;
import flixel.tweens.FlxTween.FlxTweenType;
#if ENABLE_LUA
import llua.Lua;
#end
class LuaTools {
	
	public static final Event_Cancel:Dynamic = "##BIRDLUA_EVENTCANCEL";
	public static final Event_Continue:Dynamic = "##BIRDLUA_EVENTCONTINUE";
	#if ENABLE_LUA
	public static function getCurrentSystem():String {
		return lime.system.System.platformName;
	}

	public static function getCamera(camera:String):FlxCamera {
		return switch(camera.trim().toLowerCase()) {
			case "camgame" | "game": PlayState.instance.camGame;
			case "camhud" | "hud": PlayState.instance.camHUD;
			default: FlxG.cameras.list[FlxG.cameras.list.length - 1];
		}
	}

	public static function typeToString(type:Int):String {
		switch(type) {
			case Lua.LUA_TBOOLEAN: return "boolean";
			case Lua.LUA_TNUMBER: return "number";
			case Lua.LUA_TSTRING: return "string";
			case Lua.LUA_TTABLE: return "table";
			case Lua.LUA_TFUNCTION: return "function";
		}
		if (type <= Lua.LUA_TNIL) return "nil";
		return "unknown";
	}

	public static function getObject(objectName:String):Dynamic
	{
		var varSplit = objectName.split('.');

		var object = getLuaObject(varSplit[0]);

		return object;
	}

	public static function getLuaObject(name:String):Dynamic {
		var object:Dynamic = null;

		if(PlayState.instance.luaObjects["SPRITE"].exists(name)) {
			object = PlayState.instance.luaObjects["SPRITE"].get(name);
		}
		else if(PlayState.instance.luaObjects["TEXT"].exists(name)) {
			object = PlayState.instance.luaObjects["TEXT"].get(name);
		}
		else if(object == null) {
			object = Reflect.getProperty(PlayState.instance, name);
		}

		return object;
	}
	// from Psych (sorry, I had to. Too much time to write it one by one)
	public static function getEase(?ease:String = '')
	{
		return switch(ease.toLowerCase().trim()) {
			case 'backin': FlxEase.backIn;
			case 'backinout': FlxEase.backInOut;
			case 'backout': FlxEase.backOut;
			case 'bouncein': FlxEase.bounceIn;
			case 'bounceinout': FlxEase.bounceInOut;
			case 'bounceout': FlxEase.bounceOut;
			case 'circin': FlxEase.circIn;
			case 'circinout': FlxEase.circInOut;
			case 'circout': FlxEase.circOut;
			case 'cubein': FlxEase.cubeIn;
			case 'cubeinout': FlxEase.cubeInOut;
			case 'cubeout': FlxEase.cubeOut;
			case 'elasticin': FlxEase.elasticIn;
			case 'elasticinout': FlxEase.elasticInOut;
			case 'elasticout': FlxEase.elasticOut;
			case 'expoin': FlxEase.expoIn;
			case 'expoinout': FlxEase.expoInOut;
			case 'expoout': FlxEase.expoOut;
			case 'quadin': FlxEase.quadIn;
			case 'quadinout': FlxEase.quadInOut;
			case 'quadout': FlxEase.quadOut;
			case 'quartin': FlxEase.quartIn;
			case 'quartinout': FlxEase.quartInOut;
			case 'quartout': FlxEase.quartOut;
			case 'quintin': FlxEase.quintIn;
			case 'quintinout': FlxEase.quintInOut;
			case 'quintout': FlxEase.quintOut;
			case 'sinein': FlxEase.sineIn;
			case 'sineinout': FlxEase.sineInOut;
			case 'sineout': FlxEase.sineOut;
			case 'smoothstepin': FlxEase.smoothStepIn;
			case 'smoothstepinout': FlxEase.smoothStepInOut;
			case 'smoothstepout': FlxEase.smoothStepInOut;
			case 'smootherstepin': FlxEase.smootherStepIn;
			case 'smootherstepinout': FlxEase.smootherStepInOut;
			case 'smootherstepout': FlxEase.smootherStepOut;
			default: FlxEase.linear;
		}
	}

	public static function getTweenType(type:String):Int {
		return switch (type.trim().toLowerCase()) {
			case 'backward' | 'reverse' : FlxTweenType.BACKWARD;
			case 'looping' | 'loop' | 'repeat' : FlxTweenType.LOOPING;
			case 'persist' : FlxTweenType.PERSIST;
			case 'pingpong' | 'boomerang' : FlxTweenType.PINGPONG;
			default: FlxTweenType.ONESHOT;
		}
	}
	#end
}

enum abstract ObjectType(String) {
	var SPRITE;
	var TWEEN;
	var SHADER;
}
