local g3d = require "g3d"
require("helpers")

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
        print(dx)
        return x + dx, y + dy, z + dz, dx, dy, dz
    end
    table.insert(self.particles, {x = particleX, y = particleY, z = particleZ, dx = particleDX, dy = particleDY, dz = particleDZ, t = 0, updateCallback = updateCallback, particleModel = particleModel}) 
end

function particles:update(dt)
    for _, particle in ipairs(self.particles) do
        if particle.updateCallback then -- updateCallback
            local x, y, z, dx, dy, dz, colR, colG, colB = particle.updateCallback(particle.x, particle.y, particle.z, particle.dx, particle.dy, particle.dz, particle.t)
            particle.x, particle.y, particle.z = x, y, z
            particle.dx, particle.dy, particle.dz = dx, dy, dz

            particle.t = dt -- time 
            particle.particleModel:setTranslation(x, y, z)
            particle.particleModel:setScale(1, 1, 1)
        end
    end
end

function particles:render()
    for _, particle in ipairs(self.particles) do
        particle.particleModel:draw()
    end
end