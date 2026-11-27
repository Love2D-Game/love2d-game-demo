-- for map loading and transitions (chatgpt helped code here)
local Map = {}

local sti = require('libraries/sti')
local Interactables = require('libraries/interactables')
local Collision = require('systems.collision')

-- load map using its Lua file path
function Map.load(path, villageMapPath)

    local map = sti(path)

    -- load interactable objects
    local interactables = Interactables.load(map)

    -- refresh village collision rectangles whenever village is loaded
    if path == villageMapPath then
        Collision.loadVillage(map)
    end

    return map, interactables
end

-- handle player's interaction with a Tiled object
function Map.interact(object, player, villageMapPath)

    local properties = object.properties or {}
    local destination = properties.destination

    -- this object leads to another map
    if destination and destination ~= "" then

        local path = 'maps/' .. destination .. '.lua'

        -- make sure the destination file exists
        if love.filesystem.getInfo(path, "file") then

            local map, interactables =
                Map.load(path, villageMapPath)

            -- move player to destination spawn point
            player.x = tonumber(properties.spawnX)
                or map.tilewidth * 2

            player.y = tonumber(properties.spawnY)
                or map.tileheight * 2

            return {
                map = map,
                path = path,
                interactables = interactables
            }
        end

        -- destination file is missing
        return {
            message = "Map not ready: " .. path
        }
    end

    -- object only displays a message
    return {
        message = properties.message
            or properties.dialogue
            or object.name
            or "Nothing happens."
    }
end

return Map