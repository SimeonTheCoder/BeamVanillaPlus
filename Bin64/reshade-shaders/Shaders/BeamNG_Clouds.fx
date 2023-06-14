#include "ReShade.fxh"
#include "ReShadeUI.fxh"

bool Cloud(float3 color) {
	return max(0, min(1, (color.r - color.b * 0.3 - color.g * 0.3) * 1));
}

float3 CustomPass(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
	float3 color = tex2D(ReShade::BackBuffer, texcoord).rgb;
	
	float3 depth = tex2D(ReShade::DepthBuffer, texcoord).rgb;

	depth = pow(depth, 0.1);
	depth = 1 - depth;
	depth = max(0, min(1, depth));

	depth = float3(depth.x, depth.x, depth.x);

	if(depth.x < 0.95) discard;

	float cloudMask = 0;

	for(int i = -3; i < 3; i ++) {
		for(int j = -3; j < 3; j ++) {
			cloudMask += Cloud(tex2D(ReShade::BackBuffer, texcoord + float2(i / 600.0, j / 600.0)).rgb);
		}
	}

	cloudMask /= 36;

	float cloud_level = 0;

	for(int i = 0; i < 20; i ++) {
		float3 curr = tex2D(ReShade::BackBuffer, texcoord + float2(0, i / 300.0 - 0.05)).rgb;

		float cloudiness = 0;

		for(int a = -2; a < 2; a ++) {
			for(int b = -2; b < 2; b ++) {
				cloudiness += Cloud(tex2D(ReShade::BackBuffer, texcoord + float2(i / 600.0, i / 300.0 - 0.05 - 0.03) + float2(a / 300.0, b / 300.0)).rgb);
			}
		}

		cloudiness /= 25;

		cloud_level += cloudiness;
	}

	cloud_level /= 20.0;

	return color * 1.1 - (cloud_level * length(color)) * 0.2 * cloudMask;

	//cloud_level = 1 - cloud_level;

	//return lerp(color, cloud_level * .5 + color, .2);
	//return lerp(color, color + cloud_level * 0.1, cloudMask);
}

technique BeamClouds
{
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = CustomPass;
	}
}
