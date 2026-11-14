@abstract
class_name LevelUpOffer
extends RefCounted
# One offer a level-up puts up for one hero: a new skill or talent, or an upgrade of one they own.

# Empty for a new skill or talent. An upgrade's are only those of its next rank whose requirements the hero meets.
var perks: Array[Perk] = []


@abstract func is_upgrade() -> bool


@abstract func get_name() -> String


# Null shows the placeholder.
@abstract func get_icon() -> Texture2D


@abstract func get_reached_rank_title() -> String


# An upgrade describes only what its next rank adds.
@abstract func get_description() -> String


# The perk is null for a new skill or talent.
@abstract func apply(hero: Character, perk: Perk) -> void
