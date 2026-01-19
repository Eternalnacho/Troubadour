SMODS.Atlas({
  key = "modicon",
  path = "icon.png",
  px = 46,
  py = 46
})

for _, mod in pairs(SMODS.Mods) do
  local icon_names = {"icon", "modicon", "mod_icon"}
  if mod.prefix then
    icon_names[#icon_names+1] = mod.prefix..'_icon'
    icon_names[#icon_names+1] = mod.prefix..'icon'
    icon_names[#icon_names+1] = mod.prefix..'_modicon'
    icon_names[#icon_names+1] = mod.prefix..'modicon'
    icon_names[#icon_names+1] = mod.prefix..'_mod_icon'
    icon_names[#icon_names+1] = mod.prefix..'mod_icon'
  end

  if mod.disabled then
    for _, file_path in pairs(icon_names) do
      local full_path = mod.path .. 'assets/' .. G.SETTINGS.GRAPHICS.texture_scaling .. 'x/' .. file_path .. '.png'
      local file_data, error = NFS.newFileData(full_path)
      if not error then
        print("File location found: "..full_path)
        local image_data = assert(love.image.newImageData(file_data),
                ('Failed to initialize image data for Atlas %s'):format(file_path))
        local px, py = image_data:getDimensions()
        local is_animated, frames
        px, py = px / G.SETTINGS.GRAPHICS.texture_scaling, py / G.SETTINGS.GRAPHICS.texture_scaling
        if px > py * 2 - 1 then -- If there's room for 2 frames, assume it's animated
          is_animated = true
          frames = math.floor(px / py)
          px = py
        end

        SMODS.Atlas({
          key = 'TRO_' .. mod.id ..'_modicon',
          path = file_path..'.png',
          px = px,
          py = py,
          prefix_config = {key = {mod = false}},
          atlas_table = is_animated and "ANIMATION_ATLAS",
          frames = is_animated and frames
        }).mod = mod
      end
    end
  end
end