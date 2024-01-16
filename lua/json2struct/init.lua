local json2struct = require("json2struct.json2struct")

local M = {}

local function lines_between(line1, line2)
	local lines = vim.api.nvim_buf_get_lines(0, line1, line2, false)
	return table.concat(lines, "\n")
end

function M.setup()
	vim.api.nvim_create_user_command("JSON2Struct", function(opts)
		local json = lines_between(opts.line1 - 1, opts.line2)
		local struct = json2struct(json)

		local lines = {}
		for line in struct:gmatch("[^\r\n]+") do
			table.insert(lines, line)
		end

		vim.api.nvim_buf_set_lines(0, opts.line1 - 1, opts.line2, false, lines)
	end, { range = true })
end

return M
