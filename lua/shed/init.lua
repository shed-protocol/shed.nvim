local M = {}

local operation = require("operation")
local transport = require("transport")

local api = vim.api
local json = vim.json

function M.attach(bufnr)
	local skip = false

	local buf = ""
	local client = vim.system({ "shed-client", "localhost:9042" }, {
		stdin = true,
		stdout = function(_, data)
			if not data then return end
			buf = buf .. data
			local msg
			msg, buf = transport.read(buf)
			if msg then
				local op = json.decode(msg).body.op
				vim.schedule(function()
					skip = true
					operation.apply(op)
					skip = false
				end)
			end
		end
	})

	api.nvim_buf_attach(bufnr, false, {
		on_lines = function(_, _, _, firstline, _, new_lastline, old_byte_size)
			-- TODO: Fix race condition (skip only edits equal to last remote change?)
			if skip then return end
			local ops = operation.from(firstline, new_lastline, old_byte_size)
			for _, op in ipairs(ops) do
				local content = json.encode({ kind = 1, body = { op = op } })
				transport.write(content, client)
			end
		end,
	})

	api.nvim_create_autocmd("BufUnload", {
		pattern = "*",
		callback = function()
			client:kill("sigint")
			return true -- deletes the autocmd after execution
		end,
	})
end

function M.setup()
	print("setup")
end

return M
