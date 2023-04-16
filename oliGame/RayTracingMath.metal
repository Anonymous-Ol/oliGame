//
//  RayTracingMath.metal
//  oliGame
//
//  Created by Oliver Crumrine on 4/16/23.
//

#include <metal_stdlib>
using namespace metal;


float3 unit_vector(float3 v){
    return v / length(v);
}
