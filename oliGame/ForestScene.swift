//
//  ForestScene.swift
//  oliGame
//
//  Created by Oliver Crumrine on 12/2/22.
//
import simd
class ForestScene: Scene{
    var debugCamera = DebugCamera()
    var sun1 = Sun()
    var sun2 = Sun()
    override func buildScene(){
        sun1.setPosition(float3(0,100,100))
        addLight(sun1)
        
        sun2.setPosition(float3(0,100,-100))
        sun2.setLightBrightness(0.5)
        addLight(sun2)
        
        let skySphere = SkySphere(skySphereTextureType: .Clouds)
        addChild(skySphere)
    
        debugCamera.setPosition(0,1,3)
        
        debugCamera.setRotationX(Float(10).toRadians)
        addCamera(debugCamera)
        
        let terrain = GameObject(name:"terrain", meshType: .GroundGrass)
        terrain.setScale(300)
        addChild(terrain)
        
        let flowers = Flowers(flowerRedCount: 10, flowerPurpleCount: 10, flowerYellowCount: 10)
        addChild(flowers)
    
        let trees = Trees(treeACount: 20, treeBCount: 20, treeCCount: 20)
        addChild(trees)
        



    }


}
