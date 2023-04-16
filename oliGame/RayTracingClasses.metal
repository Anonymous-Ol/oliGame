//
//  RayTracingClasses.metal
//  oliGame
//
//  Created by Oliver Crumrine on 4/16/23.
//

#include <metal_stdlib>
using namespace metal;
#pragma once


class ray{
public:
    float3 origin;
    float3 direction;
    ray(const float3 orig, const float3 dir){
        origin = orig;
        direction = dir;
    }
    float3 rayAtPoint(float t){
        return origin + t*direction;
    }
};
