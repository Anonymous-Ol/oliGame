//
//  ReflectionSkySphereShaders.metal
//  oliGame
//
//  Created by Oliver Crumrine on 1/8/23.
//
#pragma once
#include <metal_stdlib>
#include "Shared.metal"
using namespace metal;


vertex ReflectionRasterizerData skysphere_cubemap_vertex_shader(const VertexIn verticesIn [[stage_in]],
                                                        constant SceneConstants *sceneConstants [[buffer(1)]],
                                                        constant ModelConstants &modelConstants [[buffer(2)]],
                                                        constant uint           &face           [[buffer(3)]]){
    ReflectionRasterizerData rd;
    float4 worldPosition = modelConstants.modelMatrix * float4(verticesIn.position, 1);
    rd.position = sceneConstants[face].projectionMatrix * sceneConstants[face].skyViewMatrix * worldPosition;

    rd.textureCoordinate = verticesIn.textureCoordinate;
    
    rd.face = face;
     
    
    return rd;
}

fragment half4 skysphere_cubemap_fragment_shader(ReflectionRasterizerData rd [[stage_in]],
                                     sampler sampler2d [[sampler(0)]],
                                     texture2d<float> baseColorMap [[texture(10)]]){
    
    float2 texCoord = rd.textureCoordinate;

    float4 color = baseColorMap.sample(sampler2d, texCoord, level(0));


    return half4(color.r, color.g, color.b, color.a);
}
