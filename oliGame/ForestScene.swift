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
        
        let skySphere = SkySphere(s:TopLevelObjectLibrary.genGameObject(modelName: "skysphere").outline, skySphereTextureType: .Clouds)
        skySphere.setCullable(false)
        addChild(skySphere)
    
        
        
        firstPersonCamera.setPosition(0,1,0)
        
        firstPersonCamera.setRotationX(Float(10).toRadians)
        addCamera(firstPersonCamera)
        
        let terrain = Assets.Meshes[.GroundGrass]?.gameObject
        terrain!.setScale(300)
        terrain!.setCullable(false)

        addChild(terrain!)
        
        func updateTreePosition(tree: jointNode, index: Int){
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
        
        let reflectiveSphere = Assets.Meshes[.Sphere]?.gameObject
        reflectiveSphere?._material?.reflectivity = 1
        reflectiveSphere?.setPositionY(1)
        reflectiveSphere?.setPositionZ(5)
        //addChild(reflectiveSphere!)
    

        let char =  Character()
        char.moveX(6)
        char.printMD = true
        addChild(char)
//        let char2 = Character()
//        char2.motionEnabled = false
//        addChild(char2)
        
        //let aabbForCharacter = AABB(name: "aabbForCharacter", xLength: 2.5, zLength: 2.5, yLength: 4, origin: float3(-1.25,0.0,-1.25))
        //addChild(aabbForCharacter)
        
        //let char2 = TopLevelObjectLibrary.genGameObject(modelName: "Character")
        //addChild(char2)
        //char2.moveZ(4.5)

        let (animation, _) = AnimationsLibrary.animations.first!

        //char.childNode(named: "Skeleton")?.runAnimation(animation)

        
        let charInstanced = Characters(count: 5)
        addChild(charInstanced)
        
        for (x, skeletonNode) in (charInstanced.childNode(named: "Skeleton") as? InstancedGameObject)?._nodes.enumerated() ?? [].enumerated(){
            if((x % 2) != 0){

                skeletonNode.runAnimation(AnimationsLibrary.animations.first!.0)
            }
        }

 

        



    }



}
