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

function entityHolder:getEntities()
    return self.entities
end