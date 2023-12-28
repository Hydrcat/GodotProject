@tool
extends GameNode

@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D


func _ready() -> void:
	super._ready()
	cpu_particles_2d.emitting = false


func activate() -> void:
	cpu_particles_2d.emitting = true
