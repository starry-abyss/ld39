package;

import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;

/**
 * ...
 * @author scorched
 */
class Pointer extends Sprite
{

	var text: TextField;
	var image: Sprite;
	
	var spacing: Float = 100;
	
	var pointDown(default, set): Bool;
	
	function set_pointDown(value: Bool)
	{
		pointDown = value;
		
		image.rotation = pointDown ? 180 : 90;
		
		return pointDown;
	}

	public function new()
	{
		super();

		image = new Sprite();
		text = new TextField();
		
		var bitmapData = Assets.getBitmapData("img/pointer.png");
		var bitmap = new Bitmap(bitmapData);
		bitmap.x -= bitmapData.width / 2;
		bitmap.y -= bitmapData.height / 2;
		image.addChild(bitmap);

		#if js
		var textFormat = new TextFormat("Exo 2 Regular Webfont", 72, 0xffffffff);
		#else
		var textFormat = new TextFormat("font/Exo2-Regular-webfont.ttf", 72, 0xffffffff);
		#end

		//textFormat.align = CENTER;
		text.setTextFormat(textFormat);

		//multiline = true;

		text.selectable = false;
		text.text = "Destination";

		text.width = 2000;
		text.height = 100;

		//text.x = Main.baseWidth / 2 - text.width / 2;
		//text.y = Main.baseHeight * 9 / 10;

		image.scaleX = 0.25;
		image.scaleY = 0.25;

		//reset();

		addChild(image);
		addChild(text);
		
		pointDown = false;
	}
	
	public function update(scrollX: Float, holeX: Float)
	{
		var offset = 300;

		if (scrollX + Main.baseWidth < holeX)
		{
			x = Main.baseWidth - text.textWidth - spacing - image.width;
			pointDown = false;
		}
		else
		{
			x = holeX - scrollX - offset;
			pointDown = true;
		}

		image.x = text.textWidth + spacing;
		image.y = text.y + text.textHeight / 2;
	}

}