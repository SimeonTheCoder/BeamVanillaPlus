#include "ReShade.fxh"
#include "ReShadeUI.fxh"

uniform float gamma <
	ui_type = "input";
	ui_label = "Gamma";
	ui_tooltip = "Set the desired gamma";
> = 1; 


float3 CustomPass(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
	float3 color = tex2D(ReShade::BackBuffer, texcoord).rgb;

    float3 diff = color - float3(0.5, 0.5, 0.5);

    color -= diff / 5;

	return color;
}

technique BeamHDR3
{
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = CustomPass;
	}
}
