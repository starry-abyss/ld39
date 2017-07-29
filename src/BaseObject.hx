package;

import openfl.display.Sprite;
import openfl.geom.Point;

/**
 * ...
 * @author scorched
 */
class BaseObject extends Sprite 
{
	public var velocity: Point;
	public var center(get, null): Point;
	
	public var radius(default, null): Float;

	public function new(radius: Float) 
	{
		super();
		
		this.radius = radius;
		
		velocity = new Point();
		center = new Point();
	}
	
	function get_center()
	{
		
		center.x = x + radius;
		center.y = y + radius;
		
		//trace(radius);
		//trace(center);
		
		return center;
	}
	
	public function update(dt: Float)
	{
		x += velocity.x * dt;
		y += velocity.y * dt;
		
		//trace(velocity);
	}
	
}