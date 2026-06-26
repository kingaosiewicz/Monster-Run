extends Area2D


@export var level_number: int = 5

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
		
		# --- ZAKOMENTOWANY SYSTEM PUNKTOWY ---
		# # 3. OBLICZAMY PUNKTY (WYNIK) DLA TEGO BIEGU I DLA REKORDU
		# # Wzór: (Złoto * 100) - Czas w sekundach
		# var current_score = (Game.Gold * 100) - Game.time
		# var best_stored_score = (current_best_gold * 100) - current_best_time
		# 
		# # 4. Sprawdzamy, czy obecny łączny wynik jest lepszy od dotychczasowego
		# var czy_nowy_rekord = current_score > best_stored_score
		# 
		# # 5. Jeśli łączny wynik jest wyższy, nadpisujemy całą parę rekordów naraz
		# if czy_nowy_rekord:
		# 	Game.set(time_var_name, Game.time)
		# 	Game.set(gold_var_name, Game.Gold)
		# 	
		# 	# Aktualizujemy też zmienne podręczne do wyświetlenia w oknie podsumowania
		# 	current_best_time = Game.time
		# 	current_best_gold = Game.Gold
		
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
		panel.get_node("Czas").text = "Time: " + str(snapped(Game.time, 0.1)) + "s\n(Record: " + str(snapped(current_best_time, 0.1)) + "s)"
		panel.get_node("Diamenty").text = "Gold: " + str(Game.Gold) + "\n(Record: " + str(current_best_gold) + ")"
		var btn_next = panel.get_node_or_null("PlayNextLevel")
		
		if btn_next != null:
			var req_time = Game.get("req_time_level" + str(level_number))
			var req_gold = Game.get("req_gold_level" + str(level_number))
			
			var odblokowany = false
			
			if req_time != null and req_gold != null:
				if current_best_time != null and current_best_time > 0 and current_best_time <= req_time:
					if current_best_gold != null and current_best_gold >= req_gold:
						odblokowany = true
						
			btn_next.disabled = not odblokowany
		# ---------------------------------------
		
		panel.visible = true
