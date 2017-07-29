package;

import openfl.Assets;
import openfl.display.Bitmap;

/**
 * ...
 * @author scorched
 */
class PowerUp extends BaseObject 
{

	public function new() 
	{
		var bitmapData = Assets.getBitmapData("img/power_up.png");
		
		super(bitmapData.width / 2);
		
		addChild(new Bitmap(bitmapData));
	}
	
}