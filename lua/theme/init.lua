local M = {}

M.background = "#222325"

-- <07-29-26: "#9DACBF"
-- <08-03-26: "#a0aab2"
M.foreground = "#99a0a6"

M.accent = "#CC7832"

M.gray = "#616669"
M.yellow = "#E8BF6A"
M.purple = "#CC78D7"
M.green = "#96d460"
M.blue = "#6897BB"

M.pea = "#4EC9B0"
M.grass = "#6bb38a"
M.mustard = "#BBB529"
M.fuchsia = "#de3aa3"

M.blue2 = "#5daee4"
M.orange = "#ffae19"
M.red = "#ff1f5f"

-- Blends `overlay` at `alpha` (0.0–1.0) opacity on top of `base`.
-- Mimics CSS-style alpha compositing since terminal cells can't do real transparency.
function M.blend(overlay, alpha, base)
	base = base or M.background
	local function hex_to_rgb(hex)
		hex = hex:gsub("#", "")
		return tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16)
	end

	local or_, og, ob = hex_to_rgb(overlay)
	local br, bg, bb = hex_to_rgb(base)

	local function blend_channel(o, b)
		return math.floor(o * alpha + b * (1 - alpha) + 0.5)
	end

	return string.format("#%02X%02X%02X", blend_channel(or_, br), blend_channel(og, bg), blend_channel(ob, bb))
end

M.foreground_fade = M.blend(M.foreground, 0.24)
M.blue2_fade = M.blend(M.blue2, 0.1)
M.orange_fade = M.blend(M.orange, 0.1)
M.red_fade = M.blend(M.red, 0.1)

return M
