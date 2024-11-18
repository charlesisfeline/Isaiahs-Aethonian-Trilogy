import funkin.game.PlayState;
import funkin.game.StrumLine;
var bot:Bool = false;
function update(elapsed) {
	if(FlxG.keys.justPressed.TAB) {
		bot = !bot;
	}
	for(text in [scoreTxt, missesTxt, accuracyTxt]) {
		text.visible = !bot;
	}
	if(bot) {
		for(no in playerStrums.notes) {
			if(no.strumTime < Conductor.songPosition && !no.wasGoodHit && !no.avoid) {
				goodNoteHit(playerStrums, no);
			}
		}
	}
	
	
}