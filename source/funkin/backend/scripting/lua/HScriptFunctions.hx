package funkin.backend.scripting.lua;

class HScriptFunctions {
	public static function getHScriptFunctions(?script:Script):Map<String, Dynamic> {
		#if ENABLE_LUA
		return [
			"executeScript"	=> function(code:String) {
				var _script = Script.fromString(code, '${haxe.io.Path.withoutExtension(script.path)}.hx', false);
				PlayState.instance.scripts.add(_script);
			},
			"stopScript" => function() {
				var _script = PlayState.instance.scripts.getByPath('${haxe.io.Path.withoutExtension(script.path)}.hx');
				_script.active = false;
			}
		];
		#else
		return null;
		#end
	}
}