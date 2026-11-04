// An empty Item outline (spec 8.7): the Item sprite drawn grey and light, as the CSS filter
// grayscale(1) brightness(2) of the motion prototype. The node modulate sets the opacity.
shader_type canvas_item;

varying vec4 vertex_colour;

void vertex() {
	vertex_colour = COLOR;
}

void fragment() {
	vec4 sprite = texture(TEXTURE, UV);
	float grey = dot(sprite.rgb, vec3(0.2126, 0.7152, 0.0722));
	COLOR = vec4(vec3(min(2.0 * grey, 1.0)), sprite.a) * vertex_colour;
}
