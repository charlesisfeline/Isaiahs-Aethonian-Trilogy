package funkin.backend.scripting.lua;
#if ENABLE_LUA
class ReflectionFunctions {
	public static function getReflectFunctions(instance:Dynamic, ?script:Script):Map<String, Dynamic> {
		return [
			"getField" 		=> function(field:String) {
				return Reflect.getProperty(instance, field);
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