local g3d = require "g3d"
local Player = require "player"
local shaderParser = require "g3d/shaderParser"

io.stdout:setvbuf("no")
nshader = love.graphics.newShader("shaders/lighting.vert", "shaders/lighting.frag")
depthShader = love.graphics.newShader("shaders/depth.vert", "shaders/depth.frag")
shadowShader = love.graphics.newShader("shaders/lighting.vert", "shaders/shadowMap.frag")
postProcessShader = love.graphics.newShader("shaders/lighting.vert", "shaders/postProcess.frag")
testShader = shaderParser:loadShader("shaders/lighting.vert", "shaders/testPasses.frag")


local lg = love.graphics
lg.setDefaultFilter("linear")

-- require("cpml")

require("enemy")
require("particles")
require("titlescreen")
require("settings")
require("audio")

local map, background
player = {}
local mainCanvas
local accumulator = 0
local frametime = 1/60
local rollingAverage = {}

function love.load()
    settings:load()
    settings:save()

    lg.setBackgroundColor(0.25,0.5,1)

    map = g3d.newModel("assets/bodyShop.obj", "assets/texture.png", nil, nil, {-1,-1,1})
    background = g3d.newModel("assets/sphere.obj", "assets/starfield.png", {0,0,0}, nil, {500,500,500})
    player = Player:new(0,0,0)
    player:addCollisionModel(map)
    entityHolder:addEntity({model = map}, 1)

    mainCanvas = {lg.newCanvas(1024,576), depth=true}
    postProcessCanvas = {lg.newCanvas(1024,576), depth=true}
    depthCanvas = {lg.newCanvas(1024,576), depth=true, format = "r16f", readable = true}
    shadowCanvas = {lg.newCanvas(1024,576), depth=true, format = "r16f", readable = true}
end

function love.update(dt)
    if settings.open then
        settings:update()
        return
    end
    titlescreen:update()
    -- rolling average so that abrupt changes in dt
    -- do not affect gameplay
    -- the math works out (div by 60, then mult by 60)
    -- so that this is equivalent to just adding dt, only smoother
    table.insert(rollingAverage, dt)
    if #rollingAverage > 60 then
        table.remove(rollingAverage, 1)
    end
    local avg = 0
    for i,v in ipairs(rollingAverage) do
        avg = avg + v
    end

    -- fixed timestep accumulator
    accumulator = accumulator + avg/#rollingAverage
    while accumulator > frametime do
        accumulator = accumulator - frametime
        player:update(dt)
    end
    entityHolder:updateEntities(dt)
    particles:update(dt)

    -- interpolate player between frames
    -- to stop camera jitter when fps and timestep do not match
    player:interpolate(accumulator/frametime)
    background:setTranslation(g3d.camera.position[1],g3d.camera.position[2],g3d.camera.position[3])
end

function love.keypressed(k)
    if love.keyboard.isDown("escape") then
        settings.open = not settings.open
    end
    if k == "w" then
        if player.doubleTapTimer.taps ~= 2 then
            if k ~= player.doubleTapTimer.key then
                player.doubleTapTimer.time = 0
                player.doubleTapTimer.taps = 0
            end
            player.doubleTapTimer.key = k
            player.doubleTapTimer.taps = player.doubleTapTimer.taps + 1
            -- print(player.doubleTapTimer.taps)

            if player.doubleTapTimer.time > .6 then
                player.doubleTapTimer.time = 0
                player.doubleTapTimer.key = ""
                player.doubleTapTimer.taps = 0
            end

            if player.doubleTapTimer.taps == 2 then
                player.doubleTapTimer.taps = -1 -- player checks for taps < 0
                player.doubleTapTimer.time = 0
                player.doubleTapTimer.key = k
            end
        end
    elseif k == "s" then
        if player.doubleTapTimer.taps ~= 2 then
            if k ~= player.doubleTapTimer.key then
                player.doubleTapTimer.time = 0
                player.doubleTapTimer.taps = 0
            end
            player.doubleTapTimer.key = k
            player.doubleTapTimer.taps = player.doubleTapTimer.taps + 1
            -- print(player.doubleTapTimer.taps)

            if player.doubleTapTimer.time > .6 then
                player.doubleTapTimer.time = 0
                player.doubleTapTimer.key = ""
                player.doubleTapTimer.taps = 0
            end

            if player.doubleTapTimer.taps == 2 then
                player.doubleTapTimer.taps = -1 -- player checks for taps < 0
                player.doubleTapTimer.time = 0
                player.doubleTapTimer.key = k
            end
        end
    else
        player.doubleTapTimer.key = ""
        player.doubleTapTimer.time = 0
        player.doubleTapTimer.taps = 0
    end
end

function love.mousemoved(x,y, dx,dy)
    g3d.camera.firstPersonLook(dx,dy)
    if settings.open then
        settings:moveCursor(x, y)
        settings:setPosition(x, y)
    end
end

function love.draw()
    if not titlescreen.open then
        g3d.camera.projectionMatrix:setProjectionMatrix(g3d.camera.fov, g3d.camera.nearClip, g3d.camera.farClip, g3d.camera.aspectRatio);
        nshader:send("projectionMatrix", g3d.camera.projectionMatrix)
        shadowShader:send("projectionMatrix", g3d.camera.projectionMatrix)
        postProcessShader:send("projectionMatrix", g3d.camera.projectionMatrix)

        g3d.camera.viewMatrix:setViewMatrix(g3d.camera.position, g3d.camera.target, g3d.camera.down);
        nshader:send("viewMatrix", g3d.camera.viewMatrix)
        shadowShader:send("viewMatrix", g3d.camera.viewMatrix)
        postProcessShader:send("viewMatrix", g3d.camera.viewMatrix)

        renderDepthMap() -- for lights

        shadowShader:send("depthMap", depthCanvas[1])
        shadowShader:send("lights", {0, 0, 0, 1}, {0, 20, 30, 1000}, {.46896011086, 28.068234611258, -140.11638688191, 1000})

        renderPass(shadowShader, shadowCanvas) -- shadow map

        nshader:send("shadowMap", shadowCanvas[1])

        renderPass(nshader, mainCanvas)

        renderPass(depthShader, depthCanvas) -- for camera
        
        postProcessShader:send("mainTexture", mainCanvas[1])
        postProcessShader:send("shadowMap", shadowCanvas[1])
        postProcessShader:send("depthMap", depthCanvas[1])
        renderPass(postProcessShader, postProcessCanvas)

        lg.draw(postProcessCanvas[1], 1024/2, 576/2, 0, 1,-1, 1024/2, 576/2)


        windowWidth, windowHeight = love.window.getMode()
        love.graphics.rectangle("fill", windowWidth - (windowWidth * .8), windowHeight - (windowHeight / 6), windowWidth * .6, windowHeight / 10)
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("fill", windowWidth - (windowWidth * .79), windowHeight - (windowHeight / 6.5), windowWidth * .58 * enemy.health / enemy.maxHealth, windowHeight / 12)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("Current FPS: " .. tostring(love.timer.getFPS()), 10, 10)
    end

    titlescreen:render()
    credits:render()
    settings:render()

    -- lg.print(collectgarbage("count"))
end

function renderDepthMap()
    local camPos, camDir = g3d.camera.position, g3d.camera.target
    g3d.camera.position, g3d.camera.target =  {4.4504282675513,27.58430283093,-120.37671163157}, {4.4504282675513,25.58430283093,0}
    g3d.camera.projectionMatrix:setProjectionMatrix(g3d.camera.fov, g3d.camera.nearClip, g3d.camera.farClip, g3d.camera.aspectRatio);
    depthShader:send("projectionMatrix", g3d.camera.projectionMatrix)

    g3d.camera.viewMatrix:setViewMatrix(g3d.camera.position, g3d.camera.target, g3d.camera.down);
    depthShader:send("viewMatrix", g3d.camera.viewMatrix)
    shadowShader:send("lightViewMatrix", g3d.camera.viewMatrix)


    renderPass(depthShader, depthCanvas)

    g3d.camera.position, g3d.camera.target = camPos, camDir
    g3d.camera.viewMatrix:setViewMatrix(g3d.camera.position, g3d.camera.target, g3d.camera.down);

    -- restore the matrix after lighting render
    depthShader:send("viewMatrix", g3d.camera.viewMatrix)
    depthShader:send("projectionMatrix", g3d.camera.projectionMatrix)
end

function renderPostProcess()

end

function renderPass(shader, canvas)
    love.graphics.setCanvas(canvas)
    lg.clear(0,0,0,0)
    love.graphics.setShader(shader)

    player:render(shader)
    entityHolder:renderEntities(shader)
    particles:render()

    love.graphics.setShader()
    love.graphics.setCanvas()
end