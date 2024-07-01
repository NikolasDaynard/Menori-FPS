local g3d = require "g3d"
local vectors = require "g3d/vectors"
require("entities")
-- local Player = require("player")

enemy = {
    model = g3d.newModel("assets/enemy.obj", nil, {-1,-3,0}, {0, 0, 0}, {1,1,1}),
    health = 1,
    position = {x = -1, y = 0-3, z = 0}
}

entityHolder:addEntity(enemy, 8)

function enemy:render()
    self.model:draw()
end

-- function enemy:render()
--     self.model:draw()
-- end

function enemy:update(dt)
    -- entityHolder:addEntity(enemy, 8)
    -- print(player:getPosition())

    vectorToPlayer = {x = self.position.x - player:getPosition().x, y = self.position.y - player:getPosition().y, z = self.position.z - player:getPosition().z}
    local vectorX, vectorY, vectorZ = vectors.normalize(vectorToPlayer.x, vectorToPlayer.y, vectorToPlayer.z)
    self.position.x = self.position.x - vectorX / 1 * dt
    self.position.y = self.position.y - vectorY / 1 * dt
    self.position.z = self.position.z - vectorZ / 1 * dt
    self.model:setTranslation(self.position.x, self.position.y, self.position.z)

    print(self.health)

    if self.health <= 0 then
        self = nil
    end
end