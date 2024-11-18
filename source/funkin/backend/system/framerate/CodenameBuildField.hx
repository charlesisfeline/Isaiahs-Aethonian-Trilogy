package funkin.backend.system.framerate;

import openfl.text.TextFormat;
import openfl.display.Sprite;
import openfl.text.TextField;
import funkin.backend.system.macros.GitCommitMacro;

class CodenameBuildField extends TextField {
	public function new() {
		super();
		defaultTextFormat = Framerate.textFormat;
		autoSize = LEFT;
		multiline = wordWrap = false;
		text = 'Codename Engine ${Main.releaseCycle})\nIsaiah\'s Aethonian Trilogy\n(press tab to get to the mod pls)';
		selectable = false;
	}
}
