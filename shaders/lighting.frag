varying vec3 normal;
uniform Image shadowMap;
varying vec4 vertexRealPosition;
varying vec4 vertexPosition;
varying vec4 debug;
uniform mat4 modelMatrix;
uniform mat4 projectionMatrix;
uniform mat4 lightViewMatrix; // Transformation from world space to light's view space
uniform mat4 viewMatrix; // Transformation from world space to light's view space

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    vec4 texcolor = Texel(tex, texture_coords);
    if (texcolor.a == 0.0) { discard; }

    vec2 shadowMapCord = vec2((((vertexPosition.xy / vertexPosition.w) * 0.5) + 0.5));

    vec4 shadowMapValue = Texel(shadowMap, shadowMapCord);

    return vec4(((texcolor * color)).rgb, 1.0);
}