local g3d = require "g3d"
local vectors = require "g3d/vectors"
require("entities")
-- local Player = require("player")

enemy = {
    model = g3d.newModel("assets/shopkeep.obj", "assets/gradient.jpeg", {.1,-3,.1}, {0, 0, 0}, {-1,-1,1}),
    health = 1,
    position = {x = 0.1, y = -3, z = 0.1},
    speed = {x = 0, y = 0, z = 0},
    lastSpeed = {x = 0, y = 0, z = 0},
    normal = {x = 0, y = 1, z = 0},
    radius = .5,
    height = 1,
}

function enemy:moveAndSlide(mx,my,mz)
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

-- collide against all models in my collision list
-- and return the collision against the closest one
function enemy:collisionTest(mx, my, mz, rad)
    rad = rad or .2
    local bestLength, bx,by,bz, bnx,bny,bnz

    collisionModels = entityHolder:getEntities()
    for _,entity in pairs(collisionModels) do
        local len, x,y,z, nx,ny,nz = entity.model:capsuleIntersection(
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
    local friction = .8
    local maxFallSpeed = .3

    self.speed.y = 0 --math.min(self.speed.y + .7, maxFallSpeed)
    self.speed.x = self.speed.x * friction
    self.speed.z = self.speed.z * friction

    local vectorToPlayer = {x = self.position.x - player:getPosition().x, y = self.position.y - player:getPosition().y, z = self.position.z - player:getPosition().z}
    local vectorX, vectorY, vectorZ = vectors.normalize(vectorToPlayer.x, vectorToPlayer.y, vectorToPlayer.z)
    self.speed.x = (vectorX + .000001) / 1 * dt
    -- self.position.y = self.position.y - vectorY / 1 * dt
    self.speed.z = (vectorZ + .000001) / 1 * dt

    self.position.x = self.position.x - self.speed.x
    self.position.z = self.position.z - self.speed.z
    print(self.speed.y)
    print(self.speed.y)
    -- _, self.speed.y, _, nx, ny, nz = self:moveAndSlide(0, self.speed.y, 0)
    -- if self.speed.y > 0 and self:collisionTest(0.5, -.1, 0.5, .1) then
    --     -- print("clip")
    --     self.position.y = self.position.y - math.max(self.speed.y * 2, 1)
    --     self.speed.y = 0
    -- end
    -- self.speed.x, _, self.speed.z, nx, ny, nz = self:moveAndSlide(self.speed.x, 0, self.speed.z)
    print(self.speed.y)


    self.model:setTranslation(self.position.x, self.position.y, self.position.z)

    -- print(self.health)

    if self.health <= 0 then
        self = nil
        entityHolder:removeEntity(enemy, 8)
    end
end