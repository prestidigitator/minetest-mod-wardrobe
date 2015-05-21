-- Returns:
--    initSkin(player)
--    changeSkin(playerName, skin)
--    updateSkin(player)

local wardrobe = wardrobe or {};

--- Methods for initializing/changing/updating skin.  Valid values are keys
 -- from the SKIN_CHANGE_METHODS table (below).  nil means use the default
 -- method.
local SKIN_CHANGE_METHOD = '3d_armor';

local playerMesh = "character.b3d";
do  -- autodetect version of player mesh used by default
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

local function changeWardrobeSkin(playerName, skin)
   local player = minetest.get_player_by_name(playerName);
   if not player then
      error("unknown player '"..playerName.."'");
   end;
   if skin and not wardrobe.skinNames[skin] then
      error("unknown skin '"..skin.."'");
   end;

   wardrobe.playerSkins[playerName] = skin;
   wardrobe.storage.savePlayerSkins();
end;

local function defaultUpdateSkin(player)
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
end;

--- Method for updating the player skin, IF the dependent mod is enabled.
local SKIN_CHANGE_METHODS =
   {
      default =
      {
         required_mods = {},

         initSkin = defaultUpdateSkin,

         changeSkin = changeWardrobeSkin,

         updateSkin = defaultUpdateSkin
      },

      ["3d_armor"] =
      {
         required_mods = { '3d_armor' },

         initSkin = nil,

         changeSkin = function(playerName, skin)
            changeWardrobeSkin(playerName, skin);
            armor.textures[playerName].skin = skin;
         end,

         updateSkin = function(player)
            armor:update_player_visuals(player);
         end,
      },
   };

local methods = SKIN_CHANGE_METHODS[SKIN_CHANGE_METHOD];
if methods then
   for _, mod in ipairs(methods.required_mods) do
      if not minetest.get_modpath(mod) then methods = nil; break; end;
   end;
end;
if not methods then methods = SKIN_CHANGE_METHODS.default; end;

return methods.initSkin, methods.changeSkin, methods.updateSkin;
