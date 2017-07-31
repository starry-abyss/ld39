package;

import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.Shader;
import openfl.filters.ShaderFilter;

/**
 * ...
 * @author scorched
 */
class BlackHole extends BaseObject 
{
	
	var time: Float = 0.0;
	var shader: Shader;

	public function new() 
	{
		var bitmapData = Assets.getBitmapData("img/hole.png");
		
		super(100);

		var bitmap = new Bitmap(bitmapData);
		bitmap.x -= bitmap.width / 2;
		bitmap.y -= bitmap.height / 2;
		
		addChild(bitmap);
		
		//bitmap.width = 2000;
		//bitmap.height = 2000;
		
		shader = new Shader();
		
		shader.glFragmentSource =
		"varying float vAlpha;
		varying vec2 vTexCoord;
		uniform sampler2D uImage0;

		uniform vec4 color;
		uniform float time;

		float circleStrange(vec2 p)
		{
			  return (1.0 - 0.7 * length(p - 0.5)) * 0.2 - 0.07;
			  //return 1.0 - length(p - 0.5);
		}

		float circle(vec2 p)
		{
			  float d = length(p - 0.5);
			  //return exp(d * 1.0);
			  return pow(1.0 - d, 6.0) + pow(1.0 - d, 5.0);
		}

		void main(void)
		{
			// black hole
			
			float rx = (vTexCoord.x - 0.5) / 2.0;
			float ry = (vTexCoord.y - 0.5) / 2.0;
			
			float cx = sin(((1.0 - circleStrange(vTexCoord)) - time / 100.0) * 300.0) * 0.30 + 0.2;
			//float cy = sin((vTexCoord.y) * 2.0) * 0.10 + 0.2;


			float ca = atan(ry / rx) * 2.0;
			ca += length(vec2(rx, ry)) + time / 2.0;
			
			float sa = sin(ca) * 3.0;
			
			float c = circleStrange(vTexCoord) * 4.0;
			
			gl_FragColor = vec4(vec3(c * sa * 1.0 - cx) * circle(vTexCoord) * 0.25, 0.0);
		}";
		
		shader.data.time.value = [ time ];
		
		bitmap.filters = [ new ShaderFilter(shader) ];
	}
	
	override public function update(dt: Float)
	{
		super.update(dt);
		
		time += dt;
		shader.data.time.value = [ time ];
	}
	
}