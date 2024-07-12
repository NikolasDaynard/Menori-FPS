
vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    // Get color from the texture
    vec4 texcolor = Texel(tex, texture_coords);

    // Transform the fragment's world position to light's clip space
    vec4 worldSpacePosition = projectionMatrix * viewMatrix * vertexRealPosition;
    vec4 lightSpacePosition = projectionMatrix * lightViewMatrix * vertexRealPosition;
    vec3 shadowMapCoord = (lightSpacePosition.xyz / (lightSpacePosition.w)) * 0.5 + 0.5;

    // Sample the depth map
    float shadowDepth = Texel(depthMap, shadowMapCoord.xy).r;
    bool inBounds = shadowMapCoord.x >= 0.0 && shadowMapCoord.x <= 1.0 &&
                    shadowMapCoord.y >= 0.0 && shadowMapCoord.y <= 1.0 &&
                    shadowMapCoord.z >= 0.0 && shadowMapCoord.z <= 1.0;

    // Calculate dist to camera
    float currentDepth = 1 - length(vec3(4.4504282675513,27.58430283093,-120.37671163157) - vertexRealPosition.xyz) / 200;

    if (texcolor.a == 0.0) { discard; }
    
    vec3 normal = normalize(mat3(modelMatrix) * normal);
    float lightness = 0;
    bool inShadow = false;

    for (int i = 0; i < 3; i++) {
        vec3 lightDirection = normalize(lights[i].xyz - vertexRealPosition.xyz);
        float distance = length(lights[i].xyz - vertexRealPosition.xyz);
        float attenuation = lights[i].w / (distance * distance); // inverse square law

        float diffuse = max(dot(lightDirection, normal), 0.0) * attenuation;

        // Shadow calculation currentDepth < shadowDepth + 0.005 && i
        if (shadowDepth > currentDepth + .05 && inBounds) { // Add a small bias to prevent shadow acne
            diffuse *= 0; // Reduce the diffuse light if in shadow
            // diffuse = 1;
            // inShadow = true;
        }

        // Draw the color from the texture multiplied by the light amount
        lightness += diffuse;
    }
    
    if (debug == vec4(1, 0, 0, 0)) {
        return vec4(1, 1, 1, 1);
    }
    if (inShadow == true) {
        return vec4(.2, .3, 1, 1);
    }
    // return vec4(vec3(shadowDepth), 1.0);
    // return vec4(vec3(currentDepth), 1.0);
    // return vec4(shadowMapCoord, 1.0);
    return vec4((texcolor * color).rgb * (lightness + 0.2), 1.0);
}
