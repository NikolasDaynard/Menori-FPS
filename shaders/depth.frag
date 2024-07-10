varying vec3 normal;
varying vec4 vertexRealPosition;
varying vec4 vertexPosition;
varying vec4 debug;
uniform mat4 modelMatrix;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    float depth = length(vec3(1.0, 1.0, 1.0) / vertexPosition.w);
    // float depth = vertexPosition.z / vertexPosition.w;
    return vec4(vec3(depth), 1.0);
}
