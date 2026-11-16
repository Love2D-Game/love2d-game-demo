-- Read rectangle/point objects from Tiled object layers named Interactions.
local Interactables = {}

function Interactables.load(map)
    local objects = {}
    local function visit(layers)
        for _, layer in ipairs(layers) do
            if layer.type == "group" then
                visit(layer.layers)
            elseif layer.type == "objectgroup" then
                for _, object in ipairs(layer.objects) do
                    local properties = object.properties or {}
                    if object.visible ~= false and (layer.name == "Interactions"
                        or properties.dialogue or properties.destination) then
                        objects[#objects + 1] = object
                    end
                end
            end
        end
    end
    visit(map.layers)
    return objects
end

function Interactables.nearest(objects, x, y)
    local nearest, bestDistance
    for _, object in ipairs(objects) do
        -- Measure to the edge of the rectangle, or to a point object.
        local ox = math.max(object.x, math.min(x, object.x + (object.width or 0)))
        local oy = math.max(object.y, math.min(y, object.y + (object.height or 0)))
        local distance = (x - ox)^2 + (y - oy)^2
        local properties = object.properties or {}
        local range = tonumber(properties.range or properties.interactionRadius) or 80
        if distance <= range^2 and (not bestDistance or distance < bestDistance) then
            nearest, bestDistance = object, distance
        end
    end
    return nearest
end

return Interactables
