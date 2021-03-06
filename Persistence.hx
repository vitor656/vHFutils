package vHFutils;

import flixel.util.FlxSave;

class Persistence 
{

    private inline static var SAVE_DATA : String = "HAXEFLIXELGAME";
    public static var save : FlxSave;

    public static function saveScore()
    {
        save = new FlxSave();

        if(save.bind(SAVE_DATA)){
            if(save.data.score == null || save.data.score < Reg.score){
                save.data.score = Reg.score;
            }
        }

        save.flush();
    }

    public static function loadScore()
    {
        save = new FlxSave();
		
		if (save.bind(SAVE_DATA)) {
			if (save.data != null && save.data.score != null) {
				return save.data.score;
			}
		}
		
		return 0;
    }

}