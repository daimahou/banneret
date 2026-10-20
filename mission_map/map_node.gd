class_name MapNode
extends RefCounted

enum EventType { PLACEHOLDER, ENCOUNTER }

const EVENT_ICONS: Dictionary[EventType, Texture2D] = {
	EventType.PLACEHOLDER: preload("res://art/map/event_placeholder.png"),
	EventType.ENCOUNTER: preload("res://art/map/encounter.png"),
}

var column: int
var row: int
var event_type: EventType
var previous_rows: Array[int] = []
var next_rows: Array[int] = []
var jitter: Vector2
