//
//  AABB.swift
//  oliGame
//
//  Created by Oliver Crumrine on 4/12/23.
//
import simd
class AABB: GameObject{
    var minX: Float = Float(0)
    var maxX: Float = Float(0)
    var minY: Float = Float(0)
    var maxY: Float = Float(0)
    var minZ: Float = Float(0)
    var maxZ: Float = Float(0)
    var origin: float3 = float3(0,0,0)
    var xLength: Float = Float(0)
    var yLength: Float = Float(0)
    var zLength: Float = Float(0)
    var pgo: GameObject = GameObject(name: "pgo")
    var AABBParams: AABBParameters!
    init(name: String = "AABB", xLength: Float, zLength: Float, yLength: Float, origin: float3 = float3(0,0,0), parentGameObject: GameObject = GameObject(name: "pgo"), showBoxes: Bool = false){
        super.init(name: name)
        minX = origin.x
        minY = origin.y
        minZ = origin.z
        maxX = origin.x + xLength
        maxY = origin.y + yLength
        maxZ = origin.z + zLength
        self.origin = origin
        self.xLength = xLength
        self.yLength = yLength
        self.zLength = zLength
        if(parentGameObject.getName() != "pgo"){
            pgo = parentGameObject
        }else{
            pgo = self
        }
        AABBParams = AABBParameters(minX: minX, minY: minY, minZ: minZ, maxX: maxX, maxY: maxY, maxZ: maxZ, zLength: zLength, yLength: yLength, xLength: xLength, useInstanced: false, pgo: pgo)
        if(showBoxes){
            let cube1 = TopLevelObjectLibrary.genGameObject(modelName: "randomCube")
            cube1.setPosition(origin)
            cube1.setScale(0.15)
            addChild(cube1)
            let cube2 = TopLevelObjectLibrary.genGameObject(modelName: "randomCube")
            cube2.setPosition(origin)
            cube2.setScale(0.15)
            cube2.moveX(xLength)
            addChild(cube2)
            let cube3 = TopLevelObjectLibrary.genGameObject(modelName: "randomCube")
            cube3.setPosition(origin)
            cube3.setScale(0.15)
            cube3.moveZ(zLength)
            addChild(cube3)
            let cube4 = TopLevelObjectLibrary.genGameObject(modelName: "randomCube")
            cube4.setPosition(origin)
            cube4.setScale(0.15)
            cube4.moveZ(zLength)
            cube4.moveX(xLength)
            addChild(cube4)
            let cube5 = TopLevelObjectLibrary.genGameObject(modelName: "randomCube")
            cube5.setPosition(origin)
            cube5.moveY(yLength)
            cube5.setScale(0.15)
            addChild(cube5)
            let cube6 = TopLevelObjectLibrary.genGameObject(modelName: "randomCube")
            cube6.setPosition(origin)
            cube6.setScale(0.15)
            cube6.moveY(yLength)
            cube6.moveX(xLength)
            addChild(cube6)
            let cube7 = TopLevelObjectLibrary.genGameObject(modelName: "randomCube")
            cube7.setPosition(origin)
            cube7.setScale(0.15)
            cube7.moveY(yLength)
            cube7.moveZ(zLength)
            addChild(cube7)
            let cube8 = TopLevelObjectLibrary.genGameObject(modelName: "randomCube")
            cube8.setPosition(origin)
            cube8.setScale(0.15)
            cube8.moveZ(zLength)
            cube8.moveY(yLength)
            cube8.moveX(xLength)
            addChild(cube8)
        }
        
    }
    override func update(deltaTime: Float){
        let newOrigin = self.modelMatrix * float4(origin, 1)
        minX = newOrigin.x
        minY = newOrigin.y
        minZ = newOrigin.z
        maxX = newOrigin.x + xLength
        maxY = newOrigin.y + yLength
        maxZ = newOrigin.z + zLength
        AABBParams = AABBParameters(minX: minX, minY: minY, minZ: minZ, maxX: maxX, maxY: maxY, maxZ: maxZ, zLength: zLength, yLength: yLength, xLength: xLength, useInstanced: false, pgo: pgo)
        super.update(deltaTime: deltaTime)
    }
}

class AABBInstanced{
    var minX: Float = Float(0)
    var maxX: Float = Float(0)
    var minY: Float = Float(0)
    var maxY: Float = Float(0)
    var minZ: Float = Float(0)
    var maxZ: Float = Float(0)
    var origin: float3 = float3(0,0,0)
    var xLength: Float = Float(0)
    var yLength: Float = Float(0)
    var zLength: Float = Float(0)
    var pgo: jointNode = jointNode()
    var AABBParams: AABBParameters!
    init(name: String = "AABB", xLength: Float, zLength: Float, yLength: Float, origin: float3 = float3(0,0,0), parentGameObject: jointNode, showBoxes: Bool = false){
        minX = origin.x
        minY = origin.y
        minZ = origin.z
        maxX = origin.x + xLength
        maxY = origin.y + yLength
        maxZ = origin.z + zLength
        self.origin = origin
        self.xLength = xLength
        self.yLength = yLength
        self.zLength = zLength
        pgo = parentGameObject
        AABBParams = AABBParameters(minX: minX, minY: minY, minZ: minZ, maxX: maxX, maxY: maxY, maxZ: maxZ, zLength: zLength, yLength: yLength, xLength: xLength, useInstanced: true, pgoInstanced: pgo)
    }
    func update(){
        let newOrigin = pgo.worldTransform * float4(origin, 1)
        minX = newOrigin.x
        minY = newOrigin.y
        minZ = newOrigin.z
        maxX = newOrigin.x + xLength
        maxY = newOrigin.y + yLength
        maxZ = newOrigin.z + zLength
        AABBParams = AABBParameters(minX: minX, minY: minY, minZ: minZ, maxX: maxX, maxY: maxY, maxZ: maxZ, zLength: zLength, yLength: yLength, xLength: xLength, useInstanced: true, pgoInstanced: pgo)
    }
}

struct AABBParameters{
    var minX: Float
    var minY: Float
    var minZ: Float
    var maxX: Float
    var maxY: Float
    var maxZ: Float
    var zLength: Float
    var yLength: Float
    var xLength: Float
    var useInstanced: Bool
    var pgo:  GameObject!
    var pgoInstanced: jointNode!
}
