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
        
        let skySphere = SkySphere(s:(Assets.Meshes[.SkySphere]?.gameObject.outline)!, skySphereTextureType: .Clouds)
        skySphere.setCullable(false)
        addChild(skySphere)
        
        let testSphere = Assets.Meshes[.SkySphere]?.gameObject
        testSphere?.setCullable(false)
        //addChild(testSphere!)
        
        
        firstPersonCamera.setPosition(0,1,0)
        
        firstPersonCamera.setRotationX(Float(10).toRadians)
        addCamera(firstPersonCamera)
        
        let terrain = Assets.Meshes[.GroundGrass]?.gameObject
        terrain!.setScale(300)
        terrain!.setCullable(false)

        addChild(terrain!)
        
//        let flowers = Flowers(flowerRedCount: 10, flowerPurpleCount: 10, flowerYellowCount: 10)
//        addChild(flowers)
        
        //let followTree = GameObject(name: "FollowTreee", meshType: .TreePineA)
        //addChild(followTree)
        func updateTreePosition(tree: Node, index: Int){
            let treeRadius: Float = Float.random(in: 8...90)
            let pos = float3(cos(Float(index)) * treeRadius,
                             0,
                             sin(Float(index)) * treeRadius)
            tree.setPosition(pos)
            tree.setScale(Float.random(in:1...1.5))
            tree.rotateY(Float.random(in: 0...360))
        }
        
        let trees = Assets.Meshes[.TreePineA]?.instancedGameObject
        trees?.postInit(instanceCount: 200)
        trees?.updateNodes(updateTreePosition)
        addChild(trees!)
        
//        let transparentCube = Assets.Meshes[.TransparentCube]?.gameObject
//        transparentCube?.setScale(15)
//        addChild(transparentCube!)
        
//        let cruiser = GameObject(name: "Space Cruiser", meshType: .Cruiser)
//        cruiser.setPositionX(5)
//        let chest = GameObject(name: "Chest", meshType: .Chest)
//        cruiser.setPositionZ(5)
//        chest.setScale(0.01)
//        let normalSphere = GameObject(name: "Normal Sphere", meshType: .RegSphere)
//        normalSphere.setPositionZ(-5)
//        normalSphere.setPositionY(1)
//
//        addChild(cruiser)
//        addChild(chest)
//        addChild(normalSphere)
//
//        let reflectiveSphere = Assets.Meshes[.Sphere]?.gameObject
//        reflectiveSphere?._material?.reflectivity = 1
//        reflectiveSphere?.setPositionY(1)
//        addChild(reflectiveSphere!)
//
//        let reflectiveSphere2 = GameObject(name:"Reflective Sphere 2", meshType: .Sphere)
//        reflectiveSphere2.setPositionY(7)
//        addChild(reflectiveSphere2)
//
//        let reflectiveSpheres = Sphere()
//        addChild(reflectiveSpheres)
//
//        let reflectiveSphereStatic = StaticSphere()
//        addChild(reflectiveSphereStatic)
        
        
        let char = Assets.Meshes[.BunnyCharacter]?.gameObject
        addChild(char!)
 

        



    }



}
