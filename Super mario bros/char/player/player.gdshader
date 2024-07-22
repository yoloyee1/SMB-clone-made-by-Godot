shader_type canvas_item;
varying vec4 modulate;

uniform float strength: hint_range(0., 1.) = 0.;
uniform float speed: hint_range(0., 50.) = 50;
uniform float angle: hint_range(0., 360.) = 0.;

void vertex()
{
	modulate = COLOR;
}

void fragment() {
	float hue = UV.x * cos(radians(angle)) - UV.y * sin(radians(angle));
	hue = fract(hue + fract(TIME  * speed));
	float x = 1. - abs(mod(hue / (1./ 6.), 2.) - 1.);
	vec3 rainbow;
	if(hue < 1./6.){
		rainbow = vec3(1., x, 0.);
	} else if (hue < 1./3.) {
		rainbow = vec3(x, 1., 0);
	} else if (hue < 0.5) {
		rainbow = vec3(0, 1., x);
	} else if (hue < 2./3.) {
		rainbow = vec3(0., x, 1.);
	} else if (hue < 5./6.) {
		rainbow = vec3(x, 0., 1.);
	} else {
		rainbow = vec3(1., 0., x);
	}
	vec4 color = texture(TEXTURE, UV);
	COLOR = mix(color, vec4(rainbow, color.a), strength) * modulate;
}

void light()
{
	vec4 color = texture(TEXTURE, UV);
	LIGHT = vec4(color.rgb * LIGHT_COLOR.rgb * LIGHT_ENERGY, LIGHT_COLOR.a);
}

