entityHolder = {
    entities = {}
}

-- adds a loaded model into the array of all models
function entityHolder:addEntity(entity, id)
    self.entities[id] = entity
end

function entityHolder:getEntityFromModel(model)
    for k, v in pairs(self.entities) do
        if v.model == model then
            return v
        end
    end
end

function entityHolder:renderEntities()
    for k, v in pairs(self.entities) do
        if v.render then
            v:render()
        else
            v.model:draw()
        end
    end
end

function entityHolder:updateEntities(dt)
    for k, v in pairs(self.entities) do
        if v.update then
            v:update(dt)
        end
    end
end

function entityHolder:getEntities()
    return self.entities
end
function entityHolder:removeEntity(entity, id)
    self.entities[id] = nil
end