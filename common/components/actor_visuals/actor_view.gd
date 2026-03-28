class_name ActorView
extends Node2D

@onready var sprite: Sprite2D = $Sprite2D

func apply_configuration(config: ActorVisuals) -> void:
	if not config:
		push_error("EntityVisuals: Missing VisualsResource on %s" % owner.name)
		return
		
	sprite.texture = config.texture
	sprite.hframes = config.h_frames
	sprite.vframes = config.v_frames
	sprite.frame = config.default_frame
	sprite.offset = config.offset
	sprite.modulate = config.modulate

func flash_hurt(duration: float = 0.1) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(sprite, "modulate", Color.RED, duration)
	tween.chain().tween_property(sprite, "modulate", Color.WHITE, duration)
