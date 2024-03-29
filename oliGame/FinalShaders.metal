//
//  FinalShaders.metal
//  oliGame
//
//  Created by Oliver Crumrine on 12/5/22.
//

#pragma once
#include <metal_stdlib>
#include "Shared.metal"
#include "Lighting.metal"
using namespace metal;

struct FinalRasterizerData {
    float4 position [[position]];
    float2 textureCoordinate;
};

vertex FinalRasterizerData final_vertex_shader(const VertexIn vIn [[stage_in]]){
    FinalRasterizerData rd;
    rd.position = float4(vIn.position, 1.0);
    rd.textureCoordinate = float2(vIn.textureCoordinate);
    
    return rd;
}

fragment half4 final_fragment_shader(const FinalRasterizerData rd [[stage_in]],
                                     texture2d<float> baseTexture [[texture(0)]]){
    sampler s;
    float2 textureCoordinate = rd.textureCoordinate;
    textureCoordinate.y = 1 - textureCoordinate.y;
    



    float4 color = baseTexture.sample(s, textureCoordinate);
    return half4(color);
}
