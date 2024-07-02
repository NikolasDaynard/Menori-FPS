titlescreen = {
    open = true
}

function titlescreen:update()
    if love.mouse.isDown(1) then
        self.open = false
    end
end

function titlescreen:render()
    if not self.open then
        return
    end
    local windowHeight, windowWidth = love.window.getMode()
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 0, 0, windowWidth * 2, windowHeight * 2)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", windowWidth * .1, 0, (windowWidth * 2) - (windowWidth * .1) * 4, windowHeight * 2)
    love.graphics.setColor(0, 0, 0)
    love.graphics.print("foo", 100, 100)
end 