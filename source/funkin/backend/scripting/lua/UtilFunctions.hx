package funkin.backend.scripting.lua;

import funkin.backend.scripting.lua.events.TimerEvent;
import funkin.backend.scripting.events.DynamicEvent;
import flixel.util.FlxTimer;

final class UtilFunctions {
	public static function getUtilFunctions(instance:MusicBeatState, ?script:Script):Map<String, Dynamic> {
		return [
			"callStateFunction" => function(func:String, ?args:Array<Dynamic>) {
				instance.call(func, args);
				//PlayState.instance.scripts.call(func, args);
				return;
			},
			"lerp" => function(v1:Float, v2:Float, ratio:Float, fps:Bool = false) {
				return instance.lerp(v1, v2, ratio, fps);
			},
			"setTimer" => function(name:String, delay:Float = 1, times:Int = 1) {
				var timer = new FlxTimer();
				timer.time = delay;
				timer.loops = times;
				instance.luaObjects["TIMERS"].set(name, timer);
			},
			"startTimer" => function(name:String) {
				var timer:FlxTimer = instance.luaObjects["TIMERS"].get(name);
				timer.start(timer.time, (_) -> {
					var event:TimerEvent = cast(script, LuaScript).event("onTimer", EventManager.get(TimerEvent).recycle(name, timer.loopsLeft, timer.timeLeft, timer.progress, timer.finished));
					if(_.finished || event.cancelled)  {
						_.cancel();
						instance.luaObjects["TIMERS"].remove(name);
						_.destroy();
					}
				}, timer.loops);
			},
			"cancelTimer" => function(name:String) {
				var timer:FlxTimer = instance.luaObjects["TIMERS"].get(name);
				timer.cancel();
				instance.luaObjects["TIMERS"].remove(name);
				timer.destroy();
			}
		];
	}
}