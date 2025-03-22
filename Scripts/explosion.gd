extends Area2D


func expand(size):
	var tween = create_tween()
	tween.set_ease(1)
	tween.set_trans(5)
	tween.tween_property(self, "scale", Vector2(size, size), 0.5)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("blocks"):
		body.hit("ball")
