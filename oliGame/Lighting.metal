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
    static float shadowCompare(ShadowData sd)
    {
        float4 shadowNDC = (sd.shadowViewProjectionMatrix * float4(sd.worldPosition, 1));
        shadowNDC.xyz /= shadowNDC.w;
        float2 shadowCoords = shadowNDC.xy * 0.5 + 0.5;
        shadowCoords.y = 1 - shadowCoords.y;

        constexpr sampler shadowSampler(coord::normalized,
                                        address::clamp_to_edge,
                                        filter::linear,
                                        compare_func::greater_equal);
        float depthBias = 0.000115*tan(acos(sd.shadowNDotL));
        float shadowCoverage = 0;
        if(shadowCoords.x < 1 && shadowCoords.x > 0 && shadowCoords.y < 1 && shadowCoords.y > 0){
            shadowCoverage = sd.shadowMaps.sample_compare(shadowSampler, shadowCoords, sd.index, shadowNDC.z - depthBias) * 0.775;
        }
        return shadowCoverage;
    }
    static SceneLightData GetPhongIntensity(constant Material &material,
                                            constant LightData* lightDatas,
                                            int lightCount,
                                            float3 worldPosition,
                                            float3 unitNormal,
                                            float3 unitToCameraVector,
                                            float3 position,
                                            float3 cameraPosition,
                                            depth2d_array<float, access::sample> shadowTextures){
        float3 totalDiffuse  = float3(0,0,0);
        float3 totalAmbient  = float3(0,0,0);
        float3 totalSpecular = float3(0,0,0);
        float  shadowFactor  = float(1);
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
            
            //Shadows (Yes, they clutter up diffuse, but they need to be after N Dot L but before final diffuse calculations)
            float4x4 shadowViewMatrix = Lighting::calculate_lookAt_matrix(lightData.position, lightData.lookAtPosition, float3(0,1,0));
            float4x4 shadowProjectionMatrix = Lighting::ortho(-lightData.orthoSize,lightData.orthoSize,-lightData.orthoSize,lightData.orthoSize,lightData.near,lightData.far);
            float4x4 lightViewProjectMatrix = shadowProjectionMatrix * shadowViewMatrix;
            ShadowData sd;
            sd.renderShadows = true;
            sd.shadowMaps = shadowTextures;
            sd.index = i;
            sd.worldPosition = worldPosition;
            sd.shadowViewProjectionMatrix = lightViewProjectMatrix;
            sd.shadowNDotL = correctedNDotL;
            if(sd.renderShadows) shadowFactor = 1 - Lighting::shadowCompare(sd);
            
            //Final Diffuse
            float3 diffuseColor = clamp(shadowFactor * diffuseness * correctedNDotL * lightData.color * lightData.brightness, 0.0, 1.0);
            totalDiffuse += diffuseColor;
            
            if(nDotL <= 0 || shadowFactor > 0){
                totalAmbient += ambientColor;
            }
            
            //Specular
            //Blinn
            float3 lightDir   = normalize(lightData.position - position);
            float3 viewDir    = normalize(cameraPosition - position);
            float3 halfwayDir = normalize(lightDir + viewDir);
            float spec = pow(max(dot(unitNormal, halfwayDir), 0.0), material.shininess);
            
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
        Result[0][0] =   (2) / (right - left);
        Result[1][1] =   (2) / (top - bottom);
        Result[2][2] = - (2) / (zFar - zNear);
        Result[3][0] = - (right + left) / (right - left);
        Result[3][1] = - (top + bottom) / (top - bottom);
        Result[3][2] = - zNear          / (zNear - zFar);
        //Result[3][2] = - (zFar + zNear) / (zFar - zNear);
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
    static float2 Rotate(float2 input, float angle)
    {
        float deg2rad = (3.14159 * 2) / 360;
        float c = cos(angle * deg2rad);
        float s = sin(angle * deg2rad);
        return float2(
            input.x * c - input.y * s,
            input.x * s + input.y * c);
    }
     
    static uvReturn convert_xyz_to_cube_uv(float x, float y, float z)
    {
      uvReturn dataReturn;
      float absX = fabs(x);
      float absY = fabs(y);
      float absZ = fabs(z);
      
      int isXPositive = x > 0 ? 1 : 0;
      int isYPositive = y > 0 ? 1 : 0;
      int isZPositive = z > 0 ? 1 : 0;
      
      float maxAxis, uc, vc;
      bool rotateY180 = false;
      
      // POSITIVE X
      if (isXPositive && absX >= absY && absX >= absZ) {
        // u (0 to 1) goes from +z to -z
        // v (0 to 1) goes from -y to +y
        maxAxis = absX;
        uc = -z;
        vc = y;
        dataReturn.index = 0;
      }
      // NEGATIVE X
      if (!isXPositive && absX >= absY && absX >= absZ) {
        // u (0 to 1) goes from -z to +z
        // v (0 to 1) goes from -y to +y
        maxAxis = absX;
        uc = z;
        vc = y;
        dataReturn.index = 1;
      }
      // POSITIVE Y
      if (isYPositive && absY >= absX && absY >= absZ) {
        // u (0 to 1) goes from -x to +x
        // v (0 to 1) goes from +z to -z
        maxAxis = absY;
        uc = x;
        vc = -z;
          if(rotateY180){
              float2 uvCoords = Rotate(float2(uc, vc), 180);
              uc = uvCoords.x;
              vc = uvCoords.y;
          }
        dataReturn.index = 4;
      }
      // NEGATIVE Y
      if (!isYPositive && absY >= absX && absY >= absZ) {
        // u (0 to 1) goes from -x to +x
        // v (0 to 1) goes from -z to +z
        maxAxis = absY;
        uc = x;
        vc = z;
        dataReturn.index = 5;
      }
      // POSITIVE Z
      if (isZPositive && absZ >= absX && absZ >= absY) {
        // u (0 to 1) goes from -x to +x
        // v (0 to 1) goes from -y to +y
        maxAxis = absZ;
        uc = x;
        vc = y;
        dataReturn.index = 2;
      }
      // NEGATIVE Z
      if (!isZPositive && absZ >= absX && absZ >= absY) {
        // u (0 to 1) goes from +x to -x
        // v (0 to 1) goes from -y to +y
        maxAxis = absZ;
        uc = -x;
        vc = y;
        dataReturn.index = 3;
      }

      // Convert range from -1 to 1 to 0 to 1
      dataReturn.u = 0.5f * (uc / maxAxis + 1.0f);
      dataReturn.v = 0.5f * (vc / maxAxis + 1.0f);

      return dataReturn;
    }
};




