// variables provided by g3d's vertex shader
// varying vec4 worldPosition;
// varying vec3 vertexNormal;

// the model matrix comes from the camera automatically
uniform mat4 modelMatrix;
uniform vec3 lightPosition = vec3(1,1,1);
uniform float ambient = 0.2;

vec4 effect(vec4 color, Image tex, vec2 texcoord, vec2 pixcoord) {
    // diffuse light
    // computed by the dot product of the normal vector and the direction to the light source
    vec3 lightDirection = normalize(lightPosition.xyz - vec3(0, 0, 0));
    vec3 normal = normalize(mat3(modelMatrix) * vec3(0, 1, 0));
    float diffuse = max(dot(lightDirection, normal), 0);

    // get color from the texture
    vec4 texcolor = Texel(tex, texcoord);

    // if this pixel is invisible, get rid of it
    if (texcolor.a == 0.0) { discard; }

    // draw the color from the texture multiplied by the light amount
    float lightness = diffuse + ambient;
    return vec4((texcolor * color).rgb * lightness, 1.0);
}