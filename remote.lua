data:extend({
	{
		type = "recipe",
		name = "remote-control",
		category = "crafting",
		enabled = true,
		energy_required = 2,
		ingredients =
		{
		  {type="item", name="electronic-circuit", amount=5}
		},
		results=
		{
		  {type="item", name="remote-control", amount=1},
		},
	},
    {
		type = "selection-tool",
		name = "remote-control",
		icon = "__Miner_Planner__/graphics/icons/electric-mining-drill.png",
		flags = {"goes-to-quickbar"},
		subgroup = "tool",
		order = "c[automated-construction]-e[remote-control]",
		stack_size = 1,
		stackable = false,
		selection_color = {r = 0.3, g = 0.9, b = 0.3},
		alt_selection_color = {r = 0.3, g = 0.3, b = 0.9},
		selection_mode = {"tiles", "matches-force"},
		alt_selection_mode = {"tiles", "matches-force"},
		selection_cursor_box_type = "not-allowed",
		alt_selection_cursor_box_type = "not-allowed"
	}

})