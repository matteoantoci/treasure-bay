## Records the warnings that the game logs (push_warning) while it is added to the OS log. The
## runner does not run this file. Use start(), then stop() before the test ends.
extends Logger

var _warnings := PackedStringArray()
var _mutex := Mutex.new()


func start() -> void:
	OS.add_logger(self)


func stop() -> void:
	OS.remove_logger(self)


## The warnings logged since start().
func warnings() -> PackedStringArray:
	_mutex.lock()
	var copy := _warnings.duplicate()
	_mutex.unlock()
	return copy


func _log_error(_function: String, _file: String, _line: int, code: String, rationale: String, _editor_notify: bool, error_type: int, _script_backtrace: Array[ScriptBacktrace]) -> void:
	if error_type != ERROR_TYPE_WARNING:
		return
	_mutex.lock()
	_warnings.append(code if rationale.is_empty() else rationale)
	_mutex.unlock()
