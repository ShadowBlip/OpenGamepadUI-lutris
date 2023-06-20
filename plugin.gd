extends Plugin


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	logger = Log.get_logger("LutrisPlugin", Log.LEVEL.INFO)
	logger.info("Lutris plugin loaded")
	var library: Node = load(plugin_base + "/core/library.tscn").instantiate()
	add_child(library)
