uniform mat4 projectionMatrix;
uniform Image depthMap;
uniform mat4 modelMatrix;
uniform mat4 modelMatrixInverse;
uniform mat4 viewMatrix;
uniform float ambientLight;
uniform float ambientLightAdd;
uniform vec3 ambientVector;
varying vec3 vertexNormal;

varying vec4 vertexPosition;
varying vec4 vertexRealPosition;
// varying vec4 vertexScreenPosition;
varying vec4 debug;
attribute vec4 VertexNormal;
varying vec3 normal;

uniform bool animated;

uniform vec4 lights[300]; // x, y, z, lum

attribute vec4 VertexWeight;
attribute vec4 VertexBone;
uniform mat4 u_pose[16]; //100 bones crashes web version, only set to whats absolutely necessary (hoarders comment)

vec4 position(mat4 transform_projection, vec4 vertex_position)
{
    debug = vec4(0, 0, 0, 0);
    // normal = normalize(vec3(vec4(modelMatrixInverse*VertexNormal)));
    normal = normalize(vec3(vec4(modelMatrix * VertexNormal)));

    // taken from hoarders house tysm
    if (VertexBone.x != 0.0) {
        debug = vec4(1, 0, 0, 0);
        // mat4 skeleton = u_pose[int(VertexBone.x*255.0)] * VertexWeight.x +
        //     u_pose[int(VertexBone.y*255.0)] * VertexWeight.y +
        //     u_pose[int(VertexBone.z*255.0)] * VertexWeight.z +
        //     u_pose[int(VertexBone.w*255.0)] * VertexWeight.w;
        vec4 VertexBoneReal = VertexBone;
        vec4 skeleton = vec4(
            vertex_position.x + VertexBoneReal.x, 
            vertex_position.y + VertexBoneReal.y,
            vertex_position.z + VertexBoneReal.z,
            vertex_position.w + VertexBoneReal.w
        );
        vertex_position = skeleton;
    };

    vertexPosition = projectionMatrix * viewMatrix * modelMatrix * vertex_position;
    vertexRealPosition = modelMatrix * vertex_position;

    return vertexPosition;
}