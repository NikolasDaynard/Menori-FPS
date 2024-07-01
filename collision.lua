Menori = require("menori")

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

function collision:collisionSetCollider(collider, id)
    self.colliders[id] = collider
end

-- checks all collisions and returns a colldier
function collision:checkCollisions(collider, id)
    for _, otherCollider in ipairs(self.colliders) do
        if collision:bbcollide(collider.p1, collider.p2, otherCollider.p1, otherCollider.p2) then
            return otherCollider
        end
    end
end

function collision:colliderCenter(collider)
    return collider.p1 - (collider.p2 / 2)
end