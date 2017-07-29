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
import openfl.text.TextField;
import openfl.text.TextFormat;

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
	var rightMouseButton: Bool;
	
	public static inline var baseWidth = 800 * 4.0;
	public static inline var baseHeight = 480 * 4.0;
	
	var gun: Gun;
	var stars: Bitmap;
	
	var powerUps: DisplayObjectContainer;
	
	var powerLabel: TextField;
	var hpLabel: TextField;

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
		
		for (i in 0...10)
		{
			var powerUp = new PowerUp();
			powerUp.x = Math.random() * width;
			powerUp.y = Math.random() * height;
			
			powerUps.addChild(powerUp);
			addChild(powerUps);
		}
		
		gun = new Gun(Main.baseWidth, 100);
		addChild(gun);
		//gun.x -= bitmapData.width / 2;

		ship = new Ship();
		addChild(ship);
		
		stage.addEventListener(Event.RESIZE, onResize);
		stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		stage.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onRightMouseDown);
		stage.addEventListener(MouseEvent.RIGHT_MOUSE_UP, onRightMouseUp);
		
		//tempVector = new Vector2();
		tempPoint = new Point();
		
		leftMouseButton = false;
		rightMouseButton = false;
		
		time = Timer.stamp();
		
		
#if js
		var textFormat = new TextFormat("Exo 2 Extra Light Regular Webfont", 72, 0xffffffff);
#else
		var textFormat = new TextFormat("font/Exo2-ExtraLight-webfont.ttf", 72, 0xffffffff);
#end
		
		powerLabel = createTextField(textFormat);
		
		hpLabel = createTextField(textFormat);
		
		addChild(powerLabel);
		addChild(hpLabel);
		
				
		ship.powerChangedCallback = function () powerLabel.text = "Power: " + ship.power;
		ship.powerChangedCallback();
		
		stage.showDefaultContextMenu = false;
	}
	
	function createTextField(textFormat: TextFormat): TextField
	{
		var textField = new TextField();
		textField.setTextFormat(textFormat);
		
		textField.selectable = false;
		textField.width = 500;
		
		return textField;
	}
	
	function onMouseDown(event: MouseEvent)
	{
		leftMouseButton = event.buttonDown;
	}
	
	function onMouseUp(event: MouseEvent)
	{
		leftMouseButton = event.buttonDown;
	}
	
	function onRightMouseDown(event: MouseEvent)
	{
		rightMouseButton = true;// event.buttonDown;
	}
	
	function onRightMouseUp(event: MouseEvent)
	{
		rightMouseButton = false;// event.buttonDown;
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
		
		//if (leftMouseButton)
		//{
			//leftMouseButton = false;
			
			tempPoint.setTo(stage.mouseX, stage.mouseY);
			
			//trace(tempPoint);
			
			var direction = this.globalToLocal(tempPoint); //.subtract(ship.center);
			direction.x -= ship.x;
			direction.y -= ship.y;
			
			//var x1 = ship.center.x;
			//var y1 = ship.center.y;
			var x1 = ship.x;
			var y1 = ship.y;
			var x2 = x1 + direction.x;
			var y2 = y1 + direction.y;
			
			if (direction.length > ship.radius)
			{
				ship.rotation = Math.atan2(direction.y, direction.x) * 180 / Math.PI;
				
				if (leftMouseButton)
				{
					//var gun = ship.gun;
					gun.rotation = ship.rotation;
					
					//gun.x = ship.center.x;
					//gun.y = ship.center.y;
					
					gun.x = ship.x;
					gun.y = ship.y;
					
					gun.visible = true;
						
					for (i in 0...powerUps.numChildren)
					{
						var powerUp: PowerUp = cast powerUps.getChildAt(i);
						
						if (powerUp.visible == false)
							continue;
						
						var x0 = powerUp.center.x;
						var y0 = powerUp.center.y;
						
						// magnetize the power up
						//else
						{
							var distance = Math.abs((y2 - y1) * x0 - (x2 - x1) * y0 + x2 * y1 - y2 * x1) / direction.length;
							
							trace(distance);
							
							// line touches circle
							if (distance <= powerUp.radius)
							{
								//trace("YAY");
								//powerUp.visible = false;
								
								// ray touches circle
								if ((x0 - x1) * (x2 - x1) > 0 && (y0 - y1) * (y2 - y1) > 0)
								{
									direction.normalize(PowerUp.speed);
									
									powerUp.velocity.setTo(-direction.x, -direction.y);
								}
							}
						}
					}
				
				}
				
				if (rightMouseButton)
				{
					direction.normalize(Ship.speed);
					
					/*trace(x, y);
					trace(point);
					
					trace(ship.center);
					
					trace(point);
					
					trace(point);*/
					
					ship.velocity.setTo(direction.x, direction.y);
				}
			}

		//}

		for (i in 0...powerUps.numChildren)
		{
			var powerUp: PowerUp = cast powerUps.getChildAt(i);
			powerUp.update(dt);
			
			if (powerUp.visible == false)
				continue;
			
			var minDistance = ship.radius + powerUp.radius;
			var x0 = powerUp.center.x;
			var y0 = powerUp.center.y;
					
			// pick up the power up
			if (Math.sqrt((x0 - x1) * (x0 - x1) + (y0 - y1) * (y0 - y1)) < minDistance)
			{
				ship.power += PowerUp.power;
				powerUp.visible = false;
			}
			
			//if (distance <= powerUp.radius)
			{
				//trace("YAY");
				//powerUp.visible = false;
				
				//direction.normalize(PowerUp.speed);
				
				//powerUp.velocity.setTo(-direction.x, -direction.y);
			}
		}
		
		ship.update(dt);

	}
	
	// "Что случилось, штурман? У нас ЧП, капитан! Белки выдохлись. Вот почему я не люблю белковые приводы. И что нам теперь делать? Как добираться до Дессертсити?"

}
