varying vec3 normal;

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    vec4 texcolor = Texel(tex, texture_coords);
    color.x = normal.x * (screen_coords.x / 1440);
    color.y = normal.y;
    color.z = normal.z;
    return color;
}