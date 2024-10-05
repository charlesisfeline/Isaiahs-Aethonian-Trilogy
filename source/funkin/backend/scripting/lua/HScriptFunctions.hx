package funkin.backend.scripting.lua;

class HScriptFunctions {
	//No tested yet
	public static function getHScriptFunctions(?instance:MusicBeatState, ?script:Script):Map<String, Dynamic> {
		#if ENABLE_LUA
		return [
			"executeScript"	=> function(name:String, code:String) {
				var _script:Script = Script.fromString(code, '${haxe.io.Path.withoutExtension(script.path)}_${name}.hx', false);
				instance.luaObjects["SCRIPTS"].set(name, _script);
				_script.load();
				//var _script = Script.fromString(code, '${haxe.io.Path.withoutExtension(script.path)}.hx', false);
				//PlayState.instance.scripts.add(_script);
			},
			"callScriptFunction" => function(name:String, func:String, args:Array<Dynamic>):Dynamic {
				if(!instance.luaObjects["SCRIPTS"].exists(name)) return null;

				var _script:HScript = instance.luaObjects["SCRIPTS"].get(name);
				return _script.call(func, args);
			},
			"pushVar" => function(name:String, varName:String, variable:Dynamic) {
				if(!instance.luaObjects["SCRIPTS"].exists(name)) return;

				var _script:HScript = instance.luaObjects["SCRIPTS"].get(name);
				_script.set(varName, variable);
			},
			"stopScript" => function(name:String) {
				if(!instance.luaObjects["SCRIPTS"].exists(name)) return;

				var _script:HScript = instance.luaObjects["SCRIPTS"].get(name);
				_script.active = false;
				instance.luaObjects["SCRIPTS"].remove(name);
				_script.destroy();
			}
		];
		#else
		return null;
		#end
	}
}