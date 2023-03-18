//
//  Shared.metal
//  oliGame
//
//  Created by Oliver Crumrine on 11/27/22.
//
#pragma once
#include <metal_stdlib>
using namespace metal;


struct VertexIn{
    float3 position [[attribute(0)]];
    float4 color    [[attribute(1)]];
    float2 textureCoordinate [[attribute(2)]];
    float3 normal   [[attribute(3)]];
    float3 tangent [[attribute(4)]];
    float3 bitangent [[attribute(5)]];
    ushort4 jointIndices [[attribute(6)]];
    float4 jointWeights [[attribute(7)]];
};

struct RasterizerData{
    float4 position  [[position]];
    float4 color;
    float2 textureCoordinate;
    float3 vertexPosition;
    float totalGameTime;
    
    float3 worldPosition;
    float3 surfaceNormal;
    float3 toCameraVector;
    
    float3 surfaceTangent;
    float3 surfaceBiTangent;
    
    float3 reflectionVector;
    
};

struct ReflectionRasterizerData{
    float4 position  [[position]];
    float4 color;
    float2 textureCoordinate;
    float3 vertexPosition;
    float totalGameTime;
    
    float3 worldPosition;
    float3 surfaceNormal;
    float3 toCameraVector;
    
    float3 surfaceTangent;
    float3 surfaceBiTangent;
    
    uint   face [[render_target_array_index]];
};


struct ModelConstants{
    float4x4 modelMatrix;
};
struct SceneConstants{
    float totalGameTime;
    float4x4 viewMatrix;
    float4x4 skyViewMatrix;
    float4x4 projectionMatrix;
    float3 cameraPosition;
    float3 lookAtPosition;
};
struct Material{
    float4 color;
    bool isLit;
    bool useBaseTexture;
    bool useNormalMapTexture;
    
    float3 ambient;
    float3 diffuse;
    float3 specular;
    float shininess;
    
    float reflectivity;
};
struct LightData{
    float3 position;
    float3 color;

    float brightness;
    float ambientIntensity;
    float diffuseIntensity;
    float specularIntensity;
   
    float3 lookAtPosition;
    float orthoSize;
    float near;
    float far;
};
struct SceneLightData{
    float3 phongIntensity;
};
struct ShadowData{
    depth2d_array<float, access::sample> shadowMaps;
    bool     renderShadows = true;
    float3   worldPosition;
    float4x4 shadowViewProjectionMatrix;
    float    shadowNDotL = 0;
    int      index;
    
};
struct uvReturn {
    int index;
    float u;
    float v;
};

///Note: UNUSED
struct ShadowTextureArgumentBuffer{
    depth2d<float, access::sample> texture [[id(1)]];
};

struct ShadowRasterizerData{
    float4 position  [[position]];
    uint   face      [[render_target_array_index]];
};
