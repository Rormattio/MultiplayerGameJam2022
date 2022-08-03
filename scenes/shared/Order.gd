extends Reference

class_name Order

var id
var text # space-separated clues

func init(a_text: String):
	self.id = Global.gen_id()
	self.text = a_text

func serialize() -> Array:
	return [id, text]

func unserialize(data: Array):
	self.id = data[0]
	self.text = data[1]

func _to_string() -> String:
	return "Order(%d, %s)" % [id, text]
