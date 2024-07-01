local menori = require 'menori'

local ml = menori.ml
local vec3 = ml.vec3


player = {
    position = vec3(0, 0, 0),
    movementSpeed = 20,
    cameraAngle = {x = 0, y = -30},
    yAngleLimits = {max = 80, min = -70}
}

function player:getPosition()
    return self.position
end

function player:move(x, y, dt)
    y = -y
    dt = dt or .016
    self.position.x = self.position.x + (x * self.movementSpeed * dt) * math.cos(math.rad(-self.cameraAngle.x)) - (y * self.movementSpeed * dt) * math.sin(math.rad(-self.cameraAngle.x))
    self.position.z = self.position.z - (x * self.movementSpeed * dt) * math.sin(math.rad(self.cameraAngle.x)) + (y * self.movementSpeed * dt) * math.cos(math.rad(self.cameraAngle.x))
end

function player:update(dt)
    if love.keyboard.isDown("w") then
        player:move(0, 1, dt)
    end
    if love.keyboard.isDown("a") then
        player:move(-1, 0, dt)
    end
    if love.keyboard.isDown("s") then
        player:move(0, -1, dt)
    end
    if love.keyboard.isDown("d") then
        player:move(1, 0, dt)
    end
end

function player:updateCam(dx, dy)
    if (self.cameraAngle.y - dy) > self.yAngleLimits.min and (self.cameraAngle.y - dy) < self.yAngleLimits.max then
        self.cameraAngle.y = self.cameraAngle.y - dy
    end
    self.cameraAngle.x = self.cameraAngle.x - dx
end

function player:getXAngle()
    return self.cameraAngle.x
end
function player:getYAngle()
    return self.cameraAngle.y
end