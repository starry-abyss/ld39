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
import openfl.geom.Rectangle;
import openfl.media.Sound;
import openfl.media.SoundChannel;
import openfl.media.SoundTransform;
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
	//var stars: Bitmap;
	
	var powerUps: DisplayObjectContainer;
	var asteroids: DisplayObjectContainer;
	var bubbles: DisplayObjectContainer;
	
	var powerLabel: TextField;
	var hpLabel: TextField;
	
	var music: Sound;
	
	var tutorialAccelerate: Tutorial;
	var tutorialMagnetize: Tutorial;
	
	var accelerateSound: Sound;
	var magnetizeSound: Sound;

	public function new() 
	{
		super();
		
		//width = baseWidth;
		//height = baseHeight;
		
		music = Assets.getSound("music/main_track.ogg");
		var channel: SoundChannel = music.play(0, 100000);
		channel.soundTransform = new SoundTransform(0.3);
		
		for (i in 0...5)
		{
			var stars = new Bitmap(Assets.getBitmapData("img/stars.png"));
			stars.scaleX = 2;
			stars.scaleY = 2;
			stars.x = i * stars.width /** stars.scaleX*/;
			stars.y = 0;
			//stage.addChildAt(stars, 0);
			addChild(stars);
		}
		
		powerUps = new DisplayObjectContainer();
		asteroids = new DisplayObjectContainer();
		bubbles = new DisplayObjectContainer();
		
		for (i in 0...10)
		{
			var bubble = new Bubble();
			bubbles.addChild(bubble);
		}
		
		addChild(bubbles);
		addChild(powerUps);
		addChild(asteroids);
		
		
		gun = new Gun(Main.baseWidth, 90);
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
		hpLabel.y += 100;
		
		addChild(powerLabel);
		addChild(hpLabel);

		
		stage.showDefaultContextMenu = false;
		
		tutorialAccelerate = new Tutorial();
		tutorialMagnetize = new Tutorial();
		
		tutorialAccelerate.text = "Hold RMB to accelerate (uses power)";
		
		tutorialMagnetize.text = "Aim mouse and hold LMB to magnetize objects";
		
		addChild(tutorialAccelerate);
		addChild(tutorialMagnetize);
		
		
		ship.hpChangedCallback = 
			function ()
			{ 
				hpLabel.text = "HP: " + Math.ceil(ship.hp);
				
				if (ship.hp <= 0)
				{
					restartGame();
				}
			};
			
		ship.powerChangedCallback = 
			function () 
			{ 
				powerLabel.text = "Power: " + Math.ceil(ship.power);
				
				tutorialAccelerate.hide = (ship.power <= 0);
			};
			
		
		
		ship.powerChangedCallback();
		ship.hpChangedCallback();
		
		accelerateSound = Assets.getSound("sound/accelerate.wav");
		magnetizeSound = Assets.getSound("sound/magnetize.wav");
		
		restartGame(false);
		
		//this.scrollRect = new Rectangle(0, 0, baseWidth, baseHeight);
	}
	
	function restartGame(lose: Bool = true)
	{
		if (lose)
		{
			var loseSound = Assets.getSound("sound/lose.wav");
			loseSound.play();
		}
		
		// quick hack for asteroids spawning at player at start
		ship.hp = 10000.0;
		ship.x = 500;
		ship.y = baseHeight / 2;
		leftMouseButton = false;
		rightMouseButton = false;
		
		generateStuff();
		
		ship.power = 0.0;
		ship.velocity.setTo(0, 0);
	}
	
	function winGame()
	{
		var winSound = Assets.getSound("sound/win.wav");
		winSound.play();
	}
	
	function generateStuff()
	{
		powerUps.removeChildren(0, powerUps.numChildren - 1);
		asteroids.removeChildren(0, asteroids.numChildren - 1);

		for (i in 0...10)
		{
			var powerUp = new PowerUp();
			powerUp.x = Math.random() * baseWidth;
			powerUp.y = Math.random() * baseHeight;
			
			powerUp.velocity.setTo(Math.random() - 0.5, Math.random() - 0.5);
			powerUp.velocity.normalize(10);
			
			powerUps.addChild(powerUp);
		}
		
		// start
		for (i in 0...50)
		{
			var asteroid = new Asteroid();
			asteroid.x = Math.random() * 100;
			asteroid.y = Math.random() * baseHeight;
			
			//asteroid.velocity.setTo(Math.random() - 0.5, Math.random() - 0.5);
			//asteroid.velocity.normalize(10);
			
			asteroids.addChild(asteroid);
		}
		
		for (i in 0...10)
		{
			var asteroid = new Asteroid();
			asteroid.x = Math.random() * baseWidth;
			asteroid.y = Math.random() * baseHeight;
			
			asteroid.velocity.setTo(Math.random() - 0.5, Math.random() - 0.5);
			asteroid.velocity.normalize(10);
			
			asteroids.addChild(asteroid);
			
		}
		
		ship.hp = 100.0;
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
		
		this.x = Lib.application.window.width / 2 - baseWidth * scale / 2;
		this.y = Lib.application.window.height / 2 - baseHeight * scale / 2;
		
		tutorialAccelerate.x = baseWidth / 2 - tutorialAccelerate.width / 2;
		tutorialAccelerate.y = baseHeight / 3;
		
		tutorialMagnetize.x = baseWidth / 2 - tutorialMagnetize.width / 2;
		tutorialMagnetize.y = baseHeight / 3 + tutorialAccelerate.height;
		
		//this.scrollRect.setTo(0, 0, baseWidth, baseHeight);
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
			
			if (direction.length > ship.radius)
			{
				ship.rotation = Math.atan2(direction.y, direction.x) * 180 / Math.PI;
				
				if (leftMouseButton)
				{
					magnetizeSound.play();
					
					//var gun = ship.gun;
					gun.rotation = ship.rotation;
					
					//gun.x = ship.center.x;
					//gun.y = ship.center.y;
					
					gun.x = ship.x;
					gun.y = ship.y;
					
					gun.visible = true;
					
					var magnetWorks = false;
						
					for (i in 0...powerUps.numChildren)
					{
						var powerUp: PowerUp = cast powerUps.getChildAt(i);
						
						if (powerUp.visible == false)
							continue;
						
						if (rayOverlap(ship, powerUp, direction))
						{
							//direction.normalize(PowerUp.speed);
							powerUp.addVelocity(direction, -PowerUp.speed, dt);
							//powerUp.velocity.setTo( -direction.x, -direction.y);
							
							magnetWorks = true;
						}
					}
					
					for (i in 0...asteroids.numChildren)
					{
						var asteroid: Asteroid = cast asteroids.getChildAt(i);
						
						if (asteroid.visible == false)
							continue;
								
						// pick up the power up
						if (rayOverlap(ship, asteroid, direction))
						{
							//direction.normalize(Asteroid.speed);
							asteroid.addVelocity(direction, -Asteroid.speed, dt);
							//asteroid.velocity.setTo(-direction.x, -direction.y);
							
							magnetWorks = true;
						}
					}
				
					if (magnetWorks)
					{
						tutorialMagnetize.update(dt);
					}
				}
				
				if (rightMouseButton && ship.power > 0)
				//if (rightMouseButton)
				{
					tutorialAccelerate.update(dt);
					//direction.normalize(Ship.speed * dt);
					
					/*trace(x, y);
					trace(point);
					
					trace(ship.center);
					trace(point);*/
					
					ship.power -= Ship.powerCost * dt;
					ship.addVelocity(direction, Ship.speed, dt);
					//ship.velocity.setTo(ship.velocity.x + direction.x, ship.velocity.y + direction.y);
					
					var countVisible = 0;
					for (i in 0...bubbles.numChildren)
					{
						var bubble: Bubble = cast bubbles.getChildAt(i);
						if (!bubble.visible)
							bubble.emit(ship, direction);
						else
							++countVisible;
					}
					
					if (countVisible > 0)
					{
						accelerateSound.play();
					}
				}
			}

		//}

		for (i in 0...powerUps.numChildren)
		{
			var powerUp: PowerUp = cast powerUps.getChildAt(i);
			powerUp.update(dt);
			
			if (powerUp.visible == false)
				continue;
					
			// pick up the power up
			if (objectOverlap(ship, powerUp))
			{
				ship.power += PowerUp.power;
				powerUp.visible = false;
				
				if (ship.hp < 1000)
					Assets.getSound("sound/powerup.wav").play();
			}
		}
		
		for (i in 0...asteroids.numChildren)
		{
			var asteroid: Asteroid = cast asteroids.getChildAt(i);
			asteroid.update(dt);
			
			if (asteroid.visible == false)
				continue;
					
			// pick up the power up
			if (objectOverlap(ship, asteroid))
			{
				ship.hp -= Asteroid.damage;
				asteroid.visible = false;
				
				if (ship.hp < 1000)
					Assets.getSound("sound/asteroid.wav").play();
			}
			else
			{
				for (j in 0...asteroids.numChildren)
				{
					var asteroid2: Asteroid = cast asteroids.getChildAt(j);
					asteroid.update(dt);
					
					if (asteroid.visible == false)
						continue;
							
					// asteroid collision
					if (asteroid != asteroid2 && objectOverlap(asteroid, asteroid2))
					{
						//asteroid.visible = false;
						//asteroid2.visible = false;
					}
				}
			}
		}
		
		for (i in 0...bubbles.numChildren)
		{
			var bubble: Bubble = cast bubbles.getChildAt(i);
			bubble.update(dt);
		}
		
		ship.update(dt);
			
		//this.scrollRect.offset(ship.center.x, 0);
		//trace(this.scrollRect.x);
		
		var offset = ship.center.x >= 500 ? ship.center.x - 500 : 0;
		this.scrollRect = new Rectangle(offset, 0, baseWidth, baseHeight);
	}
	
	function objectOverlap(object1: BaseObject, object2: BaseObject)
	{	
		var minDistance = object1.radius + object2.radius;
		var x0 = object1.center.x;
		var y0 = object1.center.y;
		var x1 = object2.center.x;
		var y1 = object2.center.y;
		
		return Math.sqrt((x0 - x1) * (x0 - x1) + (y0 - y1) * (y0 - y1)) < minDistance;
	}
	
	function rayOverlap(ship: Ship, object: BaseObject, direction: Point): Bool
	{
		var x1 = ship.x;
		var y1 = ship.y;
		var x2 = x1 + direction.x;
		var y2 = y1 + direction.y;
			
		var x0 = object.center.x;
		var y0 = object.center.y;
		
		// magnetize the power up
		//else
		{
			var distance = Math.abs((y2 - y1) * x0 - (x2 - x1) * y0 + x2 * y1 - y2 * x1) / direction.length;
			
			//trace(distance);
			
			// line touches circle
			if (distance <= object.radius)
			{
				//trace("YAY");
				//powerUp.visible = false;
				
				// ray touches circle
				if ((x0 - x1) * (x2 - x1) > 0 && (y0 - y1) * (y2 - y1) > 0)
				{
					return true;
				}
			}
		}
		
		return false;
	}

	// "Что случилось, штурман? У нас ЧП, капитан! Белки выдохлись. Вот почему я не люблю белковые приводы. И что нам теперь делать? Как добираться до Дессертсити?"

}
