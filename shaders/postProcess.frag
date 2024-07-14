varying vec3 normal;
uniform Image mainTexture;
uniform Image shadowMap;
uniform Image depthMap;
varying vec4 vertexRealPosition;
varying vec4 vertexPosition;
varying vec4 debug;
uniform mat4 modelMatrix;
uniform mat4 projectionMatrix;
uniform mat4 lightViewMatrix; // Transformation from world space to light's view space
uniform mat4 viewMatrix; // Transformation from world space to light's view space

uniform float weight[5] = float[5](0.227027, 0.1945946, 0.1216216, 0.054054, 0.016216);
// def stolen
vec4 gaussianBlur(Image tex, vec2 coord, int kernelSize)
{
    vec3 result = Texel(tex, coord).rgb * weight[0];
	float w = 1.0 / 1024;
	float h = 1.0 / 576;

    for (int i = 1; i < kernelSize; ++i)
    {
        result += Texel(tex, coord + vec2(w * i, 0.0)).rgb * weight[i];
        result += Texel(tex, coord - vec2(w * i, 0.0)).rgb * weight[i];
        result += Texel(tex, coord + vec2(0.0, h * i)).rgb * weight[i];
        result += Texel(tex, coord - vec2(0.0, h * i)).rgb * weight[i];
    }

    return vec4(result.rgb, 1);
}

vec4 differenceOfGaussians(Image tex, vec2 coord) {
    return vec4(max(gaussianBlur(tex, coord, 2) - gaussianBlur(tex, coord, 5), vec4(0.1)).rgb, 1);
}

// sobel taken from this gist tysm! https://gist.github.com/Hebali/6ebfc66106459aacee6a9fac029d0115
void make_kernel(inout vec4 n[9], Image tex, vec2 coord)
{
	float w = 1.0 / 1024;
	float h = 1.0 / 576;

	n[0] = Texel(tex, coord + vec2( -w, -h));
	n[1] = Texel(tex, coord + vec2(0.0, -h));
	n[2] = Texel(tex, coord + vec2(  w, -h));
	n[3] = Texel(tex, coord + vec2( -w, 0.0));
	n[4] = Texel(tex, coord);
	n[5] = Texel(tex, coord + vec2(  w, 0.0));
	n[6] = Texel(tex, coord + vec2( -w, h));
	n[7] = Texel(tex, coord + vec2(0.0, h));
	n[8] = Texel(tex, coord + vec2(  w, h));
}

vec4 sobel(Image sobelImage, vec2 screenCord) {
	vec4 n[9];
	make_kernel( n, sobelImage, screenCord );

	vec4 sobel_edge_h = n[2] + (2.0*n[5]) + n[8] - (n[0] + (2.0*n[3]) + n[6]);
  	vec4 sobel_edge_v = n[0] + (2.0*n[1]) + n[2] - (n[6] + (2.0*n[7]) + n[8]);
	vec4 sobel = sqrt((sobel_edge_h * sobel_edge_h) + (sobel_edge_v * sobel_edge_v));

	return vec4( 1.0 - sobel.rgb, 1.0 );
}

vec4 posterize(vec4 color, int steps, bool smoothen) {
    float stepSize;
    if (smoothen) {
        stepSize = 255.0 / float(steps + (1 / color)); // decreace posterization at low brightnesses
    }else{
        stepSize = 255.0 / float(steps);
    }
    color.r = floor(color.r * 255.0 / stepSize) * stepSize / 255.0;
    color.g = floor(color.g * 255.0 / stepSize) * stepSize / 255.0;
    color.b = floor(color.b * 255.0 / stepSize) * stepSize / 255.0;
    return color;
}

vec4 halftoneDots(vec2 screenCord, float size) {
    // Scale screen coordinates to control the size of the dots
    const float scale = 9;
    vec2 scaledCoords = vec2(screenCord.x * (1024 / scale), screenCord.y * (576 / scale));

    float pattern = sin(scaledCoords.x * 3.14159) * cos(scaledCoords.y * 3.14159);

    float threshold = size;
    if (pattern > threshold) {
        return vec4(1, 1, 1, 1); // White dot
    } else {
        return vec4(0, 0, 0, 1); // Black dot
    }
}


vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    vec2 screenCord = vec2((((vertexPosition.xy / vertexPosition.w) * 0.5) + 0.5));

    vec4 shadowMapValue = Texel(shadowMap, screenCord);
    float shadowMapBrightness = max(shadowMapValue.r, 0) + max(shadowMapValue.g, 0) + max(shadowMapValue.b, 0); // remove the clamp
    vec4 depthMapValue = Texel(depthMap, screenCord);
    vec4 mainTextureValue = Texel(mainTexture, screenCord);

    vec4 lineArt = sobel(mainTexture, screenCord) + sobel(depthMap, screenCord);
    lineArt = vec4(max(lineArt - .07, 0).rgb, 1); 
    lineArt = min(lineArt * 100, 1);
    lineArt = vec4(vec3(lineArt.r), 1.0);

    // return lineArt;
    // return vec4(normal * mainTextureValue.rgb, 1.0);
    // return gaussianBlur(mainTexture, screenCord, 9);

    // apply lighting
    mainTextureValue = mainTextureValue + (shadowMapBrightness / 20); // Wash out bright spots
    mainTextureValue = mainTextureValue * vec4(vec3(shadowMapBrightness), 1);

    vec4 sobelDepth = sobel(depthMap, screenCord);

    vec4 posterizedMainTexture = posterize(mainTextureValue, 3, true);

    vec4 halfToneSample = halftoneDots(screenCord, .5);
    vec4 halftoneRender = 
        max(
            (posterizedMainTexture * vec4( (halfToneSample * (1 - shadowMapBrightness)).rgb,  1)),
            vec4(0)); // half tone dots clamped

    halftoneRender = posterize(halftoneRender, -1, true);
    halftoneRender = max(halftoneRender, vec4(0));
    // return halftoneRender;

    return (posterizedMainTexture + halftoneRender) * lineArt;

    // return vec4((1 - (halftoneDots(screenCord) * (shadowMapBrightness))).rgb, 1);

    return posterize(mainTextureValue, 3, true) + vec4((1 - (halftoneDots(screenCord, .5) * (shadowMapBrightness))).rgb, 1);
    // return posterize(mainTextureValue, 3); // I love my sobelito filter
}