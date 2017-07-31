package;

import haxe.Timer;
import lime.math.Vector2;
import lime.ui.Mouse;
import motion.Actuate;
import motion.easing.Linear;
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

#if js
	import lime.media.howlerjs.Howler;
#end

/**
 * ...
 * @author scorched
 */
class Main extends Sprite 
{
	var ship: Ship;
	
	var time: Float;
	var respawnAsteroidsTime: Float = 0;
	
	//var tempVector: Vector2;
	var tempPoint: Point;
	
	var leftMouseButton: Bool;
	var rightMouseButton: Bool;
	
	public static inline var baseWidth = 800 * 4.0;
	public static inline var baseHeight = 480 * 4.0;
	
	var gun: Gun;
	var stars: Bitmap;
	
	var powerUps: DisplayObjectContainer;
	var asteroids: DisplayObjectContainer;
	var bubbles: DisplayObjectContainer;
	var asteroidParts: DisplayObjectContainer;
	
	var powerLabel: TextField;
	var hpLabel: TextField;
	
	var music: Sound;
	var musicChannel: SoundChannel;
	
	var tutorialAccelerate: Tutorial;
	var tutorialMagnetize: Tutorial;
	
	var accelerateSound: Sound;
	var magnetizeSound: Sound;
	
	var accelerateSoundChannel: SoundChannel;
	var magnetizeSoundChannel: SoundChannel;
	
	var blackHole: BlackHole;
	
	var cinematicMode: Bool;
	var cinematic: Cinematic;
	
	var overlay: Sprite;
	
	var targetPointer: Pointer;
	
	public static inline var blackHolePos = baseWidth * 4;
	
	// percent of asteroids per zone
	var asteroidZones: Array<Float>;
	var mapSize: Float;
	var zoneWidth: Float;
	var asteroidCount: Int;

	public function new() 
	{
		super();
		
		// lower volume on browser builds
#if js
		//Howler.masterGain = 0.3;
		//js.html.audio.v
#end
		
		//width = baseWidth;
		//height = baseHeight;
		
		overlay = new Sprite();
		
		music = Assets.getSound("music/main_track.ogg");
		musicChannel = music.play(0, 100000);
		musicChannel.soundTransform = new SoundTransform(0.1);
		
		//for (i in 0...5)
		{
			/*var*/ stars = new Bitmap(Assets.getBitmapData("img/stars.png"));
			stars.scaleX = 2;
			stars.scaleY = 2;
			//stars.x = i * stars.width /** stars.scaleX*/;
			//stars.y = 0;
			stage.addChildAt(stars, 0);
			//addChild(stars);
		}
		
				
		blackHole = new BlackHole();
		blackHole.x = blackHolePos;
		blackHole.y = baseHeight / 2 /*- blackHole.height / 2*/;
		
		addChild(blackHole);
		
		
		
		asteroidZones = [0.0, 0.05, 0.10, 0.20, 0.30, 0.35];
		//new Array<Float>();
		asteroidCount = 30;
				
		mapSize = blackHolePos + baseWidth / 2;
		zoneWidth = mapSize / asteroidZones.length;
		
		
		
		powerUps = new DisplayObjectContainer();
		asteroids = new DisplayObjectContainer();
		bubbles = new DisplayObjectContainer();
		asteroidParts = new DisplayObjectContainer();
		
		for (i in 0...10)
		{
			var bubble = new Bubble();
			bubbles.addChild(bubble);
		}
		
		for (i in 0...100)
		{
			var part = new Asteroid();
			part.visible = false;
			//part.scaleX = 0.2;
			//part.scaleY = 0.2;
			asteroidParts.addChild(part);
		}
		
		addChild(bubbles);
		addChild(powerUps);
		addChild(asteroids);
		
		gun = new Gun(Main.baseWidth, 70);
		addChild(gun);
		//gun.x -= bitmapData.width / 2;

		ship = new Ship();
		addChild(ship);
		
		addChild(asteroidParts);
		
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
		var textFormat = new TextFormat("Exo 2 Regular Webfont", 72, 0xffffffff);
#else
		var textFormat = new TextFormat("font/Exo2-Regular-webfont.ttf", 72, 0xffffffff);
#end
		
		powerLabel = createTextField(textFormat);
		
		hpLabel = createTextField(textFormat);
		hpLabel.y += 100;
		
		overlay.addChild(powerLabel);
		overlay.addChild(hpLabel);

		
		stage.showDefaultContextMenu = false;
		
		tutorialAccelerate = new Tutorial();
		tutorialMagnetize = new Tutorial();
		
		tutorialAccelerate.text = "Hold RMB to accelerate (uses power)";
		
		tutorialMagnetize.text = "Aim with mouse and hold LMB to magnetize objects";
		
		targetPointer = new Pointer();
		
		overlay.addChild(tutorialAccelerate);
		overlay.addChild(tutorialMagnetize);
		overlay.addChild(targetPointer);
		
		ship.hpChangedCallback = 
			function ()
			{ 
				hpLabel.text = "HP: " + Math.ceil(ship.hp);
				
				if (ship.hp <= 0)
				{
					var loseSound = Assets.getSound("sound/lose.wav");
					loseSound.play();
					
					cinematicMode = true;
					
					cinematic.reset(restartGame);
					cinematic.addPage("Press LMB to play again!", "crash");
					cinematic.nextPage();
					
					//restartGame();
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

		//this.scrollRect = new Rectangle(0, 0, baseWidth, baseHeight);
		
		stage.addChild(overlay);
		
		cinematic = new Cinematic();
		overlay.addChild(cinematic);
		
		//winGame();
		
		// remove intro in debug builds
#if debug
		restartGame();
#else
		cinematicMode = true;
		
		cinematic.reset(restartGame);
		cinematic.addPage("Jim: Hey, captain! (Left Mouse Button to continue)");
		cinematic.addPage("Jim: We are running out of power! Squirrels are exhausted!", "squirrel");
		cinematic.addPage("Cpt.: Damn! Told you squirrel drive is an unreliable thing...", "squirrel");
		cinematic.addPage("Jim: But I have an idea how to get to Dessertcity!", "squirrel");
		cinematic.addPage("Jim: We can magnetize the failure recorders drifting around.", "powerup");
		cinematic.addPage("Cpt.: And?", "powerup");
		cinematic.addPage("Jim: Don't know why, but the squirrels are crazy about them!", "powerup");
		cinematic.addPage("Jim: They'll continue working if they get some.", "powerup");
		cinematic.addPage("Cpt.: Ugh... Let's try it then.", "powerup");

		cinematic.nextPage();
#end
	}
	
	public function asteroidBreak(asteroid: Asteroid)
	{
		function emit(asteroid: Asteroid, part: Asteroid)
		{
			part.visible = true;
			
			part.x = asteroid.x;
			part.y = asteroid.y;
			
			part.scaleX = 0.5;
			part.scaleY = 0.5;
		
			Actuate.tween(part, (Math.random() + 0.5) * 2, { scaleX: 0, scaleY: 0 }).ease(Linear.easeNone).onComplete(function () part.visible = false);

			part.velocity.setTo((Math.random() - 0.5) * 400, (Math.random() - 0.5) * 400);
		}
		
		var maxEmit = 10;
		for (i in 0...asteroidParts.numChildren)
		{
			if (maxEmit <= 0)
				break;
				
			var part: Asteroid = cast asteroidParts.getChildAt(i);
			if (!part.visible)
			{	
				--maxEmit;
				emit(asteroid, part);
			}
		}

	}
	
	function restartGame(/*lose: Bool = true*/)
	{
		if (accelerateSoundChannel != null)
		{
			accelerateSoundChannel.stop();
			accelerateSoundChannel = null;
		}
		
		if (magnetizeSoundChannel != null)
		{
			magnetizeSoundChannel.stop();
			magnetizeSoundChannel = null;
		}
		
		/*if (lose)
		{
			
		}*/
		
		for (i in 0...asteroidParts.numChildren)
		{
			var part: Asteroid = cast asteroidParts.getChildAt(i);
			part.visible = false;
		}
		
		hpLabel.visible = false;
		//hpLabel.visible = true;
		powerLabel.x = 20;
		powerLabel.visible = true;
		targetPointer.visible = true;
		stars.visible = true;
		
		tutorialAccelerate.update(0);
		tutorialMagnetize.update(0);
		
		// quick hack for asteroids spawning at player at start
		ship.hp = 10000.0;
		ship.x = 500;
		//ship.x = blackHole.x + 400;
		ship.y = baseHeight / 2;
		leftMouseButton = false;
		rightMouseButton = false;
		
		generateStuff();
		
		ship.power = 0.0;
		ship.velocity.setTo(0, 0);
		
		cinematicMode = false;
		
		musicChannel.soundTransform = new SoundTransform(0.3);
	}
	
	function winGame()
	{
		cinematicMode = true;
		
		cinematic.reset(restartGame);
		cinematic.addPage("Jim: And we made it!", "win");
		cinematic.addPage("Cpt.: Jim?", "win");
		cinematic.addPage("Jim: Yes, sir?", "win");
		cinematic.addPage("Cpt.: When did you last check the cat stabilizer?", "win");
		cinematic.addPage("Jim: ...", "win");
		cinematic.addPage("Made by crazy squirrels in 48 hours for LD 39 jam :-)", "credits");
		cinematic.addPage("With OpenFl framework and \"Exo 2\" font by Natanael Gama", "credits");
		cinematic.addPage("Cheers! Press LMB to play again!");
		cinematic.nextPage();
		
		musicChannel.soundTransform = new SoundTransform(0.1);
		
		var winSound = Assets.getSound("sound/win.wav");
		winSound.play();
	}
	
	function generateStuff()
	{
		powerUps.removeChildren(0, powerUps.numChildren - 1);
		asteroids.removeChildren(0, asteroids.numChildren - 1);

		// powerups at start screen
		for (i in 0...20)
		{
			var powerUp = new PowerUp();
			powerUp.x = Math.random() * baseWidth / 2;
			powerUp.y = Math.random() * baseHeight;
			
			if (objectOverlap(ship, powerUp))
				powerUp.x += 300;
			
			//powerUp.velocity.setTo(Math.random() - 0.5, Math.random() - 0.5);
			//powerUp.velocity.normalize(10);
			
			powerUps.addChild(powerUp);
		}
		
		// powerups in the other part of map
		for (i in 0...40)
		{
			var powerUp = new PowerUp();
			powerUp.x = Math.random() * (mapSize - baseWidth) + baseWidth;
			powerUp.y = Math.random() * baseHeight;
			
			//powerUp.velocity.setTo(Math.random() - 0.5, Math.random() - 0.5);
			//powerUp.velocity.normalize(10);
			
			powerUps.addChild(powerUp);
		}
		
		// start
		for (x in 0...2)
		for (y in 0...10)
		{
			var asteroid = new Asteroid();
			asteroid.x = x * 250 + (Math.random() - 0.5) * 30 + (y % 3) * 10 - 40;
			asteroid.y = y * 250 + (Math.random() - 0.5) * 30 + 40 * x - 140;
			
			//asteroid.velocity.setTo(Math.random() - 0.5, Math.random() - 0.5);
			//asteroid.velocity.normalize(10);
			
			asteroid.mainSprite = this;
			
			asteroids.addChild(asteroid);
		}
		
		var asteroidsSorted = 0;
		
		var asteroidLastNumbers = new Array<Int>();
		for (i in 0...asteroidZones.length)
		{
			var asteroidsInZone = Std.int(asteroidZones[i] * asteroidCount);
			
			asteroidLastNumbers[i] = asteroidsSorted + asteroidsInZone;
			asteroidsSorted += asteroidsInZone;
		}
		
		var zoneNumber = 0;
		for (i in 0...asteroidCount)
		{
			var asteroid = new Asteroid();
			
			if (i >= asteroidLastNumbers[zoneNumber])
				zoneNumber++;
			
			var zoneX = zoneWidth * zoneNumber;
			
			asteroid.x = Math.random() * zoneWidth + zoneX;
			asteroid.y = Math.random() * baseHeight;
			
			//asteroid.velocity.setTo(Math.random() - 0.5, Math.random() - 0.5);
			//asteroid.velocity.normalize(10);
			
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
		
		if (cinematicMode)
		{
			cinematic.nextPage();
		}
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
		//leftMouseButton = false;
		//rightMouseButton = false;
		
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
		
		overlay.x = this.x;
		overlay.y = this.y;
		
		overlay.scaleX = this.scaleX;
		overlay.scaleY = this.scaleY;
		
		stars.x = this.x;
		stars.y = this.y;
		
		stars.scaleX = this.scaleX * 2;
		stars.scaleY = this.scaleY * 2;
	}
	
	function onEnterFrame(_)
	{
		var newTime = Timer.stamp();
		var dt = newTime - time;
		time = newTime;
		
		gun.visible = false;
		
		var playAccelerateSound = false;
		var playMagnetizeSound = false;
		
		visible = !cinematicMode;
		cinematic.visible = cinematicMode;

		if (!cinematicMode)
		{
			if (objectOverlap(ship, blackHole))
			{
				winGame();
				return;
			}
			
			//leftMouseButton = false;
			
			tempPoint.setTo(stage.mouseX, stage.mouseY);
			
			//trace(tempPoint);
			
			var direction = this.globalToLocal(tempPoint); //.subtract(ship.center);
			direction.x -= ship.x;
			direction.y -= ship.y;
			
			//var x1 = ship.center.x;
			//var y1 = ship.center.y;
			
			if (direction.length > 0)
			{
				ship.rotation = Math.atan2(direction.y, direction.x) * 180 / Math.PI;
				
				if (leftMouseButton)
				{
					playMagnetizeSound = true;
					
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
						playAccelerateSound = true;
					}
				}
			}


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
						
				// bump the asteroid
				/*if (objectOverlap(blackHole, asteroid))
				{
					asteroid.visible = false;
				}
				else*/ if (objectCollide(ship, asteroid, dt))
				{
					ship.hp -= Asteroid.damage;
					asteroid.visible = false;
					
					asteroidBreak(asteroid);
					
					if (ship.hp < 1000)
						Assets.getSound("sound/asteroid.wav").play();
				}
				else
				{
					for (j in 0...asteroids.numChildren)
					{
						var asteroid2: Asteroid = cast asteroids.getChildAt(j);
						asteroid.update(dt);
						
						if (asteroid.visible == false || asteroid2.visible == false)
							continue;
								
						// asteroid collision
						if (asteroid != asteroid2 && objectCollide(asteroid, asteroid2, dt))
						{
							asteroid.visible = false;
							asteroid2.visible = false;
							
							asteroidBreak(asteroid);
							asteroidBreak(asteroid2);
						}
					}
				}
			}
			
			for (i in 0...bubbles.numChildren)
			{
				var bubble: Bubble = cast bubbles.getChildAt(i);
				bubble.update(dt);
			}
			
			for (i in 0...asteroidParts.numChildren)
			{
				var part: Asteroid = cast asteroidParts.getChildAt(i);
				part.update(dt);
			}
		
			ship.update(dt);
			gun.update(dt);
			blackHole.update(dt);
			
			if (ship.x + ship.radius < 0 || ship.x - ship.radius > Main.blackHolePos + Main.baseWidth / 2 || ship.y + ship.radius < 0 || ship.y - ship.radius > Main.baseHeight)
			{
				cinematicMode = true;
					
				cinematic.reset(restartGame);
				cinematic.addPage("Achievement unlocked: Curiousity", "curiosity");
				cinematic.addPage("Press LMB to play again!", "crash");
				cinematic.nextPage();
				return;
			}
			
			if (time - respawnAsteroidsTime > 1)
			{
				respawnAsteroidsTime = time;
				respawnAsteroids();
			}
		}
		else
		{
			tutorialAccelerate.visible = false;
			tutorialMagnetize.visible = false;
			hpLabel.visible = false;
			powerLabel.visible = false;
			targetPointer.visible = false;
			stars.visible = false;
		}
		
		if (playAccelerateSound)
		{
			if (accelerateSoundChannel == null)
				accelerateSoundChannel = accelerateSound.play(0, 100000);
		}
		else
		{
			if (accelerateSoundChannel != null)
			{
				accelerateSoundChannel.stop();
				accelerateSoundChannel = null;
			}
		}
		
		if (playMagnetizeSound)
		{
			if (magnetizeSoundChannel == null)
				magnetizeSoundChannel = magnetizeSound.play(0, 100000);
		}
		else
		{
			if (magnetizeSoundChannel != null)
			{
				magnetizeSoundChannel.stop();
				magnetizeSoundChannel = null;
			}
		}
			
		//this.scrollRect.offset(ship.center.x, 0);
		//trace(this.scrollRect.x);
		
		var offset = ship.center.x >= 500 ? ship.center.x - 500 : 0;
		if (offset > blackHole.x - baseWidth / 2)
			offset = blackHole.x - baseWidth / 2;
		this.scrollRect = new Rectangle(offset, 0, baseWidth, baseHeight);
		
		targetPointer.update(offset, blackHole.x);
	}
	
	function respawnAsteroids()
	{
		var asteroidsNeeded = new Array<Int>();
		
		// desired asteroid count per zone
		for (i in 0...asteroidZones.length)
		{
			asteroidsNeeded[i] = Math.floor(asteroidZones[i] * asteroidCount);
		}
		
		// asteroid shortage per zone
		for (i in 0...asteroids.numChildren)
		{
			var asteroid: Asteroid = cast asteroids.getChildAt(i);
			
			if (asteroid.visible)
			{
				var zoneNumber = Math.floor(asteroid.x / zoneWidth);
				if (zoneNumber < 0)
					zoneNumber = 0;
				if (zoneNumber >= asteroidZones.length)
					zoneNumber = asteroidZones.length - 1;
				
				//trace(zoneNumber, asteroidsNeeded[zoneNumber]);
				
				asteroidsNeeded[zoneNumber]--;
			}
		}
		
		// where the asteroid shortage is maximum
		var zoneToSpawn = 0;
		
		function updateZoneToSpawn()
		{
			var maxAsteroidsNeeded = asteroidsNeeded[0];
			for (i in 1...asteroidZones.length)
			{
				if (asteroidsNeeded[i] > maxAsteroidsNeeded)
				{
					maxAsteroidsNeeded = asteroidsNeeded[i];
					zoneToSpawn = i;
				}
			}
		}
		
		// respawn asteroids
		for (i in 0...asteroids.numChildren)
		{
			var asteroid: Asteroid = cast asteroids.getChildAt(i);
			
			if (!asteroid.visible)
			{
				updateZoneToSpawn();
				
				// spawn asteroid
				var zoneX = zoneToSpawn * zoneWidth;

				asteroid.x = Math.random() * zoneWidth + zoneX;
				
				var fromTop: Bool = (Math.random() > 0.5);
				asteroid.y = fromTop ? -asteroid.radius * 9 / 10 : baseHeight + asteroid.radius * 9 / 10;
			
				asteroid.velocity.setTo(Math.random() - 0.5, fromTop ? 0.5 : -0.5);
				asteroid.velocity.normalize(1.0 * zoneToSpawn);
				
				asteroid.visible = true;
				asteroidsNeeded[zoneToSpawn]--;
			}
		}
	}
	
	function objectCollide(object1: BaseObject, object2: BaseObject, dt: Float): Bool
	{
		var overlap = objectOverlap(object1, object2);
		
		if (overlap)
		{
			/*var oldVx1 = object1.velocity.x;
			var oldVy1 = object1.velocity.y;
			var oldVx2 = object2.velocity.x;
			var oldVy2 = object2.velocity.y;
			
			object1.velocity.setTo(object1.bounceCoefficient * ());
			object2.velocity.setTo();*/
		}
		
		return overlap;
	}
	
	function objectOverlap(object1: BaseObject, object2: BaseObject): Bool
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

}
