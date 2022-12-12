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
        sunMaterial.color = float4(0.5,0.5,0,1.0)
        self.useMaterial(sunMaterial)
        self.setScale(0.3)
    }
}
