//
//  Spheres.swift
//  oliGame
//
//  Created by Oliver Crumrine on 2/10/23.
//

import MetalKit

class Sphere: Node {
    init(){
        super.init(name:"Spheres")
        
        
        let flowerReds = InstancedGameObject(name: "FlowerReds", meshType: .Sphere, instanceCount: 2)
        flowerReds.setReflectionPosition(float3(0,1,0))
        flowerReds.updateNodes(updateFlowerPosition)
        addChild(flowerReds)
        
        
    }
    private func updateFlowerPosition(flower: jointNode, index: Int){
        flower.setPosition(float3(0, Float(index * 3), 0))
    }
}
