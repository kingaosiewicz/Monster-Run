extends Area2D


@export var level_number: int = 1 

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		# 1. Zatrzymujemy stoper i wyłączamy metę
		Game.timer_active = false
		set_deferred("monitoring", false)
		
		# 2. Tworzymy nazwy zmiennych w zależności od poziomu
		var time_var_name = "best_time_level" + str(level_number)
		var gold_var_name = "best_gold_level" + str(level_number)
		
		var current_best_time = Game.get(time_var_name)
		var current_best_gold = Game.get(gold_var_name)
		
		# 3. Sprawdzamy i nadpisujemy rekord CZASU
		if Game.time < current_best_time:
			Game.set(time_var_name, Game.time)
			current_best_time = Game.time
			
		# 4. Sprawdzamy i nadpisujemy rekord WISIENEK
		if Game.Gold > current_best_gold:
			Game.set(gold_var_name, Game.Gold)
			current_best_gold = Game.Gold
			
		# 5. Zapisujemy stan gry na dysku
		Utils.saveGame()
		
		print("Poziom: ", level_number, " ukończony!")
		print("Czas: ", Game.time, " | Rekord: ", current_best_time)
		print("Gold: ", Game.Gold, " | Rekord: ", current_best_gold)
		
		# 6. Wyświetlamy okienko (odznacz komentarze, gdy zbudujesz UI Podsumowania)
		var panel = get_node("../UI/Podsumowanie")
		panel.get_node("Wisienki").text
		panel.get_node("Czas").text = "Time: " + str(snapped(Game.time, 0.1)) + "s (Record: " + str(snapped(current_best_time, 0.1)) + "s)"
		panel.get_node("Diamenty").text = "Gold: " + str(Game.Gold) + " (Record: " + str(current_best_gold) + ")"
		panel.visible = true
