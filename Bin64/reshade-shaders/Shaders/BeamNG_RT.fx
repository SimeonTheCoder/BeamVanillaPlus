#include "ReShade.fxh"
#include "ReShadeUI.fxh"

uniform bool t <source="key"; keycode=0x54; toggle=true;>;
uniform bool v <source="key"; keycode=0x56; toggle=true;>;

uniform float thickness <
	ui_type = "drag";
	ui_label = "Thickness";
	ui_tooltip = "Set the desired thickness.";
> = 0;

uniform float denoise <
	ui_type = "drag";
	ui_label = "Denoise strength";
	ui_tooltip = "Set the desired denoise strength.";
> = 1;

uniform float softness <
	ui_type = "drag";
	ui_label = "Ambient softness";
	ui_tooltip = "Set the desiredambient softness";
> = 1;

uniform float light_strength <
	ui_type = "drag";
	ui_label = "Light strength";
	ui_tooltip = "Set the desired light strength.";
> = .3;

uniform float vegetation_transparency <
	ui_type = "drag";
	ui_label = "Vegetation transparency";
	ui_tooltip = "Set the desired vegetation transparency.";
> = .5;

uniform float2 light_dir <
	ui_type = "drag";
	ui_label = "Light direction";
	ui_tooltip = "Set the desired light direction.";
> = float2(0, 1);

uniform bool snow <
	ui_type = "check";
	ui_label = "Snow";
	ui_tooltip = "Makes eveyrhint snowy.";
> = false;

uniform float snow_amount <
	ui_type = "drag";
	ui_label = "Snow amount";
	ui_tooltip = "Set the desired snow amount.";
> = 1;

float VegetationMask(float3 color) {
	float vegetationMask = color.g - color.r * 0.5 - color.b * 0.5;
	vegetationMask *= 10;
	vegetationMask -= 0.9;

	vegetationMask = max(0, min(1, vegetationMask));

	vegetationMask *= 1000;

	vegetationMask = max(0, min(1, vegetationMask));

	return vegetationMask;
}

float CalculateLight(float2 texcoord, float depth, float2 light_dir) {
	float smallestDepthDiff = 10;
	float3 collColor = float3(0,0,0);

	for(int i = 0; i < 15; i ++) {
		float x = texcoord.x - i / 200.0 * light_dir.x;
		float y = texcoord.y - i / 200.0 * light_dir.y;

		float curr = tex2D(ReShade::DepthBuffer, float2(x, y)).r;
		float3 col = tex2D(ReShade::BackBuffer, float2(x, y)).rgb;

		curr = pow(curr, 0.1);
		curr = 1 - curr;
		curr = max(0, min(1, curr));

		float diff = curr - depth.x;

		if(diff < thickness) {
			smallestDepthDiff = diff;
			collColor = col;
		}
	}

	if(smallestDepthDiff < thickness) {
		return (vegetation_transparency * VegetationMask(collColor)) * 1.5;
	}

	return 1;
}

float3 CustomPass(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
	float3 color = tex2D(ReShade::BackBuffer, texcoord).rgb;
	float veg = VegetationMask(color);

	float3 skyColor;

	if(t) {
		skyColor = float3(0,0,0);
		int samplesCount = 0;

		for(int i = 0; i < 5; i ++) {
			for(int j = 0; j < 5; j ++) {
				float2 uv = float2(i / 5.0, j / 5.0);

				float3 currDepth = tex2D(ReShade::DepthBuffer, uv).rgb;

				currDepth = pow(currDepth, 0.1);
				currDepth = 1 - currDepth;
				currDepth = max(0, min(1, currDepth));

				if(currDepth.x > 0.95) {
					samplesCount ++;

					skyColor += tex2D(ReShade::BackBuffer, uv).rgb;
				}
			}
		}

		if(samplesCount != 0) {
			skyColor = skyColor / samplesCount;
		}else{
			skyColor = float3(0, 0, 0);
		}
	}else{
		skyColor = float3(179 / 255.0, 202 / 255.0, 221 / 255.0);
	}


	float3 depth = tex2D(ReShade::DepthBuffer, texcoord).rgb;

	depth = pow(depth, 0.1);
	depth = 1 - depth;
	depth = max(0, min(1, depth));

	if(depth.x > 0.95) discard;

	float ave = 0;

	for(int a = -1; a < 1; a ++) {
		for(int b = -1; b < 1; b ++) {
			ave += CalculateLight(texcoord + float2(a / 600.0 * denoise, b / 600.0 * denoise), depth, light_dir + float2(a / 10.0 * softness, b / 10.0 * softness));
			ave += CalculateLight(texcoord + float2(-a / 600.0 * denoise, -b / 600.0 * denoise), depth, light_dir + float2(-a / 10.0 * softness, b / 10.0 * softness));
		}
	}

	ave /= 18;

	float3 light = lerp(skyColor * ave * light_strength, length(skyColor * ave) * light_strength, 0.7) * color;

	if(v) return ave;

	if(snow) {
		ave -= 1 - snow_amount;
		ave = pow(ave, snow_amount);
		ave = max(0, min(1, ave));
		ave = 1 - ave;

		ave /= 5;

		return lerp(lerp(color, length(color), veg * snow_amount), length(color) + float3(.1,.1,.1), ave * 3);
	}

	//return VegetationMask(color);
	//return ave;
	return color + ave * skyColor * light_strength;
	//return lerp(color, light, ave);
}

technique BeamRT
{
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = CustomPass;
	}
}
