//
//  Shaders.metal
//  oliGame
//
//  Created by Oliver Crumrine on 11/25/22.
//
#pragma once
#include <metal_stdlib>
using namespace metal;
#include "Shared.metal"
#include "Lighting.metal"

struct FragOutput{
    half4 color0 [[color(0)]];
    half4 color1 [[color(1)]];
};

vertex RasterizerData basic_vertex_shader(const VertexIn verticesIn [[stage_in]],
                                          constant SceneConstants &sceneConstants [[buffer(1)]],
                                          constant ModelConstants &modelConstants [[buffer(2)]]){
    
    RasterizerData rd;
    
        float4 worldPosition = modelConstants.modelMatrix * float4(verticesIn.position, 1);
        rd.position = sceneConstants.projectionMatrix * sceneConstants.viewMatrix * worldPosition;
        
    

        
        
        rd.color = verticesIn.color;
        rd.vertexPosition = verticesIn.position;
        rd.textureCoordinate = verticesIn.textureCoordinate;
        rd.totalGameTime = sceneConstants.totalGameTime;
        rd.worldPosition = worldPosition.xyz;
        rd.surfaceNormal = normalize(modelConstants.modelMatrix * float4(verticesIn.normal, 1.0)).xyz;
        rd.toCameraVector = sceneConstants.cameraPosition - worldPosition.xyz;
        
        rd.surfaceTangent = normalize(modelConstants.modelMatrix * float4(verticesIn.tangent, 0.0)).xyz;
        rd.surfaceBiTangent = normalize(modelConstants.modelMatrix * float4(verticesIn.bitangent, 0.0)).xyz;
     
    
    return rd;
}


fragment FragOutput basic_fragment_shader(RasterizerData rd [[stage_in]],
                                     constant Material &material [[buffer(1)]],
                                     constant int &lightCount [[buffer(2)]],
                                     constant LightData *lightDatas [[buffer(3)]],
                                     constant float3 &cameraPosition [[buffer(4)]],
                                     sampler sampler2d [[sampler(0)]],
                                     texture2d<float> baseColorMap [[texture(0)]],
                                     texture2d<float> normalMap [[texture(1)]],
                                     depth2d<float, access::sample> shadowMap [[texture(2)]]){
        FragOutput out;

        float3 position = rd.vertexPosition;
        float2 texCoord = rd.textureCoordinate;
        float4 color = material.color;
        
        if(material.useBaseTexture){
            color = baseColorMap.sample(sampler2d, texCoord);
        }
        float3 unitNormal;
        if(material.isLit){
            unitNormal = normalize(rd.surfaceNormal);
            if(material.useNormalMapTexture){
                
                float3 sampleNormal = normalMap.sample(sampler2d, texCoord).rgb * 2 - 1;
                float3x3 TBN = { rd.surfaceTangent, rd.surfaceBiTangent, rd.surfaceNormal};
                unitNormal = TBN*sampleNormal;
                
            }
            float3 unitToCameraVector = normalize(rd.toCameraVector);
            float4x4 shadowViewMatrix = Lighting::calculate_lookAt_matrix(float3(0,100,100), float3(0,0,0), float3(0,1,0));
            float4x4 shadowProjectionMatrix = Lighting::ortho(-35,35,-35,35,0.1,1000);
            float4x4 biasedLightViewProjectMatrix = shadowProjectionMatrix * shadowViewMatrix;
            float shadowFactor = 1 - Lighting::shadow(rd.worldPosition, shadowMap, biasedLightViewProjectMatrix);
            
            SceneLightData sceneLighting = Lighting::GetPhongIntensity(material,
                                                                       lightDatas,
                                                                       lightCount,
                                                                       rd.worldPosition,
                                                                       unitNormal,
                                                                       unitToCameraVector,
                                                                       position,
                                                                       cameraPosition,
                                                                       shadowFactor);
            
            
            color *= float4(sceneLighting.phongIntensity, 1.0);
        }
        
        out.color0 = half4(color.r, color.g, color.b, color.a);
        out.color1 = half4(unitNormal.x, unitNormal.y, unitNormal.z, 1.0);


    return out;
}



