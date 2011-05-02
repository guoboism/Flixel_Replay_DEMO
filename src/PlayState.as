package
{
	import flash.geom.Point;
	import org.flixel.*;
	import org.flixel.system.FlxReplay;

	public class PlayState extends FlxState
	{
		
		//===========embed resources===========
		[Embed(source='../asst/autoChange.png')]
		private var img_autoChange:Class;
		
		[Embed(source = '../asst/simpleMap.csv', mimeType = 'application/octet-stream')]
		private var map_simple:Class;
		
		//===========declare UI stuff===========
		private var hintText:FlxText;
		
		private var replayText:FlxText;
		
		private var  btnQuit:FlxButton;
		//===========declare others===========
		private var simpleTilemap:FlxTilemap;
		
		private var thePlayer:FlxSprite;
		
		//===========declare stuff around replay===========
		private var replay:FlxReplay = new FlxReplay();
		
		private var isRecording:Boolean = true;
		
		private var playerPosWhenRecordStart:FlxPoint = new FlxPoint();
		
		override public function create():void
		{
			FlxG.framerate = 60;
			FlxG.flashFramerate = 60;
			
			//Set up the TILEMAP
			simpleTilemap = new FlxTilemap();
			simpleTilemap.loadMap(new map_simple,img_autoChange,25,25,FlxTilemap.AUTO);
			add(simpleTilemap);
			simpleTilemap.y -= 25;
			
			//Set up the Player
			thePlayer = new FlxSprite().makeGraphic(12, 12, 0xFF8CF1FF);
			thePlayer.maxVelocity.x = 80;   // Theses are pysics settings,
			thePlayer.maxVelocity.y = 200;  // controling how the players behave
			thePlayer.acceleration.y = 300; // in the game
			thePlayer.drag.x = thePlayer.maxVelocity.x * 4;
			thePlayer.x = 30;
			thePlayer.y = 200
			add(thePlayer);
			
			//Set up stuff around replay
			start_record();
			
			//Set up UI
			//Add timer text
			replayText = new FlxText(180, 0, 200, "");
			replayText.size = 16;
			add(replayText);
			
			//Add hint text;
			hintText =  new FlxText(50, 280, 350, "Press R to display replay and wait until it finishes.");
			hintText.color = 0xFF000000;
			hintText.size = 10;
			add(hintText);
			
			//Add quit btn
			btnQuit = new FlxButton(0, 0, "QUIT", onQuit);
			add(btnQuit);
		}
		
		override public function update():void
		{
			FlxG.collide(simpleTilemap, thePlayer);
			
			//Update the player
			thePlayer.acceleration.x = 0;
			if(FlxG.keys.LEFT)
			{
				thePlayer.acceleration.x -= thePlayer.drag.x
			}
			else if(FlxG.keys.RIGHT)
			{
				thePlayer.acceleration.x +=thePlayer.drag.x
			}
			if(FlxG.keys.justPressed("X") && !thePlayer.velocity.y)
			{
				thePlayer.velocity.y = -200;
			}
			
			if (FlxG.keys.justPressed("R") && isRecording) {
				start_play();
			}
			
			super.update();
			
			if (isRecording) {
				replay.recordFrame();
				replayText.color = 0xFFBD1A1E;
				replayText.text = "R : " + replay.frameCount;
			}else{
				replay.playNextFrame();
				replayText.color = 0xFF0080FF;
				replayText.text = "P : " + replay.frame +"/" + replay.frameCount;
				if (replay.finished) {
					start_record();
				}
			}
		}
		
		private function start_record():void {
			isRecording = true;
			
			playerPosWhenRecordStart.x = thePlayer.x;
			playerPosWhenRecordStart.y = thePlayer.y;
			replay.create(Math.random());
			thePlayer.alpha = 1;
		}
		
		private function start_play() :void {
			isRecording = false; 
			
			thePlayer.x = playerPosWhenRecordStart.x;
			thePlayer.y = playerPosWhenRecordStart.y;
			replay.rewind();
			thePlayer.alpha = 0.6;
		}
		
		private function onQuit() {
			FlxG.switchState(new MenuState);
		}
	}
}
