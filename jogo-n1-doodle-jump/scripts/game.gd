extends Node2D

@onready var plataform_container := $platform_container as Node2D
@onready var plataform_initial_position_y = $platform_container/platform.position.y
@onready var camera := $camera as Camera2D
@onready var player := $player as CharacterBody2D
@onready var score_label := $camera/score as Label
@onready var camera_start_position = $camera.position.y

var new_type := 0
var score := 0 
var last_type = 0

@export var platform_scene: Array[PackedScene] = []

func level_generator(amount):
		
	for items in amount:
		var new_type = 0  # Definindo 0 como padrão para garantir mais plataformas normais
		# Definindo a chance de gerar os tipos na ordem desejada
		var rand_value = randi() % 10
		
		print("last: " , last_type)
		if last_type != 3:  # Se o último não foi um inimigo
			if score > 4000:
				if rand_value < 2:  
					new_type = 0
				elif rand_value < 4: 
					new_type = 1
				elif rand_value < 7:  
					new_type = 2
				else:  
					new_type = 3
			else:
				if rand_value < 5:  
					new_type = 0
				elif rand_value < 7:  
					new_type = 1
				elif rand_value < 9 and score > 1000:  
					new_type = 2
				elif rand_value == 9 and score > 1500:  
					new_type = 3
				else:
					new_type = 0
				 
		else:  # Se o último foi um inimigo, evite gerar outro inimigo
			rand_value = randi() % 9
			if score > 4000:
				if rand_value < 2: 
					new_type = 0
				elif rand_value < 4:  
					new_type = 1
				else: 
					new_type = 2  # Evite gerar inimigos novamente
			else:
				if rand_value < 5:  
					new_type = 0
				elif rand_value < 7:  
					new_type = 1
				elif rand_value < 9 and score > 1000: 
					new_type = 2
				else:
					new_type = 0

		plataform_initial_position_y -= randf_range(54.0, 81.0)
		
		var new_platform
		
		if new_type == 0:
			new_platform = platform_scene[0].instantiate() as StaticBody2D
		elif new_type == 1:
			new_platform = platform_scene[1].instantiate() as StaticBody2D
		elif new_type == 2:
			new_platform = platform_scene[2].instantiate() as StaticBody2D
			new_platform.connect("delete_object", Callable(self, "delete_object"))
		elif new_type == 3:
			new_platform = platform_scene[3].instantiate() as StaticBody2D
			new_platform.connect("delete_object", Callable(self, "delete_object"))
		
		if new_platform != null:
			new_platform.position = Vector2(randf_range(27.0, 333.0), plataform_initial_position_y)
			plataform_container.call_deferred("add_child", new_platform)
		
		last_type = new_type  # Atualiza o tipo da última plataforma gerada
	
	
func _ready() -> void:
	randomize()
	level_generator(10)

func _physics_process(delta: float) -> void:
	if player.position.y < camera.position.y:
		camera.position.y = player.position.y
	score_update()
	
func delete_object(obstacle):
	
	if score > Global.highscore:
		Global.highscore = score
		
	if obstacle.is_in_group("player"):
		if get_tree().change_scene_to_file("res://scenes/title_screen.tscn") != OK:
			print("Algo deu errado")
	elif obstacle.is_in_group("platform") or obstacle.is_in_group("enemies"):
		obstacle.queue_free()
		level_generator(1)

func _on_platform_cleaner_body_entered(body: Node2D) -> void:
	delete_object(body)

func score_update():
	score = camera_start_position - camera.position.y
	score_label.text = str(int(score))
	
	
	
	
	
	
	
