local g3d = require "g3d"
require("entities")
local Player = require("player")

enemy = {
    model = g3d.newModel("assets/enemy.obj", "assets/starfield.png", {-1,-3,0}, {0, 0, 0}, {1,1,1}),
    health = 1000,
}

entityHolder:addEntity(enemy, 8)

function enemy:render()
    self.model:draw()
end

-- function enemy:render()
--     self.model:draw()
-- end

function enemy:update()
    -- entityHolder:addEntity(enemy, 8)
    print(Player.getPosition())
end