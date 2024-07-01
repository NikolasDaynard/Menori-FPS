local g3d = require "g3d"
local vectors = require "g3d/vectors"
require("gun")

-- TODO:
-- on-the-fly stepDownSize calculation based on normal vector of triangle
-- mario 64 style sub-frames for more precise collision checking

local function getSign(number)
    return (number > 0 and 1) or (number < 0 and -1) or 0
end

local function round(number)
    if number then
        return math.floor(number*1000 + 0.5)/1000
    end
    return "nil"
end

local Player = {}
Player.__index = Player

function Player:new(x,y,z)
    local self = setmetatable({}, Player)
    local vectorMeta = {}

    self.position = {x = 0, y = 0, z = 0}
    self.speed = {x = 0, y = 0, z = 0}
    self.lastSpeed = {x = 0, y = 0, z = 0}
    self.normal = {x = 0, y = 1, z = 0}
    self.radius = 0.2
    self.onGround = false
    self.slidingVector = nil
    self.height = 1
    self.stepDownSize = 0.075
    self.collisionModels = {}

    return self
end

function Player:addCollisionModel(model)
    table.insert(self.collisionModels, model)
    return model
end

-- collide against all models in my collision list
-- and return the collision against the closest one
function Player:collisionTest(mx,my,mz)
    local bestLength, bx,by,bz, bnx,bny,bnz

    for _,model in ipairs(self.collisionModels) do
        local len, x,y,z, nx,ny,nz = model:capsuleIntersection(
            self.position.x + mx,
            self.position.y + my - 0.15 * self.height,
            self.position.z + mz,
            self.position.x + mx,
            self.position.y + my + 0.5 * self.height,
            self.position.z + mz,
            0.2
        )

        if len and (not bestLength or len < bestLength) then
            bestLength, bx, by, bz, bnx, bny, bnz = len, x, y, z, nx, ny, nz
        end
    end

    return bestLength, bx,by,bz, bnx,bny,bnz
end

function Player:moveAndSlide(mx,my,mz)
    local len,x,y,z,nx,ny,nz = self:collisionTest(mx,my,mz)

    self.position.x = self.position.x + mx
    self.position.y = self.position.y + my
    self.position.z = self.position.z + mz

    local ignoreSlopes = ny and ny < -0.7

    if len then
        local speedLength = math.sqrt(mx^2 + my^2 + mz^2)

        if speedLength > 0 then
            self.normal = {x = mx / speedLength, y = my / speedLength, z = mz / speedLength}
            local dot = self.normal.x * nx + self.normal.y * ny + self.normal.z * nz
            local push = {x = nx * dot, y = ny * dot, z = nz * dot}

            -- modify output vector based on normal
            my = (self.normal.y - push.y) * speedLength
            if ignoreSlopes then my = 0 end

            if not ignoreSlopes then
                mx = (self.normal.x - push.x) * speedLength
                mz = (self.normal.z - push.z) * speedLength
            end
        end

        -- rejections
        self.position.y = self.position.y - ny * (len - self.radius)

        if not ignoreSlopes then
            self.position.x = self.position.x - nx * (len - self.radius)
            self.position.z = self.position.z - nz * (len - self.radius)
        end
    end

    return mx, my, mz, nx, ny, nz
end

function Player:update()
    -- collect inputs
    local moveX, moveY = 0, 0
    local speed = .05
    local friction = 0.75
    local gravity = 0.02
    local jump = .5
    local maxFallSpeed = .3

    -- friction
    self.speed.x = self.speed.x * friction
    self.speed.z = self.speed.z * friction

    -- gravity
    self.speed.y = math.min(self.speed.y + gravity, maxFallSpeed)

    if love.keyboard.isDown("w") then moveY = moveY - 1 end
    if love.keyboard.isDown("a") then moveX = moveX - 1 end
    if love.keyboard.isDown("s") then moveY = moveY + 1 end
    if love.keyboard.isDown("d") then moveX = moveX + 1 end

    if love.keyboard.isDown("lshift") then
        if not self.slidingVector then
            self.slidingVector = {self.speed.x * 1.2, self.speed.z * 1.2}
            self.height = .01
        end
    else
        self.slidingVector = nil
        self.height = 1
    end

    if love.keyboard.isDown("space") then
        if self.onGround then
            self.speed.y = self.speed.y - jump
        else
            for _,model in ipairs(self.collisionModels) do
                local len, x,y,z, nx,ny,nz = model:capsuleIntersection(
                    self.position.x + .1,
                    self.position.y + .1 - 0.15 * self.height,
                    self.position.z + .1,
                    self.position.x - .1,
                    self.position.y - .1 + 0.5 * self.height,
                    self.position.z - .1,
                    0.3
                )
                if len ~= nil and self.speed.y >= 0 then
                    self.speed.y = self.speed.y - jump
    
                    local vector = {self.position.x - x, self.position.z - z}
                    local vectorX, _, vectorZ = vectors.normalize(vector[1], 0, vector[2])
                    self.speed.x = self.speed.x + vectorX
                    self.speed.z = self.speed.z + vectorZ
                    break
                end
            end
        end
    end
    if love.mouse.isDown(1) then
        local vectorX, vectorY, vectorZ = g3d.camera:getLookVector()
        gun:fire(self.position.x, self.position.y, self.position.z, vectorX, vectorY, vectorZ, self.collisionModels)
    end

    -- do some trigonometry on the inputs to make movement relative to camera's direction
    -- also to make the player not move faster in diagonal directions
    if (moveX ~= 0 or moveY ~= 0) or self.slidingVector then
        if not self.slidingVector then
            ---@diagnostic disable-next-line: deprecated
            local angle = math.atan2(moveY,moveX)
            local direction = g3d.camera.getDirectionPitch()
            local directionX, directionZ = math.cos(direction + angle)*speed, math.sin(direction + angle + math.pi)*speed

            self.speed.x = self.speed.x + directionX
            self.speed.z = self.speed.z + directionZ
        else
            self.speed.x = self.slidingVector[1]
            self.speed.z = self.slidingVector[2]
        end
    end

    local _, nx, ny, nz

    -- vertical movement and collision check

    _, self.speed.y, _, nx, ny, nz = self:moveAndSlide(0, self.speed.y / 2, 0)
    -- if self.speed.y > 0 and se:collisionTest(0, -.1, 0) then
    --     print("clipping")
    -- end

    -- ground check
    local wasOnGround = self.onGround
    self.onGround = ny and ny < -0.7

    -- smoothly walk down slopes
    if not self.onGround and wasOnGround and self.speed.y > 0 then
        local len, x, y, z, nx, ny, nz = self:collisionTest(0, self.stepDownSize, 0)
        local mx, my, mz = 0, self.stepDownSize, 0
        if len then
            -- do the position change only if a collision was actually detected
            self.position.y = self.position.y + my

            local speedLength = math.sqrt(mx^2 + my^2 + mz^2)

            if speedLength > 0 then
                local xNorm, yNorm, zNorm = mx / speedLength, my / speedLength, mz / speedLength
                local dot = xNorm * nx + yNorm * ny + zNorm * nz
                local xPush, yPush, zPush = nx * dot, ny * dot, nz * dot

                -- modify output vector based on normal
                my = (yNorm - yPush) * speedLength
            end

            -- rejections
            self.position.y = self.position.y - ny * (len - self.radius)
            self.speed.y = 0
            self.onGround = true
        end
    end

    -- wall movement and collision check
    self.speed.x, _, self.speed.z, nx, ny, nz = self:moveAndSlide(self.speed.x, 0, self.speed.z)

    self.lastSpeed.x = self.speed.x
    self.lastSpeed.y = self.speed.y
    self.lastSpeed.z = self.speed.z
    g3d.camera.position[1] = self.position.x
    g3d.camera.position[2] = self.position.y - .5 * self.height
    g3d.camera.position[3] = self.position.z
    g3d.camera.lookInDirection()

    local vectorX, vectorY, vectorZ = g3d.camera:getLookVector()
    gun:updatePos(self.position.x, self.position.y - .2 * self.height, self.position.z, vectorX, vectorY, vectorZ)
end

function Player:interpolate(fraction)
    -- interpolate in every direction except down
    -- because gravity/floor collisions mean that there will often be a noticeable
    -- visual difference between the interpolated position and the real position

    g3d.camera.position[1] = self.position.x + self.speed.x*fraction
    -- g3d.camera.position[2] = (self.position.y + self.speed.y*fraction) - .25 * self.height
    g3d.camera.position[3] = self.position.z + self.speed.z*fraction

    g3d.camera.lookInDirection()
end

function Player:render()
    gun:render()
end

return Player
