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

}
