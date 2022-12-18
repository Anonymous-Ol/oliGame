//
//  LightObject.swift
//  oliGame
//
//  Created by Oliver Crumrine on 11/27/22.
//

import MetalKit
class LightObject: GameObject{
    
    var lightData = LightData()
    
    init(name: String){
        super.init(name:"name", meshType: .None)
    }
    override init(name:String, meshType: MeshTypes){
        super.init(name: name, meshType: meshType)
        self.setName(name)
    }
    override func update(deltaTime: Float){
        self.lightData.position = self.getPosition()
        self.lightData.projectionViewMatrix = simd_float4x4(orthographicProjectionWithLeft: -35,
                                                               top: 35,
                                                               right: 35,
                                                               bottom: -35,
                                                               near: 0.1,
                                                               far: 1000) * LightManager.calculate_lookAt_matrix(position: float3(0,100,100), target: float3(0,0,0), worldUp: float3(0,1,0))
        print("Combined Matrices: ")
        print(self.lightData.projectionViewMatrix)
        print("Projection Matrix: ")
        print(simd_float4x4(orthographicProjectionWithLeft: -35,
                            top: 35,
                            right: 35,
                            bottom: -35,
                            near: 0.1,
                            far: 1000))
        print("View Matrix: ")
        print(LightManager.calculate_lookAt_matrix(position: float3(0,100,100), target: float3(0,0,0), worldUp: float3(0,1,0)))
        super.update(deltaTime: deltaTime)

    }
    override func render(renderCommandEncoder: MTLRenderCommandEncoder){
        super.render(renderCommandEncoder:  renderCommandEncoder)
    }
    override func shadowRender(renderCommandEncoder: MTLRenderCommandEncoder){
        super.shadowRender(renderCommandEncoder: renderCommandEncoder)
    }
}
extension LightObject{
    
    public func setLightColor(_ color: float3) {self.lightData.color = color}
    public func setLightColor(_ r: Float,_ g: Float,_ b: Float) {setLightColor(float3(r,g,b))}
    public func getLightColor()->float3 { return self.lightData.color }
    
    public func setLightBrightness(_ brightness: Float) {self.lightData.brightness = brightness}
    public func getLightBrightness()->Float{ return self.lightData.brightness }
    
    
    public func setLightAmbientIntensity(_ intensity: Float) {self.lightData.ambientInensity = intensity}
    public func getLightAmbientIntensity()->Float { return self.lightData.ambientInensity}
    
    public func setLightDiffuseIntensity(_ intensity: Float) {self.lightData.diffuseIntensity = intensity}
    public func getLightDiffuseIntensity()->Float { return self.lightData.diffuseIntensity}
    
    public func setLightSpecularIntensity(_ intensity: Float) {self.lightData.specularIntensity = intensity}
    public func getLightSpecularIntensity()->Float { return self.lightData.specularIntensity}
}
