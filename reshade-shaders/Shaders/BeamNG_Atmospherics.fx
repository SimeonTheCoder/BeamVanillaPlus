#include "ReShade.fxh"
#include "ReShadeUI.fxh"

float3 CustomPass(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
	float3 color = tex2D(ReShade::BackBuffer, texcoord).rgb;
	float depth = tex2D(ReShade::DepthBuffer, texcoord).rgb;

	depth = pow(depth, 0.1);
	depth = 1 - depth;
	depth = max(0, min(1, depth));

	if(depth > 0.9) {
		depth = 0;
	}

	depth = (depth - 0.5) * 5 + 0.5;
	depth = max(0, min(1, depth));

	depth = 1 - abs(0.5 - depth) - 0.5;

	//return depth;
	return depth * 0.3 + color;
}

technique BeamAtm
{
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = CustomPass;
	}
}
