-- written by groverbuger for g3d
-- january 2021
-- MIT license

local newMatrix = require(G3D_PATH .. "/matrices")
local loadObjFile = require(G3D_PATH .. "/objloader")
local collisions = require(G3D_PATH .. "/collisions")
local vectors = require(G3D_PATH .. "/vectors")
local vectorCrossProduct = vectors.crossProduct
local vectorNormalize = vectors.normalize

iqm = require("libs/iqm")
anim9 = require("libs/anim9")
cpml  = require("libs/cpml")

----------------------------------------------------------------------------------------------------
-- define a model class
----------------------------------------------------------------------------------------------------

local model = {}
model.__index = model

-- define some default properties that every model should inherit
-- that being the standard vertexFormat and basic 3D shader
model.vertexFormat = {
    {"VertexPosition", "float", 3},
    {"VertexTexCoord", "float", 2},
    {"VertexNormal", "float", 3},
    {"VertexColor", "byte", 4},
    {"VertexBone", "float", 4},
}
model.shader = require(G3D_PATH .. "/shader")

-- model class imports functions from the collisions library
for key,value in pairs(collisions) do
    model[key] = value
end

-- this returns a new instance of the model class
-- a model must be given a .obj file or equivalent lua table, and a texture
-- translation, rotation, and scale are all 3d vectors and are all optional
local function newModel(verts, texture, translation, rotation, scale)
    local self = setmetatable({}, model)

    -- if verts is a string, use it as a path to a .obj file
    -- otherwise verts is a table, use it as a model defintion
    if type(verts) == "string" then
        local extension = verts:sub(-4,-1)
        if extension == ".obj" then
            -- print("obj" .. verts)
            given = loadObjFile(verts)
            
            self.verts = given
            self.mesh = love.graphics.newMesh(self.vertexFormat, self.verts, "triangles")
            self.animated = false
        elseif extension == ".iqm" then
            -- print("iqm" .. verts)
            local data = iqm.load(verts)
            self.data = data
            self.verts = data.triangles
            self.mesh = data.mesh
            self.animated = true
    
            self.anims = iqm.load_anims(verts)
            self.animTracks = {}
            self.anim = anim9(self.anims)
            self.animations = {}
            assert(self.anim ~= nil, "ANIMATIONS ON AN IQM MODEL CANNOT BE NIL")
        else
            print("none ERROR")
        end
    else
		--If given table of verticies (thanks hoarders house de estufa)
		self.verts = verts
		self.mesh = love.graphics.newMesh(self.vertexFormat, self.verts, "triangles")
		self.animated = false
    end
    assert(given and type(given) == "table", "Invalid vertices given to newModel")

    -- if texture is a string, use it as a path to an image file
    -- otherwise texture is already an image, so don't bother
    if type(texture) == "string" then
        texture = love.graphics.newImage(texture)
        self.texture = texture
    end

    -- tank you to Hoarder's Horrible House of Stuff for this iqm implementation
    -- initialize my variables

    self.mesh:setTexture(self.texture)
    self.matrix = newMatrix()
    self:setTransform(translation or {0,0,0}, rotation or {0,0,0}, scale or {1,1,1})
    self:generateAABB()

    return self
end
-- all animation stuff taken from Hoarder's house TYSM 
function model:update(dt)
	if self.animated then
		self.anim:update(dt)
	end
end

function model:newAnimationTrack(name)
	self.animTracks[name] = self.anim:new_track(name)
end

function model:playAnimation(name)
	self.anim:play(self.animTracks[name])
	self.anim:update(0)
end

function model:play(name)
	self.anim:play(name)
	self.anim:update(0)
end
function model:stopAnimation(name)
	self.anim:stop(self.animTracks[name])
    self.anim:update(0)
end

-- populate model's normals in model's mesh automatically
-- if true is passed in, then the normals are all flipped
function model:makeNormals(isFlipped)
    for i=1, #self.verts, 3 do
        local vp = self.verts[i]
        local v = self.verts[i+1]
        local vn = self.verts[i+2]

        local n_1, n_2, n_3 = vectorNormalize(vectorCrossProduct(v[1]-vp[1], v[2]-vp[2], v[3]-vp[3], vn[1]-v[1], vn[2]-v[2], vn[3]-v[3]))
        local flippage = isFlipped and -1 or 1
        n_1 = n_1 * flippage
        n_2 = n_2 * flippage
        n_3 = n_3 * flippage

        vp[6], v[6], vn[6] = n_1, n_1, n_1
        vp[7], v[7], vn[7] = n_2, n_2, n_2
        vp[8], v[8], vn[8] = n_3, n_3, n_3
    end
end

-- move and rotate given two 3d vectors
function model:setTransform(translation, rotation, scale)
    self.translation = translation or self.translation
    self.rotation = rotation or self.rotation
    self.scale = scale or self.scale
    self:updateMatrix()
end

-- move given one 3d vector
function model:setTranslation(tx,ty,tz)
    self.translation[1] = tx
    self.translation[2] = ty
    self.translation[3] = tz
    self:updateMatrix()
end

-- rotate given one 3d vector
-- using euler angles
function model:setRotation(rx,ry,rz)
    self.rotation[1] = rx
    self.rotation[2] = ry
    self.rotation[3] = rz
    self.rotation[4] = nil
    self:updateMatrix()
end

-- rotate given one quaternion
function model:setQuaternionRotation(x,y,z,angle)
    x,y,z = vectorNormalize(x,y,z)

    self.rotation[1] = x * math.sin(angle/2)
    self.rotation[2] = y * math.sin(angle/2)
    self.rotation[3] = z * math.sin(angle/2)
    self.rotation[4] = math.cos(angle/2)

    self:updateMatrix()
end

-- resize model's matrix based on a given 3d vector
function model:setScale(sx,sy,sz)
    self.scale[1] = sx
    self.scale[2] = sy or sx
    self.scale[3] = sz or sx
    self:updateMatrix()
end

-- update the model's transformation matrix
function model:updateMatrix()
    self.matrix:setTransformationMatrix(self.translation, self.rotation, self.scale)
end

-- draw the model
function model:draw(shader)
    local shader = shader or self.shader
    love.graphics.setShader(shader)
    shader:send("modelMatrix", self.matrix)

	if shader:hasUniform("animated") then
        if (self.animated) then
        -- print("has unitcor")
        end
		shader:send("animated", self.animated)
	end
	if self.animated and shader:hasUniform("u_pose") then
		shader:send("u_pose", "column", unpack(self.anim.current_pose))
	end

    love.graphics.draw(self.mesh)
    love.graphics.setShader()
end

return newModel
