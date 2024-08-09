package funkin.backend.scripting.lua;

import funkin.backend.shaders.CustomShader;

class ShaderFunctions {
	public static function getShaderFunctions(instance:MusicBeatState, ?script:Script):Map<String, Dynamic> {
		return [
			"initShader" => function(name:String, ?glslVersion:Int = 120) {
				if(!Options.gameplayShaders) return;

				if(instance.luaObjects["SHADER"].exists(name)) {
					Logs.trace('Shader ${name} already initialized', WARNING);
					return;
				}

				var cShader = new CustomShader(name, Std.string(glslVersion));

				instance.luaObjects["SHADER"].set(name, cShader);
			},
			"addShader" => function(object:String, shader:String) {
				if(!Options.gameplayShaders) return;

				if(!instance.luaObjects["SHADER"].exists(shader)) {
					Logs.trace('Shader ${shader} not found', ERROR);
					return;
				}

				var object:Dynamic = LuaTools.getObject(instance, object);
				var cShader:CustomShader = instance.luaObjects["SHADER"].get(shader);

				if(object != null) {
					
					if(object is FlxSprite) {
						cast(object, FlxSprite).shader = cShader;
					}
					else if(object is FlxCamera) {
						cast(object, FlxCamera).addShader(cShader);
					}
				}
				else {
					LuaTools.getCamera("default").addShader(cShader); //Adds the shader to the current state camera
					return;
				}
			},
			"removeShader" => function(object:String, ?shader:String) {
				if(!Options.gameplayShaders) return;

				var object:Dynamic = LuaTools.getObject(instance, object);

				if (object != null && (shader != null && shader.trim() != ""))
				{
					if (object is FlxSprite)
					{
						cast(object, FlxSprite).shader = null;
						instance.luaObjects["SHADER"].set(shader, null); // Sets the shader null
						instance.luaObjects["SHADER"].remove(shader); // Removes the shader from the map
						return;
					}
					else if (object is FlxCamera) // TODO: optimize the remove from map
					{
						var cShader:CustomShader = instance.luaObjects["SHADER"].get(shader);
						if (cShader == null)
							return;
						cast(object, FlxCamera).removeShader(cShader);
						instance.luaObjects["SHADER"].set(shader, null); // Sets the shader null
						instance.luaObjects["SHADER"].remove(shader); // Removes the shader from the map
						return;
					}
				}
				else {
					var cShader:CustomShader = instance.luaObjects["SHADER"].get(shader);
					if (cShader == null)
						return;
					LuaTools.getCamera("default").removeShader(cShader); //Removes the shader to the current state camera
					instance.luaObjects["SHADER"].set(shader, null); // Sets the shader null
					instance.luaObjects["SHADER"].remove(shader); // Removes the shader from the map
					return;
				}
			},
			"getShaderField" => function(shader:String, field:String) {
				if(!Options.gameplayShaders) return null;

				var cShader:CustomShader = instance.luaObjects["SHADER"].get(shader);
				if (cShader != null)
					return cShader.hget(field);
				else
				{
					Logs.trace('Shader ${shader} not found', ERROR);
					return null;
				}
			},
			"setShaderField" => function(shader:String, field:String, value:Dynamic) {
				if(!Options.gameplayShaders) return;

				var cShader:CustomShader = instance.luaObjects["SHADER"].get(shader);
				if (cShader != null)
					cShader.hset(field, value);
				else
				{
					Logs.trace('Shader ${shader} not found', ERROR);
					return;
				}
			}
		];
	}
}