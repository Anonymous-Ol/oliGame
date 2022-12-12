//
//  Cruiser.swift
//  oliGame
//
//  Created by Oliver Crumrine on 11/27/22.
//

import MetalKit
 
class Cruiser: GameObject{
    init(){
        super.init(name: "Cruiser", meshType: .Cruiser)
        useBaseColorTexture(.Cruiser)
    }
}
