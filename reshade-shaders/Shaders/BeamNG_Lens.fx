#include "ReShade.fxh"
#include "ReShadeUI.fxh"
float3 CustomPass(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
	float depth = tex2D(ReShade::DepthBuffer, texcoord);

	depth = max(0, min(1, pow(depth, 0.1)));

	float2 vec = texcoord;

	float3 colorA = tex2D(ReShade::BackBuffer, vec).rgb;
	colorA *= float3(1, 0, 0);

	vec.x += float(depth) * 0.02 * 2;

	float3 colorB = tex2D(ReShade::BackBuffer, vec).rgb;
	colorB *= float3(0, 0, 1);

	return (colorA + colorB) ;
}

technique BeamLens
{
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = CustomPass;
	}
}
