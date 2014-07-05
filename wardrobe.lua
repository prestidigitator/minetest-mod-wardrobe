local FORM_NAME = "wardrobe_wardrobeSkinForm";
local SKINS_PER_PAGE = 8;


local function showForm(player, page)
   local playerName = player:get_player_name();
   if not playerName or playerName == "" then return; end

   local n = #wardrobe.skins;
   if n <= 0 then return; end
   local nPages = math.ceil(n/SKINS_PER_PAGE);

   if not page or page > nPages then page = 1; end
   local s = 1 + SKINS_PER_PAGE*(page-1);
   local e = math.min(s+SKINS_PER_PAGE-1, n);

   local fs = "size[5,10]";
   fs = fs.."label[0,0;Change Into:]";
   for i = s, e do
      local slot = i-s+1;
      local skin = wardrobe.skins[i];
      local skinName = minetest.formspec_escape(wardrobe.skinNames[skin]);
      fs = fs.."button_exit[0,"..slot..";5,1;s:"..skin..";"..skinName.."]";
   end
   fs = fs.."label[2,9;Page "..page.."/"..nPages.."]";
   if page > 1 then
      fs = fs.."button_exit[0,9;1,1;n:p"..(page-1)..";prev]";
   end
   if page < nPages then
      fs = fs.."button_exit[4,9;1,1;n:p"..(page+1)..";next]";
   end

   minetest.show_formspec(playerName, FORM_NAME, fs);
end


minetest.register_on_player_receive_fields(
   function(player, formName, fields)
      if formName ~= FORM_NAME then return; end

      local playerName = player:get_player_name();
      if not playerName or playerName == "" then return; end

      for fieldName in pairs(fields) do
         if #fieldName > 2 then
            local action = string.sub(fieldName, 1, 1);
            local value = string.sub(fieldName, 3);

            if action == "n" then
               showForm(player, tonumber(string.sub(value, 2)));
               return;
            elseif action == "s" then
               wardrobe.changePlayerSkin(playerName, value);
               return;
            end
         end
      end
   end);


minetest.register_node(
   "wardrobe:wardrobe",
   {
      description = "Wardrobe",
      paramtype2 = "facedir",
      tiles = {
                 "wardrobe_wardrobe_topbottom.png",
                 "wardrobe_wardrobe_topbottom.png",
                 "wardrobe_wardrobe_sides.png",
                 "wardrobe_wardrobe_sides.png",
                 "wardrobe_wardrobe_sides.png",
                 "wardrobe_wardrobe_front.png"
              },
      inventory_image = "wardrobe_wardrobe_front.png",
      sounds = default.node_sound_wood_defaults(),
      groups = { choppy = 3, oddly_breakable_by_hand = 2, flammable = 3 },
      on_rightclick = function(pos, node, player, itemstack, pointedThing)
         showForm(player, 1);
      end
   });

minetest.register_craft(
   {
      output = "wardrobe:wardrobe",
      recipe = { { "group:wood", "group:stick", "group:wood" },
                 { "group:wood", "group:wool",  "group:wood" },
                 { "group:wood", "group:wool",  "group:wood" } }
   });
