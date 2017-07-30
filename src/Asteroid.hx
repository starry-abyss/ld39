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
		
		//addChild(new Bitmap(bitmapData));

		var bitmap = new Bitmap(bitmapData);
		bitmap.x -= bitmapData.width / 2;
		bitmap.y -= bitmapData.height / 2;
		addChild(bitmap);
		
		rotation = Math.random() * 360;
	}
	
	// modify parent's x and y instead
	override public function update(dt: Float)
	{
		if (visible)
		{
			x += velocity.x * dt;
			y += velocity.y * dt;
			
			if (x + radius < 0 || x - radius > Main.blackHolePos + Main.baseWidth / 2 || y + radius < 0 || y - radius > Main.baseHeight)
			{
				visible = false;
			}
		}
	}
	
	override function get_center()
	{
		center.x = x;
		center.y = y;
		
		return center;
	}
	
}