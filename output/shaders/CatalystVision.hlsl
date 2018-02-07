#include <renderer/RenderSetup.hlsl>

struct VS_INPUT
{
    float3 ssPosition   : POSITION;
    float2 texCoord     : TEXCOORD0;
};


struct VS_OUTPUT
{
    float2 texCoord     : TEXCOORD0;
    float4 ssPosition   : SV_POSITION;
};

struct PS_INPUT
{
    float2 texCoord     : TEXCOORD0;
};

sampler2D baseTexture;
sampler2D depthTexture;
sampler2D normalTexture;

cbuffer LayerConstants
{
    float   amount;
};    
    
VS_OUTPUT CatalystVisionVS(VS_INPUT input)
{
     VS_OUTPUT output;

    output.ssPosition = float4(input.ssPosition, 1);
    output.texCoord   = input.texCoord + texelCenter;
    
    return output;
}

float4 CatalystVisionPS(PS_INPUT input) : COLOR
{
    float2 texCoord = input.texCoord;
    float4 inputPixel = tex2D(baseTexture, texCoord);
    const float4 flashColor = float4(0, 0.2, 1, 1);
    float2 depth = tex2D(depthTexture, texCoord).rg;
    
    float2 screenCenter = float2(0.5, 0.5);
    float darkened = pow(clamp(length(texCoord - screenCenter), 0, 1), 2);
    
    float flash = pow(max(0, amount - 0.8) / 0.2, 2);
    float3 normal = tex2D(normalTexture, texCoord).xyz;
    float intensity = pow((abs(normal.z - 0.5) + abs(normal.y - 0.5) + abs(normal.x - 0.5)) * 1.4, 8) * 0.5;

    return inputPixel * 0.5 + inputPixel * amount * depth.g * 20 + intensity * amount * darkened * flashColor * 0.5;
}
