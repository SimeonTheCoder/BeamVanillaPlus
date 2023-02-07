#include "ReShade.fxh"
#include "ReShadeUI.fxh"

float3 CustomPass(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
	float3 original = tex2D(ReShade::BackBuffer, texcoord).rgb;

	float3 color = tex2D(ReShade::BackBuffer, texcoord).rgb;
	float3 color2 = color;
 
	color = pow(color, 1 / 2.2);
 
	color -= 0.1;
	color2 -= 0.1;

	color = color / (1.0 - color);
	color2 = color2 / (1.0 - color2);

	color2 = max(0, color2 - 1);
 
	float3 blur = float3(0.0, 0.0, 0.0);
	float blurRadius = 0.25;
 
	for(int i = -5; i < 5; i++) {
		for(int j = -5; j < 5; j++) {
			float3 currCol = tex2D(ReShade::BackBuffer, texcoord + float2(i * blurRadius / 100.0, j * blurRadius / 100.0)).rgb;
 
			currCol = currCol / (1 - currCol);
			currCol -= 1;
			currCol = max(0, min(1, currCol));
 
			blur += currCol;
		}
	}
 
	blur /= 100;
 
	color += blur * max(0, min(1, color - 1));
	color2 += blur * max(0, min(1, color2 - 1));

	float luminance = 0.0;

	for(int i = 0; i < 15; i ++) {
		for(int j = 0; j < 15; j ++) {
			luminance += tex2D(ReShade::BackBuffer, float2(i / 15.0, j / 15.0)).rgb;
		}
	}

	luminance /= 15 * 15;

	color = color / (1.0 + color);
	color = (color - 0.5) * 1.3 + 0.5;

	color2 = color2 / (1.0 + color2);

	color2 = min(1, color2);
 
	color += 0.1;
	color2 += 0.1;
 
	original -= 0.1;
 
	float3 finalColor = color * max(0, color2) * max(0, 1 - luminance) * 2 + original * max(0, 1 - color2);

	return lerp(color, finalColor, min(1, luminance));
}

technique BeamHDR
{
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = CustomPass;
	}
}
