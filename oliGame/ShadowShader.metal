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

///Note: UNUSED
struct ShadowFragOutput{
    half4 color [[color(0)]];
    //float depth [[depth(any)]];
};




vertex ShadowRasterizerData vertex_shadow(
    VertexIn in                             [[stage_in ]],
    constant ModelConstants &modelConstants [[buffer(1)]],
    constant LightData      &lightData      [[buffer(2)]],
    constant uint           &face           [[buffer(3)]])
{
    ShadowRasterizerData srd;
    
    float4 worldPosition = modelConstants.modelMatrix * float4(in.position, 1);
    
    float4x4 shadowViewMatrix = Lighting::calculate_lookAt_matrix(lightData.position, lightData.lookAtPosition, float3(0,1,0));
    float4x4 shadowProjectionMatrix = Lighting::ortho(-lightData.orthoSize,lightData.orthoSize,-lightData.orthoSize,lightData.orthoSize,lightData.near,lightData.far);
    float4x4 biasedLightViewProjectMatrix = shadowProjectionMatrix * shadowViewMatrix;
    
    float4x4 shadowMVP = biasedLightViewProjectMatrix;
    
    
    srd.position =  shadowMVP * worldPosition;
    srd.face     =  face;
    //srd.position.z += 100;
    return srd;
}

vertex ShadowRasterizerData instanced_vertex_shadow(
             VertexIn        in                     [[ stage_in  ]],
    constant ModelConstants *multipleModelConstants [[ buffer(1) ]],
    constant LightData      &lightData              [[ buffer(2) ]],
    constant uint           &face                   [[ buffer(3) ]],
             uint            instanceId             [[instance_id]])
{
    ShadowRasterizerData srd;
    ModelConstants modelConstant = multipleModelConstants[instanceId];
    float4 worldPosition = modelConstant.modelMatrix * float4(in.position, 1);

    float4x4 shadowViewMatrix = Lighting::calculate_lookAt_matrix(lightData.position, lightData.lookAtPosition, float3(0,1,0));
    float4x4 shadowProjectionMatrix = Lighting::ortho(-lightData.orthoSize,lightData.orthoSize,-lightData.orthoSize,lightData.orthoSize,lightData.near,lightData.far);
    float4x4 biasedLightViewProjectMatrix = shadowProjectionMatrix * shadowViewMatrix;
    
    float4x4 shadowMVP = biasedLightViewProjectMatrix;
    
    srd.position = shadowMVP * worldPosition;
    srd.face     = face;
    //srd.position.z = abs(srd.position.z);
    return srd;
}

fragment ShadowFragOutput basic_shadow_frag(RasterizerData srd [[stage_in]]){
    ///Note: UNUSED
    ShadowFragOutput sfo;
    sfo.color = half4(srd.position.z, srd.position.z, srd.position.z, 1);

    //sfo.depth = rand(srd.position.x, srd.position.y, srd.position.z);
    return sfo;
}


