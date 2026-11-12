class_name Draft
extends RefCounted
# One level-up of the party: a pick for each hero, all of the same kind.

var kind: Learnable.Kind
var bag: Array[Learnable] = []
var hero_drafts: Array[HeroDraft] = []


func _init(heroes: Array[Character], draft_kind: Learnable.Kind, draft_bag: Array[Learnable], roll: Callable) -> void:
	kind = draft_kind
	bag = draft_bag
	for hero in heroes:
		hero_drafts.append(HeroDraft.new(hero, kind, bag, roll))


func get_done_count() -> int:
	return hero_drafts.filter(func(hero_draft: HeroDraft) -> bool: return hero_draft.is_done()).size()


func is_complete() -> bool:
	return get_done_count() == hero_drafts.size()
