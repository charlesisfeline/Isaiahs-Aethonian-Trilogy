package funkin.backend.scripting.lua;
#if ENABLE_LUA
import flixel.tweens.*;
import flixel.tweens.FlxTween.FlxTweenType;

class TweenFunctions {
	
	public static function getTweenFunctions(instance:MusicBeatState, ?script:Script):Map<String, Dynamic> {
		return [
			"tween" 	=> function(tweenName:String, object:String, property:String, value:Dynamic, duration:Float, ease:String, type:String, timeDelayed:Int = 0) {
				var objectToTween:Dynamic = LuaTools.getObject(instance, object);
				var propertyToUse:Dynamic = null;
				if(objectToTween == null) return;
				switch(property){
					case 'x': propertyToUse = {x: value};
					case 'y': propertyToUse = {y: value};
					case 'alpha' : propertyToUse = {alpha: value};
					case 'angle' : propertyToUse = {angle: value};
					default: return; // Don't try to do the tween
				};
				// cancels the current tween of the selected object
				if(instance.luaObjects["TWEEN"].exists(tweenName)){
					cast(instance.luaObjects["TWEEN"].get(tweenName), FlxTween).cancel();
					instance.luaObjects["TWEEN"].remove(tweenName); // Redundant since Map.set() overwrite the value of the same key
				}

				instance.luaObjects["TWEEN"].set(tweenName, FlxTween.tween(objectToTween, propertyToUse, duration, 
				{
					ease: LuaTools.getEase(ease), 
					type: LuaTools.getTweenType(type), 
					startDelay: timeDelayed,
					onComplete: (_) -> {
						// Prevents removing itself on "Loop" tween type (LOOPING, PINGPONG or PERSIST)
						if(_.type == FlxTweenType.ONESHOT || _.type == FlxTweenType.BACKWARD)
							instance.luaObjects["TWEEN"].remove(tweenName);
						script.call('onTweenFinished', [tweenName]);
					}
				}));
			},
			"cancelTween" => function(tweenName:String) {
				// cancels the current specified tween and remove it from the map
				if(instance.luaObjects["TWEEN"].exists(tweenName)) {
					cast(instance.luaObjects["TWEEN"].get(tweenName), FlxTween).cancel();
					instance.luaObjects["TWEEN"].remove(tweenName);
				}
			}
		];
	}
	
}
#end
