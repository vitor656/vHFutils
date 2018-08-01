package vHFutils;

import flixel.addons.text.FlxTypeText;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxTimer;
import flixel.FlxState;
import flixel.FlxBasic;
import utils.ControlsManager;
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

    public inline static var BOX_OFFSET:Int = 20;
    private var _fontSize:Int = 8;
	private var _clickOnComplete:Bool;
	private var _fasterOnClick:Bool;
	private var _onBox:Bool;
	
	public var dialogueFinished : Bool;

    public var _typeText : FlxTypeText;
    public var _messageBox : FlxSprite;
    private var _messages : Array<String>;
    private var _currentIndex : Int;
    private var currentMessage : String;
    private var loadedDialogueId : String;

    private var _clickToContinue : Bool;
    
    public function new(?onBox:Bool = false, ?x:Float = 0, ?y:Float = 0, ?clickOnComplete:Bool = false, 
		?fasterOnClick:Bool = false)
    {
        super();
		
		_onBox = onBox;
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
            _typeText = new FlxTypeText(0, 0, Std.int(FlxG.width * 0.8) - (BOX_OFFSET * 2), "", _fontSize, true);       
        } else {
			if (_typeText != null){
				_typeText.reset(0, 0);
			} else{
				_typeText = new FlxTypeText(x, y, Std.int(FlxG.width/2), "", _fontSize, true);
			}
            
            //_typeText.screenCenter();
			//_typeText.y = FlxG.height * 0.2;
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

                //Build dialogue box
                _messageBox = new FlxSprite(0, 0);
                _messageBox.makeGraphic(Std.int(FlxG.width * 0.8), Std.int(FlxG.height * 0.3), FlxColor.BLACK);
                _messageBox.screenCenter();
                _messageBox.y = (FlxG.height - _messageBox.height) - 10;
                _messageBox.scrollFactor.set(0, 0);

                _typeText.x = _messageBox.x + BOX_OFFSET;
                _typeText.y = _messageBox.y + BOX_OFFSET;
                _typeText.width = _messageBox.width - (BOX_OFFSET * 2);

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
            case "teste":
                _messages.push("It's been a while...");
                _messages.push("Sometimes I feel like I cannot breath");
                _messages.push("And sometimes it feels so hot...");
				_messages.push("...that I forget that I exist in a real world");
				_messages.push("with real people");
				_messages.push("that I never actually see.");
				_messages.push("I'm hungry...");
				_messages.push("thirsty...");
				_messages.push("of myself...");
        }

        _currentIndex = 0;
        loadedDialogueId = id;
        currentMessage = _messages[_currentIndex];
    }

    public function onCompleteWait():Void
    {
        new FlxTimer().start(3, function(_){

            loadNextmessage();

        });
    }

    public function onCompleteClick():Void
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

}