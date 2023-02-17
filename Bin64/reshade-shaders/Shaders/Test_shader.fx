#include "ReShade.fxh"
#include "ReShadeUI.fxh"

float3 CustomPass(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
    float3 color = tex2D(ReShade::BackBuffer, texcoord).rgb;

	float3 depth = tex2D(ReShade::DepthBuffer, texcoord).rgb;
	
    depth = float3(depth.r, depth.r, depth.r);

    depth = pow(depth, 0.1);

    depth = max(0, 1 - depth);

    depth = min(1, pow(depth, 3));

    depth *= 5;

    float d = depth.r;

    float aveD = 0;

    for(int i = -5; i < 5; i ++) {
        for(int j = -5; j < 5; j ++) {
            float3 currDepth = tex2D(ReShade::DepthBuffer, texcoord + float2(i / 2400.0, j / 2400.0)).rgb;

            currDepth = pow(currDepth, 0.1);

            currDepth = max(0, 1 - currDepth);

            currDepth = min(1, pow(currDepth, 3));

            currDepth *= 5;

            aveD += currDepth;
        }
    }

    aveD /= 100;

    float haze = abs(aveD - d);
    haze *= 100;
    haze = min(1, haze);

    int x = floor(texcoord.x * 1600);
    int y = floor(texcoord.y * 900);

    x %= 10;
    y %= 10;

    x -= 5;
    y -= 5;

    d = max(0, d);

    float halftone = step(x * x + y * y, length(color) * 50 - 10);

    //return halftone;
    return (d - haze - 1 + halftone + color * 1.5) * 0.5;
}

technique TestShader
{
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = CustomPass;
	}
}
