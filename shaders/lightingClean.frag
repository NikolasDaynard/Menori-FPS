varying vec3 normal;
uniform Image depthMap;
varying vec4 vertexRealPosition;
varying vec4 vertexPosition;
varying vec4 debug;
uniform mat4 modelMatrix;
uniform mat4 projectionMatrix;
uniform mat4 lightViewMatrix; // Transformation from world space to light's view space
uniform mat4 viewMatrix; // Transformation from world space to camera's view space
uniform vec4 lights[3]; // x, y, z, lum

const float farClipPlane = 200.0; // Ensure this matches the far clip plane value used in the depth shader

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    // Get color from the texture
    vec4 texcolor = Texel(tex, texture_coords);

    // Transform the fragment's world position to light's clip space
    vec4 lightSpacePosition = projectionMatrix * lightViewMatrix * vertexRealPosition;
    vec3 shadowMapCoord = (lightSpacePosition.xyz / lightSpacePosition.w) * 0.5 + 0.5;

    // Bounds checking
    bool inBounds = shadowMapCoord.x >= 0.0 && shadowMapCoord.x <= 1.0 &&
                    shadowMapCoord.y >= 0.0 && shadowMapCoord.y <= 1.0;

    float shadowDepth = 1.0; // Default to a large value (no shadow)
    if (inBounds) {
        shadowDepth = Texel(depthMap, shadowMapCoord.xy).r;
    }

    // Calculate the current fragment depth in light space
    float currentDepth = shadowMapCoord.z;

    if (texcolor.a == 0.0) { discard; }

    vec3 transformedNormal = normalize(mat3(modelMatrix) * normal);
    float lightness = 0;

    for (int i = 0; i < 3; i++) {
        vec3 lightDirection = normalize(lights[i].xyz - vertexRealPosition.xyz);
        float distance = length(lights[i].xyz - vertexRealPosition.xyz);
        float attenuation = lights[i].w / (distance * distance); // inverse square law

        float diffuse = max(dot(lightDirection, transformedNormal), 0.0) * attenuation;

        // Shadow calculation
        if (currentDepth > shadowDepth + 0.005 && inBounds) { // Add a small bias to prevent shadow acne
            diffuse *= 0.5; // Reduce the diffuse light if in shadow
        }

        // Draw the color from the texture multiplied by the light amount
        lightness += diffuse;
    }

    if (debug == vec4(1, 0, 0, 0)) {
        return vec4(1, 1, 1, 1);
    }
    // return vec4(vec3(shadowDepth), 1.0);
    // return vec4(vec3(currentDepth), 1.0);
    return vec4((texcolor * color).rgb * (lightness + 0.2), 1.0);
}
