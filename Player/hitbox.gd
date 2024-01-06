extends Area3D

@export var damage_multiplier: int = 1

signal body_part_hit(dam)

func hit(damage: int):
	damage = damage * damage_multiplier
	
	emit_signal("body_part_hit", damage)
	
