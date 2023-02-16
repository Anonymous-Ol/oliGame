//
//  StaticSphere.swift
//  oliGame
//
//  Created by Oliver Crumrine on 2/13/23.
//

import Foundation

class StaticSphere: GameObject {
    init(){
        super.init(name:"Sphere", meshType: .RegSphere)
        self.cubeMapTexture = CubeMapLoader.loadCubeMap("cubeMapVertical", "png")
        setScale(1)
        setPositionY(1)
        usePredeterminedCubeMap(true)
        
    }
}
