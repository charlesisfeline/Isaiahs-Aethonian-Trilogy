package funkin.backend.scripting.lua;

#if ENABLE_LUA
class ReflectionFunctions
{
	public static function getReflectFunctions(instance:MusicBeatState, ?script:Script):Map<String, Dynamic>
	{
		return [
			"getField" => function(field:String) {
				var obj = instance;
				
				if(obj == null) return null;

				return LuaTools.getValueFromVariable(obj, field);
			},
			"getObjectField" => function(object:String, field:String) {
				var obj:Dynamic = LuaTools.getObject(object);

				if(obj == null) return null;

				return LuaTools.getValueFromVariable(obj, field);
			},
			"getClassField" => function(className:String, field:String) {
				var cl:Class<Dynamic> = Type.resolveClass(className);
				var value:Dynamic = null;

				if (cl != null)
				{
					value = LuaTools.getValueFromVariable(cl, field);
				}
				else
				{
					Logs.trace('getClassField: Invalid Class', ERROR);
				}
				return value;
			},
			"setField" => function(field:String, value:Dynamic) {
				var obj:Dynamic = instance;

				if (obj == null) return null;

				return LuaTools.setValueToVariable(obj, field, value);
			},
			"setObjectField" => function(object:String, field:String, value:Dynamic) {
				var obj:Dynamic = LuaTools.getObject(object);

				if(obj == null) return null;

				return LuaTools.setValueToVariable(obj, field, value);
			},
			"setClassField" => function(className:String, field:String, value:Dynamic) {
				var cl:Class<Dynamic> = Type.resolveClass(className);
				if (cl == null)
				{
					Logs.trace('getClassField: Invalid Class', ERROR);
					return null;
				}
				return LuaTools.setValueToVariable(cl, field, value);
			}
		];
	}
}
#end
