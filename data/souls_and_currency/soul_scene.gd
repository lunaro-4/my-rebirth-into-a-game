class_name SoulScene extends Node2D


@onready var soul:Soul

@onready var soul_sprite = $SoulSprite as AnimatedSprite2D

func _ready():
	soul_sprite.sprite_frames = soul.sprite
