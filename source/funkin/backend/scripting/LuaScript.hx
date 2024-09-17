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
	public var luaCallbacks:Map<String, Dynamic> = [];
	public var lastStackID:Int = 0;
    public var stack:Map<Int, Dynamic> = [];

	public var parent:ParentObject;

	public static var curLuaScript:LuaScript = null;
	
	public function new(path:String) {
		parent = {
			instance: cast(FlxG.state, MusicBeatState),
			parent: cast(FlxG.state, MusicBeatState)
		};

		super(path);
		
		if(parent.instance != null) {
			setCallbacks(); // Sets all the callbacks
		}
		
		funkin.backend.system.framerate.LuaInfo.luaCount += 1;
	}
	
    public override function onCreate(path:String) {
		super.onCreate(path);

		parent = {
			instance: cast(FlxG.state, MusicBeatState),
			parent: cast(FlxG.state, MusicBeatState)
		};

        state = LuaL.newstate();
		Lua.set_callbacks_function(cpp.Callable.fromStaticFunction(callback_handler));
		LuaL.openlibs(state);
		Lua.register_hxtrace_func(cpp.Callable.fromStaticFunction(print_function));
		state.register_hxtrace_lib();

		luaCallbacks["__onPointerIndex"] = onPointerIndex;
        luaCallbacks["__onPointerNewIndex"] = onPointerNewIndex;
        luaCallbacks["__onPointerCall"] = onPointerCall;
        luaCallbacks["__gc"] = onGarbageCollection;

		state.newmetatable("__funkinMetaTable");

        state.pushstring('__index');
        state.pushcfunction(cpp.Callable.fromStaticFunction(__index));
        state.settable(-3);
        
        state.pushstring('__newindex');
        state.pushcfunction(cpp.Callable.fromStaticFunction(__newindex));
        state.settable(-3);
        
        state.pushstring('__call');
        state.pushcfunction(cpp.Callable.fromStaticFunction(__call));
        state.settable(-3);

        state.setglobal("__funkinMetaTable");
		
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

	public static var callbackReturnVariables = [];

    public override function onCall(funcName:String, args:Array<Dynamic>):Dynamic {
		state.settop(0);
        state.getglobal(funcName);

        if (state.type(-1) != Lua.LUA_TFUNCTION)
            return LuaTools.Event_Continue;
        
        for (k=>val in args)
            pushArg(val);

        if (state.pcall(args.length, 1, 0) != 0) {
            this.error('${state.tostring(-1)}');
            return LuaTools.Event_Continue;
        }

        var v = fromLua(state.gettop());
        state.settop(0);
        return v;
    }

    public override function set(variable:String, value:Dynamic) {
		if(state == null) return;

        pushArg(value);
        state.setglobal(variable);
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
				addCallback(k, e);
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
			addCallback(k, e);
		}
		for(k=>e in OptionsVariables.getOptionsVariables(this)) {
			set(k, e);
		}
	}

	public function addCallback(funcName:String, func:Dynamic) {
		luaCallbacks.set(funcName, func);
		state.add_callback_function(funcName);
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

	public function fromLua(stackPos:Int):Dynamic {
		var ret:Any = null;

        switch(state.type(stackPos)) {
			case Lua.LUA_TNIL:
				ret = null;
			case Lua.LUA_TBOOLEAN:
				ret = state.toboolean(stackPos);
			case Lua.LUA_TNUMBER:
				ret = state.tonumber(stackPos);
			case Lua.LUA_TSTRING:
				ret = state.tostring(stackPos);
			case Lua.LUA_TTABLE:
				ret = toHaxeObj(stackPos);
			case Lua.LUA_TFUNCTION:
				null; // no support for functions yet
			// case Lua.LUA_TUSERDATA:
			// 	ret = LuaL.ref(l, Lua.LUA_REGISTRYINDEX);
			// 	trace("userdata\n");
			// case Lua.LUA_TLIGHTUSERDATA:
			// 	ret = LuaL.ref(l, Lua.LUA_REGISTRYINDEX);
			// 	trace("lightuserdata\n");
			// case Lua.LUA_TTHREAD:
			// 	ret = null;
			// 	trace("thread\n");
			case idk:
				ret = null;
				trace("return value not supported\n"+Std.string(idk)+" - "+stackPos);
		}


        if (ret is Dynamic && Reflect.hasField(ret, "__stack_id")) {
            // is a "pointer"! convert it back.
            var pos:Int = Reflect.field(ret, "__stack_id");
            return stack[pos];
        }
        return ret;
    }

	public function pushArg(val:Dynamic) {
        switch (Type.typeof(val)) {
            case Type.ValueType.TNull:
                state.pushnil();
            case Type.ValueType.TBool:
                state.pushboolean(val);
            case Type.ValueType.TInt:
                state.pushinteger(cast(val, Int));
            case Type.ValueType.TFloat:
                state.pushnumber(val);
            case Type.ValueType.TClass(String):
                state.pushstring(cast(val, String));
            case Type.ValueType.TClass(Array):
                var arr:Array<Any> = cast val;
                var size:Int = arr.length;
                state.createtable(size, 0);

                for (i in 0...size) {
                    state.pushnumber(i + 1);
                    pushArg(arr[i]);
                    state.settable(-3);
                }
            case Type.ValueType.TObject:
                @:privateAccess
                state.objectToLua(val); // {}
            default:
                
                var p = {
                    __stack_id: lastStackID++,
                };
                state.toLua(p);
                state.getmetatable("__funkinMetaTable");
                state.setmetatable(-2);
        
                state.pushstring('__gc');
                state.pushcfunction(cpp.Callable.fromStaticFunction(__gc));
                state.settable(-3);

                stack[p.__stack_id] = val;
        }
    }

	public static function __index(state:StatePointer):Int {
        return callback_handler(cast cpp.Pointer.fromRaw(state).ref, "__onPointerIndex");
    }
    public static function __newindex(state:StatePointer):Int {
        return callback_handler(cast cpp.Pointer.fromRaw(state).ref, "__onPointerNewIndex");
    }
    public static function __call(state:StatePointer):Int {
        return callback_handler(cast cpp.Pointer.fromRaw(state).ref, "__onPointerCall");
    }
    public static function __gc(state:StatePointer):Int {
        // callbackPreventAutoConvert = true;
        var v = callback_handler(cast cpp.Pointer.fromRaw(state).ref, "__gc");
        // callbackPreventAutoConvert = false;
        return v;
    }

    public function onPointerIndex(obj:Dynamic, key:String) {
		if (obj != null)
            return Reflect.getProperty(obj, key);
        return null;
    }

    public function onPointerCall(obj:Dynamic, ...args:Any) {
        trace(obj);
        trace(args);
        if (obj != null && Reflect.isFunction(obj))
            return Reflect.callMethod(null, obj, args.toArray());
        return null;
    }

    public function onPointerNewIndex(obj:Dynamic, key:String, val:Dynamic) {
		if (key == "__gc") return null;

        if (obj != null)
            Reflect.setProperty(obj, key, val);
        return null;
    }

    public function onGarbageCollection(obj:Dynamic) {
        trace(obj);
        if (Reflect.hasField(obj, "__stack_id")) {
            trace('Clearing item ID: ${obj.__stack_id} from stack due to garbage collection');
            stack.remove(obj.__stack_id);
        }
    }

	private static var callbackPreventAutoConvert:Bool = false;
	
	public static function callback_handler(l:State, fname:String):Int {

        if (!(Script.curScript is LuaScript))
            return 0;
        var curLua:LuaScript = cast Script.curScript;

		var cbf = curLua.luaCallbacks.get(fname);
        callbackReturnVariables = [];
        
		if (cbf == null || !Reflect.isFunction(cbf)) {
			trace('${fname} is null / not a function');
			return 0;
		}

		var nparams:Int = Lua.gettop(l);
		var args:Array<Dynamic> = callbackPreventAutoConvert ? [for(i in 0...nparams) l.fromLua(-nparams + i)] : [for(i in 0...nparams) curLua.fromLua(-nparams + i)];

		var ret:Dynamic = null;

        try {
            ret = (nparams > 0) ? Reflect.callMethod(null, cbf, args) : cbf();
        } catch(e) {
            curLua.error(e.details()); // for super cool mega logging!!!
            throw e;
        }
        Lua.settop(l, 0);

        if (callbackReturnVariables.length <= 0)
            callbackReturnVariables.push(ret);
        for(e in callbackReturnVariables)
            curLua.pushArg(e);

		/* return the number of results */
		return callbackReturnVariables.length;

	}

	public function toHaxeObj(i:Int):Any {
		var count = 0;
		var array = true;

		loopTable(state, i, {
			if(array) {
				if(Lua.type(state, -2) != Lua.LUA_TNUMBER) array = false;
				else {
					var index = Lua.tonumber(state, -2);
					if(index < 0 || Std.int(index) != index) array = false;
				}
			}
			count++;
		});

		return
		if(count == 0) {
			{};
		} else if(array) {
			var v = [];
			loopTable(state, i, {
				var index = Std.int(Lua.tonumber(state, -2)) - 1;
				v[index] = fromLua(-1);
			});
			cast v;
		} else {
			var v:DynamicAccess<Any> = {};
			loopTable(state, i, {
				switch Lua.type(state, -2) {
					case t if(t == Lua.LUA_TSTRING): v.set(Lua.tostring(state, -2), fromLua(-1));
					case t if(t == Lua.LUA_TNUMBER):v.set(Std.string(Lua.tonumber(state, -2)), fromLua(-1));
				}
			});
			cast v;
		}
	}

	// Grabbed from Psych (I'll try to adapt it with the CNE Lua Test implementation, I promise...)
	public static function psych_callback_handler(l:State, fname:String):Int
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
