local M = {}

local api = vim.api

--- @param pos uinteger
--- @return uinteger, uinteger
local function index(pos)
	-- TODO: Fix race condition (buffer state param?)
	local lineno = vim.fn.byte2line(pos + 1)
	local start = vim.fn.line2byte(lineno)
	if lineno == -1 or start == -1 then
		error(string.format("invalid position: %d", pos))
	end
	local offset = pos - start + 1
	local col = vim.fn.charidx(vim.fn.getline(lineno), offset)
	return lineno - 1, col
end

function M.apply(op)
	if op.type == "insertion" then
		local row, col = index(op.pos)
		api.nvim_buf_set_text(0, row, col, row, col, vim.split(op.text, "\n"))
	elseif op.type == "deletion" then
		local start_row, start_col = index(op.pos)
		local end_row, end_col = index(op.pos + op.len)
		api.nvim_buf_set_text(0, start_row, start_col, end_row, end_col, {})
	else
		error(string.format("can't apply operation of unknown kind: %s", op.type))
	end
end

return M
