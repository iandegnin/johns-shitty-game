@tool
extends Label

signal pressed(text);

func _on_pressed() -> void:
	emit_signal("pressed", text);
