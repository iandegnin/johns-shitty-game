@tool
extends VBoxContainer

const VERSION = 1;
# original pastel color palette
const TAG_WHITE = Color("ffffff");
const TAG_RED = Color("ff6663");
const TAG_ORANGE = Color("feb144");
const TAG_YELLOW = Color("fdfd97");
const TAG_GREEN = Color("9ee09e");
const TAG_BLUE = Color("9ec1cf");
const TAG_PURPLE = Color("cc99c9");
const TAG_MAGENTA = Color("f49ac1");
const TAG_COLORS = [TAG_WHITE, TAG_RED, TAG_ORANGE, TAG_YELLOW, TAG_GREEN, TAG_BLUE, TAG_PURPLE, TAG_MAGENTA];
# Paul Tol's color blind rainbow palette https://personal.sron.nl/~pault/
# commented out because I'm undecided if it's worth the transition
#  const TAG_COLORS = [Color("ffffff"), Color("dc050c"), Color("f1932d"), Color("f7f056"), Color("90c987"), Color("7bafde"), Color("1965b0"), Color("ae76a3")];
enum SortOptions {OldestPriorityFirst, HighPriorityFirst, LowPriorityFirst, OldestFirst, NewestFirst, ShortestFirst, LongestFirst, Author};
enum PriorityFilterMode {Any, GreaterEqual, LessEqual, NaN};

@export var ColorButton : PackedScene;
@export var IssueItem : PackedScene;
@export var user_config := "user://settings.cfg"; # (String, FILE)
@export var issues_json := "res://project.issues"; # (String, FILE)
@export var git_index_lock_file := "res://.git/index.lock"; # (String, FILE)
@export var save_timer_duration := 3.0;

@export var _author_edit_path : NodePath;
@onready var _author_edit := get_node_or_null(_author_edit_path) as LineEdit;
@export var _sort_path : NodePath;
@onready var _sort := (get_node_or_null(_sort_path) as MenuButton).get_popup();
@export var _issue_vbox_path : NodePath;
@onready var _issue_vbox := get_node_or_null(_issue_vbox_path) as VBoxContainer;
@export var _save_timer_path : NodePath;
@onready var _save_timer := get_node_or_null(_save_timer_path) as Timer;
@export var _count_label_path : NodePath;
@onready var _count_label := get_node_or_null(_count_label_path) as Label;
@export var _scroll_container_path : NodePath;
@onready var _scroll_container := get_node_or_null(_scroll_container_path) as ScrollContainer;
@export var _new_button_path : NodePath;
@onready var _new_button := get_node_or_null(_new_button_path) as Button;
@export var _tag_palette_popup_path : NodePath;
@onready var _tag_palette_popup := get_node_or_null(_tag_palette_popup_path) as PopupPanel;
@export var _tag_palette_grid_path : NodePath;
@onready var _tag_palette_grid := get_node_or_null(_tag_palette_grid_path) as GridContainer;

@export var _quick_filter_path : NodePath;
@onready var _quick_filter := get_node_or_null(_quick_filter_path) as HBoxContainer;
@export var _tag_edit_path : NodePath;
@onready var _tag_edit := get_node_or_null(_tag_edit_path) as LineEdit;
@export var _priority_filter_path : NodePath;
@onready var _priority_filter := get_node_or_null(_priority_filter_path) as OptionButton;
@export var _priority_edit_path : NodePath;
@onready var _priority_edit := get_node_or_null(_priority_edit_path) as SpinBox;
@export var _search_edit_path : NodePath;
@onready var _search_edit := get_node_or_null(_search_edit_path) as LineEdit;

@export var _gd_filter_path : NodePath;
@onready var _gd_filter := get_node_or_null(_gd_filter_path) as HBoxContainer;
@export var _expression_edit_path : NodePath;
@onready var _expression_edit := get_node_or_null(_expression_edit_path) as LineEdit;

var _editor_settings = null;
var _standalone_config : ConfigFile = null;
var _root_dictionary := default_dict();
var _initialized = false;
var _modified_time := 0;
var _write_lock : bool = false;
var _priority_low : float = INF;
var _priority_high : float = -INF;
var _current_selected_tag : String = "";

func default_dict() -> Dictionary:
	return {
		"version" : VERSION,
		"meta" : {
			"tag_colors" : {}
		},
		"issues" : {}
	};

func new_item_dict() -> Dictionary:
	return {
		"text" : "",
		"tags" : [],
		"timestamp" : Time.get_unix_time_from_system()
	};


func _ready():
	if !Engine.is_editor_hint():
		_initialize();


func _exit_tree():
	if _initialized:
		_save();

func _read_settings() -> void:
	if _editor_settings != null:
		_author_edit.text = _editor_settings.get_project_metadata("sticky_scribe", "author", "");
	elif _standalone_config != null:
		_author_edit.text = _standalone_config.get_value("main", "author", "");

func _write_settings() -> void:
	if _editor_settings != null:
		_editor_settings.set_project_metadata("sticky_scribe", "author", _author_edit.text);
	elif _standalone_config != null:
		_standalone_config.set_value("main", "author", _author_edit.text);
		_standalone_config.save(user_config);

func _initialize() -> void:
	_sort.clear();
	for value in SortOptions.values():
		_sort.add_item(SortOptions.keys()[value].capitalize(), value);
	_sort.connect("id_pressed", Callable(self, "_on_sort_method_pressed"));
	_read_settings();
	_on_author_changed(_author_edit.text);
	_refresh();
	_initialized = true;


func _on_author_changed(name : String) -> void:
	_write_settings();
	if _author_edit.text.is_empty():
		_new_button.disabled = true;
		_new_button.tooltip_text = "Author field required to open a new sticky";
	else:
		_new_button.disabled = false;
		_new_button.tooltip_text = "";


func _make_visible(v : bool) -> void:
	visible = v;
	if !_initialized:
		_initialize();
	if !visible:
		_save();


func _notification(what):
	if _initialized && what == MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN:
		_refresh();


func _refresh() -> void:
	if !FileAccess.file_exists(issues_json):
		_clear_state();
		return;
	var modified = FileAccess.get_modified_time(issues_json);
	if modified == _modified_time:
		return;
	if _initialized:
		if _modified_time > 0:
			print("external modification to ", issues_json, " detected; refreshing issues...");
		else:
			print("loading issues ", issues_json);
	_write_lock = true;
	_clear_state();
	for i in range(5):
		if !FileAccess.file_exists(git_index_lock_file):
			break;
		if i < 4:
			print("git index busy, trying again in a second, attemt #", i + 1);
			OS.delay_msec(500);
		else:
			printerr("git index still locked after a few attempts, tab out then back in once ongoing git operations have finished");
			return;
	var file := FileAccess.open(issues_json, FileAccess.READ);
	if file == null:
		print("failed to open issues file ", issues_json, " : ", FileAccess.get_open_error());
		return;
	_modified_time = FileAccess.get_modified_time(issues_json); # get modified time again while open just in case
	var test_json_conv = JSON.new()
	var error := test_json_conv.parse(file.get_as_text());
	file.close();
	if error != OK:
		printerr("failed to parse issues json ", issues_json, " : ", test_json_conv.get_error_message(), " @ ", test_json_conv.get_error_line());
		return;
	_root_dictionary = test_json_conv.data;
	if _root_dictionary == null || !_root_dictionary.has("version"):
		_clear_state();
		printerr("issues json is not in the correct format ", issues_json);
		return;
	if _root_dictionary.version != VERSION:
		var attempt = _root_dictionary.version;
		_clear_state();
		printerr("issues json is the wrong version ", issues_json, " with version ", attempt, " should be ", VERSION);
		return;
	for color in TAG_COLORS:
		_add_palette_color(color);
	for color_html in _root_dictionary.meta.tag_colors.values():
		_add_palette_color(Color(color_html));
	for author in _root_dictionary.issues.keys():
		var author_array : Array = _root_dictionary.issues[author];
		for i in range(author_array.size()):
			var issue_item := IssueItem.instantiate();
			_issue_vbox.add_child(issue_item);
			issue_item.initialize(_root_dictionary, author, i);
			issue_item.connect("changed", Callable(self, "_on_issue_item_changed"));
			issue_item.connect("toggle_tag_color", Callable(self, "_on_toggle_tag_color"));
			issue_item.connect("minimize_changed", Callable(self, "_on_minimize_item_changed"));
	_write_lock = false;
	_on_sort_method_pressed(SortOptions.OldestPriorityFirst);
	_refilter_issues();
	_update_count();
	_recolor_priorities();


func _clear_state() -> void:
	_modified_time = 0;
	_root_dictionary = default_dict();
	for child in _tag_palette_grid.get_children():
		_tag_palette_grid.remove_child(child);
		child.queue_free();
	for child in _issue_vbox.get_children():
		_issue_vbox.remove_child(child);
		child.queue_free();
	_update_count();
	_priority_low = INF;
	_priority_high = -INF;

func _update_count() -> void:
	var total_count := 0;
	var estimated_count := 0;
	var estimated_total := 0;
	var estimated_unknowns := 0;
	var estimated_forevers := 0;
	for child in _issue_vbox.get_children():
		if child.visible && !child.is_queued_for_deletion() && !child.item_dict.has("deleted"):
			total_count += 1;
			var estimate : int = child.item_dict.get("estimate", 0);
			if estimate >= 4096: # fun fact, GODOT OptionButton ID's are limited to the range [0, 4096] but they don't tell you that
				estimated_forevers += 1;
			elif estimate > 0:
				estimated_count += 1;
				estimated_total += estimate;
			else:
				estimated_unknowns += 1;
	# god, generating text from data is always a mess...
	if total_count == 0:
		_count_label.text = "found no matching issues";
	else:
		var est_str := "";
		if estimated_count == 0:
			est_str = "with unknown estimate"
		else:
			var guestimate : int = ceil(estimated_total / estimated_count) * estimated_unknowns;
			est_str = "with estimate " + str(estimated_total + guestimate);
			if guestimate > 0:
				est_str += "±" + str(guestimate);
			est_str += " days";
		if estimated_forevers == 1:
			est_str += " and ∞ longer";
		elif estimated_forevers > 1:
			est_str += " and " + str(estimated_forevers) + " ∞ longer";
		if total_count == 1:
			_count_label.text = "found 1 matching issue " + est_str;
		else:
			_count_label.text = "found " + str(total_count) + " matching issues " + est_str;

func _save() -> void:
	_save_timer.stop();
	if _write_lock:
		printerr("File loaded in bad state, to prevent accidental data loss changes were not saved. Manually fix ", issues_json, " and try again.");
		return;
	
	var dupe = _root_dictionary.duplicate(true);
	for author in dupe.issues.keys():
		var author_array : Array = dupe.issues[author];
		for i in range(author_array.size() - 1, -1, -1): # reverse-iterate
			var item : Dictionary = author_array[i]
			if item.has("deleted"):
				author_array.remove_at(i);
	
	var out := JSON.stringify(dupe, "\t", false);
	if FileAccess.get_modified_time(issues_json) != _modified_time:
		printerr("External modifications found since last file read, to prevent accidentally overwriting data changes were not saved. Jot down any additions you've made then refresh.");
		return;
	
	var file = FileAccess.open(issues_json, FileAccess.WRITE);
	if file == null:
		printerr("failed to open issues file for write ", issues_json, " : ", FileAccess.get_open_error());
		return;
	file.store_string(out);
	file.close();
	_modified_time = file.get_modified_time(issues_json);


func _on_new_pressed():
	var author = _author_edit.text;
	if author.is_empty():
		printerr("can't create issue with empty author");
		return;
	if !_root_dictionary.issues.has(author):
		_root_dictionary.issues[author] = [];
	var author_array : Array = _root_dictionary.issues[author]
	var index = author_array.size();
	author_array.push_back(new_item_dict());
	var issue_item := IssueItem.instantiate();
	_issue_vbox.add_child(issue_item);
	_issue_vbox.move_child(issue_item, 0);
	issue_item.initialize(_root_dictionary, author, index);
	issue_item.connect("changed", Callable(self, "_on_issue_item_changed"));
	issue_item.connect("toggle_tag_color", Callable(self, "_on_toggle_tag_color"));
	issue_item.connect("minimize_changed", Callable(self, "_on_minimize_item_changed"));
	issue_item.update_priority_range(_priority_low, _priority_high);
	_scroll_container.scroll_vertical = 0;
	_update_count();
	_save();
	

class IssueSorter:
	var option = SortOptions.OldestPriorityFirst;
	func sort(lhs : Node, rhs : Node) -> bool:
		var lhs_dict : Dictionary = lhs.item_dict;
		var rhs_dict : Dictionary = rhs.item_dict;
		var reverse := false;
		match option:
			SortOptions.LowPriorityFirst:
				reverse = true;
		match option: # continue feature is be removed in godot 4 so this is how we cope
			SortOptions.LowPriorityFirst, SortOptions.HighPriorityFirst, SortOptions.OldestPriorityFirst:
				if lhs_dict.has("priority") != rhs_dict.has("priority"):
					return lhs_dict.has("priority") != reverse; # assigned priority is considered higher than unassigned
				if lhs_dict.has("priority") && lhs_dict.priority != rhs_dict.priority:
					return (lhs_dict.priority > rhs_dict.priority) != reverse; # higher at top
		match option:
			SortOptions.OldestPriorityFirst, SortOptions.OldestFirst, SortOptions.LongestFirst:
				reverse = true;
		match option:
			SortOptions.OldestPriorityFirst, SortOptions.OldestFirst, SortOptions.NewestFirst:
				if lhs_dict.timestamp != rhs_dict.timestamp:
					return (lhs_dict.timestamp > rhs_dict.timestamp) != reverse; # higher at top
			SortOptions.ShortestFirst, SortOptions.LongestFirst:
				if lhs_dict.get("estimate", 0) != rhs_dict.get("estimate", 0):
					return (lhs_dict.get("estimate", 0) < rhs_dict.get("estimate", 0)) != reverse; # lower at the top
			SortOptions.Author:
				if lhs.author_name != rhs.author_name:
					return (lhs.author_name < rhs.author_name) != reverse; # alphabetical
		return lhs.get_index() < rhs.get_index(); # otherwise maintain current index order
			

func _on_minimize_item_changed(item : Control):
	# item size is being adjusted next frame, and then
	# the scroll container size is being adjusted the frame after, so need 2 frames of delay
	await get_tree().process_frame;
	await get_tree().process_frame;
	if is_instance_valid(item):
		_scroll_container.ensure_control_visible(item);

func _on_sort_method_pressed(index):
	var children := _issue_vbox.get_children();
	var sorter := IssueSorter.new();
	sorter.option = index;
	children.sort_custom(Callable(sorter, "sort"));
	for i in range(children.size()):
		_issue_vbox.move_child(children[i], i);

func _on_search_text_changed(new_text : String):
	_rebuild_filter_expression();

func _on_tag_text_changed(new_text : String):
	_rebuild_filter_expression();

func _recolor_priorities() -> void:
	var low = INF;
	var high = -INF;
	for child in _issue_vbox.get_children():
		if child.item_dict.has("priority"):
			low = min(low, child.item_dict.priority);
			high = max(high, child.item_dict.priority);
	if low != _priority_low || high != _priority_high:
		_priority_low = low;
		_priority_high = high;
		for child in _issue_vbox.get_children():
			child.update_priority_range(_priority_low, _priority_high);


func _add_palette_color(color : Color):
	if _tag_palette_grid.has_node(color.to_html(false)):
		return;
	var button : Button = ColorButton.instantiate();
	_tag_palette_grid.add_child(button);
	button.name = color.to_html(false);
	button.modulate = color;
	var height := button.get_theme_font("font").get_height() + button.get_theme_stylebox("normal").get_minimum_size().y;
	button.custom_minimum_size = Vector2(height, height);
	button.connect("pressed", Callable(self, "_on_set_tag_color").bind(color));


func _on_toggle_tag_color(tag : String):
	_current_selected_tag = tag;
	_tag_palette_popup.popup();
	_tag_palette_popup.reset_size();
	_tag_palette_popup.position = DisplayServer.mouse_get_position();
	_tag_palette_grid.get_node(_root_dictionary.meta.tag_colors.get(tag, "ffffff")).grab_focus();


func _on_set_tag_color(color : Color):
	_tag_palette_popup.hide();
	var tag := _current_selected_tag;
	var current := Color(_root_dictionary.meta.tag_colors.get(tag, "ffffff"));
	if current == color:
		return;
	if color == Color.WHITE:
		_root_dictionary.meta.tag_colors.erase(tag);
	else:
		_root_dictionary.meta.tag_colors[tag] = color.to_html(false);
	for issue_item in _issue_vbox.get_children():
		issue_item.refresh_tags();


func _on_issue_item_changed():
	_save_timer.start(save_timer_duration);
	_update_count();
	_recolor_priorities();


func _on_save_timer_timeout():
	_save();


func _on_priority_filter_selected(index : int):
	_priority_edit.visible = (index == PriorityFilterMode.GreaterEqual || index == PriorityFilterMode.LessEqual);
	_rebuild_filter_expression();


func _on_priority_filter_value_changed(value : float):
	_rebuild_filter_expression();


func _on_gd_toggled(pressed : bool):
	_gd_filter.visible = pressed;
	_quick_filter.visible = !pressed;


class ExpressionFilterHelpers:
	# necessary to track this so we can stop trying to evaluate if it fails
	var expression_errored := false;
	
	# true if any element in check contains any element in test as a substring
	func any_contains_any(check : Array, test : Array) -> bool:
		for item in check:
			if !(item is String):
				printerr("check doesn't contain only strings");
				expression_errored = true;
				return true;
		for item in test:
			if !(item is String):
				printerr("test doesn't contain only strings");
				expression_errored = true;
				return true;
		for check_item in check:
			for test_item in test:
				if test_item in check_item:
					return true;
		return false;
		
	# true if an occurrence of the regex pattern is found in check
	func contains_regex(check : String, pattern : String) -> bool:
		var regex := RegEx.new();
		var err := regex.compile(pattern);
		if err != OK: # compile forcibly prints an error message, so there's that -_- guess I don't need to report it
			expression_errored = true;
			return true;
		return regex.search(check) != null;
		
	
	# true if an occurrence of the regex pattern is found in any element in check
	func any_contains_regex(check : Array, pattern : String) -> bool:
		for item in check:
			if contains_regex(item, pattern): # since errors return true this handily will short-circuit on error and not print a million times
				return true;
		return false;


func _rebuild_filter_expression() -> void:
	var sub_expressions := PackedStringArray();
	var tags := PackedStringArray();
	for tag in _tag_edit.text.split(',', false):
		var test = tag.strip_edges();
		if !test.is_empty():
			tags.append("\"" + test.c_escape() + "\"");
	var tag_string := ", ".join(tags);
	if !tag_string.is_empty():
		sub_expressions.append("any_contains_any(tags, [" + tag_string + "])");
	match _priority_filter.selected:
#		PriorityFilterMode.Any:
#			pass;
		PriorityFilterMode.NaN:
			sub_expressions.append("is_nan(priority)");
		PriorityFilterMode.GreaterEqual:
			sub_expressions.append("priority >= " + str(_priority_edit.value));
		PriorityFilterMode.LessEqual:
			sub_expressions.append("priority <= " + str(_priority_edit.value));
	if !_search_edit.text.is_empty():
		sub_expressions.append("\"" + _search_edit.text.c_escape() + "\"" + " in text");
	_expression_edit.text = " and ".join(sub_expressions);
	_refilter_issues(); # reads _expression_edit.text anyways


# expression inputs:
#  priority - the priority of a given sticky
#  estimate - the estimate days of a sticky (0 for I don't know, 4096 for forever)
#  tags - the Array of tags for a given sticky
#  text - the sticky's main text
#  timestamp - the unix time the sticky was open (int seconds since epoch)
#  author - the author
func _refilter_issues() -> void: # TBD: I can probably make this cleaner, am sleepy (-_-).zZ
	var helper := ExpressionFilterHelpers.new();
	var expr := Expression.new();
	for child in _issue_vbox.get_children():
		child.visible = true;
	if _expression_edit.text.is_empty():
		_expression_edit.modulate = Color.WHITE;
		_update_count();
		return;
	var err := expr.parse(_expression_edit.text, ["priority", "estimate", "tags", "text", "timestamp", "author"]);
	if err != OK:
		printerr("couldn't parse filter expression, error: ", err);
		_expression_edit.modulate = TAG_RED;
		_update_count();
		return;
	for child in _issue_vbox.get_children():
		var item_dict : Dictionary = child.item_dict;
		var priority : float = item_dict.get("priority", NAN);
		var estimate : int = item_dict.get("estimate", 0);
		var tags : Array = item_dict.get("tags", []);
		var text : String = item_dict.get("text", "");
		var timestamp : int = item_dict.get("timestamp", 0);
		var result = expr.execute([priority, estimate, tags, text, timestamp, child.author_name], helper, true);
		if !expr.has_execute_failed() && !(result is bool):
			expr.expression_errored = true;
			printerr("expression returned non-boolean value");
		if helper.expression_errored || expr.has_execute_failed():
			print("expression execution failed, no filter applied");
			for child2 in _issue_vbox.get_children():
				child2.visible = true;
			_expression_edit.modulate = TAG_RED;
			return;
		# all clear, no errors - result is a boolean
		child.visible = result;
	_expression_edit.modulate = TAG_GREEN;
	_update_count();


func _on_expression_text_entered(new_text : String) -> void:
	# set the quick filters to their default values
	_tag_edit.text = "";
	_priority_filter.select(PriorityFilterMode.Any);
	_priority_edit.visible = false;
	_search_edit.text = "";
	_refilter_issues();


func _on_expression_text_changed(new_text):
	_expression_edit.modulate = Color.WHITE;
