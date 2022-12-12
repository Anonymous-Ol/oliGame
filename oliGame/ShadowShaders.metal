//
//  ShadowShaders.metal
//  oliGame
//
//  Created by Oliver Crumrine on 12/10/22.
//

#pragma once
#include <metal_stdlib>
using namespace metal;
#include "Shared.metal"
#include "Lighting.metal"

struct ShadowFragOutput{
    float depth [[depth(any)]];
};

vertex ShadowRasterizerData basic_shadow_vertex_shader(const VertexIn verticesIn [[stage_in]],
                                                       constant ModelConstants &modelConstants [[buffer(1)]],
                                                       constant int *lightCount [[buffer(2)]],
                                                       constant LightData *lightDatas [[buffer(3)]]){
    
    ShadowRasterizerData srd;
    
    float4 worldPosition = float4(verticesIn.position, 1) * modelConstants.modelMatrix;
    float4x4 shadowMVP = Lighting::ortho(-35,35,-35,35,0.1,1000) * Lighting::calculate_lookAt_matrix(float3(0,100,100), float3(0,0,0), float3(0,1,0));
    
    
    srd.position = worldPosition * shadowMVP;
    
    return srd;
}
vertex ShadowRasterizerData instanced_shadow_vertex_shader(const VertexIn verticesIn [[stage_in]],
                                             constant ModelConstants *modelConstants [[buffer(1)]],
                                             constant int *lightCount [[buffer(2)]],
                                             constant LightData *lightDatas [[buffer(3)]],
                                             uint instanceId [[instance_id]]){
    
    
    ShadowRasterizerData srd;
    ModelConstants modelConstant = modelConstants[instanceId];
    float4 worldPosition = modelConstant.modelMatrix * float4(verticesIn.position, 1);
    
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

fragment ShadowFragOutput basic_shadow_fragment_shader(ShadowRasterizerData srd [[stage_in]]){
    ShadowFragOutput sfo;
    sfo.depth = srd.position.z;
    return sfo;
}
