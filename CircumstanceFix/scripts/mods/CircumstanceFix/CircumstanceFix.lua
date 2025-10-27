local mod = get_mod("CircumstanceFix")

local TOP_PADDING = 10      -- above title
local GAP_PADDING = 14      -- between title and description
local BOTTOM_PADDING = 10   -- below description
local UIFonts = require("scripts/managers/ui/ui_fonts")
local UIRenderer = require("scripts/managers/ui/ui_renderer")

local SINGLE_LINE_THRESHOLD = 28 -- one line of title text height

local function ensure_padding(view)
	local sg = view._ui_scenegraph
	if not sg then
		return
	end

	local node = sg.mission_area_circumstance
	if not (node and node.size) then
		return
	end

	if not node._base_size then
		node._base_size = table.clone(node.size)
		node._base_pos_y = node.position[2]
		node._extra_pad = 0
	end

	local w = view._widgets_by_name and view._widgets_by_name.circumstance_details
	if not w then
		return
	end

	local title = w.content and w.content.circumstance_title or ""
	local desc = w.content and w.content.circumstance_description or ""
	-- set base description offset
	if not w._base_desc_offset then
		local style_desc = w.style and w.style.circumstance_description
		w._base_desc_offset = style_desc and style_desc.offset and style_desc.offset[2] or 40
	end

	-- check if description exists
	if tostring(desc):gsub("%s+", "") == "" or desc == "???" then
		-- reset any offset changes
		local style_desc = w.style and w.style.circumstance_description
		if style_desc and style_desc.offset then
			style_desc.offset[2] = w._base_desc_offset
		end

		if node._extra_pad ~= 0 then
			node.size[2] = node._base_size[2]
			node.position[2] = node._base_pos_y
			node._extra_pad = 0
		end
		return
	end

	-- Measure text height to detect wrapping
	local title_style = w.style and w.style.circumstance_title
	local desc_style = w.style and w.style.circumstance_description
local ui_renderer = view._ui_renderer
	local title_height = 0
	if ui_renderer and title_style and title ~= "" then
		local font_opts = UIFonts.get_font_options_by_style(title_style)
		local box_width = (title_style.size and title_style.size[1]) or 800
		local _, measured_h = UIRenderer.text_size(ui_renderer, title, title_style.font_type, title_style.font_size, {box_width, 2000}, font_opts)
		title_height = measured_h
	end

	local extra_title_height = math.max(0, title_height - SINGLE_LINE_THRESHOLD)

	-- Adjust description vertical offset
	if desc_style and desc_style.offset then
		desc_style.offset[2] = TOP_PADDING + title_height + GAP_PADDING
	end

	-- calculate the required total height of the node
	local desc_height = 0
	if ui_renderer and desc_style and desc ~= "" then
		local font_opts_d = UIFonts.get_font_options_by_style(desc_style)
		local box_width_d = (desc_style.size and desc_style.size[1]) or 800
		local _, dh = UIRenderer.text_size(ui_renderer, desc, desc_style.font_type, desc_style.font_size, {box_width_d, 2000}, font_opts_d)
		desc_height = dh
	end

	local needed_height = TOP_PADDING + title_height + GAP_PADDING + desc_height + BOTTOM_PADDING
	local pad = math.max(0, needed_height - node._base_size[2])

	if node._extra_pad == pad then
		return
	end

	node.size[2] = node._base_size[2] + pad
	node.position[2] = node._base_pos_y
	node._extra_pad = pad
end

mod:hook(CLASS.MissionBoardView, "_update_location_circumstance", function(func, self, ...)
	func(self, ...)
	ensure_padding(self)
end)

mod:hook_safe(CLASS.MissionBoardView, "update", function(self)
	ensure_padding(self)
end)
