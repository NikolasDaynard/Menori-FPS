uniform mat4 projectionMatrix;
uniform mat4 modelMatrix;
uniform mat4 viewMatrix;

varying vec4 vertexColor;

vec4 effect(vec4 color, Image tex, vec2 texcoord, vec2 pixcoord) {
    vec4 texcolor = Texel(tex, texcoord);
    
    // get rid of transparent pixels
    if (texcolor.a == 0.0) {
        discard;
    }
    
    return texcolor * color;
}