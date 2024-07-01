local g3d = require "g3d"
local collisions = require "g3d/collisions"
gun = {}

function gun:fire(x, y, z, cameraLookVectorX, cameraLookVectorY, cameraLookVectorZ, collisionModels)
    for _,model in ipairs(collisionModels) do
        print(model:rayIntersection(x, y, z, cameraLookVectorX, cameraLookVectorY, cameraLookVectorZ))
    end
end