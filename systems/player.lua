local Player = {}

-- create the player and load their animations
function Player.load(anim8)
    local player = {}

    -- starting position
    player.x = 720
    player.y = 1200
    player.speed = 4

    -- load sprite sheet
    player.spriteSpreet = love.graphics.newImage(
        'sprites/main-character-3x4.png'
    )

    -- each animation frame is 19 x 30 pixels
    player.grid = anim8.newGrid(
        19,
        30,
        player.spriteSpreet:getWidth(),
        player.spriteSpreet:getHeight()
    )

    -- create walking animations
    player.animations = {}

    player.animations.down = anim8.newAnimation(
        player.grid('1-3', 1, 2, 1),
        0.16
    )

    player.animations.left = anim8.newAnimation(
        player.grid('1-3', 2, 2, 2),
        0.16
    )

    player.animations.right = anim8.newAnimation(
        player.grid('1-3', 3, 2, 3),
        0.16
    )

    player.animations.up = anim8.newAnimation(
        player.grid('1-3', 4, 2, 4),
        0.16
    )

    -- initially face left
    player.anim = player.animations.left

    return player
end

-- move the player and check collisions
-- isBlocked is a function supplied by main.lua
function Player.update(player, dt, isBlocked)

    local isMoving = false

    -- remember position before movement
    local oldX = player.x
    local oldY = player.y

    -- arrow keys
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

    -- horizontal collision
    if isBlocked(player.x, oldY) then
        player.x = oldX
    end

    -- vertical collision
    if isBlocked(player.x, player.y) then
        player.y = oldY
    end

    -- update walking animation
    if isMoving then
        player.anim:update(dt)
    else
        player.anim:gotoFrame(2)
    end
end

-- draw player
function Player.draw(player)
    player.anim:draw(
        player.spriteSpreet,
        player.x,
        player.y,
        nil,
        2.5,
        2.5
    )
end

return Player