lunajson = require("libs.lunajson")
require("audio")

---@diagnostic disable: undefined-field
settings = {
    open = true,
    previous = false,
    ui = {},
    cursor = {x = 0, y = 0},
    clicking = nil, -- slider or bool
}

-- 0.0 - 1.0 range
function renderButton(self, x, y, w, h, value)
    local windowWidth, windowHeight = love.window.getMode()

    if value then
        love.graphics.setColor(.4, .5, .3)
        love.graphics.rectangle("fill", x * windowWidth, y * windowHeight, w * windowWidth, h * windowHeight)
    else
        love.graphics.setColor(.4, 1, .3)
        love.graphics.rectangle("fill", x * windowWidth, y * windowHeight, w * windowWidth, h * windowHeight)
    end
end

function buttonClick(self, x, y)
    local windowWidth, windowHeight = love.window.getMode()

    if x > self.x * windowWidth and x < (self.x) * windowWidth + self.w * windowWidth and y > self.y * windowHeight and y < (self.y * windowHeight) + self.h * windowHeight then
        print("click")
        self.value = (not self.value or false)
        return true
    end
end

-- 0.0 - 1.0 range
function renderSlider(self, x, y, w, h, value)
    local windowWidth, windowHeight = love.window.getMode()
    love.graphics.setColor(.4, .5, .3)
    love.graphics.rectangle("fill", x * windowWidth, y * windowHeight, w * windowWidth, h * windowHeight)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", ((x * windowWidth) - 10) + (self.value * w), (y * windowHeight) - 10, ((w * windowWidth) / 10) + 20, (h * windowHeight) + 20)

    if self.text then
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(self.text, x * windowWidth, (y * windowHeight) - 30)
    end
end

function sliderClick(self, x, y)
    local windowWidth, windowHeight = love.window.getMode()
    local sliderHandleX = ((self.x * windowWidth) - 10) + (self.value * self.w)
    local sliderHandleY = (self.y * windowHeight) - 10
    local sliderHandleW = ((self.w * windowWidth) / 10) + 20
    local sliderHandleH = (self.h * windowHeight) + 20

    if x > sliderHandleX and x < sliderHandleX + sliderHandleW and y > sliderHandleY and y < sliderHandleY + sliderHandleH then
        return true
    end
end
function sliderDrag(self, x, y)
    local windowWidth, windowHeight = love.window.getMode()

    -- if x > sliderHandleX and x < sliderHandleX + sliderHandleW and y > sliderHandleY and y < sliderHandleY + sliderHandleH then
    self.value = math.min(math.max(((x) - (self.x * windowWidth)) / self.w, 0), windowWidth)
end
table.insert(settings.ui, {x = .4, y = .3, w = .2, h = .1, value = 1.0, text = "Volume", render = renderSlider, click = sliderClick, drag = sliderDrag, callback = function(self)
    print(self.value)
    audio:setVolume(self.value)
    settings:save()
end})
table.insert(settings.ui, {x = .4, y = .6, w = .2, h = .1, value = 1.0, render = renderButton, click = buttonClick, callback = function(self)
    print(self.value)
    settings:save()
end})

function settings:getSettings(i)
    return self.ui[i].value
end


function settings:update()
    local x, y = self.x, self.y -- didn't wanna rewrite lmao

    if love.mouse.isDown(1) then
        if not self.clicking then
            for _, ui in ipairs(self.ui) do
                print(ui.y)
                if ui:click(x, y) then
                    self.clicking = ui
                    ui:callback()
                end
            end
        end
    else
        self.clicking = nil
    end

    if self.clicking then
        if self.clicking.drag then
            self.clicking:drag(x, y)
            self.clicking:callback()
        end
    end
end

function settings:renderUi()
    for _, ui in ipairs(self.ui) do
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
function settings:setPosition(x, y)
    self.x = x
    self.y = y
end

function settings:load()
    if love.filesystem.getInfo("settings.json") then
        local fileData = love.filesystem.read("settings.json")
        local settingsArray = lunajson.decode(fileData)

        for i, ui in ipairs(self.ui) do
            ui.value = ((settingsArray[i] or ui.value))
        end
    end
end

function settings:save()
    valuesToSave = {}

    for _, ui in ipairs(self.ui) do
        table.insert(valuesToSave, ui.value)
    end

    local jsonString = lunajson.encode(valuesToSave)
    love.filesystem.write("settings.json", jsonString)
end