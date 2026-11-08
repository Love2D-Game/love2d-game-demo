function love.load()
    camera = require 'libraries/camera'
    anim8 = require 'libraries/anim8'
    sti = require 'libraries/sti'
    NPC = require 'libraries/npc'
    narrator = require 'libraries/narrator'

    gameMap = sti('maps/village_map.lua')
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
    introPage = 1

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

-- no tree layer for now, everything on one layer
-- function treeAt(x, y)
--     local layer = gameMap.layers["Trees"]
--     local tx = math.floor( x / gameMap.tilewidth) + 1
--     local ty = math.floor( y / gameMap.tileheight) + 1

--     return layer.data[ty] and layer.data[ty][tx]
-- end

function findNearestNPC()
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

function love.update(dt)
    -- don't update gameplay during the opening cutscene
    if introActive then
        return
    end

    local dialogOpen = narrator:isOpen()

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

        -- collision check (no tree layers at the moment)
        -- if (treeAt(player.x, oldY)) then player.x = oldX end
        -- if (treeAt(player.x, player.y)) then player.y = oldY end

        if isMoving then
            player.anim:update(dt)
        else
            player.anim:gotoFrame(2)
        end
    end

    cam:lookAt(player.x, player.y)

    -- clamp the camera so it doesn't scroll off screen
    local w,h = love.graphics.getDimensions()
    -- get width of map in pixels
    local mapW = gameMap.width * gameMap.tilewidth
    local mapH = gameMap.height * gameMap.tileheight
    -- keep the camera on the screen
    cam.x = math.max( w/2, math.min(cam.x, mapW - w/2))
    cam.y = math.max( h/2, math.min(cam.y, mapH - h/2))

    myNPC:update(dt)
    -- drNPC:update(dt)

    if dialogOpen then
        nearbyNPC = nil
    else
        nearbyNPC = findNearestNPC()
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
        if key == "e" and nearbyNPC then
            narrator:startScript(nearbyNPC)
        end
    end
end

function love.draw()
    -- draw opening cutscene instead of the village
    if introActive then
        local w, h = love.graphics.getDimensions()

        love.graphics.clear(0.05, 0.05, 0.08)
        love.graphics.setColor(1, 1, 1)

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
        gameMap:drawLayer(gameMap.layers["Tile Layer 1"])
        player.anim:draw(player.spriteSpreet, player.x, player.y, nil, 2.5, 2.5)
        myNPC:draw()
        -- drNPC:draw()
        -- only have one layer in village_map for now
        -- gameMap:drawLayer(gameMap.layers["TileLayer1"])

        if nearbyNPC then
            drawInteractionPrompt(nearbyNPC)
        end
    cam:detach()
    -- draw scores, health
    love.graphics.print("x = " .. math.floor(player.x) .. " y = " .. math.floor(player.y), 10, 10)

    narrator:draw()
end
