extends RigidBody2D

var dragging: bool = false
var drag_start: Vector2
var drag_vector: Vector2
var force_vector: Vector2
var reset:bool = false
@export var max_force: float = 100.0
@export var magnetism_marker: AnimatedSprite2D


func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("Box clicked")
		magnetism_marker.visible = true
		dragging = true
		drag_start = get_global_mouse_position()


func _process(delta: float) -> void:
	
	if dragging:
		var current_mouse_pos = get_global_mouse_position()
		var mouse_vector = current_mouse_pos - drag_start
		magnetism_marker.position = drag_start
		magnetism_marker.look_at(current_mouse_pos)
		var sprite_scale = magnetism_marker.sprite_frames.get_frame_texture("default", 1).get_size().x /51200
		magnetism_marker.scale = Vector2(clamp(sprite_scale * mouse_vector.length(), 0, max_force/100), 1)
	if Input.is_action_just_released("click") and dragging:
		dragging = false
		var drag_end = get_global_mouse_position()
		drag_vector = drag_end - drag_start
		force_vector = drag_vector.normalized() * min(drag_vector.length(), max_force)
	if drag_vector.length() > 0 and Input.is_action_just_released("space"):
		release_force(force_vector)
		magnetism_marker.visible = false
	if Input.is_action_just_pressed("reset"):
		magnetism_marker.visible = false
		reset = true
	
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if reset:
		linear_velocity = Vector2(0, 0)
		angular_velocity = 0
		set_global_position(Vector2(0,0))
		dragging = false
		drag_vector = Vector2(0, 0)
		force_vector = Vector2(0, 0)
		reset = false


func release_force(force_vector: Vector2) -> void:
	apply_impulse(force_vector*10)
	print("Applied force: ", force_vector*10, " (Magnitude: ", force_vector.length()*10, ")")
