// The water of spec 7.1 and 7.2: the deep colour of the Area, short wave lines in its light colour,
// and soft light patterns (spec 8.2, Open gap 6). The water is still: it shows the motion of
// spec 8.2 at the time t = 0.
// All sizes are px of the prototype tile of 130 px (spec 8.1), relative to the Labyrinth.
shader_type canvas_item;

uniform vec4 deep_colour : source_color = vec4(0.247, 0.706, 0.847, 1.0);
uniform vec4 light_colour : source_color = vec4(0.498, 0.847, 0.937, 1.0);
// Canvas px of the Labyrinth tile (0, 0), and s = tile px / 130 of spec 8.1.
uniform vec2 labyrinth_origin = vec2(0.0);
uniform float s = 1.0;

// Wave lines: 18 % opacity, 3 px wide, rows 34 px apart, one line every 90 px in a row. Each line
// is the quadratic curve of the motion prototype: 44 px long, 3 px high in the middle.
const float WAVE_ALPHA = 0.18;
const float WAVE_WIDTH = 3.0;
const float ROW_DISTANCE = 34.0;
const float LINE_DISTANCE = 90.0;
const float LINE_LENGTH = 44.0;
// The first row and line of the prototype, relative to its Labyrinth origin (90, 150).
const vec2 GRID_START = vec2(-130.0, -40.0);
const vec2 PROTOTYPE_ORIGIN = vec2(90.0, 150.0);
// Each line moves 8 * sin(1.2 t + 0.02 x + 0.05 y) px, with x and y in prototype canvas px.
const float WAVE_SHIFT = 8.0;
// Light patterns: soft light shapes at 8 % opacity.
const float LIGHT_ALPHA = 0.08;

varying vec2 canvas_px;

void vertex() {
	canvas_px = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

// Distance in prototype px from p to the wave line of row j and column k, or a large value.
float wave_distance(vec2 p, float j, float k) {
	float row_y = GRID_START.y + j * ROW_DISTANCE;
	float line_x = GRID_START.x + k * LINE_DISTANCE;
	vec2 prototype_px = vec2(line_x, row_y) + PROTOTYPE_ORIGIN;
	float t = 0.0; // The still water.
	line_x += WAVE_SHIFT * sin(1.2 * t + 0.02 * prototype_px.x + 0.05 * prototype_px.y);
	float u = (p.x - line_x) / LINE_LENGTH;
	if (u < 0.0 || u > 1.0) {
		return 1e6;
	}
	float curve_y = row_y - 12.0 * u * (1.0 - u);
	float slope = -12.0 * (1.0 - 2.0 * u) / LINE_LENGTH;
	return abs(p.y - curve_y) / sqrt(1.0 + slope * slope);
}

float hash(vec2 cell) {
	return fract(sin(dot(cell, vec2(127.1, 311.7))) * 43758.5453);
}

// Smooth value noise from 0 to 1, with one value for each cell of size 1.
float value_noise(vec2 p) {
	vec2 cell = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	float top = mix(hash(cell), hash(cell + vec2(1.0, 0.0)), u.x);
	float bottom = mix(hash(cell + vec2(0.0, 1.0)), hash(cell + vec2(1.0, 1.0)), u.x);
	return mix(top, bottom, u.y);
}

// Soft round light shapes, a few hundred px across, on part of the water.
float light_pattern(vec2 p) {
	float n = 0.75 * value_noise(p / 170.0) + 0.25 * value_noise(p / 80.0 + vec2(17.3, 5.1));
	return smoothstep(0.5, 0.8, n);
}

void fragment() {
	vec2 p = (canvas_px - labyrinth_origin) / s;
	float j = floor((p.y - GRID_START.y) / ROW_DISTANCE + 0.5);
	float k = floor((p.x - GRID_START.x) / LINE_DISTANCE);
	float d = 1e6;
	for (float dj = -1.0; dj <= 1.0; dj += 1.0) {
		for (float dk = -1.0; dk <= 1.0; dk += 1.0) {
			d = min(d, wave_distance(p, j + dj, k + dk));
		}
	}
	// Distance in canvas px, with a soft edge of 1 px.
	float half_width = 0.5 * WAVE_WIDTH * s;
	float line = 1.0 - smoothstep(half_width - 0.5, half_width + 0.5, d * s);
	vec3 colour = mix(deep_colour.rgb, light_colour.rgb, WAVE_ALPHA * line);
	colour = mix(colour, vec3(1.0), LIGHT_ALPHA * light_pattern(p));
	COLOR = vec4(colour, 1.0);
}
