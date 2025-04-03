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

-- copied from conform.nvim
local function range_from_selection(bufnr, mode)
  -- [bufnum, lnum, col, off]; both row and column 1-indexed
  local start = vim.fn.getpos("v")
  local end_ = vim.fn.getpos(".")
  local start_row = start[2]
  local start_col = start[3]
  local end_row = end_[2]
  local end_col = end_[3]

  -- A user can start visual selection at the end and move backwards
  -- Normalize the range to start < end
  if start_row == end_row and end_col < start_col then
    end_col, start_col = start_col, end_col
  elseif end_row < start_row then
    start_row, end_row = end_row, start_row
    start_col, end_col = end_col, start_col
  end
  if mode == "V" then
    start_col = 1
    local lines = vim.api.nvim_buf_get_lines(bufnr, end_row - 1, end_row, true)
    end_col = #lines[1]
  end
  return {
    ["start"] = { start_row, start_col - 1 },
    ["end"] = { end_row, end_col - 1 },
  }
end

return {
	setup = function()
		vim.api.nvim_create_user_command("JSON2Struct", function(opts)
			local line1 = opts.line1 - 1
			local line2 = opts.line2

			if opts.range == 0 then
				local r = range_from_selection(0, vim.api.nvim_get_mode().mode)

				line1 = r['start'][1]-1
				line2 = r['end'][1]
			end

			json2struct(opts.fargs[1], line1, line2)
		end, { nargs = "?", range = true })
	end,
}
