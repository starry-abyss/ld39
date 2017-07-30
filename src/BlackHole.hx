package;

import openfl.Assets;
import openfl.display.Bitmap;

/**
 * ...
 * @author scorched
 */
class BlackHole extends BaseObject 
{

	public function new() 
	{
		var bitmapData = Assets.getBitmapData("img/hole.png");
		
		super(100);

		var bitmap = new Bitmap(bitmapData);
		bitmap.x -= bitmap.width / 2;
		bitmap.y -= bitmap.height / 2;
		
		addChild(bitmap);
	}
	
}