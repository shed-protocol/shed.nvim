local M = {}

local bit = require("bit")

---@param data string
---@param out { write: fun(self, data: string) }
function M.write(data, out)
	local length = #data
	if length > 1024*1024 then
		error(string.format("shed: message too long to write (%d bytes)", length))
	end
	local header = string.char(
		bit.band(length, 0xff000000),
		bit.band(length, 0x00ff0000),
		bit.band(length, 0x0000ff00),
		bit.band(length, 0x000000ff)
	)
	out:write(header .. data)
end

---@param buf string
---@return string? message, string buf
function M.read(buf)
	if #buf < 4 then
		return nil, buf
	end
	local length = bit.bor(
		bit.lshift(string.byte(buf, 1), 24),
		bit.lshift(string.byte(buf, 2), 16),
		bit.lshift(string.byte(buf, 3), 8),
		bit.lshift(string.byte(buf, 4), 0)
	)
	if length > 1024*1024 then
		error(string.format("shed: message too long to read (%d bytes)", length))
	end

	if #buf < length + 4 then
		return nil, buf
	end
	return buf:sub(4 + 1, 4 + length), buf:sub(4 + length + 1)
end

return M
