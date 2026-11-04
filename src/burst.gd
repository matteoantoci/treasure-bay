## A burst of small pieces (spec 8.1, 8.4 to 8.6): a one-shot CPUParticles2D that emits all its
## pieces at once, in all directions, at the burst speed times a random factor from 0.4 to 1.2.
## The pieces fade out over their life. The node frees itself when the last piece is gone. The
## values are px of the prototype; fire() scales the node by s or h (spec 8.1).
class_name Burst
extends CPUParticles2D

## The texture star has this radius in texture px.
const STAR_TEXTURE_RADIUS := 15.0
const STAR_TEXTURE_PX := 32
## The confetti texture is twice the piece size, so its edges stay smooth when it turns.
const CONFETTI_TEXTURE_SCALE := 2

static var _star_texture: ImageTexture
static var _confetti_texture: ImageTexture


func _init() -> void:
	one_shot = true
	explosiveness = 1.0
	emitting = false
	local_coords = true
	spread = 180.0
	gravity = Vector2.ZERO
	var fade := Gradient.new()
	fade.colors = PackedColorArray([Color.WHITE, Color(1, 1, 1, 0)])
	color_ramp = fade
	finished.connect(queue_free)


## Splash dots or sparkles: small white or coloured 8-point stars of radius 4 px.
static func stars(count: int, colours: Array, speed_px: float, life: float) -> Burst:
	var burst := Burst.new()
	burst.amount = count
	burst.lifetime = life
	burst.texture = star_texture()
	var star_scale := Motion.BURST_STAR_RADIUS_PX / STAR_TEXTURE_RADIUS
	burst.scale_amount_min = star_scale
	burst.scale_amount_max = star_scale
	burst._set_speed(speed_px)
	burst._set_colours(colours)
	return burst


## The confetti of the Goal (spec 8.5): turning rectangles of 10 x 6 px in 5 colours, with an
## upward push and gravity.
static func confetti() -> Burst:
	var burst := Burst.new()
	burst.amount = Motion.CONFETTI_COUNT
	burst.lifetime = Motion.CONFETTI_LIFE
	burst.texture = confetti_texture()
	burst.scale_amount_min = 1.0 / CONFETTI_TEXTURE_SCALE
	burst.scale_amount_max = 1.0 / CONFETTI_TEXTURE_SCALE
	burst._set_speed(Motion.CONFETTI_SPEED_PX)
	burst._set_colours(Motion.CONFETTI_COLOURS)
	burst.gravity = Vector2(0, Motion.CONFETTI_GRAVITY_PX)
	burst.angle_min = 0.0
	burst.angle_max = 360.0
	burst.angular_velocity_min = rad_to_deg(Motion.CONFETTI_SPIN_RAD)
	burst.angular_velocity_max = rad_to_deg(Motion.CONFETTI_SPIN_RAD)
	# The prototype gives a piece in direction a the velocity v (cos a, sin a - 0.6). Each piece
	# starts on one of these directed points: the speed v along the point normal.
	var points := PackedVector2Array()
	var normals := PackedVector2Array()
	for k in Motion.CONFETTI_COUNT:
		var angle := TAU * (k + 0.5) / Motion.CONFETTI_COUNT
		points.append(Vector2.ZERO)
		normals.append(Vector2(cos(angle), sin(angle) - Motion.CONFETTI_PUSH))
	burst.emission_shape = EMISSION_SHAPE_DIRECTED_POINTS
	burst.emission_points = points
	burst.emission_normals = normals
	burst.direction = Vector2.RIGHT
	burst.spread = 0.0
	return burst


## The 8 corners of a star: 4 long points at `radius` and 4 short ones between them at 0.35 of it
## (the prototype star()).
static func star_points(centre: Vector2, radius: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for k in 8:
		var angle := k * PI / 4.0
		var r := radius if k % 2 == 0 else radius * 0.35
		points.append(centre + Vector2(cos(angle), sin(angle)) * r)
	return points


static func star_texture() -> ImageTexture:
	if _star_texture == null:
		var image := Image.create_empty(STAR_TEXTURE_PX, STAR_TEXTURE_PX, false, Image.FORMAT_RGBA8)
		var star := star_points(Vector2.ONE * STAR_TEXTURE_PX / 2.0, STAR_TEXTURE_RADIUS)
		# 4 x 4 samples for each pixel give a smooth edge.
		for y in STAR_TEXTURE_PX:
			for x in STAR_TEXTURE_PX:
				var inside := 0
				for sy in 4:
					for sx in 4:
						if Geometry2D.is_point_in_polygon(Vector2(x + (sx + 0.5) / 4.0, y + (sy + 0.5) / 4.0), star):
							inside += 1
				image.set_pixel(x, y, Color(1, 1, 1, inside / 16.0))
		image.generate_mipmaps()
		_star_texture = ImageTexture.create_from_image(image)
	return _star_texture


static func confetti_texture() -> ImageTexture:
	if _confetti_texture == null:
		var size := Vector2i(Motion.CONFETTI_SIZE_PX) * CONFETTI_TEXTURE_SCALE
		var image := Image.create_empty(size.x, size.y, false, Image.FORMAT_RGBA8)
		image.fill(Color.WHITE)
		image.generate_mipmaps()
		_confetti_texture = ImageTexture.create_from_image(image)
	return _confetti_texture


## Adds the burst to `parent` at `centre`, scaled by `scale_factor` (s or h), and starts it.
func fire(parent: Node, centre: Vector2, scale_factor: float) -> void:
	position = centre
	scale = Vector2.ONE * scale_factor
	parent.add_child(self)
	restart()


func _set_speed(speed_px: float) -> void:
	initial_velocity_min = speed_px * Motion.BURST_SPEED_FACTOR.x
	initial_velocity_max = speed_px * Motion.BURST_SPEED_FACTOR.y


## Each piece takes one of the colours, all with the same chance.
func _set_colours(colours: Array) -> void:
	var pick := Gradient.new()
	pick.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CONSTANT
	var offsets := PackedFloat32Array()
	for i in colours.size():
		offsets.append(float(i) / colours.size())
	pick.offsets = offsets
	pick.colors = PackedColorArray(colours)
	color_initial_ramp = pick
