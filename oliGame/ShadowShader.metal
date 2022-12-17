//
//  ShadowShader.metal
//  oliGame
//
//  Created by Oliver Crumrine on 12/12/22.
//
#pragma once
#include <metal_stdlib>
using namespace metal;
#include "Shared.metal"
#include "Lighting.metal"

struct ShadowFragOutput{
    half4 color [[color(0)]];
    //float depth [[depth(any)]];
};



float rand(int x, int y, int z)
{
    int seed = x + y * 57 + z * 241;
    seed= (seed<< 13) ^ seed;
    return (( 1.0 - ( (seed * (seed * seed * 15731 + 789221) + 1376312589) & 2147483647) / 1073741824.0f) + 1.0f) / 2.0f;
}

vertex RasterizerData vertex_shadow(
    VertexIn in [[stage_in]],
    constant ModelConstants &modelConstants [[buffer(1)]],
    constant LightData *lightDatas [[buffer(2)]],
    constant int *lightCount [[buffer(3)]])
{
    RasterizerData srd;
    
    float4 worldPosition = float4(in.position, 1) * modelConstants.modelMatrix;
    float4x4 shadowMVP = Lighting::ortho(-35,35,-35,35,0.1,1000) * Lighting::calculate_lookAt_matrix(float3(0,100,100), float3(0,0,0), float3(0,1,0));
    
    
    srd.position = worldPosition * shadowMVP;
    
    return srd;
}

vertex RasterizerData instanced_vertex_shadow(
    VertexIn in [[stage_in]],
    constant ModelConstants *multipleModelConstants [[buffer(1)]],
    constant LightData *lightDatas [[buffer(2)]],
    constant int *lightCount [[buffer(3)]],
    uint instanceId [[instance_id]])
{
    RasterizerData srd;
    ModelConstants modelConstant = multipleModelConstants[instanceId];
    float4 worldPosition = modelConstant.modelMatrix * float4(in.position, 1);
    
    float4x4 shadowViewMatrix = Lighting::calculate_lookAt_matrix(float3(0,100,100), float3(0,0,0), float3(0,1,0));
    float4x4 shadowProjectionMatrix = Lighting::ortho(-35,35,-35,35,0.1,1000);
    float4x4 biasMatrix(
    0.5, 0.0, 0.0, 0.0,
    0.0, 0.5, 0.0, 0.0,
    0.0, 0.0, 0.5, 0.0,
    0.5, 0.5, 0.5, 1.0
    );
    
    float4x4 shadowMVP = shadowViewMatrix * shadowProjectionMatrix;
    float4x4 biasedShadowMVP = shadowMVP * biasMatrix;
    
    srd.position = float4((worldPosition * biasedShadowMVP).xyz, 1);
    return srd;
}

fragment ShadowFragOutput basic_shadow_frag(RasterizerData srd [[stage_in]]){
    ShadowFragOutput sfo;
    sfo.color = half4(srd.position.z, srd.position.z, srd.position.z, 1);

    //sfo.depth = rand(srd.position.x, srd.position.y, srd.position.z);
    return sfo;
}


