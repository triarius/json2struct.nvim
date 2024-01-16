local Job = require("plenary.job")

return function(json, name, on_exit)
	name = name or "JSON"

	Job:new({
		command = "json2struct",
		args = { "-name=" .. name },
		writer = json,
		on_exit = on_exit,
	}):start()
end
