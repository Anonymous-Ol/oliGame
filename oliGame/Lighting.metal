//
//  Lighting.metal
//  oliGame
//
//  Created by Oliver Crumrine on 11/29/22.
//

#pragma once
#include <metal_stdlib>
#include "Shared.metal"
using namespace metal;

class Lighting {
public:
    static float shadow(float3 worldPosition,
                        depth2d<float, access::sample> depthMap,
                        const float4x4 viewProjectionMatrix)
    {
        float4x4 newViewProjectionMatrix = {
            0.028571427, 0.0, 0.0, 0.0,
            0.0, 0.020203048, -0.00070717745, 0.0,
            0.0, -0.020203048, -0.00070717745, 0.0,
            0.0, 0.0, 0.14133547, 1.0
        };
        float4 shadowNDC = (viewProjectionMatrix * float4(worldPosition, 1));
        shadowNDC.xyz /= shadowNDC.w;
        float3 shadowCoords = shadowNDC.xyz * 0.5 + 0.5;
        shadowCoords.y = 1 - shadowCoords.y;

        constexpr sampler shadowSampler(coord::normalized,
                                        address::clamp_to_edge,
                                        filter::linear,
                                        compare_func::greater_equal);
        float bias = 0.0001;
        if(depthMap.sample(shadowSampler, shadowCoords.xy )  <  shadowCoords.z - bias){
            return 1;
        }else{
            return 0.5;
        }
    
    }

    static SceneLightData GetPhongIntensity(constant Material &material,
                                    constant LightData* lightDatas,
                                    int lightCount,
                                    float3 worldPosition,
                                    float3 unitNormal,
                                    float3 unitToCameraVector,
                                    float3 position,
                                    float3 cameraPosition,
                                    float shadowFactor){
        float3 totalDiffuse  = float3(0,0,0);
        float3 totalAmbient  = float3(0,0,0);
        float3 totalSpecular = float3(0,0,0);
        for(int i = 0; i < lightCount; i++){
            LightData lightData = lightDatas[i];
            
            float3 unitToLightVector = normalize(lightData.position - worldPosition);
            float3 unitReflectionVector = normalize(reflect(-unitToLightVector, unitNormal));
            
            //Ambient
            float3 ambientness = material.ambient * lightData.ambientIntensity;
            float3 ambientColor = clamp(ambientness * lightData.color * lightData.brightness, 0.0, 1.0);
            
            
            //Diffuse
            
            float3 diffuseness= material.diffuse * lightData.diffuseIntensity;
            float nDotL = max(dot(unitNormal, unitToLightVector), 0.0);
            float correctedNDotL = max(nDotL, 0.3);
            float3 diffuseColor = clamp(shadowFactor * diffuseness * correctedNDotL * lightData.color * lightData.brightness, 0.0, 1.0);
            totalDiffuse += diffuseColor;
            
            if(nDotL <= 0){
                totalAmbient += ambientColor;
            }
            
            //Specular
            //Blinn
            float3 lightDir   = normalize(lightData.position - position);
            float3 viewDir    = normalize(cameraPosition - position);
            float3 halfwayDir = normalize(lightDir + viewDir);
            float spec = pow(max(dot(unitNormal, halfwayDir), 0.0), material.shininess);
            
            //R Dot V
            //float  rDotV = max(dot(unitReflectionVector, unitToCameraVector),0.0);
            //float  specularExp  = pow(rDotV, material.shininess);
            //Specular Color Calculation
            float3 specularness = material.specular * lightData.specularIntensity;
            float3 specularColor = clamp(shadowFactor * specularness * spec * lightData.color * lightData.brightness, 0.0, 1.0);
            totalSpecular += specularColor;
            
        }
        float3 phongIntensity = totalAmbient + totalDiffuse + totalSpecular;
        SceneLightData sceneLightData;
        sceneLightData.phongIntensity = phongIntensity;
        return sceneLightData;
        
    }
    static float4x4 calculate_lookAt_matrix(float3 position, float3 target, float3 worldUp)
    {
        // 1. Position = known
        // 2. Calculate cameraDirection
        float3 zaxis = normalize(position - target);
        // 3. Get positive right axis vector
        float3 xaxis = normalize(cross(normalize(worldUp), zaxis));
        // 4. Calculate camera up vector
        float3 yaxis = cross(zaxis, xaxis);

        // Create translation and rotation matrix
        // In glm we access elements as mat[col][row] due to column-major layout
        float4x4 translation = float4x4(1); // Identity matrix by default
        translation[3][0] = -position.x; // Third column, first row
        translation[3][1] = -position.y;
        translation[3][2] = -position.z;
        float4x4 rotation = float4x4(1);
        rotation[0][0] = xaxis.x; // First column, first row
        rotation[1][0] = xaxis.y;
        rotation[2][0] = xaxis.z;
        rotation[0][1] = yaxis.x; // First column, second row
        rotation[1][1] = yaxis.y;
        rotation[2][1] = yaxis.z;
        rotation[0][2] = zaxis.x; // First column, third row
        rotation[1][2] = zaxis.y;
        rotation[2][2] = zaxis.z;

        // Return lookAt matrix as combination of translation and rotation matrix
        return rotation * translation; // Remember to read from right to left (first translation then rotation)
    }

    static float4x4 ortho(
        float left,
        float right,
        float bottom,
        float top,
        float zNear,
        float zFar
    )
    {
        float4x4 Result = float4x4(1);
        Result[0][0] = (2) / (right - left);
        Result[1][1] = (2) / (top - bottom);
        Result[2][2] = - (2) / (zFar - zNear);
        Result[3][0] = - (right + left) / (right - left);
        Result[3][1] = - (top + bottom) / (top - bottom);
        Result[3][2] = - (zFar + zNear) / (zFar - zNear);
        return Result;
    }
    static float4x4 my_PerspectiveFOV(float fov, float aspect, float near, float far) {
        float D2R = 3.14159 / 180.0;
        float yScale = 1.0 / tan(D2R * fov / 2);
        float xScale = yScale / aspect;
        float nearmfar = near - far;
        float4x4 m = {
            xScale, 0, 0, 0,
            0, yScale, 0, 0,
            0, 0, (far + near) / nearmfar, -1,
            0, 0, 2*far*near / nearmfar, 0
        };
        return m;
    }
};




