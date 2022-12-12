//
//  Cube.swift
//  oliGame
//
//  Created by Oliver Crumrine on 11/26/22.
//

import MetalKit

class Cube: GameObject{
    init(){
        super.init(name: "Cube", meshType: .Cube_Custom)
    }
    override func doUpdate(){
        self.rotateX(GameTime.DeltaTime)
        self.rotateY(GameTime.DeltaTime)
    }
}

