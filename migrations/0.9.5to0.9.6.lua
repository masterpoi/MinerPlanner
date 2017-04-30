for _,f in pairs(game.forces) do
    f.recipes["remote-control"].enabled=f.technologies["miner-planner-tech"].researched    
end