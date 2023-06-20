extends Library

const Lutris := preload("res://plugins/lutris/core/lutris.gd")

var lutris := Lutris.new()


func get_library_launch_items() -> Array[LibraryLaunchItem]:
	logger.info("Fetching Lutris library items")
	var items: Array[LibraryLaunchItem] = []
	
	# Get the list of games from Lutris
	var games := await lutris.get_games()
	
	# Create a launch item for each lutris game
	for game in games:
		if game.slug == "":
			continue
		
		# Create a launch item for this game
		var item := LibraryLaunchItem.new()
		item.name = game.name
		item.provider_app_id = game.slug
		item.command = lutris.get_lutris_command()
		item.args = ["lutris:rungame/" + game.slug]
		item.tags = ["lutris"]
		item.installed = true
		item.hidden = game.hidden
		
		items.append(item)
	
	logger.info("Found " + str(items.size()) + " games")
	return items
