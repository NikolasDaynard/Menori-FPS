local menori = require 'menori'
require("player")
require("helpers")
require("collision")

local ml = menori.ml
local vec3 = ml.vec3
local quat = ml.quat
local ml_utils = ml.utils

-- class inherited from UniformList for a light source.
local PointLight = menori.UniformList:extend('PointLight')
function PointLight:init(x, y, z, r, g, b)
	PointLight.super.init(self)

	self:set('position', {x, y, z})
	self:set('constant', 1.0)
	self:set('linear', 0.3)
	self:set('quadratic', 0.032)
	self:set('ambient', {r, g, b})
	self:set('diffuse', {r, g, b})
	self:set('specular', {r, g, b})
end

local scene = menori.Scene:extend('testing')

function scene:init()
	scene.super.init(self)

	local _, _, w, h = menori.app:get_viewport()
	self.camera = menori.PerspectiveCamera(60, w / h, 0.5, 1024)
	self.environment = menori.Environment(self.camera)

	-- adding light sources
	self.environment:add_light('point_lights', PointLight(0, 0.5, 2, 0.8, 0.3, 0.1))
	self.environment:add_light('point_lights', PointLight(2,   1,-1, 0.1, 0.3, 0.8))

	self.root_node = menori.Node()
	self.aabb_root = self.root_node:attach(menori.Node())

	-- loading the fragment shader code for lighting
	local lighting_frag = menori.utils.shader_preprocess(love.filesystem.read('basic_lighting/basic_lighting_frag.glsl'))
	local lighting_shader = love.graphics.newShader(menori.ShaderUtils.cache['default_mesh_vert'], lighting_frag)

	local gltf = menori.glTFLoader.load('assets/clean.glb')
	local scenes = menori.NodeTreeBuilder.create(gltf, function (scene, builder)
		-- Callback for each scene in the gltf.
		-- Create AABB for each node and add it to the aabb_root node.
		scene:traverse(function (node)
			if node.mesh then
				-- collision:collisionSetCollider(collision:generateAABBFromVerts(node.mesh:get_vertices()), node)
				node.material.shader = lighting_shader

				local bound = node:get_aabb()

				collision:collisionSetCollider({p1 = vec3(bound.min.x, bound.min.y, bound.min.z), p2 = vec3(bound.max.x, bound.max.y, bound.max.z)})
				local size = bound:size()
				local boxshape = menori.BoxShape(size.x, size.y, size.z)
				local material = menori.Material()
				material.wireframe = true
				material.mesh_cull_mode = 'none'
				material.alpha_mode = 'BLEND'
				material:set('baseColor', {1.0, 1.0, 0.0, 0.12})
				local t = menori.ModelNode(boxshape, material)
				t:set_position(bound:center())
				self.aabb_root:attach(t)
			end
		end)
	end)

	self.root_node:attach(scenes[1])

	self.view_scale = 0.1
end

function scene:render()
	love.graphics.clear(0.3, 0.25, 0.2)

	-- Recursively draw all the nodes that were attached to the root node.
	-- Sorting nodes by transparency.
	self:render_nodes(self.root_node, self.environment, {
		node_sort_comp = menori.Scene.alpha_mode_comp
	})
end

function scene:update_camera()
	local q = quat.from_euler_angles(0, math.rad(player:getXAngle()), math.rad(player:getYAngle())) * vec3.unit_z * self.view_scale
	local v = player:getPosition()
	self.camera.center = v
	self.camera.eye = q + v
	self.camera:update_view_matrix()

	self.environment:set_vector('view_position', self.camera.eye)
end

-- camera control
function scene:mousemoved(x, y, dx, dy)
	player:updateCam(dx, dy)

	local _, _, w, h = menori.app:get_viewport()
	wrapCursor(w, h)
end

function scene:wheelmoved(x, y)
	self.view_scale = self.view_scale - y * 0.2
end

function scene:update(dt)
	self:update_camera()
	self:update_nodes(self.root_node, self.environment)
	player:update(dt)
end

return scene