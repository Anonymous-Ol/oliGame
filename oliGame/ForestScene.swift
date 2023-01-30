//
//  ForestScene.swift
//  oliGame
//
//  Created by Oliver Crumrine on 12/2/22.
//
import simd
class ForestScene: Scene{
    var firstPersonCamera = FirstPersonCamera()
    var sun1 = Sun()
    var sun2 = Sun()
    var followTree = GameObject(name: "followTree", meshType: .TreePineA)
    override func buildScene(){
        sun1.setPosition(float3(0,100,100))
        addLight(sun1)
        
        sun2.setPosition(float3(0,100,-100))
        sun2.setLightBrightness(0.5)
        addLight(sun2)
        
        let skySphere = SkySphere(skySphereTextureType: .Clouds)
        skySphere.cullable = false
        addChild(skySphere)
    
        firstPersonCamera.setPosition(0,1,0)
        
        firstPersonCamera.setRotationX(Float(10).toRadians)
        addCamera(firstPersonCamera)
        
        let terrain = GameObject(name:"terrain", meshType: .GroundGrass)
        terrain.setScale(300)
        terrain.cullable = false
        addChild(terrain)
        
        
        let flowers = Flowers(flowerRedCount: 10, flowerPurpleCount: 10, flowerYellowCount: 10)
        addChild(flowers)
        
        //let followTree = GameObject(name: "FollowTreee", meshType: .TreePineA)
        //addChild(followTree)
    
        let trees = Trees(treeACount: 200, treeBCount: 200, treeCCount: 200)
        addChild(trees)
        
        let reflectiveSphere = GameObject(name:"Reflective Sphere", meshType: .Sphere)
        reflectiveSphere.setPositionY(1)
        reflectiveSphere.setScale(0.5)
        addChild(reflectiveSphere)
        



    }



}
