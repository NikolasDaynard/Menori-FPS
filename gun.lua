local g3d = require "g3d"
local collisions = require "g3d/collisions"
gun = {}
local gunMesh = g3d.newModel("assets/gu.obj", "assets/tileset.png", nil, nil, {-1, -1, 1})

function gun:fire(x, y, z, cameraLookVectorX, cameraLookVectorY, cameraLookVectorZ, collisionModels)
    for _,model in ipairs(collisionModels) do
        print(model:rayIntersection(x, y, z, cameraLookVectorX, cameraLookVectorY, cameraLookVectorZ))
    end
end

function gun:render()
    gunMesh:draw()
end

function gun:updatePos(positionX, positionY, positionZ, playerViewDirX, playerViewDirY, playerViewDirZ)
    angle = math.atan2(playerViewDirZ, playerViewDirX)
    translationY = math.sin(math.atan(playerViewDirY))
    translationX = math.cos(angle) / 2
    translationZ = math.sin(angle) / 2
    gunMesh:setRotation(-translationY, -angle - (math.pi / 2), 0)

    gunMesh:setTranslation(positionX + translationX, positionY, positionZ + translationZ)
end