extends GdUnitTestSuite

var _mission_map: MissionMap
var _upper: MapNode
var _lower: MapNode
var _upper_next: MapNode
var _lower_next: MapNode
var _encounter: MapNode


# Two first-column map nodes, each with its own road on, both leading to the encounter.
func before_test() -> void:
	_mission_map = MissionMap.new()
	_upper = MissionMapFixture.add_map_node(_mission_map, 0, 0)
	_lower = MissionMapFixture.add_map_node(_mission_map, 0, 2)
	_upper_next = MissionMapFixture.add_map_node(_mission_map, 1, 0)
	_lower_next = MissionMapFixture.add_map_node(_mission_map, 1, 2)
	_encounter = MissionMapFixture.add_map_node(_mission_map, 2, 1, MapNode.EventType.ENCOUNTER)
	MissionMapFixture.add_map_edge(_mission_map, _upper, _upper_next)
	MissionMapFixture.add_map_edge(_mission_map, _lower, _lower_next)
	MissionMapFixture.add_map_edge(_mission_map, _upper_next, _encounter)
	MissionMapFixture.add_map_edge(_mission_map, _lower_next, _encounter)


func test_before_any_travel_the_first_column_is_open() -> void:
	var mission_model := MissionModel.new(_mission_map, 1)
	assert_array(mission_model.get_open_map_nodes()).contains_exactly_in_any_order([_upper, _lower])


func test_travel_opens_the_next_map_nodes_and_closes_the_choice_passed_up() -> void:
	var mission_model := MissionModel.new(_mission_map, 1)
	_travel_and_pick(mission_model, _upper)
	assert_array(mission_model.get_open_map_nodes()).contains_exactly([_upper_next])
	assert_int(mission_model.get_map_node_visitation(_upper)).is_equal(MissionModel.Visitation.CURRENT)
	assert_int(mission_model.get_map_node_visitation(_lower)).is_equal(MissionModel.Visitation.CLOSED)
	assert_int(mission_model.get_map_node_visitation(_lower_next)).is_equal(MissionModel.Visitation.CLOSED)
	assert_int(mission_model.get_map_node_visitation(_encounter)).is_equal(MissionModel.Visitation.AHEAD)


# A lead-in road, from off the map, has no start node.
func test_roads_on_the_trail_are_travelled_and_those_passed_up_closed() -> void:
	var mission_model := MissionModel.new(_mission_map, 1)
	_travel_and_pick(mission_model, _upper)
	_travel_and_pick(mission_model, _upper_next)
	assert_int(mission_model.get_road_visitation(null, _upper)).is_equal(MissionModel.Visitation.TRAVELLED)
	assert_int(mission_model.get_road_visitation(_upper, _upper_next)).is_equal(MissionModel.Visitation.TRAVELLED)
	assert_int(mission_model.get_road_visitation(_upper_next, _encounter)).is_equal(MissionModel.Visitation.OPEN)
	assert_int(mission_model.get_road_visitation(null, _lower)).is_equal(MissionModel.Visitation.CLOSED)
	assert_int(mission_model.get_road_visitation(_lower_next, _encounter)).is_equal(MissionModel.Visitation.CLOSED)


func test_before_any_travel_lead_in_roads_are_open() -> void:
	var mission_model := MissionModel.new(_mission_map, 1)
	assert_int(mission_model.get_road_visitation(null, _lower)).is_equal(MissionModel.Visitation.OPEN)
	assert_int(mission_model.get_road_visitation(_lower, _lower_next)).is_equal(MissionModel.Visitation.AHEAD)


func test_reaching_the_encounter_ends_the_mission_with_nothing_open() -> void:
	var mission_model := MissionModel.new(_mission_map, 1)
	_travel_and_pick(mission_model, _lower)
	_travel_and_pick(mission_model, _lower_next)
	assert_bool(mission_model.is_mission_ended()).is_false()
	mission_model.travel_to(_encounter)
	assert_bool(mission_model.is_mission_ended()).is_true()
	assert_array(mission_model.get_open_map_nodes()).is_empty()


func test_offers_pending_after_travel_lock_the_map_until_one_is_picked() -> void:
	var mission_model := MissionModel.new(_mission_map, 1)
	mission_model.travel_to(_upper)
	assert_array(mission_model.get_offers()).is_not_empty()
	assert_array(mission_model.get_open_map_nodes()).is_empty()
	var offer: Offer = mission_model.get_offers()[0]
	mission_model.pick_offer(offer)
	assert_array(mission_model.get_offers()).is_empty()
	assert_object(mission_model.get_resolved_offer()).is_same(offer)
	assert_array(mission_model.get_open_map_nodes()).contains_exactly([_upper_next])


func test_pending_offers_leave_what_lies_ahead_reachable() -> void:
	var mission_model := MissionModel.new(_mission_map, 1)
	mission_model.travel_to(_upper)
	assert_int(mission_model.get_map_node_visitation(_upper_next)).is_equal(MissionModel.Visitation.AHEAD)
	assert_int(mission_model.get_map_node_visitation(_encounter)).is_equal(MissionModel.Visitation.AHEAD)


func test_the_same_seed_draws_the_same_offers() -> void:
	var first := MissionModel.new(_mission_map, 4)
	var second := MissionModel.new(_mission_map, 4)
	first.travel_to(_lower)
	second.travel_to(_lower)
	assert_array(first.get_offers()).is_equal(second.get_offers())


func test_the_encounter_resolves_without_a_pick() -> void:
	var mission_model := MissionModel.new(_mission_map, 1)
	_travel_and_pick(mission_model, _upper)
	_travel_and_pick(mission_model, _upper_next)
	mission_model.travel_to(_encounter)
	assert_array(mission_model.get_offers()).is_empty()
	assert_bool(mission_model.is_mission_ended()).is_true()


func _travel_and_pick(mission_model: MissionModel, map_node: MapNode) -> void:
	mission_model.travel_to(map_node)
	mission_model.pick_offer(mission_model.get_offers()[0])
