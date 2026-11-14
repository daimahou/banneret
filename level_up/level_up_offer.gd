@abstract
class_name LevelUpOffer
extends RefCounted
# One offer a level-up puts up for one hero: a new skill or talent, or an upgrade of one they own.


@abstract func is_upgrade() -> bool


@abstract func get_name() -> String


# Null shows the placeholder.
@abstract func get_icon() -> Texture2D


@abstract func get_reached_rank_title() -> String


# An upgrade describes only what its next rank adds.
@abstract func get_description() -> String


# Empty for a new skill or talent.
@abstract func get_perks() -> Array[Perk]


# The perk is null for a new skill or talent.
@abstract func apply(hero: Character, perk: Perk) -> void
