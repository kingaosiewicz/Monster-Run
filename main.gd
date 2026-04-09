extends Node2D

func _ready():
	Utils.saveGame() # jeśli zakomentujemy tą linijkę to zapiszą nam się nasze postępy gry w pliku savegame.bin
	Utils.loadGame()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://world.tscn")
