local shaderParser = {
    shaders = {}
}

-- gracis https://www.lua.org/pil/20.1.html
local function findAllPasses(string)
    local t = {}
    local i = 0
    while true do
        i = string.find(string, "pass {", i+1)
        if i == nil then
            table.insert(t, #string + 1)
            break
        end
        table.insert(t, i)
    end
    return t
end

function shaderParser:loadShader(vertexShader, fragmentShader)
    local shader = {}

    local subShaders = {}
    local variables = ""

    local fragShaderString = love.filesystem.read(fragmentShader)

    local previousValue = -6 -- to counter the + 5
    local firstIndex = true
    for _, v in pairs(findAllPasses(fragShaderString)) do
        if firstIndex then
            variables = string.sub(fragShaderString, previousValue + 6, v - 1)
            firstIndex = false
        else

            local subshaderString = string.sub(fragShaderString, previousValue + 6, v - 3) -- -3 clips the last '}' off
            local nameEnd = string.find(subshaderString, "\n", 2) or 0
            local name = string.sub(subshaderString, 2, nameEnd) -- first char is always new line

            local shaderCodeString = string.sub(subshaderString, nameEnd, #subshaderString - 1)

            table.insert(subShaders, {name = name, code = shaderCodeString})
        end
        previousValue = v
    end
    for _, v in ipairs(subShaders) do
    --     print(_)
    --     for k, val in pairs(v) do
    --         print("k: " .. k .. " v: " .. val)
    --     end
        shader = love.graphics.newShader("shaders/lighting.vert", variables .. v.code)
    end


    -- shader = love.graphics.newShader("shaders/lighting.vert", variables .. )
    return shader
end

return shaderParser