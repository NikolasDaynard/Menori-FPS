uniform mat4 projectionMatrix;
uniform mat4 modelMatrix;
uniform mat4 modelMatrixInverse;
uniform mat4 viewMatrix;
uniform float ambientLight;
uniform float ambientLightAdd;
uniform vec3 ambientVector;
varying vec3 vertexNormal;

varying vec3 vertexPosition;
attribute vec4 VertexNormal;
varying vec3 normal;

uniform vec4 lights[3]; // x, y, z, lum

vec4 position(mat4 transform_projection, vec4 vertex_position)
{
    // normal = vec3(vec4(modelMatrixInverse*VertexNormal));
    normal = vec3(vec4(modelMatrix * VertexNormal));
    vertexPosition = vertex_position.xyz;
    return projectionMatrix * viewMatrix * modelMatrix * vertex_position;
}