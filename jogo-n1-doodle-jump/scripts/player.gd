extends CharacterBody2D

const GRAVITY := 10
var jump_force := -550
var speed := 300

@onready var bounc_fx = $bounce_fx as AudioStreamPlayer

func move(delta):
	var input_direction = Input.get_axis("esquerda", "direita")
	
	if input_direction != 0:
		velocity.x = lerp(velocity.x, input_direction * speed, 0.5)
		$anim.scale.x = -input_direction
	else:
		velocity.x = lerp(velocity.x, 0.0, 0.5)
		
	velocity.y += GRAVITY
	var collision = move_and_collide(velocity * delta)
	
	if velocity.y > 0:
		$anim.play("fall")
	else:
		$anim.play("idle")
		
	if collision:
		velocity.y = jump_force * collision.get_collider().jump_force
		if collision.get_collider().has_method("response"):
			collision.get_collider().response()
		bounc_fx.play()
	

func _physics_process(delta: float) -> void:
	var screen_size = get_viewport_rect().size
	move(delta)
	position.x = wrapf(position.x, 0, screen_size.x)
	
func die():
	velocity = Vector2.ZERO
	set_collision_mask_value(2, false)
	set_collision_mask_value(3, false)
	
	
