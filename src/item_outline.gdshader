// The ghost of an empty Item slot (spec 8.7): the Item sprite drawn grey and light at
// `body_opacity`, as the CSS filter grayscale(1) brightness(2) of the motion prototype. A thin dark
// edge goes around the shape of the sprite, so the ghost shows on the light discs of Areas 1 to 3
// too (code review fix of ticket 12). The node modulate fades the ghost and its edge together.
shader_type canvas_item;

// The opacity of the grey sprite.
uniform float body_opacity = 0.35;
// The colour and the opacity of the edge, in sRGB like the other 2D colours.
uniform vec4 edge_colour = vec4(0.039, 0.078, 0.157, 0.8);
// The width of the edge in pixels of the sprite texture. The Item sprites have a clear margin of
// 19 texture pixels, so the edge stays inside the texture.
uniform float edge_texels = 12.0;

// Each ring of the edge test has this many samples.
const int EDGE_SAMPLES = 16;

varying vec4 vertex_colour;

void vertex() {
	vertex_colour = COLOR;
}

void fragment() {
	vec4 sprite = texture(TEXTURE, UV);
	float grey = dot(sprite.rgb, vec3(0.2126, 0.7152, 0.0722));
	float body = sprite.a * body_opacity;
	// The largest alpha of the sprite within the edge width: two rings, at the full width and at
	// half of it, so a thin part of the shape also gets its edge.
	float near = 0.0;
	vec2 reach = TEXTURE_PIXEL_SIZE * edge_texels;
	for (int i = 0; i < EDGE_SAMPLES; i++) {
		float angle = TAU * float(i) / float(EDGE_SAMPLES);
		vec2 direction = vec2(cos(angle), sin(angle)) * reach;
		near = max(near, texture(TEXTURE, UV + direction).a);
		near = max(near, texture(TEXTURE, UV + 0.5 * direction).a);
	}
	// The edge is outside the shape only. The grey sprite lies on top of it.
	float edge = clamp(near - sprite.a, 0.0, 1.0) * edge_colour.a;
	float alpha = body + edge * (1.0 - body);
	vec3 colour = edge_colour.rgb;
	if (alpha > 0.0) {
		colour = (vec3(min(2.0 * grey, 1.0)) * body + edge_colour.rgb * edge * (1.0 - body)) / alpha;
	}
	COLOR = vec4(colour, alpha) * vertex_colour;
}
