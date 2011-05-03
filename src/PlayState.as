package
{
	import flash.ui.Mouse;
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
		
		//===========declare others===========
		private var simpleTilemap:FlxTilemap;
		
		/**
		 * the blue block player controls
		 */
		private var thePlayer:FlxSprite;
		
		/**
		 * the red block represents mouse
		 */
		private var theCursor:FlxSprite;
		
		//===========declare stuff around replay===========
		/*
		 * We use these to tell which mode we are at, recording or replaying
		 */
		private static var recording:Boolean =false;
		private static var replaying:Boolean =false;
		
		
		override public function create():void
		{
			FlxG.framerate = 60;
			FlxG.flashFramerate = 60;
			FlxG.mouse.hide();
			
			//Set up the TILEMAP
			simpleTilemap = new FlxTilemap();
			simpleTilemap.loadMap(new map_simple,img_autoChange,25,25,FlxTilemap.AUTO);
			add(simpleTilemap);
			simpleTilemap.y -= 15;
			
			//Set up the cursor
			theCursor = new FlxSprite().makeGraphic(6, 6, 0xFFFF0000);
			add(theCursor);
			
			//Set up the Player
			thePlayer = new FlxSprite().makeGraphic(12, 12, 0xFF8CF1FF);
			thePlayer.maxVelocity.x = 80;   // Theses are pysics settings,
			thePlayer.maxVelocity.y = 200;  // controling how the players behave
			thePlayer.acceleration.y = 300; // in the game
			thePlayer.drag.x = thePlayer.maxVelocity.x * 4;
			thePlayer.x = 30;
			thePlayer.y = 200
			add(thePlayer);
			
			//Set up UI
			hintText =  new FlxText(0, 268, 400);
			hintText.color = 0xFF000000;
			hintText.size = 12;
			add(hintText);
			
			//adjust things according to different modes
			init();
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
			
			if(!PlayState.recording && !PlayState.replaying){
				start_record();
			}
			
			/**
			 * Notice that I add "&&recording", because recording will recording every input
			 * so R key for replay will also be recorded and
			 * be triggered at replaying
			 * Please pay attention to the inputs that are not supposed to be recorded
			 */
			if (FlxG.keys.justPressed("R") && PlayState.recording)
			{
				start_play();
			}
			
			super.update();
			
			//Update the red block cursor
			theCursor.scale = new FlxPoint(1, 1);
			if (FlxG.mouse.pressed()) {
				theCursor.scale = new FlxPoint(2, 2);
			}
			theCursor.x = FlxG.mouse.screenX;
			theCursor.y = FlxG.mouse.screenY;
			
		}
		
		/**
		 * I use this funtion to do the init differs from recording to replaying
		 */
		private function init():void{
			if (PlayState.recording) {
				thePlayer.alpha = 1;
				theCursor.alpha = 1;
				hintText.text ="Recording: Arrow Keys : move, X : jump, R : replay\nMouse move and click will also be recorded"
			}else if (PlayState.replaying) {
				thePlayer.alpha = 0.5;
				theCursor.alpha = 0.5;
				hintText.text ="Replaying: Press mouse button to stop and record again"
			}
		}
		
		private function start_record():void {
			PlayState.recording = true;
			PlayState.replaying = false;
			
			/*
			 *Note FlxG.recordReplay will restart the game or state
			 *This function will trigger a flag in FlxGame
			 *and let the internal FlxReplay to record input on every frame
			 */
			FlxG.recordReplay(false);
		}
		
		private function start_play() :void {
			PlayState.replaying = true;
			PlayState.recording = false;
			
			/*
			 * Here we get a string from stopRecoding()
			 * which records all the input during recording
			 * Then we load the save
			 */
			
			var save:String = FlxG.stopRecording();
			//trace(save);
			FlxG.loadReplay(save, new PlayState, ["MOUSE"], 0,start_record);
		}
	}
}
