#include "ReShade.fxh"
#include "ReShadeUI.fxh"
float3 CustomPass(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
	float depth = tex2D(ReShade::DepthBuffer, texcoord);

	depth = max(0, min(1, pow(depth, 0.1)));

	float2 vec = texcoord;

	float distance_factor = 1.5;

	float3 colorA = tex2D(ReShade::BackBuffer, vec).rgb;
	colorA *= float3(1, 0, 0);

	vec.x += float(depth) * 0.02 * distance_factor;

	float3 colorB = tex2D(ReShade::BackBuffer, vec).rgb;
	colorB *= float3(0, 0, 1);

	vec.x -= float(depth) * 0.02 * distance_factor / 2.0;

	float3 colorC = tex2D(ReShade::BackBuffer, vec).rgb;
	colorC *= float3(0, 1, 0);

	return (colorA + colorB + colorC) ;
}

technique BeamLens
{
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = CustomPass;
	}
}
