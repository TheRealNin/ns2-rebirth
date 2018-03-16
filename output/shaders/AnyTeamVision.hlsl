#include <renderer/RenderSetup.hlsl>

struct VS_INPUT
{
   float3 ssPosition   : POSITION;
   float2 texCoord     : TEXCOORD0;
   float4 color        : COLOR0;
};

struct VS_OUTPUT
{
   float2 texCoord     : TEXCOORD0;
   float4 color        : COLOR0;
   float4 ssPosition   : SV_POSITION;
};

struct PS_INPUT
{
   float2 texCoord     : TEXCOORD0;
   float4 color        : COLOR0;
};

sampler2D       baseTexture;
sampler2D       depthTexture;
sampler2D       normalTexture;

cbuffer LayerConstants
{
    float        startTime;
    float        teamNumber;
    float        amount;
};

/**
* Vertex shader.
*/  
VS_OUTPUT SFXBasicVS(VS_INPUT input)
{

   VS_OUTPUT output;

   output.ssPosition = float4(input.ssPosition, 1);
   output.texCoord   = input.texCoord + texelCenter;
   output.color      = input.color;

   return output;

}

float2 clamp_tex2D( sampler2D tex, float2 coord )
{
    // TODO: remove this and fix sampler using wrapped instead of clamped addressing for depthTexture
    return tex2D( tex, clamp( coord, float2( 0.001, 0.001 ), float2( 0.999, 0.999 ) ) );
}


const float4 edgeColorBlue = float4(0.1, 0.8, 1, 0) * 8.0;
const float4 edgeColorDarkOrange = float4(0.8, 0.2, 0.0, 0) * 6.0;
const float4 edgeColorGreen = float4(0.2, 0.7, 0.00, 0) * 6.0;

const float4 edgeColor2 = float4(1.0, 1.0, 1.0, 0) * 0.25;

float4 SFXDarkVisionPS(PS_INPUT input) : COLOR0
{
    float2 texCoord = input.texCoord;
    float4 inputPixel = tex2D(baseTexture, texCoord);
    
    if (amount == 0) 
    {
        return inputPixel;
    }
    
    float2 depth1 = tex2D(depthTexture, input.texCoord).rg;
    
    
    // Flashlight on
    float offset = 0.001;
    float depth2 = clamp_tex2D(depthTexture, texCoord + float2(-offset, -offset)).r;
    float depth3 = clamp_tex2D(depthTexture, texCoord + float2(-offset,  offset)).r;
    float depth4 = clamp_tex2D(depthTexture, texCoord + float2( offset, -offset)).r;
    float depth5 = clamp_tex2D(depthTexture, texCoord + float2( offset,  offset)).r;
    
    float edge = 
            max(depth2 - depth1.r, 0) +
            max(depth3 - depth1.r, 0) +
            max(depth4 - depth1.r, 0) +
            max(depth5 - depth1.r, 0);
    
    if (depth1.g > 0.5) // entities
    {
    
        if (depth1.r < 0.4) // view model
        {
            return inputPixel;
        }
        
        float4 edgeColor;
        
        if (teamNumber > 1.5){ // team 2
            if ( depth1.g > 0.9 ) // team 2
            {
                return saturate( inputPixel + edgeColorBlue * 0.1 * amount * edge );
            }
            else if ( depth1.g > 0.8 ) // team 1
            {
                return saturate( inputPixel + edgeColorDarkOrange * 0.1 * amount * edge );
            }
            else // all other entities
            {
                return lerp(inputPixel, edgeColorGreen * edge, (0.1 + edge) * amount);
            }
        }else{ // team 1
            if ( depth1.g > 0.9 ) // team 2
            {
                return saturate( inputPixel + edgeColorDarkOrange * 0.1 * amount * edge );
            }
            else if ( depth1.g > 0.8 ) // team 1
            {
                return saturate( inputPixel + edgeColorBlue * 0.1 * amount * edge );
            }
            else // all other entities
            {
                return lerp(inputPixel, edgeColorGreen * edge, (0.1 + edge) * amount);
            }
        }
    }
    else // world geometry
    { 
        // no edges for skyboxes
        edge = edge * step( depth1.r, 60 );
        edge = edge * step( depth2,   60 );
        edge = edge * step( depth3,   60 );
        edge = edge * step( depth4,   60 );
        edge = edge * step( depth5,   60 );
        return lerp(inputPixel, (edgeColor2 * edge), 0.03 * amount);
    }
}