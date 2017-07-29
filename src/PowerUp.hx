package;

import openfl.Assets;
import openfl.display.Bitmap;

/**
 * ...
 * @author scorched
 */
class PowerUp extends BaseObject 
{
	public inline static var speed = 200.0;
	public inline static var power = 100.0;
	
	public function new() 
	{
		var bitmapData = Assets.getBitmapData("img/power_up.png");
		
		super(bitmapData.width / 2);
		
		addChild(new Bitmap(bitmapData));
	}
	
}