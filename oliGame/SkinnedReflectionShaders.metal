//
//  SkinnedReflectionShaders.metal
//  oliGame
//
//  Created by Oliver Crumrine on 3/18/23.
//
#pragma once
#include <metal_stdlib>
using namespace metal;
#include "Shared.metal"
#include "Lighting.metal"


vertex ReflectionRasterizerData cubemap_skinned_vertex_shader(const    VertexIn        verticesIn             [[stage_in]],
                                                      constant SceneConstants *multipleSceneConstants [[buffer(1)]],
                                                      constant ModelConstants &modelConstants         [[buffer(2)]],
                                                      constant uint           &face                   [[buffer(3)]],
                                                      constant ModelConstants *joints [[buffer(4)]]){
    
    ReflectionRasterizerData rd;
    SceneConstants sceneConstants = multipleSceneConstants[face];
    
    float4x4 skinningMatrix =
       verticesIn.jointWeights[0] * joints[verticesIn.jointIndices[0]].modelMatrix +
       verticesIn.jointWeights[1] * joints[verticesIn.jointIndices[1]].modelMatrix +
       verticesIn.jointWeights[2] * joints[verticesIn.jointIndices[2]].modelMatrix +
       verticesIn.jointWeights[3] * joints[verticesIn.jointIndices[3]].modelMatrix;
       
    
    float4 worldPosition = modelConstants.modelMatrix * skinningMatrix *  float4(verticesIn.position, 1);
    float4 worldNormal       = normalize(modelConstants.modelMatrix * skinningMatrix * float4(verticesIn.normal, 1.0));
    
    
    rd.position          = sceneConstants.projectionMatrix * sceneConstants.viewMatrix * worldPosition;
    
    rd.color             = verticesIn.color;
    rd.vertexPosition    = verticesIn.position;
    rd.textureCoordinate = verticesIn.textureCoordinate;
    rd.totalGameTime     = sceneConstants.totalGameTime;
    rd.worldPosition     = worldPosition.xyz;
    rd.surfaceNormal     = worldNormal.xyz;
    rd.toCameraVector    = sceneConstants.cameraPosition - worldPosition.xyz;
    
    rd.surfaceTangent    = normalize(modelConstants.modelMatrix * float4(verticesIn.tangent, 0.0)).xyz;
    rd.surfaceBiTangent  = normalize(modelConstants.modelMatrix * float4(verticesIn.bitangent, 0.0)).xyz;
    
    rd.face = face;
    
    return rd;
}
vertex ReflectionRasterizerData skinned_cubemap_instanced_vertex_shader(const    VertexIn        verticesIn             [[stage_in]],
                                                                constant SceneConstants *multipleSceneConstants [[buffer(1)]],
                                                                constant ModelConstants *modelConstants         [[buffer(2)]],
                                                                constant uint           &face                   [[buffer(3)]],
                                                                         uint            instanceId             [[instance_id]],
                                                                constant ModelConstants *joints [[buffer(4)]],
                                                                constant uint &jointBufferLength [[buffer(5)]]){
        ReflectionRasterizerData rd;
    
        ModelConstants modelConstant  = modelConstants[instanceId];
        SceneConstants sceneConstants = multipleSceneConstants[face];
    
    float4x4 skinningMatrix =
    verticesIn.jointWeights[0] * joints[instanceId * jointBufferLength + verticesIn.jointIndices[0] + instanceId].modelMatrix +
    verticesIn.jointWeights[1] * joints[instanceId * jointBufferLength + verticesIn.jointIndices[1] + instanceId].modelMatrix +
    verticesIn.jointWeights[2] * joints[instanceId * jointBufferLength + verticesIn.jointIndices[2] + instanceId].modelMatrix +
    verticesIn.jointWeights[3] * joints[instanceId * jointBufferLength + verticesIn.jointIndices[3] + instanceId].modelMatrix;
   

float4 worldPosition = modelConstant.modelMatrix * skinningMatrix *  float4(verticesIn.position, 1);

float3 worldNormal       =           (modelConstant.modelMatrix * skinningMatrix * float4(verticesIn.normal.xyz, 0)).xyz ;
    
    
        rd.position = sceneConstants.projectionMatrix * sceneConstants.viewMatrix * worldPosition;
        
        
        rd.color = verticesIn.color;
        rd.textureCoordinate = verticesIn.textureCoordinate;
        rd.totalGameTime = sceneConstants.totalGameTime;
        rd.worldPosition = worldPosition.xyz;
        rd.toCameraVector = sceneConstants.cameraPosition - worldPosition.xyz;
        
        rd.surfaceNormal = worldNormal.xyz;
        rd.surfaceTangent = normalize(modelConstant.modelMatrix * float4(verticesIn.tangent, 0.0)).xyz;
        rd.surfaceBiTangent = normalize(modelConstant.modelMatrix * float4(verticesIn.bitangent, 0.0)).xyz;
    
        rd.face = face;
    

        return rd;
    
    
}
