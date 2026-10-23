class_name DamageEffect
extends Effect

@export var amount: int


func add_changes(fight_model: FightModel, delta: Delta, action: Action) -> void:
	FightRules.add_damage(fight_model, delta, action.target, amount)


func get_description() -> String:
	return "Deal %d damage" % amount
