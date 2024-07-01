local menori = require 'menori'
local ml = menori.ml
local vec3 = ml.vec3

collision = {
    colliders = {}
}

function collision:bbcollide(p1min, p1max, p2min, p2max)
    return(p1max.x > p2min.x and
        p1min.x < p2max.x and
        p1max.y > p2min.y and
        p1min.y < p2max.y and
        p1max.z > p2min.z and
        p1min.z < p2max.z);
end

function collision:vectorToPoint(startPoint, endPoint)
    local newPoint = startPoint - endPoint
    return (newPoint) / (math.max(math.max(math.abs(newPoint.x), math.abs(newPoint.y)), math.abs(newPoint.z)))
end

function collision:collisionSetCollider(collider)
    table.insert(self.colliders, collider)
end

-- checks all collisions and returns a colldier
function collision:checkCollisions(collider)
    for _, otherCollider in ipairs(self.colliders) do
        if collision:bbcollide(collider.p1, collider.p2, otherCollider.p1, otherCollider.p2) then
            return otherCollider
        end
    end
end

function collision:colliderCenter(collider)
    return collider.p1 - (collider.p2 / 2)
end

function collision:generateAABBFromVerts(verticies)
    local p1 = vec3(-math.huge, -math.huge, -math.huge)
    local p2 = vec3(math.huge, math.huge, math.huge)
    for _, vert in ipairs(verticies) do
        p1.x = math.min(p1.x, vert.x)
        p1.y = math.min(p1.y, vert.y)
        p1.z = math.min(p1.z, vert.z)

        p2.x = math.max(p2.x, vert.x)
        p2.y = math.max(p2.y, vert.y)
        p2.z = math.max(p2.z, vert.z)
    end

    return {p1, p2}
end