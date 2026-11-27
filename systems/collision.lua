local Collision = {}

-- existing collision library for other maps
local MapCollision = require('libraries/map_collision')

-- store village's Tiled collision rectangles
local villageCollisions = {}

-- load collision rectangles from village map
function Collision.loadVillage(gameMap)
    villageCollisions = {}

    local collisionLayer = gameMap.layers["Collisions"]

    if collisionLayer then
        for _, obj in ipairs(collisionLayer.objects) do
            if obj.shape == "rectangle" then
                table.insert(villageCollisions, {
                    x = obj.x,
                    y = obj.y,
                    width = obj.width,
                    height = obj.height
                })
            end
        end
    end
end

-- check whether player would hit something in village, including the edges of map
function Collision.isVillageBlocked(gameMap, x, y)

    -- small collision box near the player's feet
    local px = x + 12
    local py = y + 52
    local pw = 24
    local ph = 18

    -- map dimensions in pixels
    local mapW = gameMap.width * gameMap.tilewidth
    local mapH = gameMap.height * gameMap.tileheight

    -- stop walking off the map
    if px < 0 or py < 0 or
       px + pw > mapW or py + ph > mapH then
        return true
    end

    -- check overlap with Tiled collision rectangles
    for _, box in ipairs(villageCollisions) do
        if px < box.x + box.width and
           px + pw > box.x and
           py < box.y + box.height and
           py + ph > box.y then

            return true
        end
    end

    return false
end

-- choose collision system for the current map
function Collision.isBlocked(gameMap, currentMapPath, villageMapPath, x, y)

    if currentMapPath == villageMapPath then
        return Collision.isVillageBlocked(gameMap, x, y)
    else
        -- other-map library returns true when a position is allowed, so invert result
        return not MapCollision.canStand(gameMap, x, y)
    end
end

return Collision