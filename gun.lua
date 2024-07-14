local g3d = require "g3d"
-- local camera = require "g3d/camera"
local collisions = require "g3d/collisions"
require("particles")

gun = {
    currentTime = 0,
    firerate = 1,
}
local gunMesh = g3d.newModel("assets/shockGun.obj", nil, nil, nil, {-1, -1, 1})
local hitMesh = g3d.newModel("assets/icoSphere.obj", "assets/tileset.png", nil, nil, {-1, -1, 1})

function gun:fire(playerX, playerY, playerZ, cameraLookVectorX, cameraLookVectorY, cameraLookVectorZ, collisionModels)
    angle = math.atan2(cameraLookVectorZ, cameraLookVectorX)
    translationX = math.cos(angle) / 2
    translationZ = math.sin(angle) / 2
    for i = 1, 30 do
        local rand = math.random()
        -- particles:addParticle(playerX, playerY - .3, playerZ, translationX + math.cos(rand) / 10, math.cos(math.random()) / 10, translationZ + math.sin(rand) / 10)
    end

    collisionModels = entityHolder:getEntities()
    local intersection = {}
    intersection.distance = math.huge
    local hitModel = nil
    for _,entity in pairs(collisionModels) do
        local distance, x, y, z, nx, ny, nz = entity.model:rayIntersection(playerX, playerY, playerZ, cameraLookVectorX, cameraLookVectorY, cameraLookVectorZ)
        if (distance or math.huge) < intersection.distance then
            intersection = {distance = distance, x = x, y = y, z = z, nx = nx, ny = ny, nz = nz}
            hitModel = entity.model
        end
    end
    if hitModel then
        hitMesh:setTranslation(intersection.x, intersection.y, intersection.z)
        local entity = entityHolder:getEntityFromModel(hitModel)
        if self.currentTime > self.firerate then
            audio:playSound("audio/tu.wav", false, false)
            self.currentTime = 0
            if entity.health then
                local rand = math.random()
                particles:addParticle(intersection.x, intersection.y, intersection.z, translationX + math.cos(rand) / 10, math.cos(math.random()) / 10 - .05, translationZ + math.sin(rand) / 10)
                entity.health = entity.health - 1
            end
        end
    end
end

function gun:update(dt)
    self.currentTime = self.currentTime + dt
end

function gun:render(shader)
    shader = shader or nshader
    gunMesh:updateMatrix()

    love.graphics.setColor(.1, .1, 1)
    gunMesh:draw(shader)
    love.graphics.setColor(1, 1, 1)
    hitMesh:draw()
end

function gun:updatePos(positionX, positionY, positionZ, playerViewDirX, playerViewDirY, playerViewDirZ)
    angle = -math.atan2(playerViewDirZ, playerViewDirX)- (math.pi / 2)
    translationY = (math.atan2(playerViewDirY, 1))
    translationX = -math.sin(angle + .5) / 2
    translationZ = -math.cos(angle + 1) / 2
    -- print(angle)
    gunMesh:setRotation(translationX * translationY, angle, translationZ * translationY)

    gunMesh:setTranslation(positionX + translationX, positionY + (translationY / 3), positionZ + translationZ)
end