local MOD_NAME = minetest.get_current_modname();
local MOD_PATH = minetest.get_modpath(MOD_NAME);
local WORLD_PATH = minetest.get_worldpath();

if MOD_NAME ~= "wardrobe" then
   error("mod directory must be named 'wardrobe'");
end

local armor_mod = false;
if minetest.get_modpath("3d_armor") then armor_mod = true; end;

wardrobe = {};

dofile(MOD_PATH.."/storage.lua");
dofile(MOD_PATH.."/wardrobe.lua");

wardrobe.storage.loadSkins();
wardrobe.storage.loadPlayerSkins();

local playerMesh = "character.b3d";

-- autodetect version of player mesh used by default
do
   if default and default.registered_player_models then
      local haveCharName = false;  -- 'character.*' has priority
      local name = nil;
      local nNames = 0;
      for k in pairs(default.registered_player_models) do
         if string.find(k, "^character\\.[^\\.]+$") then
            if haveCharName then nNames = 2; break; end;
            name = k;
            nNames = 1;
            haveCharName = true;
         elseif not haveCharName then
            name = k;
            nNames = nNames + 1;
         end;
      end;

      if nNames == 1 then playerMesh = name; end;
   end;
end;

function wardrobe.setPlayerSkin(player)
   -- If 3d_armor is installed, let him set the model and textures
   if armor_mod then return end

   local playerName = player:get_player_name();
   if not playerName or playerName == "" then return; end;

   local skin = wardrobe.playerSkins[playerName];
   if not skin or not wardrobe.skinNames[skin] then return; end;

   player:set_properties(
      {
         visual = "mesh",
         visual_size = { x = 1, y = 1 },
         mesh = playerMesh,
         textures = { skin }
      });
end

function wardrobe.changePlayerSkin(playerName, skin)
   local player = minetest.get_player_by_name(playerName);
   if not player then
      error("unknown player '"..playerName.."'");
      return;
   end
   if skin and not wardrobe.skinNames[skin] then
      error("unknown skin '"..skin.."'");
      return;
   end

   wardrobe.playerSkins[playerName] = skin;
   wardrobe.storage.savePlayerSkins();

   -- If 3d_armor is installed, update the skin texture and the armor
   if armor_mod then
      armor.textures[playerName].skin = skin;
      armor:update_player_visuals(player);
   else wardrobe.setPlayerSkin(player) end
end

minetest.register_on_joinplayer(
   function(player)
      minetest.after(1,
                     function(player)
                        wardrobe.setPlayerSkin(player);
                     end,
                     player);
   end);
