package funkin.backend.scripting;

import funkin.backend.scripting.lua.LuaTools;
import flixel.util.FlxStringUtil;
import funkin.backend.scripting.events.CancellableEvent;

@:access(CancellableEvent)
class ScriptPack extends Script {
	public var scripts:Array<Script> = [];
	public var additionalDefaultVariables:Map<String, Dynamic> = [];
	public var publicVariables:Map<String, Dynamic> = [];
	public var parent:Dynamic = null;

	public override function load() {
		for(e in scripts) {
			e.load();
		}
	}

	public function contains(path:String) {
		for(e in scripts)
			if (e.path == path)
				return true;
		return false;
	}
	public function new(name:String) {
		additionalDefaultVariables["importScript"] = importScript;
		super(name);
	}

	public function getByPath(name:String) {
		for(s in scripts)
			if (s.path == name)
				return s;
		return null;
	}

	public function getByName(name:String) {
		for(s in scripts)
			if (s.fileName == name)
				return s;
		return null;
	}
	public function importScript(path:String):Script {
		var script = Script.create(Paths.script(path));
		if (script is DummyScript) {
			throw 'Script at ${path} does not exist.';
			return null;
		}
		add(script);
		script.load();
		return script;
	}

	public override function call(func:String, ?parameters:Array<Dynamic>):Dynamic {
		for(e in scripts) {
			if(e is LuaScript) continue;
			if(e.active) 
				e.call(func, parameters);
		}
		return null;
	}

	public function luaCall(func:String, ?parameters:Array<Dynamic>):Dynamic {
		var rv:Dynamic = LuaTools.Event_Continue;
		#if ENABLE_LUA
		for(e in scripts) {
			if(!(e is LuaScript)) continue;
			if(e.active) {
				var value:Dynamic = e.call(func, parameters);
				if(value == LuaTools.Event_Cancel) {
					rv = value;
					return rv;
				}
				if(value != null)
					rv = value;
			}	
		}
		#end
		return rv;
	}

	/**
	 * Sends an event to every single script, and returns the event.
	 * @param func Function to call
	 * @param event Event (will be the first parameter of the function)
	 * @return (modified by scripts)
	 */
	public inline function event<T:CancellableEvent>(func:String, event:T):T {
		for(e in scripts) {
			if(!e.active) continue;
			if(e is LuaScript) continue;
			e.call(func, [event]);
			if (event.cancelled && !event.__continueCalls) break;
		}
		return event;
	}

	public inline function luaEvent(func:String, values:Array<Dynamic>):Dynamic {
		
		var event:Dynamic = LuaTools.Event_Continue;
		#if ENABLE_LUA
		for(e in scripts) {
			if(!(e is LuaScript)) continue;
			event = e.call(func, values);
			if(event == LuaTools.Event_Cancel) 
				break;
		}
		#end
		return event;
	}

	public override function get(val:String):Dynamic {
		for(e in scripts) {
			var v = e.get(val);
			if (v != null) return v;
		}
		return null;
	}

	public override function reload() {
		for(e in scripts) e.reload();
	}

	public override function set(val:String, value:Dynamic) {
		for(e in scripts){
			if(e is LuaScript) continue;
			e.set(val, value);
		} 
	}

	public function luaSet(val:String, value:Dynamic) {
		for(e in scripts) {
			if(!(e is LuaScript)) return;
			e.set(val, value);
		}
	}

	public override function setParent(parent:Dynamic) {
		this.parent = parent;
		for(e in scripts) e.setParent(parent);
	}

	public override function destroy() {
		super.destroy();
		for(e in scripts) e.destroy();
	}

	public override function onCreate(path:String) {}

	public function add(script:Script) {
		scripts.push(script);
		__configureNewScript(script);
	}

	public function remove(script:Script) {
		scripts.remove(script);
	}

	public function insert(pos:Int, script:Script) {
		scripts.insert(pos, script);
		__configureNewScript(script);
	}

	private function __configureNewScript(script:Script) {
		if (parent != null) script.setParent(parent);
		script.setPublicMap(publicVariables);
		for(k=>e in additionalDefaultVariables) {
			if(script is LuaScript)
				switch(k) {
					case "importScript":
						cast(script, LuaScript).addCallback(k, function(path:String) {
							var script = Script.create(Paths.script(path));
							if (script is DummyScript)
							{
								Logs.trace('Script at ${path} does not exist.', ERROR);
								return;
							}
							add(script);
							script.load();
							return;
						});
				}
			else
				script.set(k, e);
		}
	}

	override public function toString():String {
		return FlxStringUtil.getDebugString([
			LabelValuePair.weak("parent", FlxStringUtil.getClassName(parent, true)),
			LabelValuePair.weak("total", scripts.length),
		]);
	}
}