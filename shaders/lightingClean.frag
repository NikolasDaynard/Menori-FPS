varying vec3 normal;
uniform Image depthMap;
varying vec4 vertexRealPosition;
varying vec4 vertexPosition;
varying vec4 debug;
uniform mat4 modelMatrix;
uniform mat4 projectionMatrix;
uniform mat4 lightViewMatrix; // Transformation from world space to light's view space
uniform mat4 viewMatrix; // Transformation from world space to light's view space
// uniform mat4 lightProjectionMatrix; // Light's projection matrix

uniform vec4 lights[3]; // x, y, z, lum
// uniform mat4 lightProjectionMatrix; // Add this uniform

float getInterpolatedDepth(Image depthMap, vec2 uv) {
    // Sample the current texel
    float depth = Texel(depthMap, uv.xy).r;

    const float sampleDist = 0.0002;

    // Sample the four neighboring texels
    float dUp = Texel(depthMap, vec2(uv.x, uv.y + sampleDist)).r;
    float dDown = Texel(depthMap, vec2(uv.x, uv.y - sampleDist)).r;
    float dRight = Texel(depthMap, vec2(uv.x + sampleDist, uv.y)).r;
    float dLeft = Texel(depthMap, vec2(uv.x - sampleDist, uv.y)).r;

    // Compute the average of the current texel and the neighboring texels
    float avg = (depth + dUp + dDown + dRight + dLeft) / 5;

    return avg;
}


vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    vec4 texcolor = Texel(tex, texture_coords);
    if (texcolor.a == 0.0) { discard; }

    vec4 lightSpacePosition = projectionMatrix * lightViewMatrix * vertexRealPosition;
    float currentDepth = 1 - (lightSpacePosition.z / 200);
    vec3 shadowMapCoord = lightSpacePosition.xyz / lightSpacePosition.w;
    shadowMapCoord = shadowMapCoord * 0.5 + 0.5;

    float shadowDepth = getInterpolatedDepth(depthMap, shadowMapCoord.xy);//Texel(depthMap, shadowMapCoord.xy).r;

    bool inBounds = all(greaterThanEqual(shadowMapCoord, vec3(0.0))) && all(lessThanEqual(shadowMapCoord, vec3(1.0)));

    vec3 normal = normalize(mat3(modelMatrix) * normal);
    float lightness = 0.0;
    bool inShadow = false;

    for (int i = 0; i < 3; i++) {
        vec3 lightDirection = normalize(lights[i].xyz - vertexRealPosition.xyz);
        float distance = length(lights[i].xyz - vertexRealPosition.xyz);
        float attenuation = lights[i].w / (distance * distance);

        float diffuse = max(dot(lightDirection, normal), 0.0) * attenuation;

        float bias = 0.005;
        if (shadowDepth - bias > currentDepth && inBounds) {
            // const int smoothness = 200;
            // for(int i = 0; i < smoothness; i++) {
            //     if (shadowDepth - .006 + (.0001 * i) < currentDepth) { // smooth
            //         // diffuse *= 1.2;
            //     }
            // }
            diffuse *= 1 - (1 * (pow(currentDepth, 3)));
            // inShadow = true;
        }

        lightness += diffuse;
    }
    if (inShadow == true) {
        // some debug color (home improvment?)
        // return vec4(.2, .3, 1, 1);
    }
    // return vec4(vec3(1 * (pow(currentDepth, 100))), 1.0);
    // return vec4(vec3(shadowDepth), 1.0);
    return vec4((texcolor * color).rgb * (lightness + 0.2), 1.0);
}