varying vec3 normal;
varying vec4 vertexPosition;
varying vec4 debug;
uniform mat4 modelMatrix;

uniform vec4 lights[3]; // x, y, z, lum

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    // ALGORITHM CREDIT: https://love2d.org/forums/viewtopic.php?p=244728#p244728

    // diffuse light
    // computed by the dot product of the normal vector and the direction to the light source

    // get color from the texture
    vec4 texcolor = Texel(tex, texture_coords);
    vec3 normal = normalize(mat3(modelMatrix) * normal);
    float lightness = 0;

    for(int i = 0; i < 3; i ++) {
        vec3 lightDirection = normalize(lights[i].xyz - vertexPosition.xyz);
        float diffuse = max(dot(lightDirection, normal) * lights[i].w, 0);


        // if this pixel is invisible, get rid of it
        if (texcolor.a == 0.0) { discard; }

        // draw the color from the texture multiplied by the light amount
        lightness = lightness + diffuse;
    }
    if(debug == vec4(1, 0, 0, 0)){
        return vec4(1, 1, 1, 1);
    }
    return vec4((texcolor * color).rgb * (lightness + .2), 1.0);
}