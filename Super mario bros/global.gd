extends Node


enum camera_type {
	single_screen,
	move_horizontal
}

enum world_style {
	normal,
	underground
}

signal play_coin_sound
signal power_up
signal extra_life
signal player_hurt
signal player_die
signal get_star
signal change_style
signal move_to_bonus(player_pos : Vector2)
signal camera_limit_change(camera_pos : Vector2, type : camera_type)

var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

var spawn_point := Vector2(40, 200)
var style := world_style.normal
var life := 3
var size := 1
var coin := 0
var player_dir := 1
var point := 0
var invincible := false
var multiple_stamp := 0
var player_position : Vector2

func restart():
	style = world_style.normal
	size = 1
	coin = 0
	point = 0
	multiple_stamp = 0
	get_tree().paused = false
	get_tree().reload_current_scene()
