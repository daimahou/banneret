extends GdUnitTestSuite

const FIVE_OFFER_BAG: Registry = preload("res://tests/doubles/bag/five_offer_bag.tres")


class OnlyIdsFilter extends BagFilter:
	var accepted_ids: Array[StringName] = []

	func get_accepted_ids(_registry: Registry) -> Array[StringName]:
		return accepted_ids.duplicate()


func test_draws_distinct_ids_from_the_bag() -> void:
	var ids := Bag.draw(FIVE_OFFER_BAG, 3, BagFilter.new(), _create_rng(1))
	assert_array(ids).has_size(3)
	assert_array(FIVE_OFFER_BAG.get_all_string_ids()).contains(ids)
	for id in ids:
		assert_int(ids.count(id)).is_equal(1)


func test_a_bag_shorter_than_the_count_gives_all_it_holds() -> void:
	var ids := Bag.draw(FIVE_OFFER_BAG, 8, BagFilter.new(), _create_rng(1))
	assert_array(ids).contains_exactly_in_any_order(FIVE_OFFER_BAG.get_all_string_ids())


func test_draws_only_ids_the_filter_accepts() -> void:
	var filter := OnlyIdsFilter.new()
	filter.accepted_ids = [&"offer_b", &"offer_d"]
	assert_array(Bag.draw(FIVE_OFFER_BAG, 5, filter, _create_rng(1))).contains_exactly_in_any_order([&"offer_b", &"offer_d"])


func test_the_same_seed_draws_the_same_ids() -> void:
	assert_array(Bag.draw(FIVE_OFFER_BAG, 3, BagFilter.new(), _create_rng(7))) \
		.is_equal(Bag.draw(FIVE_OFFER_BAG, 3, BagFilter.new(), _create_rng(7)))


func _create_rng(rng_seed: int) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = rng_seed
	return rng
