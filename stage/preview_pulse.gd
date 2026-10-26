class_name PreviewPulse
extends RefCounted
# One readout's style: it pulses red when worse for the character, green when better.

enum Style { NONE, WORSE, BETTER }

const WORSE_COLOR := Color("e0503c")
const BETTER_COLOR := Color("6cc46c")
const PULSE_DURATION := 0.9
const PULSE_ALPHA := 0.45

var _item: CanvasItem
var _tween: Tween
var _style := Style.NONE


func _init(marked: CanvasItem) -> void:
	_item = marked


func show_style(style: Style) -> void:
	if style == _style:
		return
	_style = style
	if _tween != null:
		_tween.kill()
		_tween = null
	if style == Style.NONE:
		_item.modulate = Color.WHITE
		return
	_item.modulate = BETTER_COLOR if style == Style.BETTER else WORSE_COLOR
	_tween = _item.create_tween().set_loops().set_trans(Tween.TRANS_SINE)
	_tween.tween_property(_item, "modulate:a", PULSE_ALPHA, PULSE_DURATION / 2.0)
	_tween.tween_property(_item, "modulate:a", 1.0, PULSE_DURATION / 2.0)


static func get_style(gain: int) -> Style:
	if gain > 0:
		return Style.BETTER
	return Style.WORSE if gain < 0 else Style.NONE
