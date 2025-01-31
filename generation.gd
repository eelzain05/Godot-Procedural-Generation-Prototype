extends Node2D
# LEVEL GENERATOR

# TO DO:
	# 1. Create a search tool to search for certain types of generation
	# 2. Create an ID system for thr rooms so more nicely store the room values
# Add more to do as time continues

# Variables for generating level size
@export var boardSize = Vector2(17,15) ##The size of the board; there is a border 1 unit thick so add 2 to the input to get the true size
@export var baseRoomSize = Vector2(1200, 744) ##Enter the size of each room so that rooms can be evenly spaced apart without looking poor
# Variables for the walker
@export var walkerSteps: int = 15 ##How many steps each walker will take
@export var walkerRepeats: int = 3 ##How many walkers will you have
# Variables to control how the generation appears
@export_range(0, 100) var branchChance: int = 80 ##The % chance the walker has to choose a new, sexy direction when it may walk next to a room
@export var minPoints: Array[int] = [3, 0, 0, 0] ##The minimum amount of rooms that have X amount of connections; going from 1 connect to 4 connections

@onready var room = preload("res://proceduralGeneration/Temp Level/level.tscn") # Loads temp scene
@onready var rng = RandomNumberGenerator.new() # Loads num generator

func _ready():
	# Sets up the board and position markers
	var board	# Sores the locations and values for each and every room
				#    going [y location], [x location], if a room is [up, left, right, down, total surrounding rooms]
	var start = [int(boardSize.y/2), int(boardSize.x/2)]
	var walkPosition = start
	var retry = 0
	# Walker GO GO GO!!
	while true:
		# Board set up continuation
		board = make_board(boardSize)
		board[start[0]][start[1]] = "X"
		# Has the walker step for as many times and makes as many walkers as you want
		for i in range(walkerRepeats):
			for j in range(walkerSteps):
				var walk = walker(walkPosition, board)
				board = walk[0]
				walkPosition = walk[1]
			walkPosition = start
		# Checks to see that generation meets minimum amount of endpoints then exits loop
		board = border_counter(board)
		var onePoint = room_counter(board, 1)
		var twoPoint = room_counter(board, 2)
		var triPoint = room_counter(board, 3)
		var quadPoint = room_counter(board, 4)
		if onePoint >= minPoints[0] and twoPoint >= minPoints[1] and triPoint >= minPoints[2] and quadPoint >= minPoints[3]:
			break
		retry += 1
	# Puts down the final board display
	display(board)
	print(retry)

# Fuction creating a board of any size
func make_board(size: Vector2):
	var board = []
	# Creates a board with all slots being unique
	for i in range(size.y):
		var row = []
		for j in range(size.x):
			row.append(" ")
		board.append(row)
	return board

# Function that will have little use later, was just used for trouble shooting
func display(board: Array):
	# Displays board in actual game by loading scenes
	for i in range(board.size()):
		for j in range(board[0].size()):
			if str(board[i][j]) != " ":
				# Generates room in correct position
				var newInstance = room.instantiate()
				add_child(newInstance)
				newInstance.position = Vector2(j*baseRoomSize.x, i*baseRoomSize.y)
	# Displays the board for easier viewing in terminal
	for i in range(board.size()):
		for j in range(board[0].size()):
			if str(board[i][j]) == " ":
				board[i][j] = "             "
		print(board[i])

# Counts the amount of times "search" appears in the board
func room_counter(board: Array, search: int):
	var count = 0
	# Swipes through the entire board
	for i in range(board.size()):
		for j in range (board[0].size()):
			if search == int(board[i][j][-1]):
				count += 1
	return count

# Assigns a room a value depending on how many surrounding rooms it has and where the rooms are
func border_counter(board):
	# Begins by looking for room placements
	var around = 0
	var location = []
	for i in range(1, board.size()-1, 1):
		for j in range(1, board[0].size()-1, 1):
			if board[i][j] != " ":
				# Checks to see how many rooms are around selected room
				for k in range(-1, 2, 1):
					for l in range(-1, 2, 1):
						if abs(k) != abs(l) and str(board[i+k][j+l][-1]) != " ":
							around += 1
							location.append(1)
						elif abs(k) != abs(l):
							location.append(0)
				location.append(around)
				board[i][j] = location
				around = 0
				location = []
	return board

# Places a room marker in a random direction that has a preference for branching
func walker(start: Array, board: Array):
	var move
	while true:
		# Picks a random direction for walker to move that's within the board size
		move = ([[0,1], [0,-1], [1,0], [-1,0]]).pick_random()
		var mayMove = [(start[0]+move[0]), (start[1]+move[1])]
		if (mayMove[0] >= 1 and mayMove[0] < board.size()-1) and (mayMove[1] >= 1 and mayMove[1] < board[0].size()-1):
				# Checks how many surrounding rooms there are to potential move
				var around = 0
				for i in range(1, 2, -1):
					for j in range(1, 2, -1):
						if abs(i) != abs(j) and board[mayMove[0]+j][mayMove[1]+i] == " ":
							around += 1
				# Has a [branchChance]% to change rooms if mayMove is around less than 3 rooms
				if around == 3 or branchChance < rng.randf_range(0, 100):
					# Confirms walkers movement and places a marker where the walker goes
					board[mayMove[0]][(mayMove[1])] = "O"
					break
	# Updates position of walker
	var walkerPosition = []
	walkerPosition.append_array([(start[0]+move[0]), (start[1]+move[1])])
	
	return [board, walkerPosition]
