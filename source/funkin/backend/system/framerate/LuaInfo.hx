package funkin.backend.system.framerate;

class LuaInfo extends FramerateCategory {
	
	public static var luaCount:Int = 0;

	public function new() {
		super("Lua Info");
	}

	public override function __enterFrame(t:Int) {
		if (alpha <= 0.05) return;

		_text = 'Version: ${llua.Lua.version()}';
		_text += '\nScript Count: ${(luaCount < 0) ? (luaCount = 0) : luaCount}';

		this.text.text = _text;
		super.__enterFrame(t);
	}
}
