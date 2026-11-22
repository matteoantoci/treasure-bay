## Game-flow spec part 5, fix 10: the idle hint. When the Child presses no key for 6 s while the
## play is free, the open chest or the nearest uncollected Item hops. Labyrinth 1 starts the boat on
## (0, 0) with its Items on (1, 1) and (0, 2). One press down takes the boat to (0, 2). The Item on
## (1, 1) is first in the Item list and nearer in a straight line, but it needs more presses.
extends RefCounted

const Scene := preload("res://tests/scene_helpers.gd")


## The press path of the move rule: the boat stops on each uncollected Item, so (0, 2) is one press
## away from the start and (1, 1) is more presses away.
func test_the_nearest_target_has_the_shortest_press_path(t) -> bool:
	var labyrinth := LabyrinthPlan.build(1)
	var items := {Vector2i(1, 1): false, Vector2i(0, 2): false}
	var targets := {Vector2i(1, 1): true, Vector2i(0, 2): true}
	var path := MoveRule.nearest_target(labyrinth, Vector2i(0, 0), items, targets)
	t.assert_eq(path.target, Vector2i(0, 2), "the Item on (0, 2) is the nearest")
	t.assert_eq(path.first_press, Vector2i.DOWN, "the first press is down")
	t.assert_eq(path.presses, 1, "one press")
	items[Vector2i(0, 2)] = true
	path = MoveRule.nearest_target(labyrinth, Vector2i(0, 2), items, {Vector2i(1, 1): true})
	t.assert_eq(path.target, Vector2i(1, 1), "the Item on (1, 1) from (0, 2)")
	t.assert_true(path.presses > 1, "more than one press to (1, 1)")
	t.assert_eq(MoveRule.nearest_target(labyrinth, Vector2i(1, 1), items, {Vector2i(1, 1): true}), null, "no path when the boat is on the target")
	return true


## A LabyrinthView of Labyrinth 1 with a tile of 121 px, in the tree, so it can make tweens.
static func _labyrinth_view(t) -> LabyrinthView:
	var view := LabyrinthView.new()
	t.root.add_child(view)
	view.labyrinth = LabyrinthPlan.build(1)
	view.tile_px = 121.0
	return view


static func _near(t, actual: float, expected: float, label: String) -> void:
	t.assert_true(absf(actual - expected) < 0.01, "%s: %.4f, expected %.4f" % [label, actual, expected])


## Checks one hop of `sprite` in steps of `tween`: up by 12 % of the 121 px tile at the top, then a
## landing squash of 108 % wide and 92 % tall with its bottom in place, then the rest place at
## 350 ms.
static func _check_hop(t, sprite: Sprite2D, tween: Tween, what: String) -> void:
	var rest := sprite.position
	var rest_scale := sprite.scale
	var height := sprite.texture.get_size().y * rest_scale.y
	tween.pause()
	tween.custom_step(0.1225)
	_near(t, rest.y - sprite.position.y, 0.12 * 121.0, "%s: up by 12 %% of a tile at the top" % what)
	t.assert_eq(sprite.scale, rest_scale, "%s: no squash in the air" % what)
	tween.custom_step(0.175)
	_near(t, sprite.scale.x / rest_scale.x, 1.08, "%s: 108 %% wide in the landing squash" % what)
	_near(t, sprite.scale.y / rest_scale.y, 0.92, "%s: 92 %% tall in the landing squash" % what)
	_near(t, sprite.position.y + sprite.texture.get_size().y * sprite.scale.y / 2.0, rest.y + height / 2.0, "%s: the bottom stays in place in the squash" % what)
	_near(t, sprite.position.x, rest.x, "%s: no move sideways" % what)
	tween.custom_step(0.0525)
	t.assert_true(not tween.is_valid() or not tween.is_running(), "%s: the hop ends at 350 ms" % what)
	t.assert_eq(sprite.position, rest, "%s: back in its place" % what)
	t.assert_eq(sprite.scale, rest_scale, "%s: back to its size" % what)


func test_the_chest_hops_up_with_a_landing_squash_in_350_ms(t) -> bool:
	var view := _labyrinth_view(t)
	_check_hop(t, view.chest, view.hop_chest(), "chest")
	view.free()
	return true


func test_an_item_hops_up_with_a_landing_squash_in_350_ms(t) -> bool:
	var labyrinth := LabyrinthPlan.build(1)
	var items := ItemsView.new()
	t.root.add_child(items)
	items.show_items(labyrinth, Progress.new())
	items.set_tile_px(121.0)
	var other: Sprite2D = items.sprite_of(labyrinth.items[1].id)
	var other_rest := other.position
	_check_hop(t, items.sprite_of(labyrinth.items[0].id), items.hop_item(labyrinth.items[0].id), "item")
	t.assert_eq(other.position, other_rest, "the other Item does not hop")
	items.free()
	return true
