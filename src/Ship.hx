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
	
	public var power(default, set): Float = 0.0;
		
	public inline static var powerAcceleration = 1.0; // velocity per 1 unit of power
	public inline static var powerCost = 50.0; // power waste per second
	
	//public var gun: Gun;
	public var powerChangedCallback: Void->Void;
	
	function set_power(value: Float)
	{
		power = value > 0 ? value : 0;
		powerChangedCallback();
		return power;
	}

	public function new() 
	{
		var bitmapData = Assets.getBitmapData("img/ship.png");
		
		super(bitmapData.width / 2);
		
		var bitmap = new Bitmap(bitmapData);
		bitmap.x -= bitmapData.width / 2;
		bitmap.y -= bitmapData.height / 2;
		addChild(bitmap);
		
		//gun = new Gun(Main.baseWidth, 100);
		//gun.x -= bitmapData.width / 2;
		//gun.y -= gun.height / 2;
		//addChild(gun);
	}
	
	override public function update(dt: Float)
	{
		x += velocity.x * dt;
		y += velocity.y * dt;
	}
	
}