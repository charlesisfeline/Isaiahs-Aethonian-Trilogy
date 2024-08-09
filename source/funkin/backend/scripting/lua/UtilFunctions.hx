package funkin.backend.scripting.lua;

class UtilFunctions {
	public static function getUtilFunctions(instance:MusicBeatState, ?script:Script):Map<String, Dynamic> {
		return [
			"callStateFunction" => function(func:String, ?args:Array<Dynamic>) {
				instance.call(func, args);
				//PlayState.instance.scripts.call(func, args);
				return;
			},
			"lerp" => function(v1:Float, v2:Float, ratio:Float, fps:Bool = false) {
				return instance.lerp(v1, v2, ratio, fps);
			}
		];
	}
}