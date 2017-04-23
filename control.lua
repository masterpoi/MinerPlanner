buttons = {}
entity_selections = {
    belt = "transport-belt",
    miner = "electric-mining-drill",
    pole = "small-electric-pole"
}
new_selections = {
    belt = "transport-belt",
    miner = "electric-mining-drill",
    pole = "small-electric-pole"
}
deconstruction = true
research_only = false
ghosts = true
active_direction = "left"

function remote_on_player_selected_area(event, alt)
	if (event.item == "remote-control") then
    	local player = game.players[event.player_index]
        -- select
	    remote_deselect_units(player)
	    local area = event.area
	    -- non-zero
	    area.left_top.x = area.left_top.x - 0.01
	    area.left_top.y = area.left_top.y - 0.01
	    area.right_bottom.x = area.right_bottom.x + 0.01
		area.right_bottom.y = area.right_bottom.y + 0.01
		local select_entities = player.surface.find_entities_filtered{
			area = area,
			type = "resource",
			fores = player.force
		}
		local data = {}
        global.player_selected_units[player.index] = data
        
        
		local item_found = false
        for _, entity in pairs(select_entities) do
            if not string.match(entity.name, "oil") and not string.match(entity.name, "water") then --skip oil and water patches
                item_found = true
                if not data[entity.name] then
                    data[entity.name] = {amount = 0, entities={}}
                end
                data[entity.name].amount = data[entity.name].amount  + entity.amount
                table.insert(data[entity.name].entities,entity)
            end
	    
		end

        for name, itemdata in pairs(data) do
            
            local boudingbox =   {{2000000,2000000},{-2000000,-2000000}} -- lefttop, rightbottom
            itemdata.area = boudingbox
            game.print(name)
            for _, entity in pairs(itemdata.entities) do                 
                extend_bounding_box(entity.position, boudingbox)
            end

        end

        

		if item_found then
			remote_show_gui(player)
		end
	end
end

function extend_bounding_box(point, box)
    if point.x < box[1][1] then box[1][1] = math.floor(point.x) end
    if point.y < box[1][2] then box[1][2] = math.floor(point.y) end
    if point.x > box[2][1] then box[2][1] = math.ceil(point.x) end
    if point.y > box[2][2] then box[2][2] = math.ceil(point.y) end
end

function remote_on_player_cursor_stack_changed(event)
	local player = game.players[event.player_index]
	if player.cursor_stack and player.cursor_stack.valid and player.cursor_stack.valid_for_read then
		if player.cursor_stack.name == "unit-remote-control" then
			--
		else
			remote_deselect_units(player)
		end
	else
		remote_deselect_units(player)
	end
end

function remote_deselect_units(player) 
	remote_hide_gui(player)
	if not global.player_selected_units then
		global.player_selected_units = {}
	-- elseif global.player_selected_units[player.index] then 
	-- 	local selected_units = global.player_selected_units[player.index]
	-- 	for unit_id, selected_unit in pairs(selected_units) do
	-- 		if selected_unit.selection and selected_unit.selection.valid then
	-- 			selected_unit.selection.destroy()
	-- 			selected_unit.selection = nil
	-- 		end	
	-- 		selected_units[unit_id] = nil
	-- 	end
	-- 	global.player_selected_units[player.index] = nil
    end
end

function remote_on_init()
    global.player_selected_units = {}
end
function is_item_researched(player,item)
    for _, recipe in pairs(player.force.recipes) do
        for _2, product in pairs(recipe.products) do        
            if (product.name == item.name) then             
                --game.print("found matching recipe for item " .. item.name .. ":" .. recipe.name)
                return recipe.enabled
            end            
        end
    end
    return false
end
function is_entity_researched(player, entity) 
    for key, proto in pairs(entity.items_to_place_this ) do
        if is_item_researched(player , proto) then return true end
    end
    -- for _, proto in pairs(game.item_prototypes) do
    --     if (proto.place_result == entity) then
    --         return is_item_researched(player, proto)
            
    --     end
    -- end
    return false
end

function show_picker(key, player, items)
  if player.gui.center[key .. "_picker"] == nil then
        new_selections[key] = entity_selections[key]
        local frame = player.gui.center.add { type = "frame", name = key .. "_picker" , direction=vertical}
        local vflow = frame.add {
            type="flow",
            direction = "vertical",
            name="container"
        }
        local selection_flow = vflow.add {
            type="flow",
            direction = "horizontal",
            name = "selection"
        }
        local selected_belt = selection_flow.add {
            type= "sprite-button",
            style = "square-button",
            name = "selected_" .. key,
            sprite = "item/" .. entity_selections[key]
        }
        local pick = selection_flow.add {
            type = "button",
            caption = "Pick",
            name ="pick_"..key.."_button"
        }
    
        
        local grid = vflow.add {
            type="table",
            colspan = #items,
            name= key .. "-table"
        }
        for i = 1, #items do
            grid.add {
                type= "sprite-button",
                style= "square-button",
                name =  key .. "type_" .. items[i],
                sprite = "item/" .. items[i],
                tooltip = items[i]
            }
            
            
        end
        

    end
end
function show_belt_picker(player)
        local items = {}
        for key, proto in pairs(game.entity_prototypes)  do
            if proto.belt_speed and not proto.underground_belt_distance and not string.match(key, "splitter") and not string.match(key,"loader") then
                if not research_only or is_entity_researched(player, proto) then
                    table.insert(items, key)
                end
            end
        end

        show_picker("belt", player, items)
end
function show_miner_picker(player)
        local items = {}
        for key, proto in pairs(game.entity_prototypes)  do
            if  proto.mining_drill_radius and not string.match(key, "pumpjack") and not string.match(key, "water")  then
                if not research_only or  is_entity_researched(player, proto) then
                    table.insert(items, key)
                end
            end
        end

        show_picker("miner", player, items)
end

function show_pole_picker(player)
        local items = {}
        local metaRep = player.force.recipes["mp-meta"]

        for _, item in pairs(metaRep.ingredients) do   
            local iname = item["name"]
            if not research_only or is_entity_researched(player, game.entity_prototypes[iname]) then
                table.insert(items, iname)
            end
        end
        show_picker("pole", player, items)
end
function update_selections(player) 
    local ui = player.gui.left.remote_selected_units
    if ui  then 
        ui.entity_type_picker.change_belt_button.sprite = "item/" .. entity_selections.belt
        ui.entity_type_picker.change_belt_button.tooltip = entity_selections.belt
        ui.entity_type_picker.change_pole_button.sprite = "item/" .. entity_selections.pole
        ui.entity_type_picker.change_pole_button.tooltip = entity_selections.pole
        ui.entity_type_picker.change_miner_button.sprite = "item/" .. entity_selections.miner
        ui.entity_type_picker.change_miner_button.tooltip = entity_selections.miner
    end
end

function remote_show_gui(player)
	if player.gui.left.remote_selected_units == nil then
		
		local remote_selected_units = player.gui.left.add{type = "frame", name = "remote_selected_units", caption = {"text-remote-selected-units"}, direction = "vertical"}
        remote_selected_units.add {
            type = "checkbox",
            caption = "Deconstruct selection",
            state = deconstruction ,
            name="deconstruction_button"
        }
        local direction_picker = remote_selected_units.add {
            type="flow",
            direction="horizontal",
            name="directionpicker"
        }
        buttons = {}
        local topButton = direction_picker.add {
            type = "radiobutton",
            name = "top",          
            caption = "Top",
            state = active_direction == "top"  
        }
        table.insert(buttons,topButton)
        local leftButton = direction_picker.add {
            type = "radiobutton",
            name = "left",
            caption = "Left",
            state = active_direction == "left"             
        }
        table.insert(buttons, leftButton)
        local rightButton = direction_picker.add {
            type = "radiobutton",
            name = "right",
            caption = "Right",
            state = active_direction == "right"            
        }
        table.insert(buttons, rightButton)

        local bottomButton = direction_picker.add {
            type = "radiobutton",
            name = "bottom",
            caption = "Bottom",
            state = active_direction == "bottom"            
        }
        table.insert(buttons, bottomButton)

        local entity_type_picker = remote_selected_units.add {
            type="flow",
            direction="horizontal",
            name="entity_type_picker"
        }

        local pick = entity_type_picker.add {
            type = "sprite-button",            
            name = "change_belt_button",
            style = "square-button"         
        }

        
        local pick = entity_type_picker.add {
            type = "sprite-button",            
            name = "change_miner_button",
            style = "square-button"
         
        }

        local pick = entity_type_picker.add {
            type = "sprite-button",            
            name = "change_pole_button",
            style = "square-button"
         
        }

        update_selections(player)


        for resource_name, selected_unit in pairs(global.player_selected_units[player.index]) do
            local amount = selected_unit.amount
            local unit_button = remote_selected_units.add{
					type = "button",
					name = resource_name, 
					style = "resource-button-fixed"}
            local unit_button_flow = unit_button.add{
					type = "flow",
					name = "flow", 
					direction = "horizontal"}
            unit_button_flow.add{
			        type = "sprite",					
					sprite = "item/".. resource_name}
            -- unit_button_flow.add{
			-- 		type = "label",
			-- 		name = "resource-name", 
			-- 		caption=resource_name,
			-- 		style="unit-button-label"
			-- 		}
             unit_button_flow.add{
					type = "label",
					name = "resource-amount", 
					caption=amount,
					style="button-label"
					}
       


        end

    end
end
function resource_in_area(surface, position, entity_bounds, type)
    local result = surface.find_entities_filtered {
        area = {
            { position[1] + entity_bounds.left_top.x , position[2]  +entity_bounds.left_top.y },
            { position[1] + entity_bounds.right_bottom.x , position[2]  +entity_bounds.right_bottom.y },
        },
        name = type
    }

    return #result > 0
end

function create_entity(entity_type, resource_type, position, direction, bbox, player)
    local nauvis = game.surfaces.nauvis
    local entity 
    if ghosts then 
        entity = {name="entity-ghost",inner_name=entity_type, position = position, direction=direction, force = player.force }
    else 
        entity = {name=entity_type, position = position, direction=direction, force = player.force }
    end
                    
    if resource_in_area(nauvis, position, bbox, resource_type) and nauvis.can_place_entity (entity) then                
        nauvis.create_entity (entity)
    end
end
function create_miners(direction, area, type, player)


    local nauvis = game.surfaces.nauvis
    if deconstruction then
        nauvis.deconstruct_area { area = area, force = player.force}
    end
    local drill_type = entity_selections.miner
    local belt_type = entity_selections.belt
    local pole_type = entity_selections.pole
    local right = 3
    local top = 1
    local bottom = 5
    local left = 7
    local belt_dir="top"
    local nudge = 0.5
    local line_space = 0    
    local bbox = game.entity_prototypes[drill_type].selection_box
    local size = math.ceil(bbox.right_bottom.x - bbox.left_top.x)
    local item_run = size + line_space
    local column_run = size + 1
    local metaRep = player.force.recipes["mp-meta"]
    local pole_spacing = 1
    for _, item in pairs(metaRep.ingredients) do   
            local iname = item["name"]
            if iname == pole_type then
                pole_spacing = math.ceil( item["amount"]  * 2 / 10 )
            end
    end
    if direction == "left" then belt_dir=left end
    if direction == "right" then belt_dir=right end
    if direction == "top" then belt_dir=top end
    if direction == "bottom" then belt_dir=bottom end

    local flip = false
    if (direction == "left" or direction == "right") then -- horizontal
        for y = area[1][2] + 1 + nudge, area[2][2] + nudge, column_run do
            for x = area[1][1] + 1 + nudge ,area[2][1] + nudge, item_run do
                local position = {x, y}
                local dir = bottom
                if flip then dir = top end
                create_entity(drill_type, type, position, dir, bbox, player)                
            end     
            if not flip then 
                for x = area[1][1] + 1 + nudge ,area[2][1] + nudge, 1 do  
                    local position = {x, y + 2}
                    create_entity(belt_type, type, position, belt_dir, bbox, player)
             
                end
            else 
                for x = area[1][1] + 1 + nudge ,area[2][1] + nudge, pole_spacing do  
                    local position = {x, y + 2}
                    create_entity(pole_type, type, position, nil, bbox, player)
                end
            end
            flip = not flip
        end
    else  -- vertical
        flip = false
        for x = area[1][1] + 1 + nudge, area[2][1] + nudge, column_run do
            for y = area[1][2] + 1 + nudge ,area[2][2] + nudge, item_run do
                local position = {x, y}
                local dir = right
                if flip then dir = left end
                create_entity(drill_type, type, position, dir, bbox, player)
            end     
            if not flip then 
                for y = area[1][2] + 1 + nudge ,area[2][2] + nudge, 1 do  
                    local position = {x + 2, y }                    
                    create_entity(belt_type, type, position, belt_dir, bbox, player)
                end
            else 
                for y = area[1][2] + 1 + nudge ,area[2][2] + nudge, pole_spacing do  
                    local position = {x + 2, y }                    
                    create_entity(pole_type, type, position, nil, bbox, player)
                end
            end
            flip = not flip
        end
    end

end

function remote_on_gui_click(event)
	local player_index = event.player_index
    local ui = game.players[player_index].gui.left.remote_selected_units
	if ui ~= nil then -- avoid looping if menu is closed
		
        
        local player = game.players[player_index]
        if event.element.name == "deconstruction_button" then
            deconstruction = not deconstruction
            ui.deconstruction_button.state = deconstruction
        end
        if event.element.name == "change_belt_button" then
            hide_picker_guis(player)
            show_belt_picker(player)
        end
        if event.element.name == "change_pole_button" then
            hide_picker_guis(player)
            show_pole_picker(player)
        end
        if event.element.name == "change_miner_button" then
            hide_picker_guis(player)
            show_miner_picker(player)
        end

        local types = { "belt", "pole", "miner"}

        for i = 1, #types do
            local type = types[i]
            if  string.match( event.element.name, type .. "type_") then
                local selection =  player.gui.center[type .. "_picker"].container.selection
                new_selections[type] = string.gsub(event.element.name, type .. "type_" ,"")
                selection["selected_" .. type].sprite = "item/" .. new_selections[type]
            end

            if event.element.name == "pick_" .. type .. "_button" then
                entity_selections[type] = new_selections[type]
                update_selections(player)
                player.gui.center[type .. "_picker"].destroy()
                return
            end
        end
        if event.element.parent.name == "directionpicker" then
            
            active_direction = event.element.name
            for n,item in pairs(buttons) do                
                item.state = item == event.element
            end

        end
		if event.element.parent.name == "remote_selected_units" then
            local item_type = event.element.name
            
			if (event.element.type == "button") then             
                create_miners( active_direction, global.player_selected_units[player.index][item_type].area, item_type, player)   
            end
		end
	end
end
function remote_hide_gui(player)
	if player.gui.left.remote_selected_units ~= nil then
		player.gui.left.remote_selected_units.destroy()
	end
    hide_picker_guis(player)
end

function hide_picker_guis(player)
    if player.gui.center.belt_picker ~= nil then
        player.gui.center.belt_picker.destroy()
    end
    if player.gui.center.pole_picker ~= nil then
        player.gui.center.pole_picker.destroy()
    end
    if player.gui.center.miner_picker ~= nil then
        player.gui.center.miner_picker.destroy()
    end

end


local function on_player_selected_area(event)
	remote_on_player_selected_area(event, false)
end

local function on_player_alt_selected_area(event)
	remote_on_player_selected_area(event, true)
end
local function on_player_cursor_stack_changed(event)
	remote_on_player_cursor_stack_changed(event, true)
end
local function on_init()
   remote_on_init() 
end
local function on_gui_click(event)
	remote_on_gui_click(event)
end
script.on_event(defines.events.on_player_selected_area, on_player_selected_area)
script.on_event(defines.events.on_player_alt_selected_area, on_player_alt_selected_area)
script.on_event(defines.events.on_player_cursor_stack_changed, on_player_cursor_stack_changed)
script.on_event(defines.events.on_gui_click, on_gui_click)

script.on_init(on_init)