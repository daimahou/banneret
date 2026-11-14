class_name RunModel
extends RefCounted

const HERO_REGISTRY: Registry = preload("res://hero/hero_registry.tres")
const PARTY_HERO_IDS: Array[StringName] = [&"warrior", &"rogue", &"mage"]
const BRIGAND: CharacterData = preload("res://enemy/brigand.tres")
const ENCOUNTER_ENEMIES: Array[CharacterData] = [BRIGAND, BRIGAND, BRIGAND]
const SKILL_BAG: Registry = preload("res://skill/skill_bag.tres")

var party: Array[Character] = []

var _level_up_rng: RandomNumberGenerator
var _skill_bag: Array[SkillData] = []
# Null before the first level-up.
var _level_up: LevelUp


func _init(level_up_rng := RandomNumberGenerator.new()) -> void:
	_level_up_rng = level_up_rng
	for id in PARTY_HERO_IDS:
		party.append(Character.new(HERO_REGISTRY.load_entry(id) as CharacterData))
	_skill_bag.assign(SKILL_BAG.load_all_blocking().values())


func create_encounter_enemies() -> Array[Character]:
	var enemies: Array[Character] = []
	for enemy_data in ENCOUNTER_ENEMIES:
		enemies.append(Character.new(enemy_data))
	return enemies


func has_level_up_left() -> bool:
	return _level_up == null or not _level_up.is_complete() or _level_up.number < LevelUp.LAST_NUMBER


# Null once the last level-up is complete.
func get_next_level_up() -> LevelUp:
	if _level_up != null and not _level_up.is_complete():
		return _level_up
	var number := 1 if _level_up == null else _level_up.number + 1
	if number > LevelUp.LAST_NUMBER:
		return null
	_level_up = LevelUp.new(number, party, _skill_bag, _level_up_rng)
	return _level_up


func is_lost() -> bool:
	return party.all(func(hero: Character) -> bool: return hero.is_fallen())
