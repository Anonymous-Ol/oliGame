//
//  InstancedShaders.metal
//  oliGame
//
//  Created by Oliver Crumrine on 11/27/22.
//
#pragma once
#include <metal_stdlib>
using namespace metal;
#include "Shared.metal"
#include "Lighting.metal"

vertex RasterizerData instanced_vertex_shader(const VertexIn verticesIn [[stage_in]],
                                              constant SceneConstants &sceneConstants [[buffer(1)]],
                                              constant ModelConstants *modelConstants [[buffer(2)]],
                                              uint instanceId [[instance_id]]){
        RasterizerData rd;
    
        ModelConstants modelConstant = modelConstants[instanceId];
    
        float4 worldPosition = modelConstant.modelMatrix * float4(verticesIn.position, 1);
        float4 worldNormal       = normalize(modelConstant.modelMatrix * float4(verticesIn.normal, 1.0));
        float3 reflectionNormal  = normalize(modelConstant.modelMatrix * float4(verticesIn.normal.xyz, 0)).xyz;
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
