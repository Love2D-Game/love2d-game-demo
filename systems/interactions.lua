local Interactions = {}

function Interactions.handle(object)

    local name = object.name
    local properties = object.properties or {}

    -- let map.lua handle entrances that change maps
    if properties.destination and properties.destination ~= "" then
        return nil
    end

    -- qi pool
    if name == "QiPool" then
        return properties.message

    -- chief's house
    elseif name == "ChiefHouse" then
        return properties.message

    -- not your house #1
    elseif name == "NotUrHouse1" then
        return properties.message

    -- not your house #2
    elseif name == "NotUrHouse2" then
        return properties.message

    -- player's home
    elseif name == "UrHouse" then
        return properties.message

    -- village exit (will lead to death if player leaves in all cases)
    elseif name == "GetLost" then
        return properties.message
    end

    -- objects without special behavior are handled by map.lua
    return nil
end

return Interactions