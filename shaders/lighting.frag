varying vec3 normal;
uniform Image depthMap;
varying vec4 vertexRealPosition;
varying vec4 vertexPosition;
// varying vec4 vertexScreenPosition;
varying vec4 debug;
uniform mat4 modelMatrix;

uniform vec4 lights[3]; // x, y, z, lum

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    // ALGORITHM CREDIT: https://love2d.org/forums/viewtopic.php?p=244728#p244728

    // get color from the texture
    vec4 texcolor = Texel(tex, texture_coords);
    vec2 shadowMapCoord = ((vertexPosition.xy / vertexPosition.w) * 0.5) + 0.5;;
    vec4 depthColor = Texel(depthMap, shadowMapCoord);

    if (texcolor.a == 0.0) { discard; }
    
    vec3 normal = normalize(mat3(modelMatrix) * normal);
    float lightness = 0;

    for(int i = 0; i < 3; i ++) {
        vec3 lightDirection = normalize(lights[i].xyz - vertexRealPosition.xyz);
        float distance = length(lights[i].xyz - vertexRealPosition.xyz);
        float attenuation = lights[i].w / (distance * distance); // inverse square law

        float diffuse = max(dot(lightDirection, normal), 0.0) * attenuation;

        // draw the color from the texture multiplied by the light amount
        lightness += diffuse;
    }
    
    if(debug == vec4(1, 0, 0, 0)){
        return vec4(1, 1, 1, 1);
    }
    // return vec4((texcolor * color).rgb * (lightness + 0.2), 1.0);
    return depthColor;
    // return vec4(shadowMapCoord.xy, 1.0, 1.0);
}
