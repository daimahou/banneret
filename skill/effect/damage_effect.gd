class_name DamageEffect
extends Effect

const DAMAGE_COLOR := Color("a8241a")

@export var amount: int


func add_changes(fight_model: FightModel, delta: Delta, action: Action) -> void:
	FightRules.add_damage(fight_model, delta, action.target, amount)


func get_description() -> String:
	return "Deal [color=#%s]%d[/color] damage" % [DAMAGE_COLOR.to_html(false), amount]
