function layout_chests(player, direction, drill_type, belt_type, pole_type, resource_type, chest_type, area) 


    game.print (drill_type .. " chests")
    local right = 3
    local top = 1
    local bottom = 5
    local left = 7
    local undeground_belt_type = string.gsub(belt_type, "transport", "underground")
    local metaRep = player.force.recipes["mp-meta"]
    local pole_spacing = 1
    local belt_dir=top
    local reverse_belt_dir=bottom
    local nudge = 0.5
    local line_space = 0    
    for _, item in pairs(metaRep.ingredients) do   
            local iname = item["name"]
            if iname == pole_type then
                pole_spacing = math.ceil(item["amount"]  * 2 / 10)
            end
    end
    if direction == "left" then 
        belt_dir=left 
        reverse_belt_dir = right
    end
    if direction == "right" then 
        belt_dir=right 
        reverse_belt_dir = left
    end
    if direction == "top" then 
        belt_dir=top 
        reverse_belt_dir = bottom
    end
    if direction == "bottom" then 
        belt_dir=bottom 
        reverse_belt_dir = top
    end

    local flip = false
       local bbox = game.entity_prototypes[drill_type].selection_box
    local size = math.ceil(bbox.right_bottom.x - bbox.left_top.x)
    local item_run = 1
    local column_run =  1+2* size
    if spacing_mode == "tight" then
        item_run = size + line_space        
        pole_spacing = math.ceil(pole_spacing / item_run) * item_run
    end

    if spacing_mode == "optimal" then
        item_run = game.entity_prototypes[drill_type].mining_drill_radius * 2
        pole_spacing = math.floor(pole_spacing / item_run) * item_run
    end
    

    if (direction == "left" or direction == "right") then -- horizontal
        for y = area[1][2] + 1 + nudge, area[2][2] + nudge, column_run do
            
            for x = area[1][1] + 1 + nudge ,area[2][1] + nudge, item_run do
                local position = { x, y }
                create_entity(drill_type, resource_type, position, bottom, bbox, player)                
                position = { x, y + size +1 }
                create_entity(drill_type, resource_type, position, top, bbox, player)                
                position = { x  , y + 2 }                    
                create_entity(chest_type, resource_type, position, nil , bbox, player)
            end    
            for x = area[1][1] + 1 + nudge, area[2][1] + nudge, pole_spacing do  
                    local position = { x + 1, y + 2 }
                    create_entity(pole_type, resource_type, position, nil, bbox, player)
                    
                   
            end            
        end
    else  -- vertical
        flip = false
        for x = area[1][1] + 1 + nudge, area[2][1] + nudge, column_run do
            for y = area[1][2] + 1 + nudge ,area[2][2] + nudge, item_run do
                local position = { x, y }
                create_entity(drill_type, resource_type, position, right, bbox, player)                
                position = { x + size +1 , y}
                create_entity(drill_type, resource_type, position, left, bbox, player)    
                position = { x + 2  , y }                    
                create_entity(chest_type, resource_type, position, nil , bbox, player)
            end
            for y = area[1][2] + 1 + nudge ,area[2][2] + nudge, pole_spacing do
                    local position = { x + 2, y + 1 }
                    create_entity(pole_type, resource_type, position, nil, bbox, player)
                    
                
            end
        end
    end
end
