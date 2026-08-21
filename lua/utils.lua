local M = {}

function M.wrapin(value)
    local square = "[" .. value .. "]"
    local curly = "{" .. value .. "}"
    local round = "(" .. value .. ")"
    local arrow = "<" .. value .. ">"
    return {
        ["square"] = function() return square end,
        ["curly"] = function () return curly end,
        ["round"] = function () return round end,
        ["arrow"] = function () return arrow end,
        ["d"] = function () return square end
    }
end

return M

