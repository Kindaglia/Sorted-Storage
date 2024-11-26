-- Ottieni il percorso del modulo
local modpath = minetest.get_modpath("voxelcube")

-- Registra il nodo "Sorted Chest"
minetest.register_node("voxelcube:sorted_chest", {
    description = "Dark Chest",
    tiles = {"sorted_chest_front.png"},
    drawtype = "nodebox",
    paramtype = "light",
    paramtype2 = "facedir",
    is_ground_content = true,
    groups = {cracky = 3},
})

-- Registra la ricetta di crafting
minetest.register_craft({
    output = "voxelcube:sorted_chest",  -- Output del crafting
    recipe = {
        {"", "", ""},      -- Riga superiore
        {"mcl_barrels:barrel_closed", "mesecons:redstone", "mcl_barrels:barrel_closed"},  -- Riga centrale
        {"", "", ""},      -- Riga inferiore
    },
})

-- Carica il file chest.lua
dofile(modpath.."/chest.lua")
