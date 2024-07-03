titlescreenMusic = love.audio.newSource("audio/Blast Zone - Hour 5 - COMPLETED.mp3", "stream")
titlescreenMusic:setLooping(true)
titlescreenMusic:play()

titleimage = love.graphics.newImage("assets/title.png")

titlescreen = {
    open = true
}

function titlescreen:update()
    if love.mouse.isDown(1) and self.open then
        self.open = false
        love.audio.stop()
        titlescreenMusic = nil
        gameMusicF = love.audio.newSource("audio/Battle Theme.mp3", "static")
        gameMusicF:setLooping(true)
        gameMusicF:play()
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

    love.graphics.draw(titleimage, windowWidth * .1, -100, 0, (1024 / windowWidth) / 4, 576 / windowHeight) 
    -- love.graphics.rectangle("fill", windowWidth * .1, 0, (windowWidth * 2) - (windowWidth * .1) * 4, windowHeight * 2)
    love.graphics.setColor(0, 0, 0)
end 