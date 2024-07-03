io.stdout:setvbuf("no")
nshader = love.graphics.newShader("shaders/lighting.vert", "shaders/lighting.frag")

local lg = love.graphics
lg.setDefaultFilter("linear")

local g3d = require "g3d"
local Player = require "player"
local vectors = require "g3d/vectors"
local primitives = require "primitives"
-- require("cpml")

require("enemy")
require("particles")
require("titlescreen")
require("settings")

local map, background
player = {}
local canvas
local accumulator = 0
local frametime = 1/60
local rollingAverage = {}

music = love.audio.newSource("audio/Battle Theme.mp3", "stream")
deathmusic = love.audio.newSource("audio/Broke Down - Hour 4 - COMPLETED.mp3", "stream")
gunAudio = love.audio.newSource("audio/tu.wav", "stream")
music:setLooping(true)

function love.load()
    lg.setBackgroundColor(0.25,0.5,1)

    map = g3d.newModel("assets/bodyShop.obj", "assets/checker.png", nil, nil, {-1,-1,1})
    background = g3d.newModel("assets/sphere.obj", "assets/starfield.png", {0,0,0}, nil, {500,500,500})
    player = Player:new(0,0,0)
    player:addCollisionModel(map)
    entityHolder:addEntity({model = map}, 1)

    canvas = {lg.newCanvas(1024,576), depth=true}
end

function love.update(dt)
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
    if k == "escape" then love.event.push("quit") end
    if k == "w" then
        if player.doubleTapTimer.taps ~= 2 then
            if k ~= player.doubleTapTimer.key then
                player.doubleTapTimer.time = 0
                player.doubleTapTimer.taps = 0
            end
            player.doubleTapTimer.key = k
            player.doubleTapTimer.taps = player.doubleTapTimer.taps + 1
            print(player.doubleTapTimer.taps)

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
            print(player.doubleTapTimer.taps)

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
end

local function setColor(r,g,b,a)
    lg.setColor(r/255, g/255, b/255, a and a/255)
end

local function drawTree(x,y,z)
    setColor(56,48,46)
    primitives.line(x,y,z, x,y-1.25,z)
    primitives.circle(x,y,z, 0,0,0, 0.1,1,0.1)

    setColor(71,164,61)
    for i=1, math.pi*2, math.pi*2/3 do
        local r = 0.35
        --primitives.axisBillboard(1 + math.cos(i)*r, -0.5, 0 + math.sin(i)*r, 0,-1,0)
        primitives.fullBillboard(x + math.cos(i)*r, y - 1, z + math.sin(i)*r)
    end
    primitives.fullBillboard(x, y-1.5, z)
end

function love.draw()
    if not titlescreen.open then
        g3d.camera.projectionMatrix:setProjectionMatrix(g3d.camera.fov, g3d.camera.nearClip, g3d.camera.farClip, g3d.camera.aspectRatio);
        nshader:send("projectionMatrix", g3d.camera.projectionMatrix)

        g3d.camera.viewMatrix:setViewMatrix(g3d.camera.position, g3d.camera.target, g3d.camera.down);
        nshader:send("viewMatrix", g3d.camera.viewMatrix)

        g3d.camera.viewMatrix:setViewMatrix(g3d.camera.position, g3d.camera.target, g3d.camera.down);
        nshader:send("lights", {0, 0, 0, 1}, {0, 20, 30, 1})

        lg.setCanvas(canvas)
        lg.clear(0,0,0,0)

        --lg.setDepthMode("lequal", true)
        background:draw()
        player:render()
        entityHolder:renderEntities()
        particles:render()

        drawTree(1,0.5,0)
        drawTree(0,0.5,1.5)
        drawTree(-2,0.5,-1)

        lg.setColor(1,1,1)

        lg.setCanvas()
        lg.draw(canvas[1], 1024/2, 576/2, 0, 1,-1, 1024/2, 576/2)
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

    --lg.print(collectgarbage("count"))
end
