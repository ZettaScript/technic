-- POWER MONITOR
-- The power monitor can be used to monitor how much power is available on a network,
-- similarly to the old "slave" switching stations.

local S = technic.getter

minetest.register_craft({
	output = "technic:power_monitor",
	recipe = {
		{"",                 "",                       ""},
		{"",                 "technic:machine_casing", "default:copper_ingot"},
		{"technic:lv_cable", "technic:lv_cable",       "technic:lv_cable"}
	}
})

minetest.register_node("technic:power_monitor",{
	description = S("Power Monitor"),
	tiles  = {"technic_water_mill_top_active.png", "technic_water_mill_top_active.png",
                  "technic_water_mill_top_active.png", "technic_water_mill_top_active.png",
	          "technic_water_mill_top_active.png", "technic_water_mill_top_active.png"},
	groups = {snappy=2, choppy=2, oddly_breakable_by_hand=2, technic_all_tiers=1, technic_machine=1},
	connect_sides = {"bottom"},
	sounds = default.node_sound_wood_defaults(),
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", S("Power Monitor"))
	end,
})

minetest.register_abm({
	nodenames = {"technic:power_monitor"},
	label = "Power Monitor",
	interval   = 1,
	chance     = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local meta = minetest.get_meta(pos)
		local network_hash = technic.cables[minetest.hash_node_position(pos)]
		local network = network_hash and minetest.get_position_from_hash(network_hash)
		local sw_pos = network and {x=network.x,y=network.y+1,z=network.z}
		local timeout = 0
		for tier in pairs(technic.machines) do
			timeout = math.max(meta:get_int(tier.."_EU_timeout"),timeout)
		end
		if timeout > 0 and sw_pos and minetest.get_node(sw_pos).name == "technic:switching_station" then
			local sw_meta = minetest.get_meta(sw_pos)
			local supply = sw_meta:get_int("supply")
			local demand = sw_meta:get_int("demand")
			meta:set_string("infotext",
					S("Power Monitor. Supply: @1 Demand: @2",
					technic.pretty_num(supply), technic.pretty_num(demand)))
		else
			meta:set_string("infotext",S("Power Monitor Has No Network"))
		end
	end,
})

for tier in pairs(technic.machines) do
	-- RE in order to use the "timeout" functions, although it consumes 0 power
	technic.register_machine(tier, "technic:power_monitor", "RE")
end

