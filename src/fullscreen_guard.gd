## Spec 11.1 and Open gap 5: if the game leaves exclusive fullscreen (for example with Ctrl+Cmd+F),
## it goes back. On each size change of the window, a mode other than exclusive fullscreen is set
## back to it. A run that starts in a window (`--windowed`, the screenshot tool) stays in its window.
class_name FullscreenGuard
extends Node

const EXCLUSIVE_FULLSCREEN := DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN

## The display server. Tests set a fake with window_get_mode() and window_set_mode() before the
## node enters the tree.
var display: Object = DisplayServer
var _keep_fullscreen := false


func _ready() -> void:
	_keep_fullscreen = display.window_get_mode() == EXCLUSIVE_FULLSCREEN
	get_window().size_changed.connect(_on_size_changed)


func _on_size_changed() -> void:
	if _keep_fullscreen and display.window_get_mode() != EXCLUSIVE_FULLSCREEN:
		display.window_set_mode(EXCLUSIVE_FULLSCREEN)
