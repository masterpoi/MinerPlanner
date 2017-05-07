function layout_default(player, direction, drill_type, belt_type, pole_type, resource_type, area) 

    game.print (drill_type .. " default")
    local right = 3
    local top = 1
    local bottom = 5
    local left = 7

    local metaRep = player.force.recipes["mp-meta"]
    local pole_spacing = 1
    local belt_dir="top"
    local nudge = 0.5
    local line_space = 0    
    for _, item in pairs(metaRep.ingredients) do   
            local iname = item["name"]
            if iname == pole_type then
                pole_spacing = math.ceil(item["amount"]  * 2 / 10)
            end
    end
    if direction == "left" then belt_dir=left end
    if direction == "right" then belt_dir=right end
    if direction == "top" then belt_dir=top end
    if direction == "bottom" then belt_dir=bottom end

    local flip = false
    local bbox = game.entity_prototypes[drill_type].selection_box
    local size = math.ceil(bbox.right_bottom.x - bbox.left_top.x)
    local item_run = 1
    local column_run =  1+size
    if spacing_mode == "tight" then
        item_run = size + line_space        
    end

    if spacing_mode == "optimal" then
        item_run = game.entity_prototypes[drill_type].mining_drill_radius * 2
    end
    if (direction == "left" or direction == "right") then -- horizontal
        for y = area[1][2] + 1 + nudge, area[2][2] + nudge, column_run do
            for x = area[1][1] + 1 + nudge ,area[2][1] + nudge, item_run do
                local position = {x, y}
                local dir = bottom
                if flip then dir = top end
                create_entity(drill_type, resource_type, position, dir, bbox, player)                
            end     
            if not flip then 
                for x = area[1][1] + 1 + nudge ,area[2][1] + nudge, 1 do  
                    local position = { x, y + 2}
                    create_entity(belt_type, resource_type, position, belt_dir, bbox, player)             
                end
            else 
                for x = area[1][1] + 1 + nudge ,area[2][1] + nudge, pole_spacing do  
                    local position = { x, y + 2}
                    create_entity(pole_type,resource_type, position, nil, bbox, player)
                end
            end
            flip = not flip
        end
    else  -- vertical
        flip = false
        for x = area[1][1] + 1 + nudge, area[2][1] + nudge, column_run do
            for y = area[1][2] + 1 + nudge ,area[2][2] + nudge, item_run do
                local position = { x, y }
                local dir = right
                if flip then dir = left end
                create_entity(drill_type, resource_type, position, dir, bbox, player)
            end     
            if not flip then 
                for y = area[1][2] + 1 + nudge, area[2][2] + nudge, 1 do  
                    local position = { x + 2, y }                    
                    create_entity(belt_type, resource_type, position, belt_dir, bbox, player)
                end
            else 
                for y = area[1][2] + 1 + nudge ,area[2][2] + nudge, pole_spacing do  
                    local position = { x + 2, y }                    
                    create_entity(pole_type, resource_type, position, nil, bbox, player)
                end
            end
            flip = not flip
        end
    end
end