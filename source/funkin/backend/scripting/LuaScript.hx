package funkin.backend.scripting;

import funkin.backend.scripting.lua.HScriptFunctions;
import funkin.backend.scripting.lua.ReflectionFunctions;
#if ENABLE_LUA
import funkin.backend.scripting.lua.TweenFunctions;
import haxe.io.Path;
import funkin.backend.scripting.lua.LuaPlayState;
import funkin.backend.scripting.lua.LuaTools;
import flixel.FlxState;

import llua.Lua;
import llua.LuaL;
import llua.State;
import llua.Convert;
import llua.Macro.*;
import haxe.DynamicAccess;

import openfl.utils.Assets;

using llua.Lua;
using llua.LuaL;
using llua.Convert;

class LuaScript extends Script{

    public var state:State = null;
	public var luaPath:String = '';
    public var callbacks:Map<String, Dynamic> = [];

	var game:MusicBeatState;

	public static function getPlayStateVariables(?script:Script):Map<String, Dynamic> {
		return LuaPlayState.getPlayStateVariables();
	}

	public function new(path:String) {
		game = PlayState.instance;

		super(path, true);
		rawPath = path;
		path = Paths.getFilenameFromLibFile(path);

		fileName = Path.withoutDirectory(path);
		extension = Path.extension(path);
		this.path = path;
		onCreate(path);
		if(game != null) {
			for(k=>e in LuaPlayState.getPlayStateVariables(this)) {
				set(k, e);
			}
			for(k=>e in LuaPlayState.getPlayStateFunctions()) {
				addCallback(k, e);
			}
			for(k=>e in ReflectionFunctions.getReflectFunctions(game, this)) {
				addCallback(k, e);
			}
			for(k=>e in HScriptFunctions.getHScriptFunctions(this)) {
				addCallback(k, e);
			}
		}
		for(k=>e in LuaPlayState.getOptionsVariables(this)) {
			set(k, e);
		}
		for(k=>e in TweenFunctions.getTweenFunctions(this)) {
			addCallback(k, e);
		}
		
		addCallback("disableScript", function() {
			close();
		});
	}

    public override function onCreate(path:String) {

        state = LuaL.newstate();
		LuaL.openlibs(state);

		this.luaPath = path.trim();
		//For now, it only executes on PlayState
		//game.stateScripts.scripts.push(this);
		
        set('Event_Cancel', LuaTools.Event_Cancel);
        set('Event_Continue', LuaTools.Event_Continue);
		set('chartingMode', false);

		#if GLOBAL_SCRIPT
		funkin.backend.scripting.GlobalScript.call("onScriptCreated", [null, "luascript"]);
		#end
    }

    public override function onLoad() {
        if (state.dostring(Assets.getText(path)) != 0)
            this.error('${state.tostring(-1)}');
    }

    public override function onCall(funcName:String, args:Array<Dynamic>):Dynamic {
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

	public function addCallback(funcName:String, func:Dynamic) {
		Lua_helper.add_callback(state, funcName, func);
	}

	public override function destroy() {
		close();
	}

    public override function reload() {
        Logs.trace('Hot-reloading is currently not supported on Lua.', WARNING);
    }

    public override function setParent(variable:Dynamic) {
		Logs.trace('Set-Parent is currently not available on Lua.', WARNING);
	}

	public override function setPublicMap(map:Map<String, Dynamic>) {
		Logs.trace('Set-Public-Map is currently not available on Lua.', WARNING);
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
		// TODO: Lua execution from String
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
	}
}
#end
