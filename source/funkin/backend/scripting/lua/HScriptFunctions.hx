package funkin.backend.scripting.lua;

class HScriptFunctions {
	public static function getHScriptFunctions(?script:Script):Map<String, Dynamic> {
		#if ENABLE_LUA
		return [
			"executeScript"	=> function(code:String, ?funcName:String = null, ?funcArgs:Array<Dynamic> = null) {
				var script = Script.fromString(code, script.path, false);
				script.loadFromString(code);
				PlayState.instance.scripts.add(script);
				script.load();
			}
		];
		#else
		return null;
		#end
	}
}