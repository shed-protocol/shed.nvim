local M = {}

local api = vim.api

function M.attach(bufnr)
	local stdin = vim.system({"shed-client"}, { stdin = true, stdout = function() end })
	api.nvim_buf_attach(bufnr, false, {
		on_lines = function ()
		end
	})
end

function M.setup()
	print("setup")
end

return M
