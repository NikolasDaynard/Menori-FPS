local g3d = require "g3d"
-- local camera = require "g3d/camera"
local collisions = require "g3d/collisions"
require("particles")
local nshader = love.graphics.newShader [[
    uniform mat4 projectionMatrix;
    uniform mat4 modelMatrix;
    uniform mat4 viewMatrix;

    varying vec4 vertexColor;

    #ifdef VERTEX
        vec4 position(mat4 transform_projection, vec4 vertex_position)
        {
            vertexColor = VertexColor;
            return projectionMatrix * viewMatrix * modelMatrix * vertex_position;
        }
    #endif

    #ifdef PIXEL
        vec4 effect(vec4 color, Image tex, vec2 texcoord, vec2 pixcoord)
        {
            vec4 texcolor = Texel(tex, vec2(texcoord.x, 1-texcoord.y));
            if (texcolor.a == 0.0) { discard; }
            return vec4(texcolor)*color*vertexColor;
        }
    #endif
]]

gun = {
    currentTime = 0,
    firerate = 1,
}
local gunMesh = g3d.newModel("assets/shockGun.obj", "assets/tileset.png", nil, nil, {-1, -1, 1})
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
        local distance, x, y, z, nx, ny, nz = entity.model:rayIntersection(playerX, playerY - .3, playerZ, cameraLookVectorX, cameraLookVectorY, cameraLookVectorZ)
        if (distance or math.huge) < intersection.distance then
            intersection = {distance = distance, x = x, y = y, z = z, nx = nx, ny = ny, nz = nz}
            hitModel = entity.model
        end
    end
    if hitModel then
        hitMesh:setTranslation(intersection.x, intersection.y, intersection.z)
        local entity = entityHolder:getEntityFromModel(hitModel)
        if self.currentTime > self.firerate then
            gunAudio:play()
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

function gun:render()
    gunMesh:updateMatrix()
    g3d.camera.projectionMatrix:setProjectionMatrix(g3d.camera.fov, g3d.camera.nearClip, g3d.camera.farClip, g3d.camera.aspectRatio);
    nshader:send("projectionMatrix", g3d.camera.projectionMatrix)
    g3d.camera:updateViewMatrix(nshader)
    gunMesh:draw(nshader)
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