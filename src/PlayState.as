package
{
	import org.flixel.*;
	import org.flixel.system.FlxReplay;

	public class PlayState extends FlxState
	{
		
		//===========embed resources===========
		[Embed(source='./asst/tiles.png')]
		private var img_autoChange:Class;
		
		[Embed(source = './asst/simpleMap.csv', mimeType = 'application/octet-stream')]
		private var map_simple:Class;
		
		//===========declare UI stuff===========
		private var hintText:FlxText;
		
		private var replayText:FlxText;
		
		private var  btnQuit:FlxButton;
		
		//===========declare others===========
		private var simpleTilemap:FlxTilemap;
		
		/**
		 * the blue block player controls
		 */
		private var thePlayer:FlxSprite;
		
		//===========declare stuff around replay===========
		/**
		 * This is the main class for replay
		 */
		private var replay:FlxReplay;
		
		/**
		 * We use this to tell which mode we are at, recording or replaying
		 */
		private var isRecording:Boolean = true;
		
		/**
		 * Record down the position of player when record is started
		 */
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
			replay = new FlxReplay();//create the instance, but it still needs initializtion by create(); 
			start_record();//set to record mode
			
			//Set up UI
			//Add timer text
			replayText = new FlxText(300, 0, 200);
			replayText.size = 12;
			add(replayText);
			
			//Add hint text;
			hintText =  new FlxText(0, 282, 350);
			hintText.color = 0xFF000000;
			hintText.size = 12;
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
			
			/**
			 * Notice that I add "&&isRecording", because recording will recording every input
			 * so R key for replay will also be recorded at recording and
			 * be triggered at replaying
			 * Please pay attention to the inputs that are not supposed to be recorded
			 */
			if (FlxG.keys.justPressed("R") && isRecording) {
				start_play();
			}
			
			super.update();
			
			/**
			 * In fact, recording is just remembering all the inputs(keyboard and mouse) at every frame.
			 * When replay, it reads the inputs at each frame and artificially trigger that input
			 * and let your input handler (the logic above this comment in thsi case) to handle it
			 * When recording, call replay.recordFrame() at eachframe
			 * when replaying, call replay.playNextFrame()
			 */
			
			if (isRecording) {
				replay.recordFrame();
				
				//set color to dark red
				replayText.color = 0xFFBD1A1E;
				replayText.text = "R : " + replay.frameCount;
				hintText.text = "Recording. Arrow keys : move. 'R' : replay."
			}else{
				replay.playNextFrame();
				
				//set color ro blue
				replayText.color = 0xFF0080FF;
				replayText.text = "P : " + replay.frame +"/" + replay.frameCount;
				if (replay.finished) {
					start_record();
				}
				hintText.text = "Replaying. Press wait until it finishes."
			}
		}
		
		private function start_record():void {
			isRecording = true;
			
			//record player's position
			playerPosWhenRecordStart.x = thePlayer.x;
			playerPosWhenRecordStart.y = thePlayer.y;
			
			/**
			 * we use this to "reinit" a FlxReplay, 
			 * otherwise new recording will be added after the old
			 * NOTE i created a randon number as the Seed, which serves as identifer
			 */
			replay.create(Math.random());
			
			thePlayer.alpha = 1;
		}
		
		private function start_play() :void {
			isRecording = false; 
			
			//reset player's position to where it was when record started
			thePlayer.x = playerPosWhenRecordStart.x;
			thePlayer.y = playerPosWhenRecordStart.y;
			
			replay.rewind();//this put the "playhead back to start", so that we play it from start
			thePlayer.alpha = 0.6;
		}
		
		private function onQuit():void {
			FlxG.switchState(new MenuState);
		}
	}
}
