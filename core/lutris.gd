extends Resource

var logger := Log.get_logger("Lutris", Log.LEVEL.DEBUG)
var thread_pool := load("res://core/systems/threading/thread_pool.tres") as ThreadPool


func _init() -> void:
	thread_pool.start()


## Returns the command string to run Lutris
func get_lutris_command() -> LutrisCmd:
	if await _valid_lutris_cmd("lutris", []):
		return LutrisCmd.new("lutris")
	if await _valid_lutris_cmd("flatpak", ["run", "net.lutris.Lutris"]):
		return LutrisCmd.new("flatpak", ["run", "net.lutris.Lutris"])
	
	return LutrisCmd.new("lutris")


## Returns a list of locally install Lutris games
func get_games() -> Array[LutrisApp]:
	var games: Array[LutrisApp] = []
	var out := await _exec(["--list-games", "-j"]) as CmdOutput
	if out.code != OK:
		logger.warn("Unable to list lutris games. Exited with code " + str(out.code) + ": " + out.output)
		return games

	# Try to parse the JSON output
	var parsed = JSON.parse_string(out.output)
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
func _exec(args: PackedStringArray) -> CmdOutput:
	var lutris_cmd := await get_lutris_command()
	var cmd := lutris_cmd.cmd
	var arguments := lutris_cmd.args.duplicate()
	arguments.append_array(args)
	return await _exec_cmd(cmd, arguments)


## Execute the given command and return its output
func _exec_cmd(cmd: String, args: PackedStringArray) -> CmdOutput:
	logger.debug("Executing command: " + cmd + " " + " ".join(args))
	var output := []
	var code := await thread_pool.exec(OS.execute.bind(cmd, args, output)) as int
	var cmd_out := CmdOutput.new()
	cmd_out.code = code
	cmd_out.output = output[0]
	logger.debug("Command exit code: " + str(code))
	logger.debug("Command output: " + output[0])
	
	return cmd_out


## Tries to execute the given Lutris command to see if it exists. This will
## append the '--version' argument to the given command to see if it
## executes successfully, indiciating that this command will work.
func _valid_lutris_cmd(cmd: String, args: PackedStringArray) -> bool:
	var cmd_args := args.duplicate()
	cmd_args.push_back("--version")
	var cmd_output := await _exec_cmd(cmd, args)
	logger.debug("Executing command: " + cmd + " " + " ".join(args))

	return cmd_output.code == 0


## Structure that defines a lutris command
class LutrisCmd extends RefCounted:
	var cmd: String
	var args: PackedStringArray
	
	func _init(command: String, arguments: PackedStringArray = []) -> void:
		self.cmd = command
		self.args = arguments


## Output of a lutris command
class CmdOutput extends RefCounted:
	var code: int
	var output: String


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
