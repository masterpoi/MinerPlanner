require("remote");
require("styles");


function copyPrototype(type, name, newName, change_results)
  if not data.raw[type][name] then error("type "..type.." "..name.." doesn't exist") end
  local p = table.deepcopy(data.raw[type][name])
  p.name = newName
  if p.minable and p.minable.result then
    p.minable.result = newName
  end
  if change_results then
    if p.place_result then
      p.place_result = newName
    end
    if p.result then
      p.result = newName
    end
    if p.take_result then
      p.take_result = newName
    end
    if p.placed_as_equipment_result then
      p.placed_as_equipment_result = newName
    end
  end
  return p
end

local metarecipe = copyPrototype("recipe", "science-pack-1", "mp-meta")
metarecipe.ingredients = {}
metarecipe.enabled = false
metarecipe.hidden = true

local vanilla = {["small-electric-pole"]=true, ["medium-electric-pole"]=true, ["big-electric-pole"]=true, ["substation"]=true}

for name, _ in pairs(vanilla) do
  table.insert(metarecipe.ingredients, {name, data.raw["electric-pole"][name].supply_area_distance*10})
end

for _, ent in pairs(data.raw["electric-pole"]) do
  if ent.minable and ent.supply_area_distance and ent.supply_area_distance > 0 and not vanilla[ent.name] then
    local item_name = false
    local item = data.raw["item"][ent.name]
    if item and item.place_result and item.place_result == ent.name then
      item_name = ent.name
    else
      -- item and entity name don't match
      --check if mining result matches an item that has entity as place result
      if ent.minable.result and type(ent.minable.result) == "string" then
        local result = data.raw["item"][ent.minable.result]
        if result and result.place_result and result.place_result == ent.name then
          item_name = result.place_result
        else
          --assume it's some proxy item, don't add it
          item_name = false
          log("MP: No item found for pole: "..ent.name)
        end
      end
    end
    if item_name then
      table.insert(metarecipe.ingredients, {item_name, ent.supply_area_distance*10})
    end
  end
end

data:extend({metarecipe})