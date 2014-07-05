wardrobe = wardrobe or {};

local MOD_NAME = minetest.get_current_modname();
local MOD_PATH = minetest.get_modpath(MOD_NAME);
local WORLD_PATH = minetest.get_worldpath();

if MOD_NAME ~= "wardrobe" then
   error("mod directory must be named 'wardrobe'");
end

dofile(MOD_PATH.."/storage.lua");
dofile(MOD_PATH.."/wardrobe.lua");

wardrobe.storage.loadSkins();
wardrobe.storage.loadPlayerSkins();

function wardrobe.setPlayerSkin(player)
   local playerName = player:get_player_name();
   if not playerName or playerName == "" then return; end

   local skin = wardrobe.playerSkins[playerName];
   if not skin or not wardrobe.skinNames[skin] then return; end

   player:set_properties(
      {
         visual = "mesh",
         visual_size = { x = 1, y = 1 },
         mesh = "character.x",
         textures = { skin }
      });
end

function wardrobe.changePlayerSkin(playerName, skin)
   local player = minetest.get_player_by_name(playerName);
   if not player then
      error("unknown player '"..playerName.."'");
   end
   if skin and not wardrobe.skinNames[skin] then
      error("unknown skin '"..skin.."'");
   end

   wardrobe.playerSkins[playerName] = skin;
   wardrobe.storage.savePlayerSkins();

   wardrobe.setPlayerSkin(player);
end

minetest.register_on_joinplayer(
   function(player)
      minetest.after(1,
                     function(player)
                        wardrobe.setPlayerSkin(player);
                     end,
                     player);
   end);

