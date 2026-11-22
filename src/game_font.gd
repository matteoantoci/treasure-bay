## The one rounded font of the game (game-flow spec part 3): Fredoka, SIL Open Font License. The
## title of the opening screen, the total count and the star number of the Party use it. The file
## is a variable font. bold() sets its weight axis.
class_name GameFont
extends RefCounted

const FILE := preload("res://assets/fonts/fredoka/Fredoka-Variable.ttf")
## The weight of the title and the numbers: Fredoka SemiBold.
const BOLD_WEIGHT := 600

static var _bold: FontVariation


## Fredoka at the bold weight. All callers share one FontVariation.
static func bold() -> Font:
	if _bold == null:
		_bold = FontVariation.new()
		_bold.base_font = FILE
		var weight_tag := TextServerManager.get_primary_interface().name_to_tag("wght")
		_bold.variation_opentype = {weight_tag: BOLD_WEIGHT}
	return _bold
