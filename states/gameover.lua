local GameOver = {}

local titleFont
local promptFont

function GameOver.init(title, prompt)
    titleFont = title
    promptFont = prompt
end

function GameOver.draw()
    local width, height = love.graphics.getDimensions()

    love.graphics.clear(0.35, 0.02, 0.06)
    love.graphics.setColor(1, 1, 1)

    love.graphics.setFont(titleFont)
    love.graphics.printf(
        "Game Over",
        0,
        height * 0.4,
        width,
        "center"
    )

    love.graphics.setFont(promptFont)
    love.graphics.printf(
        "Enter to return to Main Menu  |  Esc to quit",
        0,
        height * 0.5,
        width,
        "center"
    )
end

function GameOver.keypressed(key)
    if key == "return" then
        return "menu"
    elseif key == "escape" then
        return "quit"
    end
end

return GameOver