class_name CombatantView
extends Node2D

@onready var sprite: Sprite2D = $Sprite2D

func apply_configuration(config: CombatantVisuals) -> void:
	if not config:
		push_error("EntityVisuals: Missing VisualsResource on %s" % owner.name)
		return
		
	sprite.texture = config.texture
	sprite.hframes = config.h_frames
	sprite.vframes = config.v_frames
	sprite.frame = config.default_frame
	sprite.offset = config.offset
	sprite.modulate = config.modulate
