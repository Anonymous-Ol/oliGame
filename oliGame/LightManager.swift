//
//  LightManager.swift
//  oliGame
//
//  Created by Oliver Crumrine on 11/27/22.
//

import MetalKit

class LightManager{
    private var _lightObjects: [LightObject] = []
    
    func addLightObject(_ lightObject: LightObject){
        self._lightObjects.append(lightObject)
    }
    private func gatherLightData()->[LightData]{
        var result: [LightData] = []
        for lightObject in _lightObjects {
            result.append(lightObject.lightData)
        }
        return result
    }
    func setLightData(_ renderCommandEncoder: MTLRenderCommandEncoder){
        var lightDatas = gatherLightData()
        var lightCount = lightDatas.count
        renderCommandEncoder.setFragmentBytes(&lightCount,
                                              length: Int32.size,
                                              index: 2)
        renderCommandEncoder.setFragmentBytes(&lightDatas,
                                              length: LightData.stride(lightDatas.count),
                                              index: 3)
    }
    func setShadowLightData(_ renderCommandEncoder: MTLRenderCommandEncoder){
        var lightDatas = gatherLightData()
        var lightCount = lightDatas.count
        renderCommandEncoder.setVertexBytes(&lightDatas, length: LightData.stride(lightDatas.count), index: 2)
        renderCommandEncoder.setVertexBytes(&lightCount, length: Int32.size, index: 3)
    }
    static func calculate_lookAt_matrix(position: float3, target: float3, worldUp: float3) -> float4x4
    {
        // 1. Position = known
        // 2. Calculate cameraDirection
        var zaxis: float3 = normalize(position - target);
        // 3. Get positive right axis vector
        var xaxis: float3 = normalize(cross(normalize(worldUp), zaxis));
        // 4. Calculate camera up vector
        var yaxis: float3 = cross(zaxis, xaxis);

        // Create translation and rotation matrix
        // In glm we access elements as mat[col][row] due to column-major layout
        var translation: float4x4 = matrix_identity_float4x4; // Identity matrix by default
        translation[3][0] = -position.x; // Third column, first row
        translation[3][1] = -position.y;
        translation[3][2] = -position.z;
        var rotation: float4x4 = matrix_identity_float4x4;
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

}
