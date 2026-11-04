## The look of each Area (spec 7.2): water colours and decoration.
extends RefCounted


func test_water_colours_of_each_area(t) -> bool:
	var deep := ["#3fb4d8", "#2aa6a0", "#1f6fb5", "#14284f"]
	var light := ["#7fd8ef", "#76d6c4", "#5aa0dc", "#3a5a92"]
	for area in range(1, 5):
		t.assert_eq(Area.deep_colour(area), Color(deep[area - 1]), "Area %d deep colour" % area)
		t.assert_eq(Area.light_colour(area), Color(light[area - 1]), "Area %d light colour" % area)
	return true


func test_decoration_of_each_area(t) -> bool:
	t.assert_eq(Area.decoration(1), Area.Decoration.WAVES, "Area 1 Lagoon")
	t.assert_eq(Area.decoration(2), Area.Decoration.BUBBLES, "Area 2 Coral reef")
	t.assert_eq(Area.decoration(3), Area.Decoration.DROPLETS, "Area 3 Open sea")
	t.assert_eq(Area.decoration(4), Area.Decoration.STARS, "Area 4 Sea at night")
	return true
