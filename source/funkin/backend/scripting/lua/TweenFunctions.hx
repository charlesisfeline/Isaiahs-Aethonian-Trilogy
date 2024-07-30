package funkin.backend.scripting.lua;
#if ENABLE_LUA
import flixel.tweens.*;

class TweenFunctions {
	
	public static function getTweenFunctions(?script:Script):Map<String, Dynamic> {
		return [
			"tween" 	=> function(tweenName:String, object:String, property:String, value:Dynamic, duration:Float, ease:String, type:String, timeDelayed:Int = 0) {
				var objectToTween = LuaTools.getObject(object);
				var propertyToUse:Dynamic = null;
				switch(property){
					case 'x': propertyToUse = {x: value};
					case 'y': propertyToUse = {y: value};
					case 'alpha' : propertyToUse = {alpha: value};
					case 'angle' : propertyToUse = {angle: value};
					default: return; // Don't try to do the tween
				};
				// cancels the current tween of the selected object
				FlxTween.cancelTweensOf(objectToTween);

				FlxTween.tween(objectToTween, propertyToUse, duration, 
				{
					ease: LuaTools.getEase(ease), 
					type: LuaTools.getTweenType(type), 
					startDelay: timeDelayed,
					onComplete: (_) -> {
						script.call('onTweenFinished', [tweenName, object]);
					}
				});
			}
		];
	}
	
}
#end
