//
//  SkinnedShadowShaders.metal
//  oliGame
//
//  Created by Oliver Crumrine on 3/18/23.
//

#pragma once
#include <metal_stdlib>
#include "Shared.metal"
#include "Lighting.metal"
using namespace metal;

vertex ShadowRasterizerData skinned_vertex_shadow(
    VertexIn in                             [[stage_in ]],
    constant ModelConstants &modelConstants [[buffer(1)]],
    constant LightData      &lightData      [[buffer(2)]],
    constant uint           &face           [[buffer(3)]],
    constant ModelConstants *joints [[buffer(4)]])
{
    ShadowRasterizerData srd;
    float4x4 skinningMatrix =
       in.jointWeights[0] * joints[in.jointIndices[0]].modelMatrix +
       in.jointWeights[1] * joints[in.jointIndices[1]].modelMatrix +
       in.jointWeights[2] * joints[in.jointIndices[2]].modelMatrix +
       in.jointWeights[3] * joints[in.jointIndices[3]].modelMatrix;
       
    
    float4 skinnedPosition = modelConstants.modelMatrix * float4(in.position, 1);
    float4 worldPosition     = skinningMatrix * skinnedPosition;
    
    float4x4 shadowViewMatrix = Lighting::calculate_lookAt_matrix(lightData.position, lightData.lookAtPosition, float3(0,1,0));
    float4x4 shadowProjectionMatrix = Lighting::ortho(-lightData.orthoSize,lightData.orthoSize,-lightData.orthoSize,lightData.orthoSize,lightData.near,lightData.far);
    float4x4 biasedLightViewProjectMatrix = shadowProjectionMatrix * shadowViewMatrix;
    
    float4x4 shadowMVP = biasedLightViewProjectMatrix;
    
    
    srd.position =  shadowMVP * worldPosition;
    srd.face     =  face;
    return srd;
}
vertex ShadowRasterizerData skinned_instanced_vertex_shadow(
             VertexIn        in                     [[ stage_in  ]],
    constant ModelConstants *multipleModelConstants [[ buffer(1) ]],
    constant LightData      &lightData              [[ buffer(2) ]],
    constant uint           &face                   [[ buffer(3) ]],
             uint            instanceId             [[instance_id]],
    constant ModelConstants *joints [[buffer(4)]],
    constant uint &jointBufferLength [[buffer(5)]])
{
    ShadowRasterizerData srd;
    ModelConstants modelConstant = multipleModelConstants[instanceId];
    float4x4 skinningMatrix =
    in.jointWeights[0] * joints[instanceId * jointBufferLength + in.jointIndices[0] + instanceId].modelMatrix +
    in.jointWeights[1] * joints[instanceId * jointBufferLength + in.jointIndices[1] + instanceId].modelMatrix +
    in.jointWeights[2] * joints[instanceId * jointBufferLength + in.jointIndices[2] + instanceId].modelMatrix +
    in.jointWeights[3] * joints[instanceId * jointBufferLength + in.jointIndices[3] + instanceId].modelMatrix;
   

    float4 worldPosition = modelConstant.modelMatrix * skinningMatrix *  float4(in.position, 1);


    float4x4 shadowViewMatrix = Lighting::calculate_lookAt_matrix(lightData.position, lightData.lookAtPosition, float3(0,1,0));
    float4x4 shadowProjectionMatrix = Lighting::ortho(-lightData.orthoSize,lightData.orthoSize,-lightData.orthoSize,lightData.orthoSize,lightData.near,lightData.far);
    float4x4 biasedLightViewProjectMatrix = shadowProjectionMatrix * shadowViewMatrix;
    
    float4x4 shadowMVP = biasedLightViewProjectMatrix;
    
    srd.position = shadowMVP * worldPosition;
    srd.face     = face;
    //srd.position.z = abs(srd.position.z);
    return srd;
}
