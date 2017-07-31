package;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.filters.BlurFilter;
import openfl.filters.GlowFilter;
import openfl.text.TextField;
import openfl.text.TextFormat;

typedef Page =
{
	var text: String;
	var image: String;
}

/**
 * ...
 * @author scorched
 */
class Cinematic extends Sprite 
{
	var pages: Array<Page>;
	
	public var endCallback: Void->Void;
	
	var currentPage: Int;
	
	var image: Bitmap;
	var text: TextField;
	
	public function nextPage()
	{
		if (currentPage >= pages.length)
		{
			if (endCallback != null)
			{
				endCallback();
				endCallback = null;
			}
			return;
		}
		
		if (pages[currentPage].image != null)
		{
			image.bitmapData = Assets.getBitmapData("img/cinematic/" + pages[currentPage].image + ".png");
			image.x = Main.baseWidth / 2 - image.width / 2;
			image.y = Main.baseHeight / 2 - image.height / 2 - image.height / 8;
			image.visible = true;
		}
		else
		{
			image.visible = false;
		}
		
		text.text = pages[currentPage].text;
		
		++currentPage;
	}
	
	public function reset(endCallback: Void->Void = null)
	{
		pages = new Array<Page>();
		currentPage = 0;
		
		this.endCallback = endCallback;
	}
	
	public function addPage(text: String, image: String = null)
	{
		pages.push( { text: text, image: image } );
	}

	public function new() 
	{
		super();
		
		image = new Bitmap();
		text = new TextField();
		
		
#if js
		var textFormat = new TextFormat("Exo 2 Regular Webfont", 72, 0xffffffff);
#else
		var textFormat = new TextFormat("font/Exo2-Regular-webfont.ttf", 72, 0xffffffff);
#end

		textFormat.align = CENTER;
		text.setTextFormat(textFormat);
		
		//multiline = true;
		
		text.selectable = false;
		
		text.width = 2000;
		text.height = 100;
		
		text.x = Main.baseWidth / 2 - text.width / 2;
		text.y = Main.baseHeight * 9 / 10;
		
		image.scaleX = 4;
		image.scaleY = 4;
		
		reset();
		
		addChild(image);
		addChild(text);
		
		//image.filters = [ new GlowFilter(0xffffffff, 1, 4, 4) ];
	}
	
}