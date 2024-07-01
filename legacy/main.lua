local menori = require 'menori'

local scene_iterator = 1
local example_list = {
	{ title = "testing", path = "scenes.testing.scene" },
	-- { title = "basic_lighting", path = "examples.basic_lighting.scene" },
	-- { title = "SSAO", path = "examples.SSAO.scene" },
}
for _, v in ipairs(example_list) do
	local Scene = require(v.path)
	menori.app:add_scene(v.title, Scene())
end
menori.app:set_scene('testing')

function love.draw()
	menori.app:render()

	local font = love.graphics.getFont()
	local w, h = love.graphics.getDimensions()
end

function love.update(dt)
	menori.app:update(dt)

	if love.keyboard.isDown('escape') then
		love.event.quit()
	end
	love.mouse.setRelativeMode(love.mouse.isDown(2))
end

local function set_scene()
	menori.app:set_scene(example_list[scene_iterator].title)
end

function love.wheelmoved(...)
	menori.app:handle_event('wheelmoved', ...)
end
function love.keyreleased(key, ...)
	menori.app:handle_event('keyreleased', key, ...)
end
function love.keypressed(...)
	menori.app:handle_event('keypressed', ...)
end
function love.mousemoved(...)
	menori.app:handle_event('mousemoved', ...)
end