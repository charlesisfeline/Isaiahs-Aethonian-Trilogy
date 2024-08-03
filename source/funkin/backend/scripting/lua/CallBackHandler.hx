package funkin.backend.scripting.lua;
#if ENABLE_LUA
import llua.Lua;
import llua.LuaL;
import llua.State;
import llua.Convert;

class CallBackHandler
{
	public static function init()
	{
		//Lua.set_callbacks_function(cpp.Callable.fromStaticFunction(CallBackHandler.call));
	}

	// Grabbed from Psych
	
}
#end
