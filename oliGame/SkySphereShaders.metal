//
//  SkySphereShaders.metal
//  oliGame
//
//  Created by Oliver Crumrine on 12/3/22.
//
#pragma once
#include <metal_stdlib>
using namespace metal;
#include "Shared.metal"


vertex RasterizerData skysphere_vertex_shader(const VertexIn verticesIn [[stage_in]],
                                          constant SceneConstants &sceneConstants [[buffer(1)]],
                                          constant ModelConstants &modelConstants [[buffer(2)]]){
    RasterizerData rd;
    float4 worldPosition = modelConstants.modelMatrix * float4(verticesIn.position, 1);
    rd.position = sceneConstants.projectionMatrix * sceneConstants.skyViewMatrix * worldPosition;

    rd.textureCoordinate = verticesIn.textureCoordinate;

     
    
    return rd;
}

fragment half4 skysphere_fragment_shader(RasterizerData rd [[stage_in]],
                                     sampler sampler2d [[sampler(0)]],
                                     texture2d<float> baseColorMap [[texture(10)]]){
    
    float2 texCoord = rd.textureCoordinate;

    float4 color = baseColorMap.sample(sampler2d, texCoord, level(0));


    return half4(color.r, color.g, color.b, color.a);
}
