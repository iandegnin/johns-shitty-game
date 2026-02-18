class_name EntityVisuals
extends Node2D

@onready var sprite: Sprite2D = $Sprite2D

## Applies the visual settings from the resource to the sprite
func apply_configuration(config: VisualsConfig) -> void:
	if not config:
		push_error("EntityVisuals: Missing VisualsResource on %s" % owner.name)
		return
		
	sprite.texture = config.texture
	sprite.hframes = config.h_frames
	sprite.vframes = config.v_frames
	sprite.frame = config.default_frame
	sprite.offset = config.offset
	sprite.modulate = config.modulate

## Direct access for temporary visual effects (like damage flashes)
func flash_hurt(duration: float = 0.1) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(sprite, "modulate", Color.RED, duration)
	tween.chain().tween_property(sprite, "modulate", Color.WHITE, duration)
