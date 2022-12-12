//
//  Trees.swift
//  oliGame
//
//  Created by Oliver Crumrine on 12/3/22.
//

import MetalKit

class Trees: Node {
    init(treeACount: Int, treeBCount: Int, treeCCount: Int){
        super.init(name:"Trees")
        
        
        let treeAs = InstancedGameObject(name: "TreeA", meshType: .TreePineA, instanceCount: treeACount)
        treeAs.updateNodes(updateTreePosition)
        addChild(treeAs)
        let treeBs = InstancedGameObject(name: "TreeB", meshType: .TreePineB, instanceCount: treeBCount)
        treeBs.updateNodes(updateTreePosition)
        addChild(treeBs)
        let treeCs = InstancedGameObject(name: "TreeC", meshType: .TreePineC, instanceCount: treeCCount)
        treeCs.updateNodes(updateTreePosition)
        addChild(treeCs)
        
        
    }
    private func updateTreePosition(tree: Node, index: Int){
        let treeRadius: Float = Float.random(in: 8...70)
        let pos = float3(cos(Float(index)) * treeRadius,
                         0,
                         sin(Float(index)) * treeRadius)
        tree.setPosition(pos)
        tree.setScale(Float.random(in:1...2))
        tree.rotateY(Float.random(in: 0...360))
    }
}
