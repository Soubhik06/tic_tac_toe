extends Control

var board := [0, 0, 0, 0, 0, 0, 0, 0, 0] # 0: empty, 1: X, -1: O
var current_player := 1
var is_active := true

# UI References created in code for simplicity
var status_label: Label
var buttons: Array[Button] = []

func _ready() -> void:
	_setup_ui()
	reset_game()

func _setup_ui() -> void:
	# background styling
	var bg := ColorRect.new()
	bg.color = Color(0.12, 0.12, 0.14) # Clean dark background
	bg.set_anchors_preset(PRESET_FULL_RECT)
	add_child(bg)
	
	# center container for alignment
	var center := CenterContainer.new()
	center.set_anchors_preset(PRESET_FULL_RECT)
	add_child(center)
	
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 24)
	center.add_child(vbox)
	
	# status text
	status_label = Label.new()
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.add_theme_font_size_override("font_size", 36)
	vbox.add_child(status_label)
	
	# 3x3 grid
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	vbox.add_child(grid)
	
	# generate buttons dynamically
	for i in range(9):
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(120, 120)
		btn.add_theme_font_size_override("font_size", 64)
		btn.focus_mode = Control.FOCUS_NONE
		btn.pressed.connect(_on_cell_pressed.bind(i))
		grid.add_child(btn)
		buttons.append(btn)
	
	# reset button
	var reset_btn := Button.new()
	reset_btn.text = "Play Again"
	reset_btn.custom_minimum_size = Vector2(0, 60)
	reset_btn.add_theme_font_size_override("font_size", 28)
	reset_btn.focus_mode = Control.FOCUS_NONE
	reset_btn.pressed.connect(reset_game)
	vbox.add_child(reset_btn)

func _on_cell_pressed(idx: int) -> void:
	# ignore if game is over or cell is taken
	if not is_active or board[idx] != 0:
		return
		
	board[idx] = current_player
	_update_button(idx)
	
	if _check_win():
		status_label.text = "%s Wins!" % _get_player_char(current_player)
		is_active = false
	elif not 0 in board:
		status_label.text = "It's a Draw!"
		is_active = false
	else:
		current_player *= -1
		_update_status()

func _update_button(idx: int) -> void:
	var btn := buttons[idx]
	var val: int = board[idx]
	
	if val == 1:
		btn.text = "X"
		btn.add_theme_color_override("font_color", Color(0.9, 0.3, 0.4)) # Red-ish accent
	elif val == -1:
		btn.text = "O"
		btn.add_theme_color_override("font_color", Color(0.3, 0.7, 0.9)) # Blue-ish accent
	else:
		btn.text = ""

func _check_win() -> bool:
	# all possible winning lines
	var lines := [
		[0, 1, 2], [3, 4, 5], [6, 7, 8], # rows
		[0, 3, 6], [1, 4, 7], [2, 5, 8], # cols
		[0, 4, 8], [2, 4, 6]             # diagonals
	]
	
	for line in lines:
		if board[line[0]] != 0 and board[line[0]] == board[line[1]] and board[line[1]] == board[line[2]]:
			# optional: highlight winning line here if desired
			return true
	return false

func _get_player_char(player: int) -> String:
	return "X" if player == 1 else "O"

func _update_status() -> void:
	status_label.text = "Player %s's Turn" % _get_player_char(current_player)
	
func reset_game() -> void:
	board = [0, 0, 0, 0, 0, 0, 0, 0, 0]
	current_player = 1
	is_active = true
	
	for i in range(9):
		_update_button(i)
		
	_update_status()
