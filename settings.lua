settings = {
    open = true,
    previous = false,
    ui = {},
    cursor = {x = 0, y = 0},
    clicking = false,
}

-- 0.0 - 1.0 range
function renderSlider(self, x, y, w, h, value)
    local windowWidth, windowHeight = love.window.getMode()
    love.graphics.setColor(.4, .5, .3)
    love.graphics.rectangle("fill", x * windowWidth, y * windowHeight, w * windowWidth, h * windowHeight)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", (x * windowWidth) - 10, (y * windowHeight) - 10, ((w * windowWidth) / 10) + 20, (h * windowHeight) + 20)
end

function sliderClick(self, x, y, w, h, value)
    local windowWidth, windowHeight = love.window.getMode()
    local sliderHandleX = (x * windowWidth) - 10
    local sliderHandleY = (y * windowHeight) - 10
    local sliderHandleW = ((w * windowWidth) / 10) + 20
    local sliderHandleH = (h * windowHeight) + 20

    if x > sliderHandleX and x < sliderHandleX + sliderHandleW and y > sliderHandleY and y < sliderHandleY + sliderHandleH then
        print("click")
    end
end

table.insert(settings.ui, {x = .5, y = .3, w = .2, h = .1, value = 1.0, render = renderSlider})

function settings:click(x, y)
    for _, ui in ipairs(self.ui) do
        ui:click(x, y)
    end
end

function settings:renderUi()
    for _, ui in ipairs(self.ui) do
        -- print("rendering")
        ui:render(ui.x, ui.y, ui.w, ui.h, ui.value)
    end
end

function settings:moveCursor(x, y)
    self.cursor = {x = x, y = y}
end

function settings:render()
    if self.previous ~= self.open then
        self.previous = self.open
        if self.open then
            settings:onOpen()
        else
            settings:onExit()
        end
    end
    if not self.open then
        return
    end

    local windowWidth, windowHeight = love.window.getMode()
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 0, 0, windowWidth * 2, windowHeight * 2)
    love.graphics.setColor(.4, .5, .3)
    love.graphics.rectangle("fill", 288, 172.8, 100, 100)

    love.graphics.setColor(1, 1, 1)

    settings:renderUi()

    love.graphics.setColor(.5, .5, .5)
    love.graphics.rectangle("fill", self.cursor.x, self.cursor.y, 10, 10)
end

function settings:onOpen()
    love.mouse.setRelativeMode(false)
end
function settings:onExit()
    love.mouse.setRelativeMode(true)
end