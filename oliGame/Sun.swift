//
//  Sun.swift
//  oliGame
//
//  Created by Oliver Crumrine on 11/27/22.
//

import simd

class Sun: LightObject{
    var sunMaterial: Material = Material()
    init(){
        super.init(name: "Sun", meshType: .None)
        self.setScale(25)
        sunMaterial.color = float4(0.5,0.5,0,1.0)
        
        //Shadow Projection Stuff
        self.lightData.near = 0.1
        self.lightData.lookAtPosition = float3(0,0,0)
        self.lightData.far = 1000
        self.lightData.orthoSize = 35
        self.setLightAmbientIntensity(0.015)
        
        
        self.useMaterial(sunMaterial)
        self.setScale(0.3)
    }
}
