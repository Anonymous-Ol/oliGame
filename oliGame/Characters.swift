//
//  File.swift
//  oliGame
//
//  Created by Oliver Crumrine on 3/18/23.
//

import MetalKit

class Characters: Node {
    init(count: Int){
        super.init(name:"Characters")
        
        
        let flowerReds = TopLevelObjectLibrary.genIGOWithSkeleton(modelName: "Character", instanceCount: 5)
        flowerReds.setName("Characters")
        flowerReds.setTopLevelObjects()
        flowerReds.updateNodes(updateFlowerPosition)
        flowerReds.continualUpdateNodes(updateCharacterPositionContinuous, time:10)
        addChild(flowerReds)
        
        
    }
    private func updateFlowerPosition(flower: jointNode, index: Int){
        if(flower.topLevelObject){
            flower.setPositionX(Float.random(in: -20...20))
            flower.setScale(Float.random(in:0.55...1))
            //flower.rotateY(Float.random(in: 0...360))
        }
    }
    private func updateCharacterPositionContinuous(flower: jointNode, index: Int){
        if(flower.topLevelObject){
            flower.setPositionX(Float.random(in: -35...35))
        }
    }

}
