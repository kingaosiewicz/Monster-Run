extends Node

var playerHP = 10
var Gold = 0

var timer_active: bool = true
var time: float = 0.0
var is_invincible = false

# --- REKORDY DLA POZIOMÓW ---
var best_time_level1: float = 99999.0
var best_gold_level1: int = 0

var req_time_level1 = 45.0
var req_gold_level1 = 10

var best_time_level2: float = 99999.0
var best_gold_level2: int = 0

var req_time_level2 = 50.0
var req_gold_level2 = 15

var best_time_level3: float = 99999.0
var best_gold_level3: int = 0

var req_time_level3 = 50.0
var req_gold_level3 = 20

var best_time_level4: float = 99999.0
var best_gold_level4: int = 0

var req_time_level4 = 55.0
var req_gold_level4 = 25

var best_time_level5: float = 99999.0
var best_gold_level5: int = 0

var req_time_level5 = 55.0
var req_gold_level5 = 25

var best_time_level6: float = 99999.0
var best_gold_level6: int = 0

var req_time_level6 = 55.0
var req_gold_level6 = 25
