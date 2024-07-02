local g3d = require "g3d"
require("helpers")
-- local shader = love.graphics.newShader(g3d.shaderpath, "shaders/particle.glsl")

-- purely the visual effect, no game logic happens here

particles = {
    particleModel = g3d.newModel("assets/particle.obj", "assets/gradient.jpeg", {.1,-3,.1}, {0, 0, 0}, {-1,-1,1}),
    particles = {}
}

function particles:addParticle(particleX, particleY, particleZ, particleDX, particleDY, particleDZ, updateCallback)
    particleDX = particleDX or 0
    particleDY = particleDY or 0
    particleDZ = particleDZ or 0
    local particleModel = g3d.newModel("assets/particle.obj", "assets/gradient.jpeg", {particleX, particleY, particleZ}, {0, 0, 0}, {-1,-1,1})
    
    updateCallback = updateCallback or function(x, y, z, dx, dy, dz, t)
        -- print(dx)
        if t > 10 then
            return nil
        end
        return x + dx, y + dy, z + dz, dx, dy, dz
    end
    table.insert(self.particles, {x = particleX, y = particleY, z = particleZ, dx = particleDX, dy = particleDY, dz = particleDZ, t = 0, updateCallback = updateCallback, particleModel = particleModel}) 
end

function particles:removeParticle(particleToRemove)
    for i, particle in ipairs(self.particles) do
        if particle == particleToRemove then
            table.remove(self.particles, i)
            return
        end
    end
end

function particles:update(dt)
    for _, particle in ipairs(self.particles) do
        if particle.updateCallback then -- updateCallback
            local x, y, z, dx, dy, dz, colR, colG, colB = particle.updateCallback(particle.x, particle.y, particle.z, particle.dx, particle.dy, particle.dz, particle.t)
            if x then
                particle.x, particle.y, particle.z = x, y, z
                particle.dx, particle.dy, particle.dz = dx, dy, dz

                particle.t = dt -- time 
                particle.particleModel:setTranslation(x, y, z)
                particle.particleModel:setScale(1, 1, 1)
            else
                particles:removeParticle(particle)
                particle.particleModel = nil
                particle.updateCallback = nil
                particle = nil
            end
        end
    end
end

function particles:render()
    for _, particle in ipairs(self.particles) do
        particle.particleModel:draw()
    end
end