class_name Bag
extends RefCounted


# Distinct IDs at random among those `filter` accepts; fewer when the bag holds fewer than `count`.
static func draw(registry: Registry, count: int, filter: BagFilter, rng: RandomNumberGenerator) -> Array[StringName]:
	var ids := filter.get_accepted_ids(registry)
	var drawn: Array[StringName] = []
	while drawn.size() < count and not ids.is_empty():
		drawn.append(ids.pop_at(rng.randi_range(0, ids.size() - 1)))
	return drawn
