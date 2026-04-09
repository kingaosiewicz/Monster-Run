extends Node2D

func _ready():
	Utils.saveGame() # jeśli zakomentujemy tą linijkę to zapiszą nam się nasze postępy gry w pliku savegame.bin
	Utils.loadGame()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://world.tscn")


# TODO: Zrobić gałęzie na Githubie
# TODO: Dodać do mapy przeszkody
# TODO: Jeśli wejdziemy w potwora i odejmie nam HP to niech ten powtór nie ginie tylko dalej jest, a my zostaniemy odrzuceni troche do tyłu jak w Mario
# TODO: Zrobić kolejne mapy jak ktoś przejdzie poziom i żeby zapisywało, które poziomy już przeszedłeś. Można potem dodać konta graczy? W kodzie jest stworzona
# możliwość zapisywania HP i Golda, ale jeśli chcemy zrobić w formie poziomów to trzeba będzie zmienić logikę.
# TODO: Fajnie jakby obiekty do zbierania tworzyły się przed naszym liskiem, żeby ogólnie sens gry był taki, że idziemy do przodu, a nie do tyłu po itemy
# TODO: Możemy dodać też czas do wykonania poziomu? Chyba tak było w Mario.
# TODO: Dodać nowe moby. 
# TODO: Na trudnejszych poziomach więcej mobów, a mniej nagród i trudniejsze przeszkody.
# TODO: Wykorzystać animację śmierci i bólu, które już są stworzone w kodzie trzeba tylko je dodać.
# TODO: Dodać nowe animacje przeciskania się przez szczeliny i logikę.
# TODO: Po przejściu poziomu - animacja WIN
