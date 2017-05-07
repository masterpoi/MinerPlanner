require("layouts/default")
require("layouts/interleaved")
require("layouts/chests")

black_list = { "extractor", "underground", "factory.port.marker","vehicle.miner.*attachment", "splitter", "loader", "pumpjack", "water", "factory.connection", "dummy"}
buttons = {}
mode_buttons = {}
layout_buttons = {}
entity_selections = {
    belt = "transport-belt",
    miner = "electric-mining-drill",
    pole = "small-electric-pole",
    chest = "iron-chest"
}
new_selections = {
    belt = "transport-belt",
    miner = "electric-mining-drill",
    pole = "small-electric-pole",
    chest = "iron-chest"
}
deconstruction = true
research_only = false
ghosts = true
active_direction = "left"
spacing_mode = "tight"
layout_strategy = "default"

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
        data["all"] = { amount = 0, entities = {}}
        
		local item_found = false
        for _, entity in pairs(select_entities) do
            if not string.match(entity.name, "oil") and not string.match(entity.name, "water") then --skip oil and water patches
                item_found = true
                if not data[entity.name] then
                    data[entity.name] = {amount = 0, entities={}}
                end
                data[entity.name].amount = data[entity.name].amount  + entity.amount
                data["all"].amount = data["all"].amount + entity.amount
                table.insert(data[entity.name].entities,entity)
                table.insert(data["all"].entities, entity)
            end
	    
		end

        for name, itemdata in pairs(data) do
            
            local boudingbox =   {{2000000,2000000},{-2000000,-2000000}} -- lefttop, rightbottom
            itemdata.area = boudingbox
            
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
		if player.cursor_stack.name == "remote-control" then
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
    end
end

function remote_on_init()
    global.player_selected_units = {}
end
function is_item_researched(player,item)
    for _, recipe in pairs(player.force.recipes) do
        for _2, product in pairs(recipe.products) do        
            if (product.name == item.name) then                             
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
        
function is_blacklisted(key)     
    for i=1, #black_list do
        local filter = black_list[i]
        if string.match(key, filter) then
             return true
        end
    end

    return false
end
function show_belt_picker(player)
        local items = {}
        for key, proto in pairs(game.entity_prototypes)  do
            if proto.belt_speed then
                if not is_blacklisted(key) and (not research_only or is_entity_researched(player, proto)) then
                    table.insert(items, key)
                end
            end
        end

        show_picker("belt", player, items)
end
function show_miner_picker(player)

        local items = {}
        for key, proto in pairs(game.entity_prototypes)  do
            if  proto.mining_drill_radius  then
       
                if not is_blacklisted(key) and ( not research_only or  is_entity_researched(player, proto)) then
                    table.insert(items, key)
                end
            end
        end

        show_picker("miner", player, items)
end

function show_chest_picker(player)
        local items = {}
        for key, proto in pairs(game.entity_prototypes)  do
            if  string.match(key, "chest")  then
       
                if not is_blacklisted(key) and ( not research_only or  is_entity_researched(player, proto)) then
                    table.insert(items, key)
                end
            end
        end

        show_picker("chest", player, items)
end

function show_pole_picker(player)
        local items = {}
        local metaRep = player.force.recipes["mp-meta"]

        for _, item in pairs(metaRep.ingredients) do   
            local iname = item["name"]
            if not is_blacklisted(iname) and (not research_only or is_entity_researched(player, game.entity_prototypes[iname])) then
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
        ui.entity_type_picker.change_chest_button.sprite = "item/" .. entity_selections.chest
        ui.entity_type_picker.change_chest_button.tooltip = entity_selections.chest
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
        local mode_picker = remote_selected_units.add {
            type="flow",
            direction="horizontal",
            name="mode_picker"
        }
        mode_picker.add { 
            type = "label",
            caption = "Positioning"
        }

        local tight = mode_picker.add {
            type = "radiobutton",
            name = "mode_tight",          
            caption = "Tight",
            state = spacing_mode == "tight"  
        }

        local optimal = mode_picker.add {
            type = "radiobutton",
            name = "mode_optimal",          
            caption = "Spread out",
            state = spacing_mode == "optimal"  
        }

        mode_buttons = {}
        table.insert(mode_buttons, tight)
        table.insert(mode_buttons, optimal)

        local layout_picker = remote_selected_units.add {
            type="flow",
            direction="horizontal",
            name="layout_picker"
        }
        layout_picker.add { 
            type = "label",
            caption = "Layout"
        }

        local default = layout_picker.add {
            type = "radiobutton",
            name = "layout_default",          
            caption = "Default",
            state = layout_strategy == "default"
        }

        local interleaved = layout_picker.add {
            type = "radiobutton",
            name = "layout_interleaved",          
            caption = "Interleaved",
            state = layout_strategy == "interleaved"
        }


        local chests = layout_picker.add {
            type = "radiobutton",
            name = "layout_chests",          
            caption = "Chests",
            state = layout_strategy == "chests"
        }


        

        layout_buttons = {}
        table.insert(layout_buttons, interleaved)
        table.insert(layout_buttons, default)
        table.insert(layout_buttons, chests)

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

        local pick = entity_type_picker.add {
            type = "sprite-button",            
            name = "change_chest_button",
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
            local icon_name = resource_name
            local infinite = false
            if (string.find( resource_name, "infinite")) then
                icon_name = string.gsub(resource_name, "infinite." , "")
                infinite = true
            end 
            if icon_name == "all" then
                unit_button_flow.add {
                        type = "label",                        
                        caption="all",
                        style="button-label"
                }
            else 
                unit_button_flow.add{
                        type = "sprite",					
                        sprite = "item/".. icon_name}
            end
            if infinite then
                amount = "infinite"
            end
       
            unit_button_flow.add {
                        type = "label",
                        name = "resource-amount", 
                        caption=amount,
                        style="button-label"
                }


        end

    end
end
function resource_in_area(surface, position, entity_bounds, type)
    
    if type == "all" then
        local result = surface.find_entities_filtered {
            area = {
                { position[1] + entity_bounds.left_top.x , position[2]  + entity_bounds.left_top.y },
                { position[1] + entity_bounds.right_bottom.x , position[2] + entity_bounds.right_bottom.y },
            },
            type = "resource"
        }
        
        return #result > 0
    end
    local result = surface.find_entities_filtered {
        area = {
            { position[1] + entity_bounds.left_top.x , position[2]  + entity_bounds.left_top.y },
            { position[1] + entity_bounds.right_bottom.x , position[2] + entity_bounds.right_bottom.y },
        },
        name = type
    }

    return #result > 0
end
function create_entity(entity_type, resource_type, position, direction, bbox, player)
    create_entity(entity_type, resource_type, position, direction, bbox, player, nil)
end
function create_entity(entity_type, resource_type, position, direction, bbox, player, type)
    local surface = player.surface
    local entity 
    if ghosts then 
        entity = { name = "entity-ghost", inner_name = entity_type, expires = false, position = position, direction = direction, force = player.force, type = type }
    else 
        entity = { name = entity_type, position = position, direction = direction, force = player.force , type = type}
    end
    -- if not surface.can_place_entity(entity) then
    --     game.print ("cannot place " .. entity_type .." at " .. position[1] .. "x" .. position[2])
    -- end -- and surface.can_place_entity (entity)
    if resource_in_area(surface, position, bbox, resource_type)  then                
        surface.create_entity (entity)
    end
end
function create_miners(direction, area, type, player)

    local surface = player.surface
    if deconstruction then
        surface.deconstruct_area { area = area, force = player.force}
    end
    local drill_type = entity_selections.miner
    local belt_type = entity_selections.belt
    local pole_type = entity_selections.pole   
    local chest_type = entity_selections.chest   

    if (layout_strategy == "default") then
        layout_default(player, direction, drill_type, belt_type, pole_type, type, area)
    end
    if (layout_strategy == "interleaved") then
        layout_interleaved(player, direction, drill_type, belt_type, pole_type, type, area)
    end
    if (layout_strategy == "chests") then
        layout_chests(player, direction, drill_type, belt_type, pole_type, type, chest_type, area)
    end
end




function remote_on_gui_click(event)
	local player_index = event.player_index
    local ui = game.players[player_index].gui.left.remote_selected_units
	if ui ~= nil then -- avoid looping if menu is closed
        
        local player = game.players[player_index]

        if event.element.parent.name == "mode_picker" then
            active_mode = event.element.name
            for n,item in pairs(mode_buttons) do                
                item.state = item == event.element
            end
            spacing_mode = string.gsub(event.element.name, "mode_", "")
        end
        if event.element.parent.name == "layout_picker" then
            active_mode = event.element.name
            for n,item in pairs(layout_buttons) do                
                item.state = item == event.element
            end
            layout_strategy = string.gsub(event.element.name, "layout_", "")
        end
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
          if event.element.name == "change_chest_button" then
            hide_picker_guis(player)
            show_chest_picker(player)
        end

        local types = { "belt", "pole", "miner", "chest"}

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