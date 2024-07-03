credits = {
    open = false
}

function credits:render()
    if not self.open then
        return
    end

    local windowHeight, windowWidth = love.window.getMode()
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 0, 0, windowWidth * 2, windowHeight * 2)
    love.graphics.setColor(1, 1, 1)

    -- love.graphics.rectangle("fill", windowWidth * .1, 0, (windowWidth * 2) - (windowWidth * .1) * 4, windowHeight * 2)
    love.graphics.print("CREDITS", 100, 100)
    love.graphics.print("PROGRAMMING: NIKOLAS DAYNARD", 100, 150)
    love.graphics.print("SOUND ENGINEER: JAYDEN WENG", 100, 200)
    love.graphics.print("MADE WITH LÖVE", 100, 300)
end