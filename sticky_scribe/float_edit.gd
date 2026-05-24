@tool
extends LineEdit

signal value_changed(value);

@export var value := NAN:
	set(new_value):
		value = new_value;
		text = "" if is_nan(value) else str(value);
		caret_column = text.length();


func _ready():
	self.text_submitted.connect(_on_text_entered);
	self.focus_exited.connect(_on_text_entered.bind(""));


func ui_increment_value(increment : float):
	ui_set_value(increment if is_nan(value) else value + increment);


func ui_set_value(new_value : float):
	if new_value != value:
		value = new_value;
		value_changed.emit(new_value);


func _on_text_entered(new_text : String):
	if text.is_empty():
		ui_set_value(NAN);
	elif text.is_valid_float():
		ui_set_value(text.to_float());
	else:
		value = value;
