package;

import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;

/**
 * ...
 * @author scorched
 */
class Ship extends BaseObject
{
	public inline static var speed = 100.0;
	public inline static var rotationSpeed = 100.0;
	
	public var power(default, set): Float = 0.0;
	public var hp(default, set): Float = 100.0;
		
	public inline static var powerAcceleration = 3.0; // velocity per 1 unit of power
	public inline static var powerCost = 50.0; // power waste per second
	
	//public var gun: Gun;
	public var powerChangedCallback: Void->Void;
	public var hpChangedCallback: Void->Void;
	
	var decals: Array<Bitmap>;
	
	function set_power(value: Float)
	{
		power = value > 0 ? value : 0;
		powerChangedCallback();
		return power;
	}
	
	function set_hp(value: Float)
	{
		hp = value > 0 ? value : 0;
		hpChangedCallback();
		return hp;
	}
	
	function addBitmap(bitmapData: BitmapData): Bitmap
	{
		var bitmap = new Bitmap(bitmapData);
		bitmap.x -= bitmapData.width / 2;
		bitmap.y -= bitmapData.height / 2;
		addChild(bitmap);
		
		return bitmap;
	}

	public function new() 
	{
		decals = new Array<Bitmap>();
		
		var bitmapData = Assets.getBitmapData("img/ship.png");
		
		super(bitmapData.width / 2);
		
		addBitmap(bitmapData);
		
		for (i in 1...5)
		{
			decals[i] = addBitmap(Assets.getBitmapData('img/decals/decal$i.png'));
			decals[i].visible = (i == 4);
		}
		
		/*var bitmap = new Bitmap(bitmapData);
		bitmap.x -= bitmapData.width / 2;
		bitmap.y -= bitmapData.height / 2;
		addChild(bitmap);*/
		
		//gun = new Gun(Main.baseWidth, 100);
		//gun.x -= bitmapData.width / 2;
		//gun.y -= gun.height / 2;
		//addChild(gun);
	}
	
	// modify parent's x and y instead
	override public function update(dt: Float)
	{
		x += velocity.x * dt;
		y += velocity.y * dt;

		if (hp < 30)
		{
			decals[4].visible = false;
		}
		else if (hp < 45)
		{
			decals[3].visible = true;
		}
		else if (hp < 60)
		{
			decals[2].visible = true;
		}
		else if (hp < 80)
		{
			decals[1].visible = true;
		}
		else
		{
			decals[1].visible = false;
			decals[2].visible = false;
			decals[3].visible = false;
			decals[4].visible = true;
		}
	}
	
	override function get_center()
	{
		center.x = x;
		center.y = y;
		
		return center;
	}
	
}