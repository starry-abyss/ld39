package;

import haxe.Timer;
import lime.math.Vector2;
import lime.ui.Mouse;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.Lib;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Point;

/**
 * ...
 * @author scorched
 */
class Main extends Sprite 
{
	var ship: Ship;
	
	var time: Float;
	
	//var tempVector: Vector2;
	var tempPoint: Point;
	
	var leftMouseButton: Bool;
	
	var baseWidth = 800 * 4.0;
	var baseHeight = 480 * 4.0;
	
	var gun: Gun;
	var stars: Bitmap;
	
	var powerUps: DisplayObjectContainer;

	public function new() 
	{
		super();
		
		//width = baseWidth;
		//height = baseHeight;
		
		stars = new Bitmap(Assets.getBitmapData("img/stars.png"));
		stars.scaleX = 2;
		stars.scaleY = 2;
		//stage.addChildAt(stars, 0);
		addChild(stars);
		
		powerUps = new DisplayObjectContainer();
		powerUps.addChild(new PowerUp());
		addChild(powerUps);
		
		gun = new Gun(baseWidth, 100);
		addChild(gun);

		ship = new Ship();
		addChild(ship);
		
		stage.addEventListener(Event.RESIZE, onResize);
		stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		
		//tempVector = new Vector2();
		tempPoint = new Point();
		
		leftMouseButton = false;
		
		time = Timer.stamp();
	}
	
	function onMouseDown(event: MouseEvent)
	{
		leftMouseButton = event.buttonDown;
	}
	
	function onMouseUp(event: MouseEvent)
	{
		leftMouseButton = event.buttonDown;
	}
	
	function onResize(_)
	{
		var scaleX = Lib.application.window.width / baseWidth;
		var scaleY = Lib.application.window.height / baseHeight;
		var scale = Math.min(scaleX, scaleY);
		
		this.scaleX = scale;
		this.scaleY = scale;
		
		this.x = Lib.application.window.width / 2 - width * scale / 2;
		this.y = Lib.application.window.height / 2 - height * scale / 2;
		
		//stars.scaleX = 4;
		//stars.scaleY = 4;
	}
	
	function onEnterFrame(_)
	{
		var newTime = Timer.stamp();
		var dt = newTime - time;
		time = newTime;
		
		gun.visible = false;
		
		if (leftMouseButton)
		{
			//leftMouseButton = false;
			
			tempPoint.setTo(stage.mouseX, stage.mouseY);
			
			//trace(tempPoint);
			
			var direction = this.globalToLocal(tempPoint).subtract(ship.center);
			
			if (direction.length > ship.radius)
			{
				gun.rotation = Math.atan2(direction.y, direction.x) * 180 / Math.PI;
				
				gun.x = ship.center.x;
				gun.y = ship.center.y;
				
				gun.visible = true;
				
				
				direction.normalize(Ship.speed);
				
				/*trace(x, y);
				trace(point);
				
				trace(ship.center);
				
				trace(point);
				
				trace(point);*/
				
				ship.velocity.setTo(direction.x, direction.y);
			
			}

		}

		//trace(dt);
		ship.update(dt);
		
		//Mouse.
		
		//if ()
		{
			
		}
	}
	
	// "Что случилось, штурман? У нас ЧП, капитан! Белки выдохлись. Вот почему я не люблю белковые приводы. И что нам теперь делать? Как добираться до Дессертсити?"

}
