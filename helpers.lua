-- shamelessly stolen
function deepCopy(original)
    local copy = {}
    for k, v in pairs(original) do
        if type(v) == "table" then
            copy[k] = deepCopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

function lerp(a, b, t)
    return a + (b - a) * t
end

function updateShader(shader, mesh)
    mesh:updateMatrix()
    g3d.camera.projectionMatrix:setProjectionMatrix(g3d.camera.fov, g3d.camera.nearClip, g3d.camera.farClip, g3d.camera.aspectRatio);
    shader:send("projectionMatrix", g3d.camera.projectionMatrix)

    g3d.camera.viewMatrix:setViewMatrix(g3d.camera.position, g3d.camera.target, g3d.camera.down);
    shader:send("viewMatrix", g3d.camera.viewMatrix)

    g3d.camera.viewMatrix:setViewMatrix(g3d.camera.position, g3d.camera.target, g3d.camera.down);
    shader:send("lights", {0, 0, 0, 10}, {0, 20, 30, 10})
end