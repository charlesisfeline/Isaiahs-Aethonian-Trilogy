package funkin;

class OopsState extends MusicBeatState
{
    public function new()
    {
        super();
    }

    override function create()
    {
        super.create();
        
        FlxG.resetGame(); // just restart the game lol
    }
    
    override function update(elapsed:Float)
    {
        super.update(elapsed);
    }
}