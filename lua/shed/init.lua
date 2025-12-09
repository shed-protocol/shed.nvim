local M = {}

local transport = require("transport")

local api = vim.api

function M.attach(bufnr)
	local buf = ""
	local client = vim.system({"shed-client", "localhost:9042"}, {
		stdin = true,
		stdout = function(_, data)
			buf = buf .. data
			local msg
			msg, buf = transport.read(buf)
			if msg then
				vim.schedule(function ()
					vim.notify(msg)
				end)
			end
		end
	})

	api.nvim_buf_attach(bufnr, false, {
		on_lines = function ()
			local json = '{"kind":1,"body":{"op":{"type":"deletion","pos":20,"len":0}}}'
			transport.write(json, client)
		end
	})
end

function M.setup()
	print("setup")
end

return M
