local g3d = require "g3d"
local collisions = require "g3d/collisions"
gun = {}
local gunMesh = g3d.newModel("assets/gu.obj", "assets/tileset.png", nil, nil, {-1, -1, 1})
local hitMesh = g3d.newModel("assets/icoSphere.obj", "assets/tileset.png", nil, nil, {-1, -1, 1})

function gun:fire(playerX, playerY, playerZ, cameraLookVectorX, cameraLookVectorY, cameraLookVectorZ, collisionModels)
    local intersection = {}
    intersection.distance = math.huge
    for _,model in ipairs(collisionModels) do
        local distance, x, y, z, nx, ny, nz = model:rayIntersection(playerX, playerY - .3, playerZ, cameraLookVectorX, cameraLookVectorY, cameraLookVectorZ)
        if (distance or math.huge) < intersection.distance then
            intersection = {distance = distance, x = x, y = y, z = z, nx = nx, ny = ny, nz = nz}
        end
    end
    if intersection.x then
        hitMesh:setTranslation(intersection.x, intersection.y, intersection.z)
    end
end

function gun:render()
    gunMesh:draw()
    hitMesh:draw()
end

function gun:updatePos(positionX, positionY, positionZ, playerViewDirX, playerViewDirY, playerViewDirZ)
    angle = math.atan2(playerViewDirZ, playerViewDirX)
    translationY = (math.atan2(playerViewDirY, 1))
    translationX = math.cos(angle) / 2
    translationZ = math.sin(angle) / 2
    gunMesh:setRotation(-translationY, -angle - (math.pi / 2), 0)

    gunMesh:setTranslation(positionX + translationX, positionY + (translationY / 3), positionZ + translationZ)
end