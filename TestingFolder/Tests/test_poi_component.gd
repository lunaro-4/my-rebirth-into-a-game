extends GutTest


# @onready var test_scene = preload('./testing_ground.gd')

@onready var poic : PointsOfInterestComponent

func before_each():
	poic = PointsOfInterestComponent.new()
func after_each():
	poic.free()

const STARTING_POINT = Vector2i(0,0)

var arr_of_arrs= [

[Vector2(0, 0), Vector2(16, 16), Vector2(32, 16), Vector2(48, 16), Vector2(64, 16), Vector2(80, 16),
Vector2(96, 16), Vector2(112, 16), Vector2(128, 16), Vector2(144, 32), Vector2(160, 32), Vector2(176, 32),
Vector2(192, 32), Vector2(208, 32), Vector2(224, 32), Vector2(240, 32), Vector2(256, 48), Vector2(272, 64),
Vector2(288, 80), Vector2(304, 96), Vector2(304, 112), Vector2(320, 128), Vector2(320, 144), Vector2(336, 160),
Vector2(336, 176), Vector2(352, 192), Vector2(352, 208), Vector2(368, 224), Vector2(368, 240)],

[Vector2(0, 0),
Vector2(16, 16), Vector2(32, 16), Vector2(48, 16), Vector2(64, 16), Vector2(80, 16), Vector2(96, 16),
Vector2(112, 16), Vector2(128, 16), Vector2(144, 32), Vector2(160, 48), Vector2(160, 64), Vector2(160, 80),
Vector2(160, 96), Vector2(176, 112), Vector2(176, 128), Vector2(192, 144), Vector2(192, 160), Vector2(208, 176),
Vector2(208, 192), Vector2(224, 208), Vector2(224, 224)],

[Vector2(0, 0), Vector2(0, 16), Vector2(0, 32), Vector2(-16, 48), Vector2(-16, 64), Vector2(-16, 80),
Vector2(-16, 96), Vector2(-16, 112), Vector2(-16, 128), Vector2(-16, 144), Vector2(-16, 160), Vector2(-16, 176),
Vector2(-16, 192), Vector2(0, 208), Vector2(0, 224)]

]

func test_generate_path_map():
	var test_map = poic._get_uniqe_tail_array_vector({STARTING_POINT: arr_of_arrs}, 0)
	assert_eq(str(test_map), "{ (0, 0): [{ (144, 32): [(368, 240), (224, 224)] }, (0, 224)] }")
