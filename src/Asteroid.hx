package;

import openfl.Assets;
import openfl.display.Bitmap;

/**
 * ...
 * @author scorched
 */
class Asteroid extends BaseObject 
{

	public inline static var speed = 200.0;
	public inline static var damage = 22.0;
	
	public function new() 
	{
		var bitmapData = Assets.getBitmapData("img/asteroid.png");
		
		super(bitmapData.width / 2);
		
		addChild(new Bitmap(bitmapData));
	}
	
}