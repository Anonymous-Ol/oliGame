//
//  Flowers.swift
//  oliGame
//
//  Created by Oliver Crumrine on 12/3/22.
//

import MetalKit

class Flowers: Node {
    init(flowerRedCount: Int, flowerPurpleCount: Int, flowerYellowCount: Int){
        super.init(name:"Flowers")
        
        
        let flowerReds = InstancedGameObject(name: "FlowerReds", meshType: .flower_red, instanceCount: flowerRedCount)
        flowerReds.updateNodes(updateFlowerPosition)
        addChild(flowerReds)
        let flowerPurples = InstancedGameObject(name: "FlowerPurples", meshType: .flower_purple, instanceCount: flowerPurpleCount)
        flowerPurples.updateNodes(updateFlowerPosition)
        addChild(flowerPurples)
        let flowerYellows = InstancedGameObject(name: "FlowerYellows", meshType: .flower_yellow, instanceCount: flowerYellowCount)
        flowerYellows.updateNodes(updateFlowerPosition)
        addChild(flowerYellows)
        
        
    }
    private func updateFlowerPosition(flower: Node, index: Int){
        let flowerRadius: Float = Float.random(in: 0.9...70)
        let pos = float3(cos(Float(index)) * flowerRadius,
                         0,
                         sin(Float(index)) * flowerRadius)
        flower.setPosition(pos)
        flower.setScale(Float.random(in:0.55...1))
        flower.rotateY(Float.random(in: 0...360))
    }
}

