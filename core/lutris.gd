extends Resource

var _lutris_command := ""
var _lutris_base_args := [] as Array[String]
var logger := Log.get_logger("Lutris", Log.LEVEL.INFO)


## Returns the command string to run Lutris
func get_lutris_command() -> Command:
	if not _lutris_command.is_empty():
		return Command.create(_lutris_command, _lutris_base_args.duplicate())
	if await _valid_lutris_cmd("lutris", []):
		logger.info("Detected native installation of Lutris")
		_lutris_command = "lutris"
		_lutris_base_args = []
	elif await _valid_lutris_cmd("flatpak", ["run", "net.lutris.Lutris"]):
		logger.info("Detected flatpak installation of Lutris")
		_lutris_command = "flatpak"
		_lutris_base_args = ["run", "net.lutris.Lutris"]

	return Command.create(_lutris_command, _lutris_base_args.duplicate())


## Returns a list of locally install Lutris games
func get_games() -> Array[LutrisApp]:
	var games: Array[LutrisApp] = []
	var out := await _exec(["--list-games", "-j"]) as Command
	if out.code != OK:
		logger.warn("Unable to list lutris games. Exited with code " + str(out.code) + ": " + out.stdout + " " + out.stderr)
		return games

	# Try to parse the JSON output
	var parsed = JSON.parse_string(out.stdout)
	if not parsed is Array:
		logger.warn("Unable to parse lutris games output")
		return games

	# Validate and add each found game to the list of games
	for game in parsed:
		if not game is Dictionary:
			continue
		var app := LutrisApp.new()
		if not "slug" in game:
			continue
		app.slug = game["slug"]
		games.append(app)

		if "id" in game and game["id"] is int:
			app.id = game["id"]
		if "name" in game and game["name"] is String:
			app.name = game["name"]
		if "runner" in game and game["runner"] is String:
			app.runner = game["runner"]
		if "platform" in game and game["platform"] is String:
			app.platform = game["platform"]
		if "year" in game and game["year"] is String:
			app.year = game["year"]
		if "directory" in game and game["directory"] is String:
			app.directory = game["directory"]
		if "hidden" in game and game["hidden"] is bool:
			app.hidden = game["hidden"]
		if "playtime" in game and game["playtime"] is String:
			app.playtime = game["playtime"]
		if "lastplayed" in game and game["lastplayed"] is String:
			app.lastplayed = game["lastplayed"]

	return games


## Executes the lutris command with the given arguments
func _exec(args: PackedStringArray) -> Command:
	var lutris_cmd := await get_lutris_command()
	for arg in args:
		lutris_cmd.args.push_back(arg)
	await _exec_cmd(lutris_cmd)
	return lutris_cmd


## Execute the given command and return its output
func _exec_cmd(cmd: Command) -> void:
	logger.debug("Executing command: " + cmd.command + " " + " ".join(cmd.args))
	cmd.execute()
	await cmd.finished
	logger.debug("Command exit code: " + str(cmd.code))
	logger.debug("Command output: " + cmd.stdout + " " + cmd.stderr)


## Tries to execute the given Lutris command to see if it exists. This will
## append the '--version' argument to the given command to see if it
## executes successfully, indiciating that this command will work.
func _valid_lutris_cmd(cmd: String, args: PackedStringArray) -> bool:
	var command := Command.create(cmd, args)
	command.args.push_back("--version")
	await _exec_cmd(command)

	return command.code == 0


## A lutris game entry
class LutrisApp extends RefCounted:
	var id: int
	var slug: String
	var name: String
	var runner: String
	var platform: String
	var year: int
	var directory: String
	var hidden: bool
	var playtime: String
	var lastplayed: String
