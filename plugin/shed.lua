local api = vim.api
local shed = require("shed")

api.nvim_create_user_command("Shed", function () shed.attach(0) end, {})
