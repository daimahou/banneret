class_name PreviewPulse
extends RefCounted
# A difference the preview makes to one readout: it pulses, red when bad for the character, green when good.

const WORSE_COLOR := Color("e0503c")
const BETTER_COLOR := Color("6cc46c")
const PULSE_DURATION := 0.9
const PULSE_ALPHA := 0.45

var _item: CanvasItem
var _tween: Tween
var _gain := 0


func _init(marked: CanvasItem) -> void:
	_item = marked


# The gain for the character: above zero better, below worse, zero no difference. A pulse already going on in the same direction keeps its rhythm.
func show_gain(gain: int) -> void:
	if signi(gain) == signi(_gain):
		return
	_gain = gain
	if _tween != null:
		_tween.kill()
		_tween = null
	if gain == 0:
		_item.modulate = Color.WHITE
		return
	_item.modulate = BETTER_COLOR if gain > 0 else WORSE_COLOR
	_tween = _item.create_tween().set_loops().set_trans(Tween.TRANS_SINE)
	_tween.tween_property(_item, "modulate:a", PULSE_ALPHA, PULSE_DURATION / 2.0)
	_tween.tween_property(_item, "modulate:a", 1.0, PULSE_DURATION / 2.0)
