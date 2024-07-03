-- 0.0 - 1.0 range
function renderSlider(self, x, y, w, h, value)
    local windowHeight, windowWidth = love.window.getMode()
    love.graphics.setColor(.4, .5, .3)
    love.graphics.rectangle("fill", x * windowWidth, y * windowHeight, w * windowWidth, h * windowHeight)
    love.graphics.setColor(.8, .5, .7)
    love.graphics.rectangle("fill", (x * windowWidth) - 10, (y * windowHeight) - 10, (w * windowWidth) + 20, (h * windowHeight) + 20)
end

settings = {
    open = true,
    ui = {
        slider1 = {x = .5, y = .3, w = .2, h = .1, value = 1.0, render = renderSlider}
    },
}

function settings:renderUi()
    for _, ui in ipairs(self.ui) do
        ui:render(ui.x, ui.y, ui.w, ui.h, ui.value)
    end
end

function settings:render()
    if not self.open then
        return
    end

    local windowHeight, windowWidth = love.window.getMode()
    love.graphics.setColor(.4, .5, .3)
    love.graphics.rectangle("fill", .5 * windowWidth, .3 * windowHeight, .2 * windowWidth, .1 * windowHeight)
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 0, 0, windowWidth * 2, windowHeight * 2)

    love.graphics.setColor(1, 1, 1)

    settings:renderUi()
end
