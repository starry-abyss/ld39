package;

import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;

/**
 * ...
 * @author scorched
 */
class Gun extends Sprite
{

	public function new(width: Float, height: Float) 
	{
		super();
		
		var bitmap = new Bitmap(new BitmapData(Std.int(width), Std.int(height), true, 0xaaaaaaaa));
		bitmap.y -= height / 2;

		addChild(bitmap);
	}
	
}