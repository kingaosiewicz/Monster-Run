extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(1, 7):
		var time_label = get_node("Tabela/Time" + str(i))
		var gold_label = get_node("Tabela/Gold" + str(i))
		
		var best_time = Game.get("best_time_level" + str(i))
		var best_gold = Game.get("best_gold_level" + str(i))
		
		# Pobieramy wymagania dla KOLEJNEGO poziomu (i + 1), 
		# żeby sprawdzić, czy obecny wynik pozwala go odblokować.
		var req_time = Game.get("req_time_level" + str(i))
		var req_gold = Game.get("req_gold_level" + str(i))
		
		# Ustawiamy tekst dla czasu
		if best_time == null or best_time == 0 or best_time >= 99999:
			time_label.text = "-- s"
		else:
			time_label.text = str(snapped(best_time, 0.1)) + " s"
			
		# Ustawiamy tekst dla złota
		if best_gold == null:
			gold_label.text = "0"
		else:
			gold_label.text = str(best_gold)
			
		## LOGIKA KOLOROWANIA REKORDÓW
		if req_time != null and req_gold != null:
			
			# NAJPIERW SPRAWDZAMY: Czy gracz w ogóle zagrał w ten poziom?
			if best_time != null and best_time > 0 and best_time < 99999:
				
				# Poziom został rozegrany -> sprawdzamy i kolorujemy
				# Kolorujemy CZAS
				if best_time <= req_time:
					time_label.add_theme_color_override("font_color", Color.GREEN)
				else:
					time_label.add_theme_color_override("font_color", Color.RED)
					
				# Kolorujemy ZŁOTO
				if best_gold != null and best_gold >= req_gold:
					gold_label.add_theme_color_override("font_color", Color.GREEN)
				else:
					gold_label.add_theme_color_override("font_color", Color.RED)
					
			else:
				# Poziom NIE był grany (wartości domyślne) -> zostawiamy na biało
				time_label.remove_theme_color_override("font_color")
				gold_label.remove_theme_color_override("font_color")
				
		else:
			# Jeśli to ostatni poziom (Poziom 6), zdejmujemy kolory
			time_label.remove_theme_color_override("font_color")
			gold_label.remove_theme_color_override("font_color")
			
	# --- 2. GENEROWANIE TEKSTU DO PANELU 2 (PO PRAWEJ) ---
	
	# Zaczynamy od nagłówka (pierwsza linijka)
	var tekst_wymagan = ""
	
	# Pętla od 2 do 6 (wymagania dla poziomów 2, 3, 4, 5, 6)
	for i in range(1, 6):
		# Pobieramy wymagania ze skryptu Game
		var req_time = Game.get("req_time_level" + str(i))
		var req_gold = Game.get("req_gold_level" + str(i))
		
		if req_time != null and req_gold != null:
			# Zauważ "\n\n" na samym końcu – to wymusi pusty wiersz odstępu!
			tekst_wymagan += "Time: " + str(req_time) + "s   Gold: " + str(req_gold) + "\n\n\n"
		else:
			tekst_wymagan += "-\n\n"
			
	$Panel2/Wymagania.text = tekst_wymagan
			


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_return_pressed() -> void:
	get_tree().change_scene_to_file("res://level-scenes/main.tscn")
