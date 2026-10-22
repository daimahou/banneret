extends GdUnitTestSuite

const FIVE_OFFER_REGISTRY: Registry = preload("res://tests/doubles/registry/five_offer_registry.tres")


class OnlyIdsFilter extends RegistryFilter:
	var accepted_ids: Array[StringName] = []

	func get_accepted_ids(_registry: Registry) -> Array[StringName]:
		return accepted_ids.duplicate()


func test_picks_distinct_ids_from_the_registry() -> void:
	var ids := FIVE_OFFER_REGISTRY.pick_random(3, RegistryFilter.new(), _create_rng(1))
	assert_array(ids).has_size(3)
	assert_array(FIVE_OFFER_REGISTRY.get_all_string_ids()).contains(ids)
	for id in ids:
		assert_int(ids.count(id)).is_equal(1)


func test_a_registry_shorter_than_the_count_gives_all_it_holds() -> void:
	var ids := FIVE_OFFER_REGISTRY.pick_random(8, RegistryFilter.new(), _create_rng(1))
	assert_array(ids).contains_exactly_in_any_order(FIVE_OFFER_REGISTRY.get_all_string_ids())


func test_picks_only_ids_the_filter_accepts() -> void:
	var filter := OnlyIdsFilter.new()
	filter.accepted_ids = [&"offer_b", &"offer_d"]
	assert_array(FIVE_OFFER_REGISTRY.pick_random(5, filter, _create_rng(1))).contains_exactly_in_any_order([&"offer_b", &"offer_d"])


func test_the_same_seed_picks_the_same_ids() -> void:
	assert_array(FIVE_OFFER_REGISTRY.pick_random(3, null, _create_rng(7))) \
		.is_equal(FIVE_OFFER_REGISTRY.pick_random(3, null, _create_rng(7)))


func test_without_filter_or_rng_picks_from_every_entry() -> void:
	assert_array(FIVE_OFFER_REGISTRY.pick_random(5)).contains_exactly_in_any_order(FIVE_OFFER_REGISTRY.get_all_string_ids())


func _create_rng(rng_seed: int) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = rng_seed
	return rng
