package;

import motion.Actuate;
import motion.easing.Linear;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.geom.Point;

/**
 * ...
 * @author scorched
 */
class Bubble extends BaseObject 
{

	//public inline static var speed = 200.0;
	//public inline static var power = 20.0;
	
	public function new() 
	{
		var bitmapData = Assets.getBitmapData("img/bubble.png");
		
		super(bitmapData.width / 2);
		
		visible = false;
		
		var bitmap = new Bitmap(bitmapData);
		bitmap.x -= bitmap.width / 2;
		bitmap.y -= bitmap.height / 2;
		
		addChild(bitmap);
	}
	
	public function emit(ship: BaseObject, direction: Point)
	{
		visible = true;
		
		direction.normalize(1);
		
		//var point = globalToLocal(localToGlobal(ship.center));
		
		x = ship.center.x - direction.x * ship.radius;
		y = ship.center.y - direction.y * ship.radius;
		
		scaleX = 2;
		scaleY = 2;
		
		Actuate.tween(this, (Math.random() + 0.5) * 2, { scaleX: 0, scaleY: 0 }).ease(Linear.easeNone).onComplete(function () visible = false);

		velocity.setTo(-direction.x * 200 + (Math.random() - 0.5) * 50, -direction.y * 200 + (Math.random() - 0.5) * 50);
	}
	
}