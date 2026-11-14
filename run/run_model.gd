class_name RunModel
extends RefCounted

const HERO_REGISTRY: Registry = preload("res://hero/hero_registry.tres")
const PARTY_HERO_IDS: Array[StringName] = [&"warrior", &"rogue", &"mage"]
const BRIGAND: CharacterData = preload("res://enemy/brigand.tres")
const ENCOUNTER_ENEMIES: Array[CharacterData] = [BRIGAND, BRIGAND, BRIGAND]
const SKILL_BAG: Registry = preload("res://skill/skill_bag.tres")
const TALENT_BAG: Registry = preload("res://talent/talent_bag.tres")

var party: Array[Character] = []
var level_up_count := 0

var _seed: int
var _bags: Dictionary[LevelUp.Draft, Array] = {}


func _init(run_seed := randi()) -> void:
	_seed = run_seed
	for id in PARTY_HERO_IDS:
		party.append(Character.new(HERO_REGISTRY.load_entry(id) as CharacterData))
	_bags[LevelUp.Draft.SKILL] = SKILL_BAG.load_all_blocking().values()
	_bags[LevelUp.Draft.TALENT] = TALENT_BAG.load_all_blocking().values()


func create_encounter_enemies() -> Array[Character]:
	var enemies: Array[Character] = []
	for enemy_data in ENCOUNTER_ENEMIES:
		enemies.append(Character.new(enemy_data))
	return enemies


func has_level_up_left() -> bool:
	return level_up_count < LevelUp.LAST_NUMBER


# The same level-up of the same run always draws the same offers.
func create_level_up() -> LevelUp:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash([_seed, level_up_count + 1])
	return LevelUp.new(level_up_count + 1, party, _bags, rng)


func confirm_level_up(level_up: LevelUp) -> void:
	if level_up.number != level_up_count + 1:
		push_error("Level-up %d is not the next one" % level_up.number)
		return
	if not level_up.is_ready():
		push_error("Level-up %d waits on a selection" % level_up.number)
		return
	level_up.apply_picks()
	level_up_count += 1


func is_lost() -> bool:
	return party.all(func(hero: Character) -> bool: return hero.is_fallen())
