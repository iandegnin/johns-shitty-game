@tool
extends EditorPlugin


const MainPanel = preload("res://addons/sticky_scribe/main_panel.tscn")

var main_panel_instance


func _enter_tree():
	main_panel_instance = MainPanel.instantiate()
	main_panel_instance._editor_settings = get_editor_interface().get_editor_settings()
	# Add the main panel to the editor's main viewport.
	get_editor_interface().get_editor_main_screen().add_child(main_panel_instance)
	# Hide the main panel. Very much required.
	_make_visible(false)


func _exit_tree():
	if main_panel_instance:
		main_panel_instance.queue_free()


func _has_main_screen():
	return true


func _make_visible(visible):
	if main_panel_instance:
		main_panel_instance._make_visible(visible)


func _get_plugin_name():
	return "Stickies"


func _get_plugin_icon():
	return get_editor_interface().get_base_control().get_theme_icon("Edit", "EditorIcons")
