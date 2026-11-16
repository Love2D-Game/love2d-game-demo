-- STI converts nonzero cells to tile tables; empty cells become nil.
local Collision = {}

function Collision.canStand(map, x, y)
    local layer = map.layers['Collision']
    if not layer then return true end
    -- The existing sprite is drawn from its top-left. Check a small foot box.
    for _, dx in ipairs({16, 31}) do
        for _, dy in ipairs({63, 72}) do
            local tx = math.floor((x + dx) / map.tilewidth) + 1
            local ty = math.floor((y + dy) / map.tileheight) + 1
            if tx < 1 or ty < 1 or tx > map.width or ty > map.height
                or (layer.data[ty] and layer.data[ty][tx]) then
                return false
            end
        end
    end
    return true
end

return Collision
