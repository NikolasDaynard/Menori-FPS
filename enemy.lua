local g3d = require "g3d"
local iqm = require "iqm-exm"
local vectors = require "g3d/vectors"
require("entities")
-- local Player = require("player")

enemy = {
    model = g3d.newModel("assets/shopkeep.obj", "assets/gradient.jpeg", {.1,-3,.1}, {0, 0, 0}, {-1,-1,1}),
    tazers = g3d.newModel("assets/tazer.obj", "assets/gradient.jpeg", {0, -2.2, 18.6}, {0, 0, 0}, {-1,-1,1}),
    tazers2 = g3d.newModel("assets/tazer.obj", "assets/gradient.jpeg", {0, -2.2, 21.3}, {0, 0, 0}, {-1,-1,1}),
    hitVis = g3d.newModel("assets/hit.obj", "assets/gradient.jpeg", {0, -2.2, 21.3}, {0, 0, 0}, {-10,-1,10}),
    health = 30,
    maxHealth = 30,
    position = {x = 0, y = -2.2, z = 20},
    speed = {x = 0, y = 0, z = 0},
    lastSpeed = {x = 0, y = 0, z = 0},
    normal = {x = 0, y = 1, z = 0},
    radius = .5,
    height = 1,
    timer = 0,
}

enemy.states = {
    idle = true,
    zapping = false,
    charging = false,
    protected = false,
    movingTowardsPlayer = false,
    tazePlayerClose = false,
    electrifyDist = false,
    waves = false,
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
        self.position.y = self.position.y -- - ny * (len - self.radius) nope

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
function enemy:collisionTestForPlayer(mx, my, mz, rad, checkModel)
    rad = rad or .2
    local bestLength

    local len, x,y,z, nx,ny,nz = checkModel:capsuleIntersection(
        player.position.x + mx,
        player.position.y + my - 0.15 * player.height,
        player.position.z + mz,
        player.position.x + mx,
        player.position.y + my + 0.5 * player.height,
        player.position.z + mz,
        0.2
    )

    if len then
        return true
    end

    return nil
end

entityHolder:addEntity(enemy, 8)

function enemy:render()
    self.model:draw()
    self.tazers:draw()
    self.tazers2:draw()
    self.hitVis:draw()
end

function enemy:repickState()
    local vectorToPlayer = {x = self.position.x - player:getPosition().x, y = self.position.y - player:getPosition().y, z = self.position.z - player:getPosition().z}

    if vectorToPlayer.x + vectorToPlayer.z < .2 then
        self.states.tazePlayerClose = true
        self.states.movingTowardsPlayer = true
        self.states.idle = false
    end
    if not self.states.idle then
        if vectorToPlayer.x + vectorToPlayer.z > 10 then
            self.states.tazePlayerClose = false
            self.states.zapping = false
            self.states.electrifyDist = true
            self.states.movingTowardsPlayer = false
        end
        if vectorToPlayer.y > 4 then
            self.states.tazePlayerClose = false
            self.states.electrifyDist = false
            self.states.zapping = true -- for when camping on the shelves
            self.states.movingTowardsPlayer = false
        end
    end
end

-- boss doesn't move a lot 
function enemy:update(dt)
    if self.states.idle then
        self.health = 30
        enemy:repickState()
    end
    self.timer = self.timer + dt
    -- entityHolder:addEntity(enemy, 8)
    -- print(player:getPosition())
    local friction = .8
    local maxFallSpeed = .3

    self.speed.y = 0 --math.min(self.speed.y + .7, maxFallSpeed)
    self.speed.x = self.speed.x * friction

    self.speed.z = self.speed.z * friction
    local vectorToPlayer = {x = self.position.x - player:getPosition().x, y = self.position.y - player:getPosition().y, z = self.position.z - player:getPosition().z}

    if self.states.movingTowardsPlayer then
        local vectorToPlayer = {x = self.position.x - player:getPosition().x, y = self.position.y - player:getPosition().y, z = self.position.z - player:getPosition().z}
        local vectorX, vectorY, vectorZ = vectorToPlayer.x, vectorToPlayer.y, vectorToPlayer.z
        self.speed.x = ((((vectorX) / 1 * dt) * 10) / math.abs(vectorToPlayer.x))
        -- self.position.y = self.position.y - vectorY / 1 * dt
        self.speed.z = ((((vectorZ) / 1 * dt) * 10) / math.abs(vectorToPlayer.z))

        self.speed.x = self.speed.x / 2
        self.speed.z = self.speed.z / 2

        -- self.speed.x, _, self.speed.z, nx, ny, nz = self:moveAndSlide(-self.speed.x, 0, -self.speed.z)
        self.speed.x = self.speed.x * 2
        self.speed.z = self.speed.z * 2
    end
    if self.states.tazePlayerClose then
        self.hitVis:setScale(1,1,1)
        if enemy:collisionTestForPlayer(0, -player.position.y, 0, 0, self.hitVis) then
            player.health = player.health - 20
        end
        -- print(self.timer)
        if self.timer >= 5 then
            self.timer = 0
            self.hitVis:setScale(10,10,10)
            enemy:repickState()
        end
    end
    if self.states.electrifyDist then
        self.hitVis:setScale(40,1,50)
        self.hitVis:setTranslation(0, 0, 5)
        if self.timer >= 5 then
            if enemy:collisionTestForPlayer(0, -player.position.y, 0, 0, self.hitVis) then
                player.health = player.health - 50
            end
            self.hitVis:setScale(40,100,50)
            self.timer = 0
            enemy:repickState()
        end
    end

    if self.states.zapping then
        local vectorToPlayer = {x = self.position.x - player:getPosition().x, y = self.position.y - player:getPosition().y, z = self.position.z - player:getPosition().z}
        self.model:setRotation(0, -math.atan2(vectorToPlayer.z, vectorToPlayer.x), 0)
        self.hitVis:setScale(1,1,1)
        local step = .1
        
        self.hitVis:setTranslation(lerp(self.hitVis.translation[1], player:getPosition().x, step), 
            lerp(self.hitVis.translation[2], player:getPosition().y, step),
            lerp(self.hitVis.translation[3], player:getPosition().z, step))

        if enemy:collisionTestForPlayer(0, 0, 0, 0, self.hitVis) then
            player.health = player.health - 1
        end
        if self.timer >= 5 then
            self.timer = 0
            self.hitVis:setScale(20,100,30)
            enemy:repickState()
        end
    end


    self.model:setTranslation(self.position.x, self.position.y, self.position.z)


    -- if (enemy:collisionTestForEntity(0, 0, 0, 0)) == player then
    --     print("plater")
    -- end

    -- print(self.health)

    if self.health <= 0 then
        self = nil
        entityHolder:removeEntity(enemy, 8)
    end
end