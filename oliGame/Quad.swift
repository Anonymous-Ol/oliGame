//
//  Quad.swift
//  oliGame
//
//  Created by Oliver Crumrine on 11/27/22.
//

import simd

class Quad: GameObject {
    init(){
        super.init(name:"Quad", meshType: .Quad)
        useBaseColorTexture(.BaseColorRender_0)
    }
}
