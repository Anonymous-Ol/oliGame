//
//  RayTracingComputeShaders.metal
//  oliGame
//
//  Created by Oliver Crumrine on 4/16/23.
//

#include <metal_stdlib>
#include "RayTracingClasses.metal"
#include "RayTracingMath.metal"
using namespace metal;

float3 ray_color(ray r){
    float3 unit_dir = unit_vector(r.direction);
    float  t = 0.5*(unit_dir.y + 1);
    return (1-t)*float3(1.0,1.0,1.0) + t*float3(0.5, 0.7, 1.0);
}

kernel void raytrace(uint2 pixel [[thread_position_in_grid]]){
    //Image
    float aspectRatio = 16/9;
    int imageWidth  = 2560;
    int imageHeight = imageWidth/aspectRatio;
    
    //Camera
    float cameraHeight = 2;
    float cameraWidth = aspectRatio * cameraHeight;
    float focalLength = 1.0;
    
    float3 origin     = float3(0,0,0);
    float3 horizontal = float3(cameraWidth, 0, 0);
    float3 vertical   = float3(0, cameraHeight,0);
    auto   lowerLeft  = origin - horizontal/2 - vertical/2 - float3(0,0, focalLength);
    
    
    
}



