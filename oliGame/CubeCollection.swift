//
//  CubeCollection.swift
//  oliGame
//
//  Created by Oliver Crumrine on 11/27/22.
//

import MetalKit

class CubeCollection: InstancedGameObject {
    var cubesWide: Int = 0
    var cubesHigh: Int = 0
    var cubesBack: Int = 0
    
    init(name: String, cubesWide: Int, cubesHigh: Int, cubesBack: Int){
        super.init(name: name, meshType: .Cube_Custom, instanceCount: cubesWide * cubesHigh * cubesBack)
        self.cubesWide = cubesWide
        self.cubesHigh = cubesHigh
        self.cubesBack = cubesBack
        self.setName("Cube Collection")
        setColor(ColorUtils.randomColor)
    }
    var time: Float = 0.0
    override func doUpdate(){
        
        let halfWide: Float = Float(cubesWide / 2)
        let halfHigh: Float = Float(cubesHigh / 2)
        let halfBack: Float = Float(cubesBack / 2)
        
        var index: Int = 0
        let gap:Float = cos(GameTime.TotalGameTime / 2) * 10
        
        for y in stride(from: -halfHigh, to: halfHigh, by: 1.0){
            let posY = Float(y * gap)
            for x in stride(from: -halfWide, to: halfWide, by: 1.0){
                let posX = Float(x * gap)
                for z in stride(from: -halfBack, to: halfBack, by: 1.0){
                    let posZ = Float(z * gap)
                    _nodes[index].setPositionY(posY)
                    _nodes[index].setPositionX(posX)
                    _nodes[index].rotate(0, -GameTime.DeltaTime*2, -GameTime.DeltaTime*2)
                    _nodes[index].setScale(0.3)
                    index += 1
                }
            }
        }
        
    }
    
}
