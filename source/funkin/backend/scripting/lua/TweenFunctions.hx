package funkin.backend.scripting.lua;
#if ENABLE_LUA
import flixel.tweens.*;
import flixel.tweens.FlxTween.FlxTweenType;

class TweenFunctions {
	
	public static function getTweenFunctions(instance:MusicBeatState, ?script:Script):Map<String, Dynamic> {
		return [
			"tween" 	=> function(tweenName:String, object:String, property:String, value:Dynamic, duration:Float, ease:String, type:String, timeDelayed:Int = 0) {
				var obj = object.split(".");
				var objectToTween:Dynamic = LuaTools.getObject(instance, obj[0]);
				// Ex: tween("invert", "camHUD.flashSprite", "scaleX", getField("camHUD", "flashSprite.scaleX") * -1, 0.5)
				if(obj.length > 1) {
					var objectVars = object.substring(object.indexOf(".") + 1);
					objectToTween = LuaTools.getValueFromVariable(objectToTween, objectVars);
				}
				var propertyToUse = {};
				if(objectToTween == null) return;
				switch(property){ //most common property uses
					case 'x': propertyToUse = {x: value};
					case 'y': propertyToUse = {y: value};
					case 'alpha' : propertyToUse = {alpha: value};
					case 'angle' : propertyToUse = {angle: value};
					default: Reflect.setField(propertyToUse, property, value);
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
	
	public static function getNotITGTweenFunctions(instance:MusicBeatState, ?script:Script):Map<String, Dynamic> {
		if(!(instance is PlayState)) return null;
		return [
			"tweenNote" => function(tweenName:String, strumLine:Int, note:Int, property:String, value:Dynamic, duration:Float, ease:String, type:String, timeDelayed:Int = 0) {
				var strumlineToUse:funkin.game.StrumLine = PlayState.instance.strumLines.members[strumLine];
				var propertyToUse = {};
				if(strumlineToUse == null) return;
				if(note < 1 || note > 4) return; // Only note index between 1 - 4
				switch(property){
					case 'x': propertyToUse = {x: value};
					case 'y': propertyToUse = {y: value};
					case 'alpha' : propertyToUse = {alpha: value};
					case 'angle' : propertyToUse = {angle: value};
					case 'skew.x' : propertyToUse = {"skew.x": value};
					case 'skew.y' : propertyToUse = {"skew.y": value};
					default: Reflect.setField(propertyToUse, property, value);
				};

				if(instance.luaObjects["TWEEN"].exists(tweenName)){
					cast(instance.luaObjects["TWEEN"].get(tweenName), FlxTween).cancel();
					instance.luaObjects["TWEEN"].remove(tweenName); // Redundant since Map.set() overwrite the value of the same key
				}

				instance.luaObjects["TWEEN"].set(tweenName, FlxTween.tween(strumlineToUse.members[note - 1], propertyToUse, duration, 
				{
					ease: LuaTools.getEase(ease),
					type: LuaTools.getTweenType(type),
					startDelay: timeDelayed,
					onComplete: (_) ->
					{
						// Prevents removing itself on "Loop" tween type (LOOPING, PINGPONG or PERSIST)
						if (_.type == FlxTweenType.ONESHOT || _.type == FlxTweenType.BACKWARD)
							instance.luaObjects["TWEEN"].remove(tweenName);
						script.call('onTweenFinished', [tweenName]);
					}
				}));
			}
		];
	}
}
#end
