package;

import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Shader;
import openfl.display.Sprite;
import openfl.filters.ShaderFilter;

/**
 * ...
 * @author scorched
 */
class Gun extends Sprite
{
	
	var time: Float = 0.0;
	var shader: Shader;

	public function new(width: Float, height: Float) 
	{
		super();
		
		var bitmap = new Bitmap(new BitmapData(Std.int(width), Std.int(height), true, 0xaaaaaaaa));
		bitmap.y -= height / 2;

		addChild(bitmap);
		
		
		shader = new Shader();
		
		shader.glFragmentSource =
		"varying float vAlpha;
		varying vec2 vTexCoord;
		uniform sampler2D uImage0;

		uniform vec4 color;
		uniform float time;

		void main(void)
		{
			float cx = sin(((1.0 - vTexCoord.x) - time / 20.0) * 300.0) * 0.30 + 0.2;
			float cy = sin((vTexCoord.y) * 2.0) * 0.10 + 0.2;
			
			float c = cy * cx;
			
			gl_FragColor = vec4(vec3(c), 0.2);
		}";
		
		shader.data.time.value = [ time ];
		
		bitmap.filters = [ new ShaderFilter(shader) ];
	}
	
	public function update(dt: Float)
	{
		time += dt;
		shader.data.time.value = [ time ];
	}
	
}