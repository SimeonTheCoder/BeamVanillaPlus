#include "ReShade.fxh"
#include "ReShadeUI.fxh"

uniform float offset <
	ui_type = "drag";
	ui_label = "Offset";
	ui_tooltip = "Set the hue offset";
> = 0;

// cosine based palette, 4 vec3 params
float3 Palette( float t )
{
	float3 a = float3(0.630, 0.410, 0.450);
	float3 b = float3(0.390, 0.620, 0.370);
	float3 c = float3(1.000, 0.920, 1.110);
	float3 d = float3(0.000, 0.383, 0.557);

    return a + b*cos( 6.28318*(c*t+d) );
}


// RGB to HSL conversion
float3 RGBtoHSL(float3 rgb)
{
    float r = rgb.r;
    float g = rgb.g;
    float b = rgb.b;
    
    float maxVal = max(max(r, g), b);
    float minVal = min(min(r, g), b);
    
    float h, s, l;
    
    l = (maxVal + minVal) * 0.5;
    
    if (maxVal == minVal)
    {
        h = 0.0;
        s = 0.0;
    }
    else
    {
        float delta = maxVal - minVal;
        
        s = (l <= 0.5) ? (delta / (maxVal + minVal)) : (delta / (2.0 - maxVal - minVal));
        
        if (r == maxVal)
            h = (g - b) / delta + (g < b ? 6.0 : 0.0);
        else if (g == maxVal)
            h = (b - r) / delta + 2.0;
        else
            h = (r - g) / delta + 4.0;
        
        h /= 6.0;
    }
    
    return float3(h, s, l);
}


float HueToRGB(float p, float q, float t)
{
    if (t < 0.0)
        t += 1.0;
    if (t > 1.0)
        t -= 1.0;
    if (t < 1.0 / 6.0)
        return p + (q - p) * 6.0 * t;
    if (t < 1.0 / 2.0)
        return q;
    if (t < 2.0 / 3.0)
        return p + (q - p) * (2.0 / 3.0 - t) * 6.0;
    return p;
}

// HSL to RGB conversion
float3 HSLtoRGB(float3 hsl)
{
    float h = hsl.r;
    float s = hsl.g;
    float l = hsl.b;
    
    float r, g, b;
    
    if (s == 0.0)
    {
        r = l;
        g = l;
        b = l;
    }
    else
    {
        float q = (l < 0.5) ? (l * (1.0 + s)) : (l + s - l * s);
        float p = 2.0 * l - q;
        
        r = HueToRGB(p, q, h + 1.0 / 3.0);
        g = HueToRGB(p, q, h);
        b = HueToRGB(p, q, h - 1.0 / 3.0);
    }
    
    return float3(r, g, b);
}

float3 CustomPass(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
	float3 depth = tex2D(ReShade::DepthBuffer, texcoord).rgb;

	depth = pow(depth, 0.1);
	depth = 1 - depth;
	depth = max(0, min(1, depth));

	depth = float3(depth.x, depth.x, depth.x);

	if(depth.x > 0.95) discard;

	float3 color = tex2D(ReShade::BackBuffer, texcoord).rgb;
	float3 orig = tex2D(ReShade::BackBuffer, texcoord).rgb;
	
	color = RGBtoHSL(color);

	float3 swapped = Palette(color.r + offset);
	swapped = RGBtoHSL(swapped);

	color.r = swapped.r;
	color.g -= 0.1;

	color = HSLtoRGB(color);

	return lerp(orig, color, max(0, min(1, pow(1 - depth, 10) * 20)));
}

technique BeamColors
{
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = CustomPass;
	}
}
