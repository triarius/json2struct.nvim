local function lines_between(line1, line2)
	local lines = vim.api.nvim_buf_get_lines(0, line1, line2, false)
	return table.concat(lines, "\n")
end

local function json2struct(name, first, last)
	name = name or vim.fn.input("Struct name: ")
	local json = lines_between(first, last)

	if vim.json.decode(json) == nil then
		vim.notify("Invalid JSON", vim.log.levels.ERROR)
		return
	end

	local Job = require("plenary.job")
	Job:new({
		command = "json2struct",
		args = { "-name=" .. name },
		writer = json,
		on_exit = function(job, exit_code)
			if exit_code ~= 0 then
				vim.notify("Error generating struct: exit " .. exit_code, vim.log.levels.ERROR)
				return
			end

			local struct = job:result()
			if not assert(struct) or #struct == 0 then
				vim.notify("Error generating struct", vim.log.levels.ERROR)
				return
			end

			vim.schedule(function()
				vim.api.nvim_buf_set_lines(0, first, last, false, struct)
			end)
		end,
	}):start()
end

return {
	setup = function()
		vim.api.nvim_create_user_command("JSON2Struct", function(opts)
			json2struct(opts.fargs[1], opts.line1 - 1, opts.line2)
		end, { nargs = "?", range = true })
	end,
}
