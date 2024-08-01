package funkin.backend.scripting.lua;
#if ENABLE_LUA
class ReflectionFunctions {
	public static function getReflectFunctions(instance:MusicBeatState, ?script:Script):Map<String, Dynamic> {
		return [
			"getField" 		=> function(field:String) {
				return Reflect.getProperty(instance, field);
			},
			"getObjectField" => function(object:String, field:String) {
				var obj:Dynamic = null;
				if(instance.luaObjects["SPRITE"].exists(object))
					obj = instance.luaObjects["SPRITE"].get(object);
				else if(instance.luaObjects["TEXT"].exists(object))
					obj = instance.luaObjects["TEXT"].get(object);
				
				var value:Dynamic = null;

				if(obj != null) {
					value = Reflect.getProperty(obj, field);
				}

				return value;
			},
			"getClassField" => function(className:String, field:String) {
				var cl:Class<Dynamic> = Type.resolveClass(className);
				if(cl == null) {
					Logs.trace('getClassField: Invalid Class', ERROR);
					return null;
				}
				return Reflect.getProperty(cl, field);
			},
			"setField" 		=> function(field:String, value:Dynamic) {
				Reflect.setProperty(instance, field, value);
				return value;
			},
			"setObjectField" => function(object:String, field:String, value:Dynamic) {
				var obj:Dynamic = null;
				if(instance.luaObjects["SPRITE"].exists(object))
					obj = instance.luaObjects["SPRITE"].get(object);
				else if(instance.luaObjects["TEXT"].exists(object))
					obj = instance.luaObjects["TEXT"].get(object);

				if(obj != null) {
					Reflect.setProperty(obj, field, value);
				}
				return value;
			},
			"setClassField" => function(className:String, field:String, value:Dynamic) {
				var cl:Class<Dynamic> = Type.resolveClass(className);
				if(cl == null) {
					Logs.trace('getClassField: Invalid Class', ERROR);
					return null;
				}
				Reflect.setProperty(cl, field, value);
				return value;
			}
		];
	}
}
#end