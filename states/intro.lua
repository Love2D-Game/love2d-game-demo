local Intro = {}

local titleFont
local bodyFont
local promptFont

-- page 0 is AI credits screen
local currentPage = 0

local pages = {
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

-- get fonts from main.lua and reset to first page
function Intro.init(title, body, prompt)
    titleFont = title
    bodyFont = body
    promptFont = prompt

    bodyFont:setLineHeight(1.2)

    currentPage = 0
end

-- move intro to next page when space/enter is pressed
function Intro.keypressed(key)
    if key == "space" or key == "return" then
        currentPage = currentPage + 1

        -- all intro pages have been shown
        if currentPage > #pages then
            return "finished"
        end
    end
end

function Intro.draw()
    local w, h = love.graphics.getDimensions()

    love.graphics.clear(0.05, 0.05, 0.08)
    love.graphics.setColor(1, 1, 1)

    -- AI credits screen
    if currentPage == 0 then
        love.graphics.setFont(titleFont)

        love.graphics.printf(
            "CREDITS",
            0,
            h * 0.25,
            w,
            "center"
        )

        love.graphics.setFont(bodyFont)

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

        love.graphics.setFont(promptFont)

        love.graphics.printf(
            "Press SPACE to continue",
            0,
            h - 60,
            w,
            "center"
        )

        return
    end

    -- chapter title on the first story page
    if currentPage == 1 then
        love.graphics.setFont(titleFont)

        love.graphics.print(
            "CHAPTER 1: YOUR WORST NIGHTMARE",
            60,
            h * 0.25
        )

        -- slightly bold effect from the original code
        love.graphics.print(
            "CHAPTER 1: YOUR WORST NIGHTMARE",
            61,
            h * 0.25
        )
    end

    -- story text
    love.graphics.setFont(bodyFont)

    local bodyText = pages[currentPage]

    if currentPage == 1 then
        bodyText = bodyText:gsub(
            "CHAPTER 1: YOUR WORST NIGHTMARE",
            ""
        )
    end

    -- get rid of indentation and extra whitespace
    bodyText = bodyText:gsub("\n[ \t]+", "\n")
    bodyText = bodyText:gsub("^%s+", "")
    bodyText = bodyText:gsub("%s+$", "")

    love.graphics.printf(
        bodyText,
        60,
        currentPage == 1 and h * 0.32 or h * 0.25,
        w - 120,
        "left"
    )

    -- continue prompt
    love.graphics.setFont(promptFont)

    love.graphics.printf(
        "Press SPACE to continue",
        0,
        h - 60,
        w,
        "center"
    )
end

return Intro