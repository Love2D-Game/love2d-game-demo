function love.load()
    camera = require 'libraries/camera'
    anim8 = require 'libraries/anim8'
    sti = require 'libraries/sti'
    NPC = require 'libraries/npc'
    narrator = require 'libraries/narrator'

    gameMap = sti('maps/testMap.lua')
    cam = camera()

    love.graphics.setDefaultFilter("nearest", "nearest")

    player = {}
    player.x = 400
    player.y = 200
    player.speed = 4
    player.sprite = love.graphics.newImage('sprites/slug.png')
    player.spriteSpreet = love.graphics.newImage('sprites/player-sheet.png')
    player.grid = anim8.newGrid( 12, 18, player.spriteSpreet:getWidth(), player.spriteSpreet:getHeight() )

    player.animations = {}
    player.animations.down  = anim8.newAnimation( player.grid('1-4', 1), 0.2)
    player.animations.left  = anim8.newAnimation( player.grid('1-4', 2), 0.2)
    player.animations.right = anim8.newAnimation( player.grid('1-4', 3), 0.2)
    player.animations.up    = anim8.newAnimation( player.grid('1-4', 4), 0.2)

    player.anim = player.animations.left

    myNPC = NPC.new('sprites/player-sheet.png', 796,216, 80, 0)
    drNPC = NPC.new('sprites/player-sheet.png', 804,1036, 0, 80)

    -- narrator init
    narrator:init()

    characterBella = narrator:newCharacter("Bella", "sprites/bella_avatar.png")
    characterDoc   = narrator:newCharacter("Doctor", "sprites/doctor_avatar.png")

    narrator:bindNPC(myNPC, characterBella, "BellaSaysHello")
    narrator:bindNPC(drNPC, characterDoc, "DrSaysHello")

    -- distance I can interact at
    interactRange = 80

    -- nearbyNPC
    nearbyNPC = nil
end

function treeAt(x, y)
    local layer = gameMap.layers["Trees"]
    local tx = math.floor( x / gameMap.tilewidth) + 1
    local ty = math.floor( y / gameMap.tileheight) + 1

    return layer.data[ty] and layer.data[ty][tx]
end

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

        -- collision check
        if (treeAt(player.x, oldY)) then player.x = oldX end
        if (treeAt(player.x, player.y)) then player.y = oldY end

        if isMoving == false then
            player.anim:gotoFrame(2)
        end
    end
    player.anim:update(dt)

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
    drNPC:update(dt)

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
    cam:attach()
        gameMap:drawLayer(gameMap.layers["Ground"])
        player.anim:draw(player.spriteSpreet, player.x, player.y, nil, 4)
        myNPC:draw()
        drNPC:draw()
        gameMap:drawLayer(gameMap.layers["Trees"])

        if nearbyNPC then
            drawInteractionPrompt(nearbyNPC)
        end
    cam:detach()
    -- draw scores, health
    love.graphics.print("x = " .. math.floor(player.x) .. " y = " .. math.floor(player.y), 10, 10)

    narrator:draw()
end
