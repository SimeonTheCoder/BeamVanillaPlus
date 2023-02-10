#ifndef USE_OLD_TONEMAP
#define BNG_ACES_TONEMAP
#endif
#ifdef BNG_ACES_TONEMAP
#include "shaders/common/postfx/hdr/ACES.h.hlsl"
#endif

// http://de.slideshare.net/ozlael/hable-john-uncharted2-hdr-lighting
float3 TonemapOperatorUncharted2(float3 x)
{
   float A = 0.15;
   float B = 0.50;
   float C = 0.10;
   float D = 0.20;
   float E = 0.02;
   float F = 0.30;

   return ((x*(A*x+C*B)+D*E)/(x*(A*x+B)+D*F))-E/F;
}

float3 TonemapUncharted2(float3 color)
{
    const float exposure_adjustment = 1; //16;
    const float exposure_bias = 1.25; //2;

    color = max(color, 0) * exposure_adjustment;
    const float whiteScale = (1.0f / TonemapOperatorUncharted2(11.2f)).x;
    return saturate(TonemapOperatorUncharted2(exposure_bias * color) * whiteScale);
}

float3 tonemap(float3 rgb) {
#ifdef BNG_ACES_TONEMAP
    //return 1.0 - ACESFitted(rgb);

    float3 color = ACESFitted(rgb);

    color = pow(color, 1 / 2.2);
    float3 color2 = color;
 
	color -= 0.1;
	color2 -= 0.1;

	color = color / (1.0 - color);
	color2 = color2 / (1.0 - color2);

	color2 = max(0, color2 - 1);
 
	color += 0.5 * max(0, min(1, color - 1));
	color2 += 0.5 * max(0, min(1, color2 - 1));

	float luminance = 0.5;

	color = color / (1.0 + color);
	color = (color - 0.5) * 1.3 + 0.5;

	color2 = color2 / (1.0 + color2);

	color2 = min(1, color2);
 
	color += 0.1;
	color2 += 0.1;
 
	rgb -= 0.1;
 
	float3 finalColor = color * max(0, color2) * max(0, 1 - luminance) * 2 + rgb * max(0, 1 - color2);

	finalColor = lerp(color, finalColor, min(1, luminance));

	return lerp(length(finalColor), finalColor, 1.2) * 1.21;
#else
   return TonemapUncharted2(rgb);
#endif
}