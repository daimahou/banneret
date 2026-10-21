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
	var mission_model := MissionModel.new(_mission_map)
	assert_array(mission_model.get_open_map_nodes()).contains_exactly_in_any_order([_upper, _lower])


func test_travel_opens_the_next_map_nodes_and_closes_the_choice_passed_up() -> void:
	var mission_model := MissionModel.new(_mission_map)
	mission_model.travel_to(_upper)
	assert_array(mission_model.get_open_map_nodes()).contains_exactly([_upper_next])
	assert_int(mission_model.get_map_node_visitation(_upper)).is_equal(MissionModel.Visitation.CURRENT)
	assert_int(mission_model.get_map_node_visitation(_lower)).is_equal(MissionModel.Visitation.CLOSED)
	assert_int(mission_model.get_map_node_visitation(_lower_next)).is_equal(MissionModel.Visitation.CLOSED)
	assert_int(mission_model.get_map_node_visitation(_encounter)).is_equal(MissionModel.Visitation.AHEAD)


# A lead-in road, from off the map, has no start node.
func test_roads_on_the_trail_are_travelled_and_those_passed_up_closed() -> void:
	var mission_model := MissionModel.new(_mission_map)
	mission_model.travel_to(_upper)
	mission_model.travel_to(_upper_next)
	assert_int(mission_model.get_road_visitation(null, _upper)).is_equal(MissionModel.Visitation.TRAVELLED)
	assert_int(mission_model.get_road_visitation(_upper, _upper_next)).is_equal(MissionModel.Visitation.TRAVELLED)
	assert_int(mission_model.get_road_visitation(_upper_next, _encounter)).is_equal(MissionModel.Visitation.OPEN)
	assert_int(mission_model.get_road_visitation(null, _lower)).is_equal(MissionModel.Visitation.CLOSED)
	assert_int(mission_model.get_road_visitation(_lower_next, _encounter)).is_equal(MissionModel.Visitation.CLOSED)


func test_before_any_travel_lead_in_roads_are_open() -> void:
	var mission_model := MissionModel.new(_mission_map)
	assert_int(mission_model.get_road_visitation(null, _lower)).is_equal(MissionModel.Visitation.OPEN)
	assert_int(mission_model.get_road_visitation(_lower, _lower_next)).is_equal(MissionModel.Visitation.AHEAD)


func test_reaching_the_encounter_ends_the_mission_with_nothing_open() -> void:
	var mission_model := MissionModel.new(_mission_map)
	mission_model.travel_to(_lower)
	mission_model.travel_to(_lower_next)
	assert_bool(mission_model.is_mission_ended()).is_false()
	mission_model.travel_to(_encounter)
	assert_bool(mission_model.is_mission_ended()).is_true()
	assert_array(mission_model.get_open_map_nodes()).is_empty()
