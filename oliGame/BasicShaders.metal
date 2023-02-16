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
};

vertex RasterizerData basic_vertex_shader(const VertexIn verticesIn [[stage_in]],
                                          constant SceneConstants &sceneConstants [[buffer(1)]],
                                          constant ModelConstants &modelConstants [[buffer(2)]]){
    
    RasterizerData rd;
    
    float4 worldPosition     = modelConstants.modelMatrix * float4(verticesIn.position, 1);
    
    float3 worldNormal       =           (modelConstants.modelMatrix * float4(verticesIn.normal.xyz, 0)).xyz ;
    float3 reflectionNormal = normalize(modelConstants.modelMatrix * float4(verticesIn.normal.xyz, 0)).xyz;
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


fragment FragOutput basic_fragment_shader(RasterizerData rd [[stage_in]],
                                          constant Material &material [[buffer(1)]],
                                          constant int &lightCount [[buffer(2)]],
                                          constant LightData *lightDatas [[buffer(3)]],
                                          constant float3 &cameraPosition [[buffer(4)]],
                                          constant uint &reflectionIndex [[buffer(5)]],
                                          constant bool &usePreRenderedReflections [[buffer(6)]],
                                          sampler sampler2d [[sampler(0)]],
                                          texture2d<float> baseColorMap [[texture(0)]],
                                          texture2d<float> normalMap [[texture(1)]],
                                          depth2d_array<float, access::sample> shadowTextures [[texture(2)]],
                                          texturecube_array<float> reflectionCubeMap [[texture(3)]],
                                          texturecube<float> cubeMap [[texture(4)]]
                                          ){
    FragOutput out;
    //Rasterizer Data Stuff
    float2 texCoord = rd.textureCoordinate;
    float4 color = material.color;
    
    //Textures
    if(material.useBaseTexture){
        color = baseColorMap.sample(sampler2d, texCoord);
    }
    if(material.reflectivity > 0 && reflectionIndex > 0 && !usePreRenderedReflections){
        float4 reflectionColor = reflectionCubeMap.sample(sampler2d, rd.reflectionVector, reflectionIndex - 1);
        float reflectionPrecentage = 1 - material.reflectivity;
        float bothR = reflectionColor.r * material.reflectivity + color.r * reflectionPrecentage;
        float bothG = reflectionColor.g * material.reflectivity + color.g * reflectionPrecentage;
        float bothB = reflectionColor.b * material.reflectivity + color.b * reflectionPrecentage;
        float bothA = reflectionColor.a * material.reflectivity + color.a * reflectionPrecentage;
        float4 averageColor = float4(bothR, bothG, bothB, bothA);
        color = averageColor;
    }else if(usePreRenderedReflections){
        float4 reflectionColor = cubeMap.sample(sampler2d, rd.reflectionVector);
        color = reflectionColor;
    }
    
    //Normals And Lighting
    float3 unitNormal;
    if(material.isLit){
        unitNormal = normalize(rd.surfaceNormal);
        if(material.useNormalMapTexture){
            
            float3 sampleNormal = normalMap.sample(sampler2d, texCoord).rgb * 2 - 1;
            float3x3 TBN = { normalize(rd.surfaceTangent), normalize(rd.surfaceBiTangent), normalize(rd.surfaceNormal)};
            unitNormal = TBN*sampleNormal;
            
        }
        float3 unitToCameraVector = normalize(rd.toCameraVector);
        
        SceneLightData sceneLighting = Lighting::GetPhongIntensity(material,
                                                                   lightDatas,
                                                                   lightCount,
                                                                   rd.worldPosition,
                                                                   unitNormal,
                                                                   unitToCameraVector,
                                                                   rd.worldPosition,
                                                                   cameraPosition,
                                                                   shadowTextures);
        
        
        color *= float4(sceneLighting.phongIntensity, 1.0);
    }
    
    out.color0 = half4(color.r, color.g, color.b, color.a);
    
    
    
    return out;
}






