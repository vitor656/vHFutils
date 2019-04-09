package vHFutils;

import openfl.Assets;
import flixel.addons.text.FlxTypeText;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxTimer;
import flixel.FlxState;
import flixel.FlxBasic;
import flixel.util.FlxColor;

/*

How to use it:

Declare a Dialogue variable in the Main State class 

Ex:
_dialogue = new Dialogue();
add(_dialogue);
_dialogue.startDialogue(this, "teste");

*/

// Add this manager to the current State to manage messages properly
class DialogueManager extends FlxBasic
{

    public inline static var DELAY_NORMAL:Float = 0.3;
    public inline static var DELAY_FAST:Float = 0.05;

    private var _padding:Int = 5;
    private var _outsideMargin:Int = 10;
    private var _fontSize:Int = 16;
	private var _clickOnComplete:Bool;
	private var _fasterOnClick:Bool;
	private var _onBox:Bool;
	
	public var dialogueFinished : Bool;

    private var _typeText : FlxTypeText;
    private var _messageBox : FlxSprite;
    private var _messages : Array<String>;
    private var _currentIndex : Int;
    public var currentMessage : String;
    public var loadedDialogueId : String;

    private var _clickToContinue : Bool;
    
    public function new(?x:Float = 0, ?y:Float = 0, ?clickOnComplete:Bool = false, 
		?fasterOnClick:Bool = false)
    {
        super();
    
		_clickOnComplete = clickOnComplete;
		_fasterOnClick = fasterOnClick;
		loadDialogueReceiver(x, y);
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        if(_typeText != null){  
            if(_clickToContinue){
                if(ControlsManager.justPressedConfirm())
                    loadNextmessage();
            } else {
				
				if (_fasterOnClick){
					if(ControlsManager.pressedConfirm())
						_typeText.delay = DELAY_FAST;
					else
						_typeText.delay = DELAY_NORMAL;
				}
            }
        }
    }

    public function loadDialogueReceiver(?x:Float = 0, ?y:Float = 0)
    {
        if(_onBox){
                  
        } else {
			if (_typeText != null){
				_typeText.reset(0, 0);
			} else{
				_typeText = new FlxTypeText(x, y, Std.int(FlxG.width/2), "", _fontSize, true);
			}
            
        }

        _typeText.skipKeys = [];
        _typeText.scrollFactor.set(0, 0);

    }

    public function startDialogue(?state:FlxState, ?id:String)
    {
		dialogueFinished = false;
		
        if(_typeText == null || !_typeText.alive){
            loadDialogueReceiver();
        }

        if(id != null && id != ""){
            loadDialogue(id);
        }

        if(_typeText != null){

            if(_onBox){

                _messageBox.screenCenter();
                _messageBox.y = (FlxG.height - _messageBox.height) - _outsideMargin;
                _messageBox.scrollFactor.set(0, 0);

                _typeText.x = _messageBox.x + _padding;
                _typeText.y = _messageBox.y + _padding;
                _typeText.width = _messageBox.width - (_padding * 2);

                state.add(_messageBox);
            }

            //Adiciona somente se carregou a lista de mensagens pela primeira vez
            if(_currentIndex == 0)
                state.add(_typeText);
           
            keepDialogueGoing();
        }
    }

    private function keepDialogueGoing()
    {
        if(_messages != null && _messages.length > 0){
            _clickToContinue = false;
            _typeText.resetText(currentMessage);
			
            if(!_clickOnComplete)
				_typeText.start(DELAY_NORMAL, false, false, onCompleteWait);
			else
				_typeText.start(DELAY_NORMAL, false, false, onCompleteClick);

        } else {
            trace("No messages loaded...");
        }
    }

    // Load messages from some kind of file maybe?
    public function loadDialogue(id:String)
    {
        _messages = new Array<String>();

        switch(id){
            case "hello":
                _messages.push("Hello world.");
                _messages.push("Ut mattis nisl id nisl porta bibendum.");
                _messages.push("Nullam id libero sit amet lorem gravida vestibulum.");
        }

        _currentIndex = 0;
        loadedDialogueId = id;
        currentMessage = _messages[_currentIndex];
    }

    private function loadFromFile(fileName : String) : Array<String> 
    {
        return Assets.getText(fileName).split("@@");
    }

    private function onCompleteWait():Void
    {
        new FlxTimer().start(3, function(_){

            loadNextmessage();

        });
    }

    private function onCompleteClick():Void
    {
        _clickToContinue = true;
    }

    private function loadNextmessage(){
        if(_messages != null && _typeText != null){
            _currentIndex++;
            if(_currentIndex < _messages.length){
                currentMessage = _messages[_currentIndex];
                keepDialogueGoing();
            } else {
				dialogueFinished = true;
                _typeText.kill();
                if(_messageBox != null)
                    _messageBox.destroy();
            }
        }
    }
	
	public function setTypeTextPosition(x : Float, y : Float) : Void
	{
		if (_typeText != null){
			_typeText.setPosition(x, y);
		}
	}
	
	public function setTypeTextFontSize(size : Int) : Void
	{
		_fontSize = size;
		if (_typeText != null)
			_typeText.size = _fontSize;
	}

    public function useBox(?box : FlxSprite) : Void
    {
        if (box == null) {
            _messageBox = new FlxSprite(0, 0);
            _messageBox.makeGraphic(Std.int(FlxG.width * 0.8), Std.int(FlxG.height * 0.3), FlxColor.BLACK);
        } else {
            _messageBox = box;
        }
        
        _typeText = new FlxTypeText(0, 0, Std.int(_messageBox.width) - (_padding * 2), "", _fontSize, true); 

        _onBox = true;
    }

}