#include "ReShade.fxh"
#include "ReShadeUI.fxh"
float3 CustomPass(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
	float depth = tex2D(ReShade::DepthBuffer, texcoord);
    depth = exp2(depth) - 0.5;
	depth = max(0, min(1, depth));
	//depth = pow(depth, 0.1);

    float2 vec = texcoord;

    float distance_factor = 0.033 / 2.0;

    vec.x -= depth * distance_factor; // offset left image
    float3 colorA = tex2D(ReShade::BackBuffer, vec).rgb;
	colorA = colorA * float3(1, 0, 0);

    vec.x += depth * 2 * distance_factor; // offset right image
    float3 colorB = tex2D(ReShade::BackBuffer, vec).rgb;
	colorB = colorB * float3(0, 1, 1);

	//return colorA;
    return colorA + colorB;
}

technique BeamLens
{
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = CustomPass;
	}
}
