package funkin.backend.scripting.lua;

import funkin.backend.shaders.CustomShader;

class ShaderFunctions {
	public static function getShaderFunctions(?script:Script):Map<String, Dynamic> {
		return [
			"initShader" => function(name:String, ?glslVersion:Int = 120) {
				if(!Options.gameplayShaders) return;

				if(PlayState.instance.luaObjects["SHADER"].exists(name)) {
					Logs.trace('Shader ${name} already initialized', WARNING);
					return;
				}

				var cShader = new CustomShader(name, Std.string(glslVersion));

				PlayState.instance.luaObjects["SHADER"].set(name, cShader);
			},
			"addShader" => function(object:String, shader:String) {
				if(!Options.gameplayShaders) return;

				if(!PlayState.instance.luaObjects["SHADER"].exists(shader)) {
					Logs.trace('Shader ${shader} not found', ERROR);
					return;
				}

				var object:Dynamic = LuaTools.getObject(object);

				if(object != null) {
					var cShader:CustomShader = PlayState.instance.luaObjects["SHADER"].get(shader);
					if(object is FlxSprite) {
						cast(object, FlxSprite).shader = cShader;
					}
					else if(object is FlxCamera) {
						cast(object, FlxCamera).addShader(cShader);
					}
					else {
						return;
					}
				}
			},
			"removeShader" => function(object:String, ?shader:String) {
				var object:Dynamic = LuaTools.getObject(object);

				if(object != null) {
					if(object is FlxSprite) {
						cast(object, FlxSprite).shader = null;
						PlayState.instance.luaObjects["SHADER"].set(shader, null); //Sets the shader null
						PlayState.instance.luaObjects["SHADER"].remove(shader); //Removes the shader from the map
						return;
					}
					else if(object is FlxCamera) {
						if(shader != null && shader.trim() != "") {
							var cShader:CustomShader = PlayState.instance.luaObjects["SHADER"].get(shader);
							cast(object, FlxCamera).removeShader(cShader);
							PlayState.instance.luaObjects["SHADER"].set(shader, null); //Sets the shader null
							PlayState.instance.luaObjects["SHADER"].remove(shader); //Removes the shader from the map
						}
						return;
					}
				}
			},
			"getShaderField" => function(shader:String, field:String) {
				if(PlayState.instance.luaObjects["SHADER"].exists(shader)) {
					var cShader:CustomShader = PlayState.instance.luaObjects["SHADER"].get(shader);
					return cShader.hget(field);
				}
				else {
					Logs.trace('Shader ${shader} not found', ERROR);
					return null;
				}
			},
			"setShaderField" => function(shader:String, field:String, value:Dynamic) {
				if(PlayState.instance.luaObjects["SHADER"].exists(shader)) {
					var cShader:CustomShader = PlayState.instance.luaObjects["SHADER"].get(shader);
					cShader.hset(field, value);
					return;
				}
				else {
					Logs.trace('Shader ${shader} not found', ERROR);
				}
			}
		];
	}
}