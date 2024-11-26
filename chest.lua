local sorting_icon = "icon_sorting.png"  -- Sorting icon

local formspec_sorted_chest = "size[9,12.5]"..  -- Formspec size adjusted for larger inventory
    "label[0,0;"..minetest.formspec_escape(minetest.colorize("#313131", "Sorted Chest")).."]"..
    "image_button[8.1,0;0.75,0.75;"..sorting_icon..";sort_inventory;]"..  -- Button with sorting icon (larger and placed higher)
    "list[current_name;main;0,0.8;9,6;]"..  -- Inventory list (9 columns, 6 rows)
    mcl_formspec.get_itemslot_bg(0,0.8,9,6)..  -- Add background for the node inventory slots
    "label[0,7.0;"..minetest.formspec_escape(minetest.colorize("#313131", "Inventory")).."]"..
    "list[current_player;main;0,7.5;9,3;9]"..
    mcl_formspec.get_itemslot_bg(0,7.5,9,3)..  -- Add background for the player's inventory slots
    "list[current_player;main;0,10.74;9,1;]"..
    mcl_formspec.get_itemslot_bg(0,10.74,9,1)..  -- Add background for the final row of the player's inventory
    "listring[current_name;main]"..  -- Link the node inventory
    "listring[current_player;main]"  -- Link the player's inventory
    minetest.register_node("sortedstorage:sorted_chest", {
        description = "Sorted Chest",
        tiles = {
            "sorted_chest_up.png",          -- Top
            "sorted_chest_side.png",  -- Bottom
            "sorted_chest_side.png",  -- Right
            "sorted_chest_side.png",  -- Left
            "sorted_chest_side.png",  -- Back
            "sorted_chest_front.png",  -- Front
        },
        drawtype = "nodebox",
        paramtype = "light",
        paramtype2 = "facedir",
        is_ground_content = false,
        groups = { handy = 1, axey = 1, deco_block = 1, material_wood = 1, flammable = -1 },
        _mcl_hardness = 5,  -- Durezza maggiore per una rottura più lenta
        _mcl_blast_resistance = 3,  -- Resistenza alle esplosioni
        node_box = {
            type = "fixed",
            fixed = {
                {-0.5, -0.5, -0.5,  0.5,  0.5,  0.5}, -- Full block
            },
        },
    
        -- on_construct function to initialize the inventory
        on_construct = function(pos)
            local meta = minetest.get_meta(pos)
            local inv = meta:get_inventory()
    
            -- Define the inventory (9 columns, 6 rows)
            inv:set_size("main", 9 * 6)  -- 9 columns, 6 rows for the Sorted Chest
    
            -- Set the formspec
            meta:set_string("formspec", formspec_sorted_chest)
            
            -- Set the informational text for the node
            meta:set_string("infotext", "Sorted Chest")
        end,
    
        -- Function to handle right-click
        on_rightclick = function(pos, node, player, itemstack, pointed_thing)
            local meta = minetest.get_meta(pos)
    
            -- Play the sound when the chest is opened
            minetest.sound_play("open_sorted_chest", {
                pos = pos,
                gain = 1.0,  -- Volume adjustment
                max_hear_distance = 16,  -- Maximum distance the sound can be heard
            })
    
            -- Show the inventory formspec
            minetest.show_formspec(player:get_player_name(), "sortedstorage:sorted_chest_"..minetest.pos_to_string(pos), meta:get_string("formspec"))
        end,
    
        -- Function to allow destruction only if the inventory is empty
        can_dig = function(pos, player)
            local meta = minetest.get_meta(pos)
            local inv = meta:get_inventory()
            return inv:is_empty("main") -- Allow digging only if the inventory is empty
        end,
    })
    

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname:match("^sortedstorage:sorted_chest_") then
        if fields.sort_inventory then
            local player_name = player:get_player_name()
            local pos = minetest.string_to_pos(formname:match("sorted_chest_(.+)"))
            if not pos then
                minetest.chat_send_player(player_name, "Error: Position not found.")
                return
            end

            local meta = minetest.get_meta(pos)
            local inv = meta:get_inventory()

            -- Get all items from the chest
            local items = inv:get_list("main")

            -- Table for grouping and managing stacking
            local grouped_items = {}

            for _, stack in ipairs(items) do
                if not stack:is_empty() then
                    local item_name = stack:get_name()
                    local stack_max = stack:get_stack_max()  -- Get the maximum stack size for the item
                    local count = stack:get_count()

                    -- Handle stacking
                    while count > 0 do
                        local added = false
                        for _, grouped_stack in ipairs(grouped_items) do
                            if grouped_stack:get_name() == item_name and grouped_stack:get_count() < stack_max then
                                local space_left = stack_max - grouped_stack:get_count()
                                local to_add = math.min(space_left, count)
                                grouped_stack:set_count(grouped_stack:get_count() + to_add)
                                count = count - to_add
                                added = true
                                break
                            end
                        end

                        if not added then
                            -- Create a new slot if adding is not possible
                            local new_stack = ItemStack(item_name)
                            local to_add = math.min(stack_max, count)
                            new_stack:set_count(to_add)
                            table.insert(grouped_items, new_stack)
                            count = count - to_add
                        end
                    end
                end
            end

            -- Sort items by name
            table.sort(grouped_items, function(a, b)
                return a:get_name() < b:get_name()
            end)

            -- Fill the inventory with sorted items and empty slots
            for i = 1, #items do
                items[i] = grouped_items[i] or ""
            end
            inv:set_list("main", items)

            -- Notify player of completion
            minetest.chat_send_player(player_name, "The items in the Sorted Chest have been sorted and grouped by name!")
        end
    end
end)