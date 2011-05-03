package
{
	import org.flixel.*;
	[SWF(width="400", height="300", backgroundColor="0xFFFFFF")]
	[Frame(factoryClass="Preloader")]

	public class Feature_Replay extends FlxGame
	{
		public function Feature_Replay()
		{
			super(400, 300, MenuState, 1, 20, 20);
		}
	}
}
