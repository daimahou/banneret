class_name StaggerEffect
extends Effect

const STAGGER_COLOR := Color("2f5d8a")

@export var ticks: int


func add_changes(fight_model: FightModel, delta: Delta, action: Action) -> void:
	FightRules.add_stagger(fight_model, delta, action.target, ticks)


func create_changed(mod: SkillMod) -> Effect:
	if mod.stagger_change == 0:
		return self
	var changed := StaggerEffect.new()
	changed.ticks = maxi(0, ticks + mod.stagger_change)
	return changed


func get_description() -> String:
	return "Stagger [color=#%s]%d[/color]" % [STAGGER_COLOR.to_html(false), ticks]
