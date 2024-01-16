local Job = require("plenary.job")

return function(json, name)
	name = name or "JSON"

	local job = Job:new({
		command = "json2struct",
		args = { "-name=" .. name },
		writer = json,
	}):sync()
	return table.concat(job, "\n")
end
