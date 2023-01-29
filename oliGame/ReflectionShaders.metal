//
//  ReflectionShaders.metal
//  oliGame
//
//  Created by Oliver Crumrine on 12/26/22.
//



#pragma once
#include <metal_stdlib>
using namespace metal;
#include "Shared.metal"
#include "Lighting.metal"

struct FragOutput{
    half4 color0 [[color(0)]];
};

vertex ReflectionRasterizerData cubemap_instanced_vertex_shader(const    VertexIn        verticesIn             [[stage_in]],
                                                                constant SceneConstants *multipleSceneConstants [[buffer(1)]],
                                                                constant ModelConstants *modelConstants         [[buffer(2)]],
                                                                constant uint           &face                   [[buffer(3)]],
                                                                         uint            instanceId             [[instance_id]]){
        ReflectionRasterizerData rd;
    
        ModelConstants modelConstant  = modelConstants[instanceId];
        SceneConstants sceneConstants = multipleSceneConstants[face];
    
        float4 worldPosition = modelConstant.modelMatrix * float4(verticesIn.position, 1);
        float4 worldEyeDirection = normalize(worldPosition - float4(sceneConstants.cameraPosition,1));
        float4 worldNormal       = normalize(modelConstant.modelMatrix * float4(verticesIn.normal, 1.0));
    
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

vertex ReflectionRasterizerData cubemap_vertex_shader(const    VertexIn        verticesIn             [[stage_in]],
                                                      constant SceneConstants *multipleSceneConstants [[buffer(1)]],
                                                      constant ModelConstants &modelConstants         [[buffer(2)]],
                                                      constant uint           &face                   [[buffer(3)]]){
    
    ReflectionRasterizerData rd;
    SceneConstants sceneConstants = multipleSceneConstants[face];
    
    float4 worldPosition     = modelConstants.modelMatrix * float4(verticesIn.position, 1);
    float4 worldEyeDirection = normalize(worldPosition - float4(sceneConstants.cameraPosition,1));
    float4 worldNormal       = normalize(modelConstants.modelMatrix * float4(verticesIn.normal, 1.0));
    
    
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


fragment FragOutput cubemap_fragment_shader(ReflectionRasterizerData rd [[stage_in]],
                                            constant Material &material [[buffer(1)]],
                                            constant int &lightCount [[buffer(2)]],
                                            constant LightData *lightDatas [[buffer(3)]],
                                            constant float3 *cameraPositions [[buffer(4)]],
                                            sampler sampler2d [[sampler(0)]],
                                            texture2d<float> baseColorMap [[texture(0)]],
                                            texture2d<float> normalMap [[texture(1)]],
                                            depth2d_array<float, access::sample> shadowTextures [[texture(2)]]
                                            ){
    FragOutput out;
    float3 cameraPosition = cameraPositions[rd.face];
    //Rasterizer Data Stuff
    float3 position = rd.vertexPosition;
    float2 texCoord = rd.textureCoordinate;
    float4 color = material.color;
    
    //Textures
    if(material.useBaseTexture){
        color = baseColorMap.sample(sampler2d, texCoord);
    }
    
    //Normals And Lighting
    float3 unitNormal;
    if(material.isLit){
        unitNormal = normalize(rd.surfaceNormal);
        if(material.useNormalMapTexture){
            
            float3 sampleNormal = normalMap.sample(sampler2d, texCoord).rgb * 2 - 1;
            float3x3 TBN = { rd.surfaceTangent, rd.surfaceBiTangent, rd.surfaceNormal};
            unitNormal = TBN*sampleNormal;
            
        }
        float3 unitToCameraVector = normalize(rd.toCameraVector);
        
        SceneLightData sceneLighting = Lighting::GetPhongIntensity(material,
                                                                   lightDatas,
                                                                   lightCount,
                                                                   rd.worldPosition,
                                                                   unitNormal,
                                                                   unitToCameraVector,
                                                                   position,
                                                                   cameraPosition,
                                                                   shadowTextures);
        
        
        color *= float4(sceneLighting.phongIntensity, 1.0);
    }
    
    out.color0 = half4(color.r, color.g, color.b, color.a);
    
    
    return out;
}
