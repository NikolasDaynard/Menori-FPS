local menori = require 'menori'
require("collision")

local ml = menori.ml
local vec3 = ml.vec3


player = {
    position = vec3(0, 0, 0),
    momentum = vec3(0, 0, 0),
    drag = .84,
    defaultDrag = .84,
    movementSpeed = 100,
    jumpForce = 40,
    cameraAngle = {x = 0, y = -30},
    yAngleLimits = {max = 80, min = -70},
    touchingGround = false,
}

player.movementSpeed = player.movementSpeed * (1 / player.drag) -- adust for drag

function player:move(x, y, dt)
    y = -y
    dt = dt or .016
    self.momentum.x = self.momentum.x + (x * self.movementSpeed * dt) * math.cos(math.rad(-self.cameraAngle.x)) - (y * self.movementSpeed * dt) * math.sin(math.rad(-self.cameraAngle.x))
    self.momentum.z = self.momentum.z - (x * self.movementSpeed * dt) * math.sin(math.rad(self.cameraAngle.x)) + (y * self.movementSpeed * dt) * math.cos(math.rad(self.cameraAngle.x))
end

function player:update(dt)
    self.position = self.position + self.momentum * dt
    if love.keyboard.isDown("lshift") then
        self.drag = 1
    else
        self.drag = self.defaultDrag
        self.momentum.x = self.momentum.x * self.drag
        self.momentum.z = self.momentum.z * self.drag
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

    self.momentum.y = self.momentum.y - 2
    if love.keyboard.isDown("space") and self.touchingGround then
        self.touchingGround = false
        player.momentum.y = player.momentum.y + self.jumpForce
    end
    if self.position.y < 1 then
        self.position.y = 1
        self.momentum.y = 0
        self.touchingGround = true
    end
    local col = collision:checkCollisions({p1 = self.position, p2 = (self.position + vec3(1, 1, 1))})
    if col then
        collisionVector = collision:vectorToPoint(collision:colliderCenter(col), collision:colliderCenter({p1 = self.position, p2 = (self.position + vec3(1, 1, 1))}))
        if collisionVector.y >= -.1 then
            -- self.position.y = math.min(self.position.y - collisionVector.y / 10, 5)
            -- self.position.z = math.min(self.position.z - collisionVector.z / 10, 5)
            -- self.position.x = math.min(self.position.x - collisionVector.x / 10, 5)
        else
            self.touchingGround = true
            self.momentum.y = 0
        end
        self.position.y = math.min(self.position.y - collisionVector.y / 10, 5)
        self.position.z = math.min(self.position.z - collisionVector.z / 10, 5)
        self.position.x = math.min(self.position.x - collisionVector.x / 10, 5)
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
function player:getPosition()
    return self.position
end