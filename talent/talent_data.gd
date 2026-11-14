class_name TalentData
extends Resource
# A talent's preset, which is its Basic rank, and the ranks above it.

@export var name: String
# Null shows the placeholder.
@export var icon: Texture2D
@export var modifiers: Array[HeroModifier] = []
# Advanced, then Expert.
@export var ranks: Array[TalentRank] = []
