class_name MapNode
extends RefCounted

enum EventType { PLACEHOLDER, ENCOUNTER }

const EVENT_ICONS: Dictionary[EventType, Texture2D] = {
	EventType.PLACEHOLDER: preload("res://mission/event_placeholder.png"),
	EventType.ENCOUNTER: preload("res://mission/encounter.png"),
}

const EVENT_BAGS: Dictionary[EventType, Registry] = {
	EventType.PLACEHOLDER: preload("res://mission/event/placeholder_bag.tres"),
	EventType.ENCOUNTER: preload("res://mission/event/encounter_bag.tres"),
}
const EVENT_OFFER_COUNTS: Dictionary[EventType, int] = {
	EventType.PLACEHOLDER: 3,
	EventType.ENCOUNTER: 1,
}
const PICKED_EVENT_TYPES: Array[EventType] = [EventType.PLACEHOLDER]

var column: int
var row: int
var event_type: EventType
var previous_rows: Array[int] = []
var next_rows: Array[int] = []
var jitter: Vector2
