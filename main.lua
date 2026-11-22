local villageMapPath = 'maps/village_map/village.lua'
local collisions

function love.load()
    camera = require 'libraries/camera'
    anim8 = require 'libraries/anim8'
    sti = require 'libraries/sti'
    NPC = require 'libraries/npc'
    narrator = require 'libraries/narrator'
    Interactables = require 'libraries/interactables'
    MapCollision = require 'libraries/map_collision'

    currentMapPath = villageMapPath
    gameMap = sti(currentMapPath)
    interactables = Interactables.load(gameMap)
    interactionMessage = nil
    interactionMessageTimer = 0
    -- Load the village collision rectangles.
    collisions = {}

    local collisionLayer = gameMap.layers["Collisions"]

    if collisionLayer then
        for _, obj in ipairs(collisionLayer.objects) do
            if obj.shape == "rectangle" then
                table.insert(collisions, {
                    x = obj.x,
                    y = obj.y,
                    width = obj.width,
                    height = obj.height
                })
            end
        end
    end

    cam = camera()

    love.graphics.setDefaultFilter("nearest", "nearest")

    player = {}
    -- test to change starting player coordinates
    player.x = 720
    player.y = 1200
    player.speed = 4
    player.spriteSpreet = love.graphics.newImage('sprites/main-character-3x4.png')
    player.grid = anim8.newGrid( 19, 30, player.spriteSpreet:getWidth(), player.spriteSpreet:getHeight() )

    player.animations = {}
    player.animations.down  = anim8.newAnimation( player.grid('1-3', 1, 2, 1), 0.16)
    player.animations.left  = anim8.newAnimation( player.grid('1-3', 2, 2, 2), 0.16)
    player.animations.right = anim8.newAnimation( player.grid('1-3', 3, 2, 3), 0.16)
    player.animations.up    = anim8.newAnimation( player.grid('1-3', 4, 2, 4), 0.16)

    player.anim = player.animations.left

    myNPC = NPC.new('sprites/villager.png', 796, 216, 80, 0, 19, 32, 3)
    -- drNPC = NPC.new('sprites/player-sheet.png', 804, 1036, 0, 80)

    -- narrator init
    narrator:init()

    -- create villager character
    characterVillager = narrator:newCharacter("Villager", "sprites/villager-avatar.png")

    -- connect the villager to your Ink story
    narrator:bindNPC(myNPC, characterVillager, "VillageIntro")

    -- distance I can interact at
    interactRange = 80

    -- nearbyNPC
    nearbyNPC = nil

    -- opening cutscene before the village appears
    introActive = true
    -- page 0 is for AI credits scene
    introPage = 0

    -- fonts for the opening cutscene
    introTitleFont = love.graphics.newFont(24)
    introBodyFont = love.graphics.newFont(16)
    introPromptFont = love.graphics.newFont(14)

    -- spacing between lines
    introBodyFont:setLineHeight(1.2)

    introPages = {
        [[
CHAPTER 1: YOUR WORST NIGHTMARE

As you were walking to class at UCSC, you didn’t notice a small rock on the slope and tripped over it.

You rolled downhill at an amazing speed of 35 mph before crashing headfirst into a tree.

The last thing you hear are concerned shrieks from other students near you.
        ]],

        [[
When you wake up, you realize that you’re lying in a bed in a rotting, wooden hut.
        ]],

        [[
As you drag yourself outside, you discover, from a confused local you’ve randomly grabbed on the road, that you’re in a cultivation world where people train their spiritual energy (qi) in hopes of attaining immortality.

Unfortunately, you have no money, no cultivation, and no idea how to survive.

You must find a way to survive in this unfamiliar world.
        ]]
    }   
end

-- chatgpt helped code --> collision-checking function
local function isBlocked(x, y)
    -- player collision box near their feet, not the entire sprite
    local px = x + 12
    local py = y + 52
    local pw = 24
    local ph = 18

    -- map boundaries
    local mapW = gameMap.width * gameMap.tilewidth
    local mapH = gameMap.height * gameMap.tileheight

    -- prevent walking off the map
    if px < 0 or py < 0 or
       px + pw > mapW or py + ph > mapH then
        return true
    end

    -- check collision with obstacles
    for _, box in ipairs(collisions) do
        if px < box.x + box.width and
           px + pw > box.x and
           py < box.y + box.height and
           py + ph > box.y then
            return true
        end
    end

    return false
end

function findNearestNPC()
    if currentMapPath ~= villageMapPath then return nil end
    local closest, closestDist = nil, interactRange
    for _, npc in ipairs(narrator._boundNPCs) do
        local dx = npc.x - player.x
        local dy = npc.y - player.y
        local dist = math.sqrt(dx*dx + dy*dy)
        if dist <= closestDist then
            closest = npc
            closestDist = dist
        end
    end
    return closest
end

function interactWithObject(object)
    local properties = object.properties or {}
    local destination = properties.destination
    if destination and destination ~= "" then
        local path = 'maps/' .. destination .. '.lua'
        if love.filesystem.getInfo(path, "file") then
            gameMap = sti(path)
            currentMapPath = path
            interactables = Interactables.load(gameMap)
            player.x = tonumber(properties.spawnX) or gameMap.tilewidth * 2
            player.y = tonumber(properties.spawnY) or gameMap.tileheight * 2
            nearbyNPC, nearbyObject = nil, nil
            interactionMessage = nil
            return
        end
        interactionMessage = "Map not ready: " .. path
    else
        interactionMessage = properties.message or properties.dialogue or object.name or "Nothing happens."
    end
    interactionMessageTimer = 3
end

function love.update(dt)
    -- don't update gameplay during the opening cutscene
    if introActive then
        return
    end

    local dialogOpen = narrator:isOpen()
    interactionMessageTimer = math.max(0, interactionMessageTimer - dt)
    if interactionMessageTimer == 0 then interactionMessage = nil end

    if not dialogOpen then 
        local isMoving = false
        local oldX, oldY = player.x, player.y

        if love.keyboard.isDown("right") then
            player.x = player.x + player.speed
            player.anim = player.animations.right
            isMoving = true
        end

        if love.keyboard.isDown("left") then
            player.x = player.x - player.speed
            player.anim = player.animations.left
            isMoving = true
        end

        if love.keyboard.isDown("down") then
            player.y = player.y + player.speed
            player.anim = player.animations.down
            isMoving = true
        end

        if love.keyboard.isDown("up") then
            player.y = player.y - player.speed
            player.anim = player.animations.up
            isMoving = true
        end

        if currentMapPath == villageMapPath then
            if isBlocked(player.x, oldY) then player.x = oldX end
            if isBlocked(player.x, player.y) then player.y = oldY end
        else
            -- Resolve each axis separately so the player can slide along walls.
            if not MapCollision.canStand(gameMap, player.x, oldY) then player.x = oldX end
            if not MapCollision.canStand(gameMap, player.x, player.y) then player.y = oldY end
        end

        if isMoving then
            player.anim:update(dt)
        else
            player.anim:gotoFrame(2)
        end
    end

    -- Player coordinates mark the sprite's top-left; follow its visual center.
    local frameWidth, frameHeight = player.anim:getDimensions()
    cam:lookAt(player.x + frameWidth * 2.5 / 2, player.y + frameHeight * 2.5 / 2)

    -- clamp the camera so it doesn't scroll off screen
    local w,h = love.graphics.getDimensions()
    -- get width of map in pixels
    local mapW = gameMap.width * gameMap.tilewidth
    local mapH = gameMap.height * gameMap.tileheight
    -- keep the camera on the screen
    cam.x = math.max(w/2, math.min(cam.x, mapW - w/2))
    cam.y = math.max(h/2, math.min(cam.y, mapH - h/2))

    if currentMapPath == villageMapPath then myNPC:update(dt) end
    -- drNPC:update(dt)

    if dialogOpen then
        nearbyNPC = nil
        nearbyObject = nil
    else
        nearbyNPC = findNearestNPC()
        nearbyObject = not nearbyNPC and Interactables.nearest(interactables, player.x, player.y) or nil
    end
    narrator:update(dt)
end

function drawInteractionPrompt(npc)
    love.graphics.setColor(1,1,1)
    love.graphics.print("Press E", npc.x - 25, npc.y - 25)
end

function love.keypressed(key)
    -- opening cutscene controls
    if introActive then
        if key == "space" or key == "return" then
            introPage = introPage + 1

            if introPage > #introPages then
                introActive = false
            end
        end

        return
    end

    if key == "escape" then
        love.event.quit()
    end
    if narrator:isOpen() then
        if key == "space" or key == "return" then
            narrator:onAction()
        elseif key == "up" then
            narrator:prevOption()
        elseif key == "down" then
            narrator:nextOption()
        end        
    else
        if key == "e" then
            local npc = findNearestNPC()
            local object = Interactables.nearest(interactables, player.x, player.y)
            if npc then
                narrator:startScript(npc)
            elseif object then
                interactWithObject(object)
            end
        end
    end
end

function love.draw()
    -- draw opening cutscene instead of the village
    if introActive then
        local w, h = love.graphics.getDimensions()

        love.graphics.clear(0.05, 0.05, 0.08)
        love.graphics.setColor(1, 1, 1)

        -- AI credits screen (before Chapter 1)
        if introPage == 0 then
            love.graphics.setFont(introTitleFont)

            love.graphics.printf(
                "CREDITS",
                0,
                h * 0.25,
                w,
                "center"
            )

            love.graphics.setFont(introBodyFont)

            love.graphics.printf(
                "AI-generated artwork was created with the assistance of ChatGPT (OpenAI), including environmental tiles, buildings, and village props.",
                100,
                h * 0.40,
                w - 200,
                "center"
            )

            love.graphics.printf(
                "Super's base model used for walking animations and character base: https://ertylerex.itch.io/top-down-character-base",
                100,
                h * 0.55,
                w - 200,
                "center"
            )

            love.graphics.setFont(introPromptFont)

            love.graphics.printf(
                "Press SPACE to continue",
                0,
                h - 60,
                w,
                "center"
            )

            return
        end

        -- chapter title
        if introPage == 1 then
            love.graphics.setFont(introTitleFont)

            love.graphics.print(
                "CHAPTER 1: YOUR WORST NIGHTMARE",
                60, h * 0.25
            )

            -- slight bold effect
            love.graphics.print(
                "CHAPTER 1: YOUR WORST NIGHTMARE",
                61, h * 0.25
            )
        end

        -- body text
        love.graphics.setFont(introBodyFont)

        local bodyText = introPages[introPage]

        if introPage == 1 then
            bodyText = bodyText:gsub(
                "CHAPTER 1: YOUR WORST NIGHTMARE", ""
            )
        end

        -- remove indentation before each line
        bodyText = bodyText:gsub("\n[ \t]+", "\n")
        bodyText = bodyText:gsub("^%s+", "")
        bodyText = bodyText:gsub("%s+$", "")

        love.graphics.printf(
            bodyText,
            60,
            introPage == 1 and h * 0.32 or h * 0.25,
            w - 120,
            "left"
        )

        -- continue prompt
        love.graphics.setFont(introPromptFont)

        love.graphics.printf(
            "Press SPACE to continue",
            0,
            h - 60,
            w,
            "center"
        )

        return
    end

    cam:attach()
        local function drawTiles(layers)
            for _, layer in ipairs(layers) do
                if layer.visible ~= false then
                    if layer.type == "group" then
                        drawTiles(layer.layers)
                    elseif layer.type == "tilelayer" or layer.type == "imagelayer" then
                        gameMap:drawLayer(layer)
                    end
                end
            end
        end
        drawTiles(gameMap.layers)
        player.anim:draw(player.spriteSpreet, player.x, player.y, nil, 2.5, 2.5)
        if currentMapPath == villageMapPath then myNPC:draw() end
        -- drNPC:draw()

        if nearbyNPC then
            drawInteractionPrompt(nearbyNPC)
        elseif nearbyObject then
            love.graphics.setColor(1, 1, 1)
            love.graphics.print((nearbyObject.properties or {}).prompt or ("E: " .. nearbyObject.name),
                nearbyObject.x, nearbyObject.y - 25)
        end

    cam:detach()

    -- draw scores, health
    love.graphics.print("x = " .. math.floor(player.x) .. " y = " .. math.floor(player.y), 10, 10)
    if interactionMessage then
        local width = love.graphics.getWidth()
        love.graphics.setColor(0, 0, 0, 0.85)
        love.graphics.rectangle("fill", 5, 30, width - 10, 105)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(interactionMessage, 15, 40, width - 30)
    end

    narrator:draw()
end
