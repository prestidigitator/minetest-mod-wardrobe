wardrobe = wardrobe or {};
wardrobe.storage = wardrobe.storage or {};


local MOD_NAME = minetest.get_current_modname();
local MOD_PATH = minetest.get_modpath(MOD_NAME);
local WORLD_PATH = minetest.get_worldpath();

local SKIN_FILES = { MOD_PATH.."/skins.txt", WORLD_PATH.."/skins.txt" };
local PLAYER_SKIN_DB = WORLD_PATH.."/playerSkins.txt";


local function removePrefix(str, prefix)
   local n = #prefix;
   if #str >= n and string.sub(str, 1, n) == prefix then
      return string.sub(str, n+1);
   else
      return str;
   end
end

local function removeSuffix(str, suffix)
   local n = #suffix;
   if #str >= n and string.sub(str, -n, -1) == suffix then
      return string.sub(str, 1, -(n+1));
   else
      return str;
   end
end

local function trimTail(str)
   local e = string.find(str, "%s+$");
   return (e and string.sub(str, e-1)) or str;
end

local function parsePlayerSkinLine(line)
   local k, v;
   local p = string.find(line, "%S");
   if p and not string.find(line, "^%-%-", p) then
      local ss, se = string.find(line, "%s*:%s*", p);
      if ss then
         k = string.sub(line, p, ss-1);
         v = trimTail(string.sub(line, se+1));
         if k == "" then k = nil; end
         if v == "" then v = nil; end
      end
   end
   return k, v;
end

local function parseSkinLine(line)
   local k, v, n, e;

   local p = string.find(line, "%S");
   if p then
      n, e = string.find(line, "^%-%-?", p);
      if not n or n == e then
         if n then p = n+1; end
         local ss, se = string.find(line, "%s*:%s*", p);
         if ss then
            k = string.sub(line, p, ss-1);
            v = trimTail(string.sub(line, se+1));
            if v == "" then v = nil; end
         else
            k = trimTail(string.sub(line, p));
         end
         if k == "" then k = nil; end
      end
   end

   return k, v, n;
end

--- Parses the files with the given paths for key/value pairs.  Once a key is
 -- negated, it stays negated.  Otherwise, the last (non-nil) value assigned to
 -- a key wins.
 --
 -- @return A list of non-negated keys.  This may include keys for which the
 --         values are nil.
 -- @return A map from key to value for all non-negated keys with non-nil
 --         values.
 --
local function loadSkinsFromFiles(filePaths)
   local normKeys, negKeys, values = {}, {}, {}

   for _, filePath in ipairs(filePaths) do
      local file = io.open(filePath, "r");
      if file then
         for line in file:lines() do
            local k, v, n = parseSkinLine(line)
            if k then
               if n then
                  normKeys[k] = nil;
                  values[k] = nil;
                  negKeys[k] = k;
               elseif not negKeys[k] then
                  normKeys[k] = k;
                  if v then
                     values[k] = v;
                  end
               end
            end
         end
         file:close()
      end
   end

   local keyList = {};
   for k in pairs(normKeys) do
      table.insert(keyList, k);
   end

   return keyList, values;
end

--- Loads skin names from skin files, storing the result in wardrobe.skins and
 -- wardrobe.skinNames.
 --
function wardrobe.storage.loadSkins()
   local skins, skinNames = loadSkinsFromFiles(SKIN_FILES);

   for i, skin in ipairs(skins) do
      local name = skinNames[skin];

      if not name then
         local s, e;

         name = removeSuffix(
                   removePrefix(
                      removePrefix(skin, MOD_NAME.."_"),
                      "skin_"),
                   ".png");

         if name == "" then
            name = skin;
         else
            name = string.gsub(name, "_", " ");
         end
      end

      skinNames[skin] = name;
   end

   table.sort(skins,
              function(sL, sR)
                 return skinNames[sL] < skinNames[sR];
              end);

   wardrobe.skins = skins;
   wardrobe.skinNames = skinNames;
end

--- Parses the player skins database file and stores the result in
 -- wardrobe.playerSkins.
 --
function wardrobe.storage.loadPlayerSkins()
   local playerSkins = {};

   local file = io.open(PLAYER_SKIN_DB, "r");
   if file then
      for line in file:lines() do
         local name, skin = parsePlayerSkinLine(line);
         if name then
            playerSkins[name] = skin;
         end
      end
      file:close();
   end

   wardrobe.playerSkins = playerSkins;
end

--- Writes wardrobe.playerSkins to the player skins database file.
 --
function wardrobe.storage.savePlayerSkins()
   local file = io.open(PLAYER_SKIN_DB, "w");
   if not file then error("Couldn't write file '"..filePath.."'"); end

   for name, skin in pairs(wardrobe.playerSkins) do
      file:write(name, ":", skin, "\n");
   end

   file:close();
end
