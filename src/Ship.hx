package;

import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.Sprite;

/**
 * ...
 * @author scorched
 */
class Ship extends BaseObject
{
	public inline static var speed = 100.0;

	public function new() 
	{
		var bitmapData = Assets.getBitmapData("img/ship.png");
		
		super(bitmapData.width / 2);
		
		addChild(new Bitmap(bitmapData));
	}
	
}