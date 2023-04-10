//
//  SkinnedShaders.metal
//  oliGame
//
//  Created by Oliver Crumrine on 3/11/23.
//
#pragma once
#include <metal_stdlib>
#include "Shared.metal"
using namespace metal;


vertex RasterizerData skinned_vertex_shader(const VertexIn verticesIn [[stage_in]],
                                            constant SceneConstants &sceneConstants [[buffer(1)]],
                                            constant ModelConstants &modelConstants [[buffer(2)]],
                                            constant ModelConstants *joints [[buffer(4)]]){
    
    RasterizerData rd;
    
    float4x4 skinningMatrix =
    verticesIn.jointWeights[0] * joints[verticesIn.jointIndices[0]].modelMatrix +
    verticesIn.jointWeights[1] * joints[verticesIn.jointIndices[1]].modelMatrix +
    verticesIn.jointWeights[2] * joints[verticesIn.jointIndices[2]].modelMatrix +
    verticesIn.jointWeights[3] * joints[verticesIn.jointIndices[3]].modelMatrix;
    
    
    float4 worldPosition = modelConstants.modelMatrix * skinningMatrix *  float4(verticesIn.position, 1);
    
    float3 worldNormal       =           (modelConstants.modelMatrix * skinningMatrix * float4(verticesIn.normal.xyz, 0)).xyz ;
    float3 reflectionNormal = normalize(modelConstants.modelMatrix * skinningMatrix * float4(verticesIn.normal.xyz, 0)).xyz;
    float3 viewVector = normalize(sceneConstants.cameraPosition.xyz - worldPosition.xyz);
    
    
    rd.position          = sceneConstants.projectionMatrix * sceneConstants.viewMatrix * worldPosition;
    
    rd.color             = verticesIn.color;
    rd.vertexPosition    = verticesIn.position;
    rd.textureCoordinate = verticesIn.textureCoordinate;
    rd.totalGameTime     = sceneConstants.totalGameTime;
    rd.worldPosition     = worldPosition.xyz;
    rd.surfaceNormal     = worldNormal.xyz;
    rd.toCameraVector    = sceneConstants.cameraPosition - worldPosition.xyz;
    
    rd.surfaceTangent    = (modelConstants.modelMatrix * float4(verticesIn.tangent, 0.0)).xyz;
    rd.surfaceBiTangent  = (modelConstants.modelMatrix * float4(verticesIn.bitangent, 0.0)).xyz;
    
    
    rd.reflectionVector  = reflect(-viewVector, reflectionNormal);
    rd.reflectionVector = float3(-rd.reflectionVector.x, rd.reflectionVector.y, rd.reflectionVector.z);
    
    return rd;
}

vertex RasterizerData skinned_instanced_vertex_shader(const VertexIn verticesIn [[stage_in]],
                                                      constant SceneConstants &sceneConstants [[buffer(1)]],
                                                      constant ModelConstants *modelConstants [[buffer(2)]],
                                                      uint instanceId [[instance_id]],
                                                      constant ModelConstants *joints [[buffer(4)]],
                                                      constant uint &jointBufferLength [[buffer(5)]]){
    RasterizerData rd;
    
    ModelConstants modelConstant = modelConstants[instanceId];
    float4x4 skinningMatrix =
    verticesIn.jointWeights[0] * joints[instanceId * jointBufferLength + verticesIn.jointIndices[0] + instanceId].modelMatrix +
    verticesIn.jointWeights[1] * joints[instanceId * jointBufferLength + verticesIn.jointIndices[1] + instanceId].modelMatrix +
    verticesIn.jointWeights[2] * joints[instanceId * jointBufferLength + verticesIn.jointIndices[2] + instanceId].modelMatrix +
    verticesIn.jointWeights[3] * joints[instanceId * jointBufferLength + verticesIn.jointIndices[3] + instanceId].modelMatrix;
    
    
    float4 worldPosition = modelConstant.modelMatrix * skinningMatrix *  float4(verticesIn.position, 1);
    
    float3 worldNormal       =           (modelConstant.modelMatrix * skinningMatrix * float4(verticesIn.normal.xyz, 0)).xyz ;
    float3 reflectionNormal = normalize(modelConstant.modelMatrix * skinningMatrix * float4(verticesIn.normal.xyz, 0)).xyz;
    
    float3 viewVector = normalize(sceneConstants.cameraPosition.xyz - worldPosition.xyz);
    
    rd.position = sceneConstants.projectionMatrix * sceneConstants.viewMatrix * worldPosition;
    
    
    rd.color = verticesIn.color;
    rd.textureCoordinate = verticesIn.textureCoordinate;
    rd.totalGameTime = sceneConstants.totalGameTime;
    rd.worldPosition = worldPosition.xyz;
    rd.toCameraVector = sceneConstants.cameraPosition - worldPosition.xyz;
    
    rd.surfaceNormal = worldNormal.xyz;
    rd.surfaceTangent = normalize(modelConstant.modelMatrix * float4(verticesIn.tangent, 0.0)).xyz;
    rd.surfaceBiTangent = normalize(modelConstant.modelMatrix * float4(verticesIn.bitangent, 0.0)).xyz;
    
    rd.reflectionVector = reflect(-viewVector, reflectionNormal);
    rd.reflectionVector = float3(-rd.reflectionVector.x, rd.reflectionVector.y, rd.reflectionVector.z);
    
    return rd;
    
    
}
