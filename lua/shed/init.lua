local M = {}

local api = vim.api

function M.attach(bufnr)
	api.nvim_buf_attach(bufnr, false, {
		on_lines = function ()
		end
	})
end

function M.setup()
	print("setup")
end

return M
