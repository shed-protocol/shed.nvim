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
		on_lines = function()
			local json = '{"kind":1,"body":{"op":{"type":"deletion","pos":20,"len":0}}}'
			-- TODO: Fix race condition (skip only edits equal to last remote change?)
			if not skip then transport.write(json, client) end
		end
	})
end

function M.setup()
	print("setup")
end

return M
