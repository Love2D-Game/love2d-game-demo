local Menu = {}

local options = {
    "Start Game",
    "Quit Game"
}

-- select "Start Game" in the beginning
local selected = 1

-- fonts to use (given by main.lua)
local titleFont
local bodyFont
local promptFont

-- initialize menu
function Menu.init(title, body, prompt)
    titleFont = title
    bodyFont = body
    promptFont = prompt

    selected = 1
end

-- menu navigation (up, down, enter/space)
function Menu.keypressed(key)
    if key == "up" then
        selected = selected - 1

        if selected < 1 then
            selected = #options
        end

    elseif key == "down" then
        selected = selected + 1

        if selected > #options then
            selected = 1
        end

    elseif key == "return" or key == "space" then

        if selected == 1 then
            return "start"

        elseif selected == 2 then
            return "quit"
        end
    end
end

-- draw main menu
function Menu.draw()
    -- chatgpt helped code this section (especially color design)
    local w, h = love.graphics.getDimensions()

    -- dark background
    love.graphics.clear(0.05, 0.07, 0.11)

    -- game title
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(titleFont)

    love.graphics.printf(
        "SURVIVE IN A CULTIVATION WORLD",
        0,
        h * 0.25,
        w,
        "center"
    )

    -- subtitle (optional tbh, can delete if you want)
    love.graphics.setColor(0.75, 0.78, 0.82)
    love.graphics.setFont(bodyFont)

    love.graphics.printf(
        "Your path to immortality begins here. Don't die.",
        0,
        h * 0.35,
        w,
        "center"
    )

    -- draw menu options
    for i, option in ipairs(options) do

        local y = h * 0.5 + (i - 1) * 55
        local label = option

        if i == selected then
            -- highlight selected option (for fancy looks hehe)
            love.graphics.setColor(0.95, 0.83, 0.55)
            label = "> " .. option .. " <"
        else
            love.graphics.setColor(1, 1, 1)
        end

        love.graphics.printf(
            label,
            0,
            y,
            w,
            "center"
        )
    end

    -- control instructions
    love.graphics.setColor(0.65, 0.68, 0.72)
    love.graphics.setFont(promptFont)

    love.graphics.printf(
        "Use UP/DOWN to navigate, ENTER or SPACE to select",
        0,
        h - 60,
        w,
        "center"
    )

    -- reset drawing color
    love.graphics.setColor(1, 1, 1)
end

return Menu