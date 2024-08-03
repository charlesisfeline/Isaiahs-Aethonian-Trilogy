package funkin.backend.scripting.lua;

#if ENABLE_LUA
class ReflectionFunctions
{
	public static function getReflectFunctions(instance:MusicBeatState, ?script:Script):Map<String, Dynamic>
	{
		return [
			"getField" => function(field:String) {
				var obj = instance;
				var value:Dynamic = null;

				if(obj == null) return value;
				
				var fields = field.trim().split('.');
				if (fields.length > 1) {
					var _var:Dynamic = Reflect.getProperty(obj, fields[0]);
					for (i in 1...fields.length)
					{
						_var = Reflect.getProperty(_var, fields[i]);
					}
					value = _var;
				}
				else {
					value = Reflect.getProperty(obj, fields[0]);
				}
				return value;
				//return Reflect.getProperty(instance, field);
			},
			"getObjectField" => function(object:String, field:String) {
				var obj:Dynamic = LuaTools.getObject(object);
				var value:Dynamic = null;

				if (obj != null)
				{
					var fields = field.trim().split('.');
					if (fields.length > 1)
					{
						var _var:Dynamic = Reflect.getProperty(obj, fields[0]);
						for (i in 1...fields.length)
						{
							_var = Reflect.getProperty(_var, fields[i]);
						}
						value = _var;
					}
					else
					{
						value = Reflect.getProperty(obj, fields[0]);
					}
				}

				return value;
			},
			"getClassField" => function(className:String, field:String) {
				var cl:Class<Dynamic> = Type.resolveClass(className);
				var value:Dynamic = null;

				if (cl != null)
				{
					var fields = field.trim().split('.');
					if (fields.length > 1)
					{
						var _var:Dynamic = Reflect.getProperty(cl, fields[0]);
						for (i in 1...fields.length)
						{
							_var = Reflect.getProperty(_var, fields[i]);
						}
						value = _var;
					}
					else
					{
						value = Reflect.getProperty(cl, fields[0]);
					}
				}
				else
				{
					Logs.trace('getClassField: Invalid Class', ERROR);
					return null;
				}
				return value;
			},
			"setField" => function(field:String, value:Dynamic) {
				var obj:Dynamic = instance;

				if (obj == null) return null;

				var fields = field.trim().split('.');
				if (fields.length > 1)
				{
					var _var:Dynamic = Reflect.getProperty(obj, fields[0]);
					for (i in 1...fields.length - 1)
					{
						_var = Reflect.getProperty(_var, fields[i]);
					}
					Reflect.setProperty(_var, fields[fields.length - 1], value);
				}
				else
				{
					Reflect.setProperty(obj, fields[0], value);
				}
				
				return value;
			},
			"setObjectField" => function(object:String, field:String, value:Dynamic) {
				var obj:Dynamic = LuaTools.getObject(object);
				if (obj != null)
				{
					var fields = field.trim().split('.');
					if (fields.length > 1)
					{
						var _var:Dynamic = Reflect.getProperty(obj, fields[0]);
						for (i in 1...fields.length - 1)
						{
							_var = Reflect.getProperty(_var, fields[i]);
						}
						Reflect.setProperty(_var, fields[fields.length - 1], value);
					}
					else
					{
						Reflect.setProperty(obj, fields[0], value);
					}
				}
				return value;
			},
			"setClassField" => function(className:String, field:String, value:Dynamic) {
				var cl:Class<Dynamic> = Type.resolveClass(className);
				if (cl != null)
				{
					var fields = field.trim().split('.');
					if (fields.length > 1)
					{
						var _var:Dynamic = Reflect.getProperty(cl, fields[0]);
						for (i in 1...fields.length - 1)
						{
							_var = Reflect.getProperty(_var, fields[i]);
						}
						Reflect.setProperty(_var, fields[fields.length - 1], value);
					}
					else
					{
						Reflect.setProperty(cl, fields[0], value);
					}
				}
				else
				{
					Logs.trace('getClassField: Invalid Class', ERROR);
					return null;
				}
				return value;
			}
		];
	}
}
#end
