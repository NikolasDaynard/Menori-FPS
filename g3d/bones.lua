local bones = {
    testTike = 0
}

function bones:addBone(model, name)
    model.animated = true
end

function bones:test(model, dt)
    self.testTike = self.testTike + dt
    local mesh = model.mesh
    for i = 1, mesh:getVertexCount() do
        -- The 3rd vertex attribute for a standard mesh is its color.
        mesh:setVertexAttribute(i, 5,
             0, 10, 10, 10) -- 5 is index of VertexBone
    end
end

return bones