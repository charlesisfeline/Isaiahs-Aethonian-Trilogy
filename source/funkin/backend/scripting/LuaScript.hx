package funkin.backend.scripting;
#if ENABLE_LUA
import flixel.FlxState;
import funkin.backend.scripting.lua.*;

import haxe.DynamicAccess;
import haxe.io.Path;

import llua.Lua;
import llua.LuaL;
import llua.State;
import llua.Convert;
import llua.Macro.*;

import openfl.utils.Assets;

using llua.Lua;
using llua.LuaL;
using llua.Convert;

class LuaScript extends Script{
    /**
     * TODO: rewrite the Lua Scripting completely, since many code lines are grabbed from Psych.
	 * It will have the same Lua implementation from official CNE "lua-test" branch
     */
    public var state:State = null;
	public var luaPath:String = '';
    public var callbacks:Map<String, Dynamic> = new Map<String, Dynamic>();

	public var parent:ParentObject;

	public static var curLuaScript:LuaScript = null;

	public function new(path:String) {
		parent = {
			instance: cast(FlxG.state, MusicBeatState),
			parent: cast(FlxG.state, MusicBeatState)
		};

		super(path, true);
		rawPath = path;
		path = Paths.getFilenameFromLibFile(path);

		fileName = Path.withoutDirectory(path);
		extension = Path.extension(path);
		this.path = path;
		onCreate(path);
		if(parent.instance != null) {
			setCallbacks(); // Sets all the callbacks
		}
		addCallback("disableScript", function() {
			close();
		}, true);
		funkin.backend.system.framerate.LuaInfo.luaCount += 1;
	}

    public override function onCreate(path:String) {

        state = LuaL.newstate();
		Lua.set_callbacks_function(cpp.Callable.fromStaticFunction(callback_handler));
		LuaL.openlibs(state);
		Lua.register_hxtrace_func(cpp.Callable.fromStaticFunction(print_function));
		state.register_hxtrace_lib();

		this.luaPath = path.trim();
		
        set('Event_Cancel', LuaTools.Event_Cancel);
        set('Event_Continue', LuaTools.Event_Continue);
		//set('chartingMode', PlayState.chartingMode);

		#if GLOBAL_SCRIPT
		funkin.backend.scripting.GlobalScript.call("onScriptCreated", [null, "luascript"]);
		#end
    }

    public override function onLoad() {
        var code = Assets.getText(path);
		if(code != null && code.trim() != "") {
			if (state.dostring(code) != 0)
            this.error('${state.tostring(-1)}');
		}
    }

    public override function onCall(funcName:String, args:Array<Dynamic>):Dynamic {
		curLuaScript = this;
		try {
			if(state == null) return LuaTools.Event_Continue;

			Lua.getglobal(state, funcName);
			var type = Lua.type(state, -1);

			if (type != Lua.LUA_TFUNCTION) 
			{
				if (type > Lua.LUA_TNIL)
					Logs.trace("ERROR (" + funcName + "): attempt to call a " + LuaTools.typeToString(type) + " value", ERROR);

				Lua.pop(state, 1);
				return LuaTools.Event_Continue;
			}

			for (arg in args) Convert.toLua(state, arg);
			var status:Int = Lua.pcall(state, args.length, 1, 0);

			if (status != Lua.LUA_OK) {
				var error:String = getErrorMessage(status);
				Logs.trace("ERROR (" + funcName + "): " + error, ERROR);
				return LuaTools.Event_Continue;
			}

			var result:Dynamic = cast Convert.fromLua(state, -1);
			if (result == null) result = LuaTools.Event_Continue;

			Lua.pop(state, 1);
			return result;
		}
		catch(e)
		{
			trace(e);
		}
		
		return LuaTools.Event_Continue;
    }

    public override function set(variable:String, value:Dynamic) {
        if(state == null) return;

		Convert.toLua(state, value);
		Lua.setglobal(state, variable);
    }

	function setCallbacks() {
		if(parent.instance is PlayState) {
			for(k=>e in LuaPlayState.getPlayStateVariables(this)) {
				set(k, e);
			}
			for(k=>e in LuaPlayState.getPlayStateFunctions(this)) {
				addCallback(k, e);
			}
			for(k=>e in TweenFunctions.getNotITGTweenFunctions(parent.instance, this)) {
				addCallback(k, e);
			}
			for (k => e in HScriptFunctions.getHScriptFunctions(this))
			{
				switch (k)
				{
					case "executeScript":
						addCallback(k, e, true);
					default:
						addCallback(k, e);
				}
			}
		}
		
		for(k=>e in SpriteFunctions.getSpriteFunctions(parent.instance, this)) {
			addCallback(k, e);
		}
		for(k=>e in TweenFunctions.getTweenFunctions(parent.instance, this)) {
			addCallback(k, e);
		}
		for(k=>e in ReflectionFunctions.getReflectFunctions(parent.instance, this)) {
			addCallback(k, e);
		}
		for(k=>e in UtilFunctions.getUtilFunctions(parent.instance, this)) {
			addCallback(k, e);
		}
		for(k=>e in ShaderFunctions.getShaderFunctions(parent.instance, this)) {
			switch(k) {
				case "initShader" | "addShader": 
					addCallback(k, e, true);
				default:
					addCallback(k, e);
			}
		}
		for(k=>e in OptionsVariables.getOptionsVariables(this)) {
			set(k, e);
		}
	}

	public function addCallback(funcName:String, func:Dynamic, ?isLocal:Bool = false) {
		if(isLocal)
			callbacks.set(funcName, func);
		Lua_helper.add_callback(state, funcName, (isLocal) ? null : func);
	}

	public override function destroy() {
		close();
	}

    public override function reload() {
        Logs.trace('Hot-reloading is currently not supported on Lua.', WARNING);
    }

    public override function setParent(variable:Dynamic) {
		parent.parent = variable;
	}

	public override function setPublicMap(map:Map<String, Dynamic>) {
		//Logs.trace('Set-Public-Map is currently not available on Lua.', WARNING);
	}

	public function getErrorMessage(status:Int):String {
		var v:String = Lua.tostring(state, -1);
		Lua.pop(state, 1);

		if (v != null) v = v.trim();
		if (v == null || v == "") {
			switch(status) {
				case Lua.LUA_ERRRUN: return "Runtime Error";
				case Lua.LUA_ERRMEM: return "Memory Allocation Error";
				case Lua.LUA_ERRERR: return "Critical Error";
			}
			return "Unknown Error";
		}

		return v;
		return null;
	}

	public override function loadFromString(code:String):Script {
		if(this.state.dostring(code) != 0) {
			this.error('${state.tostring(-1)}');
			return null;
		}

		return this;
	}

	public function close()
	{
		if(state == null) {
			return;
		}
		this.active = false;
		Lua.close(state);
		state = null;
		funkin.backend.system.framerate.LuaInfo.luaCount -= 1;
	}

	static inline function print_function(s:String) : Int {
		if (Script.curScript != null)
            Script.curScript.trace(s);
		return 0;
	}

	// Grabbed from Psych (I'll try to adapt it with the CNE Lua Test implementation, I promise...)
	public static function callback_handler(l:State, fname:String):Int
	{
		try
		{
			// trace('calling $fname');
			var cbf:Dynamic = Lua_helper.callbacks.get(fname);

			// Local functions have the lowest priority
			// This is to prevent a "for" loop being called in every single operation,
			// so that it only loops on reserved/special functions
			if (cbf == null)
			{
				// trace('checking last script');
				var last:LuaScript = LuaScript.curLuaScript;
				if (last == null || last.state != l)
				{
					// trace('looping thru scripts');
					for (script in PlayState.instance.scripts.scripts)
						if (script is LuaScript)
						{
							var luaScript:LuaScript = cast(script, LuaScript);
							if (luaScript != LuaScript.curLuaScript && luaScript != null && luaScript.state == l)
							{
								// trace('found script');
								cbf = luaScript.callbacks.get(fname);
								break;
							}
						}
				}
				else
					cbf = last.callbacks.get(fname);
			}

			if (cbf == null)
				return 0;

			var nparams:Int = Lua.gettop(l);
			var args:Array<Dynamic> = [];

			for (i in 0...nparams)
			{
				args[i] = Convert.fromLua(l, i + 1);
			}

			var ret:Dynamic = null;
			/* return the number of results */

			ret = Reflect.callMethod(null, cbf, args);

			if (ret != null)
			{
				Convert.toLua(l, ret);
				return 1;
			}
		}
		catch (e:Dynamic)
		{
			if (Lua_helper.sendErrorsToLua)
			{
				LuaL.error(l, 'CALLBACK ERROR! ${if (e.message != null) e.message else e}');
				return 0;
			}
			trace(e);
			throw(e);
		}
		return 0;
	}
}

typedef ParentObject =
{
	var instance:MusicBeatState;
	var parent:Dynamic;
}
#end
