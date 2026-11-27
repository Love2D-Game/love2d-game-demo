local villageMapPath = 'maps/village_map/village.lua'

-- load state files
local Menu = require('states.menu')
local GameOver = require('states.gameover')
local Intro = require('states.intro')

-- load systems files
local Player = require('systems.player')
local Collision = require('systems.collision')
local Map = require('systems.map')

function love.load()
    camera = require 'libraries/camera'
    anim8 = require 'libraries/anim8'
    NPC = require 'libraries/npc'
    narrator = require 'libraries/narrator'
    Interactables = require 'libraries/interactables'

    -- start in the village map
    currentMapPath = villageMapPath

    -- load map, interactables, and village collisions
    gameMap, interactables = Map.load(
        currentMapPath,
        villageMapPath
    )

    interactionMessage = nil
    interactionMessageTimer = 0

    cam = camera()

    love.graphics.setDefaultFilter("nearest", "nearest")

    -- create player and load animations
    player = Player.load(anim8)

    myNPC = NPC.new('sprites/villager.png', 856, 332, 80, 0, 19, 32, 3)

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

    -- screen states
    menuActive = true
    introActive = true
    gameOverActive = false

    -- fonts for the opening cutscene
    introTitleFont = love.graphics.newFont(24)
    introBodyFont = love.graphics.newFont(16)
    introPromptFont = love.graphics.newFont(14)

    -- pass fonts into state files for use in drawing text
    Menu.init(introTitleFont, introBodyFont, introPromptFont)
    GameOver.init(introTitleFont, introPromptFont)
    Intro.init(introTitleFont, introBodyFont, introPromptFont)
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
    local result = Map.interact(
        object,
        player,
        villageMapPath
    )

    -- if object sends us to another map
    if result.map then

        gameMap = result.map
        currentMapPath = result.path
        interactables = result.interactables

        -- clear nearby interactions from previous map
        nearbyNPC = nil
        nearbyObject = nil
        interactionMessage = nil

        return
    end

    -- otherwise display the object's message
    interactionMessage = result.message
    interactionMessageTimer = 3
end

function love.update(dt)
    -- pause game when main menu is active
    if menuActive then
        return
    end

    -- don't update gameplay during the opening cutscene
    if introActive or gameOverActive then
        return
    end

    local dialogOpen = narrator:isOpen()
    interactionMessageTimer = math.max(0, interactionMessageTimer - dt)
    if interactionMessageTimer == 0 then
        interactionMessage = nil
    end

    if not dialogOpen then
        Player.update(player, dt, function(x, y)
            return Collision.isBlocked(
                gameMap,
                currentMapPath,
                villageMapPath,
                x,
                y
            )
        end)
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
    -- main menu controls
    if menuActive then
        local action = Menu.keypressed(key)

        if action == "start" then
            menuActive = false
        elseif action == "quit" then
            love.event.quit()
        end

        return
    end

    -- opening cutscene controls
    if introActive then
        local action = Intro.keypressed(key)

        if action == "finished" then
            introActive = false
        end

        return
    end

    if gameOverActive then
        local action = GameOver.keypressed(key)

        if action == "menu" then
            -- reset game and return to main menu
            love.load()
            introActive = false

        elseif action == "quit" then
            love.event.quit()
        end

        return
    end

    -- this is temporary death trigger
    if key == "1" and not introActive and not gameOverActive then
        gameOverActive = true
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
    -- draw main menu if active
    if menuActive then
        Menu.draw()
        return
    end

    -- draw opening cutscene
    if introActive then
        Intro.draw()
        return
    end

    -- draw game over
    if gameOverActive then
        GameOver.draw()
        return
    end

    -- village/other gameplay maps
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
        Player.draw(player)
        if currentMapPath == villageMapPath then myNPC:draw() end

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