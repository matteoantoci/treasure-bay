// The foam dashes of spec 8.2 on a Line2D. The line draws a 1 x 1 white texture in tile mode, so
// UV.x is the distance along the line in line widths.
shader_type canvas_item;

// Dash and dash + gap, in line widths.
uniform float dash_widths = 2.5;
uniform float period_widths = 4.75;
// How far the dashes moved along the line, in line widths.
uniform float shift_widths = 0.0;

void fragment() {
	float u = mod(UV.x - shift_widths, period_widths);
	// A soft dash end, one screen pixel long.
	float edge = max(fwidth(UV.x), 1e-4);
	float on = smoothstep(0.0, edge, u) * (1.0 - smoothstep(dash_widths - edge, dash_widths, u));
	COLOR.a *= on;
}
