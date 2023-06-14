#include "ReShade.fxh"
#include "ReShadeUI.fxh"

float3 YCbCrToRGB(float3 YCbCr)
{
    float Y = YCbCr.x;
    float Cb = YCbCr.y - 0.5;
    float Cr = YCbCr.z - 0.5;
    
    float R = Y + 1.402 * Cr;
    float G = Y - 0.344136 * Cb - 0.714136 * Cr;
    float B = Y + 1.772 * Cb;
    
    return float3(R, G, B);
}

float3 RGBToYCbCr(float3 RGB)
{
    float R = RGB.x;
    float G = RGB.y;
    float B = RGB.z;
    
    float Y = 0.299 * R + 0.587 * G + 0.114 * B;
    float Cb = -0.168736 * R - 0.331264 * G + 0.5 * B + 0.5;
    float Cr = 0.5 * R - 0.418688 * G - 0.081312 * B + 0.5;
    
    return float3(Y, Cb, Cr);
}

float3 CustomPass(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
	float3 color = tex2D(ReShade::BackBuffer, texcoord).rgb;

	float3 average = float3(113.64173841674926 / 255.0, 123.28457269986785 / 255.0, 127.0869760695408 / 255.0);
	float3 deviation = float3(49.85091323301966 / 255.0, 9.123249402217837 / 255.0, 6.809616781862127 / 255.0);

	// float3 average = float3(0,0,0);
	// float3 deviation = float3(0,0,0);

	// for(int i = 0; i < 10; i ++) {
	// 	for(int j = 0; j < 10; j ++) {
	// 		float2 uv = float2(i / 10.0, j / 10.0);

	// 		float3 curr = tex2D(ReShade::BackBuffer, uv).rgb;
	// 		curr = RGBToYCbCr(curr);

	// 		average += curr;
	// 	}
	// }

	// average /= 100;

	// for(int i = 0; i < 10; i ++) {
	// 	for(int j = 0; j < 10; j ++) {
	// 		float2 uv = float2(i / 10.0, j / 10.0);

	// 		float3 curr = tex2D(ReShade::BackBuffer, uv).rgb;
	// 		curr = RGBToYCbCr(curr);

	// 		float3 diff = curr - average;
	// 		diff = pow(diff, 2);

	// 		deviation += diff;
	// 	}
	// }

	// deviation /= 100;
	// deviation = sqrt(deviation);

	color = RGBToYCbCr(color);

	color -= average;
	color *= float3(53.10000993225072 / 255.0, 14.636158810871017 / 255.0, 10.235458342729457 / 255.0) / deviation;
	color += float3(95.47650414737655 / 255.0, 119.99221498842593 / 255.0, 129.50694155092592 / 255.0);

	// color -= float3(91.8396378279321 / 255.0, 127.66565923996913 / 255.0, 126.1294671103395 / 255.0);
	// color *= deviation / float3(49.42292899679166 / 255.0, 8.279024195055023 / 255.0, 7.416248878614973 / 255.0);
	// color += average;

	color = YCbCrToRGB(color);

	color *= float3(1, 1, 1.1);

	return color;
}

technique BeamTransfer
{
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = CustomPass;
	}
}
