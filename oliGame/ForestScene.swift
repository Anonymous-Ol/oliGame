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
        terrain.setScale(200)
        addChild(terrain)
        
        let flowers = Flowers(flowerRedCount: 2000, flowerPurpleCount: 2000, flowerYellowCount: 2000)
        addChild(flowers)
        
        let trees = Trees(treeACount: 1000, treeBCount: 1000, treeCCount: 1000)
        addChild(trees)
        



    }


}
