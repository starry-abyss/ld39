package;

import openfl.text.TextField;
import openfl.text.TextFormat;

/**
 * ...
 * @author scorched
 */
class Tutorial extends TextField
{
	var timer: Float;
	var maxTime: Float = 1.0;
	public var hide(default, set): Bool;

	public function new() 
	{
		super();
		
#if js
		var textFormat = new TextFormat("Exo 2 Extra Light Regular Webfont", 80, 0xffffffff);
#else
		var textFormat = new TextFormat("font/Exo2-ExtraLight-webfont.ttf", 80, 0xffffffff);
#end

		textFormat.align = CENTER;
		setTextFormat(textFormat);
		
		//multiline = true;
		
		selectable = false;
		
		width = 2000;
		height = 200;
		
		reset();
	}
	
	public function reset()
	{
		timer = 0.0;
		//visible = true;
		hide = false;
		
		update(0);
	}
	
	function set_hide(value: Bool)
	{
		this.hide = value;
		
		update(0);
		
		return this.hide;
	}
	
	public function update(dt: Float)
	{
		if (timer < maxTime && !hide)
		{
			timer += dt;
			visible = true;
			//hide = false;
		}
		else
		{
			visible = false;
			//hide = true;
		}
	}
	
}