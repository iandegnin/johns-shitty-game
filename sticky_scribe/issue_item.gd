@tool
extends PanelContainer

@export var TagButton : PackedScene;
@export var priority_temp : Gradient;

@export var _stub_view_path : NodePath;
@onready var _stub_view := get_node_or_null(_stub_view_path) as Button;
@export var _priority_label_path : NodePath;
@onready var _priority_label := get_node_or_null(_priority_label_path) as Label;
@export var _priority_clear_path : NodePath;
@onready var _priority_clear := get_node_or_null(_priority_clear_path) as Button;
@export var _tag_hbox_path : NodePath;
@onready var _tag_hbox := get_node_or_null(_tag_hbox_path) as HBoxContainer;
@export var _text_label_path : NodePath;
@onready var _text_label := get_node_or_null(_text_label_path) as Label;
@export var _copied_label_path : NodePath;
@onready var _copied_label := get_node_or_null(_copied_label_path) as Label;
@export var _estimate_label_path : NodePath;
@onready var _estimate_label := get_node_or_null(_estimate_label_path) as Label;
@export var _strike_path : NodePath;
@onready var _strike := get_node_or_null(_strike_path) as HSeparator;
@export var _delete_button_path : NodePath;
@onready var _delete_button := get_node_or_null(_delete_button_path) as Button;

@export var _edit_view_path : NodePath;
@onready var _edit_view := get_node_or_null(_edit_view_path);
@export var _priority_edit_path : NodePath;
@onready var _priority_edit := get_node_or_null(_priority_edit_path) as LineEdit;
@export var _estimate_button_path : NodePath;
@onready var _estimate_button := get_node_or_null(_estimate_button_path) as OptionButton;
@export var _tags_edit_path : NodePath;
@onready var _tags_edit := get_node_or_null(_tags_edit_path) as LineEdit;
@export var _text_edit_path : NodePath;
@onready var _text_edit := get_node_or_null(_text_edit_path) as TextEdit;
@export var _details_path : NodePath;
@onready var _details := get_node_or_null(_details_path) as Label;

signal toggle_tag_color(tag);
signal changed();
signal minimize_changed(item);

var item_dict : Dictionary;
var author_name : String;

var _tag_color_dict : Dictionary;
var _author_array : Array;
var _minimized := true;
var _low_priority := 0.0;
var _high_priority := 0.0;

func initialize(root : Dictionary, author : String, index : int) -> void:
	_tag_color_dict = root.meta.tag_colors;
	_author_array = root.issues[author];
	item_dict = _author_array[index];
	author_name = author;
	_details.text = "Opened " + Time.get_datetime_string_from_unix_time(item_dict.timestamp, true) + " utc by " + author;
	if item_dict.has("priority"):
		_priority_edit.value = item_dict.priority;
		_priority_label.visible = true;
		_priority_label.text = _str_clean(item_dict.priority);
		_priority_clear.disabled = false;
	else:
		_priority_edit.value = NAN;
		_priority_label.visible = false;
		_priority_clear.disabled = true;
	var estimate = item_dict.get("estimate", 0);
	_estimate_button.select(_get_index_of_estimate(estimate)); # does not emit item_selected signal - which is good
	_update_estimate_label(estimate);
	_text_label.text = item_dict.text;
	_stub_view.tooltip_text = item_dict.text;
	_text_edit.text = item_dict.text;
	_text_edit.clear_undo_history();
	refresh_tags();
	minimize(!item_dict.text.is_empty());


func minimize(minimize : bool) -> void:
	_minimized = minimize;
	_edit_view.visible = !_minimized;

func refresh_tags(update_edit : bool = true) -> void:
	var tags : Array = item_dict.tags;
	for child in _tag_hbox.get_children():
		_tag_hbox.remove_child(child);
		child.queue_free();
	for tag in tags:
		var color = Color(_tag_color_dict.get(tag, "ffffff"));
		var tag_button : Label = TagButton.instantiate();
		tag_button.modulate = color;
		tag_button.text = tag;
		tag_button.connect("pressed", Callable(self, "_on_tag_button_pressed"));
		_tag_hbox.add_child(tag_button);
	if update_edit:
		_tags_edit.text = ", ".join(PackedStringArray(tags));


func update_priority_range(low : float, high : float) -> void:
	_low_priority = low;
	_high_priority = high;
	if !item_dict.has("priority"):
		return;
	var temp = inverse_lerp(low, high, item_dict.priority);
	_priority_label.modulate = priority_temp.sample(temp);


func _on_stub_button_pressed() -> void:
	if (Input.get_mouse_button_mask() & MOUSE_BUTTON_MASK_RIGHT) != 0:
		DisplayServer.clipboard_set(item_dict.text.split("\n")[0]);
		if _copied_label.visible:
			return;
		_text_label.visible = false;
		_copied_label.visible = true;
		await get_tree().create_timer(1.0).timeout;
		if !is_instance_valid(self):
			return;
		_text_label.visible = true;
		_copied_label.visible = false;
	else:
		minimize(!_minimized);
		emit_signal("minimize_changed", self);


func _on_delete_pressed() -> void:
	if item_dict.has("deleted"):
		item_dict.erase("deleted");
		_delete_button.text = "Delete";
		_stub_view.disabled = false;
		_strike.visible = false;
	else:
		item_dict.deleted = true;
		_delete_button.text = "Restore";
		_stub_view.disabled = true;
		_strike.visible = true;
		minimize(true);
	emit_signal("changed");


func _on_text_changed() -> void:
	_text_label.text = _text_edit.text;
	_stub_view.tooltip_text = _text_edit.text;
	item_dict.text = _text_edit.text;
	emit_signal("changed");


func _on_tags_changed(new_text : String) -> void:
	var tags = [];
	for tag in new_text.split(',',false):
		tags.push_back(tag.strip_edges());
	item_dict.tags = tags;
	refresh_tags(false);
	emit_signal("changed");


func _on_priority_changed(value : float) -> void:
	if is_nan(value) || is_inf(value):
		item_dict.erase("priority");
		_priority_label.visible = false;
		_priority_clear.disabled = true;
	else:
		item_dict.priority = value;
		_priority_label.visible = true;
		_priority_label.text = _str_clean(value);
		_priority_clear.disabled = false;
	update_priority_range(_low_priority, _high_priority);
	emit_signal("changed");

func _on_estimate_item_selected(index : int):
	var id := _estimate_button.get_item_id(index);
	if id == 0:
		item_dict.erase("estimate");
	else:
		item_dict.estimate = id;
	_update_estimate_label(id);
	emit_signal("changed");

func _update_estimate_label(estimate : int):
	_estimate_label.visible = (estimate != 0);
	match estimate:
		1:
			_estimate_label.text = "1 day";
		4096:
			_estimate_label.text = "∞ days";
		_:
			_estimate_label.text = str(estimate) + " days";

func _on_tag_button_pressed(text : String):
	emit_signal("toggle_tag_color", text);

func _get_index_of_estimate(estimate : int):
	var index := 0;
	for i in range(_estimate_button.get_item_count()):
		index = i;
		if estimate <= _estimate_button.get_item_id(index):
			break;
	return index;

# idk why GODOT 4 changed the default behavior of str to suddenly include a decimal when given ANY float
#  but it's annoying, and there isn't an (exposed) better way to do this -_-
func _str_clean(value : float) -> String:
	return str(value) if step_decimals(value) != 0 else str(int(value));
