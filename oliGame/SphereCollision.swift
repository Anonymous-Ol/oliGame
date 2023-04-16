//
//  SphereCollision.swift
//  oliGame
//
//  Created by Oliver Crumrine on 4/10/23.
//

import simd
import MetalKit

class SphereCollision{
    private static var spheres: [SphereParameters] = []
    private static var objectOneVertices: [float3] = []
    private static var objectTwoVertices: [float3] = []
    private static var objectOneModelMatrix: matrix_float4x4 = matrix_identity_float4x4
    private static var obejctTwoModelMatrix: matrix_float4x4 = matrix_identity_float4x4
    static func addObjectOneVertices(vertices: [float3]){
        objectOneVertices.append(contentsOf: vertices)
    }
    static func addObjectTwoVertices(vertices: [float3]){
        objectTwoVertices.append(contentsOf: vertices)
    }
    static func clearAllVertices(){
        objectOneVertices = []
        objectTwoVertices = []
    }
    static func printAllVertices(){
        print(objectOneVertices)
        print("two")
        print(objectTwoVertices)
    }
    static func checkAllVertices(computeCommandEncoder: MTLComputeCommandEncoder){
        //To be implemented
    }
    static func addGameObject(object: SphereParameters){
        spheres.append(object)
    }
    static func clearList(){
        spheres = []
    }
    static func checkAllCollisions(){
        for x in spheres{
            for y in spheres{
                let dx = x.centerPosition.x - y.centerPosition.x
                let dy = x.centerPosition.y - y.centerPosition.y
                let dz = x.centerPosition.z - y.centerPosition.z
                let distance = sqrt(dx * dx + dy * dy + dz * dz)
                
                let colliding: Bool = distance < x.sphereRadius + y.sphereRadius
                if(x.pgo.getName() == "Character" && y.pgo.getName() == "Character" && (x.pgo.getID() != y.pgo.getID())){
                    print(dx)
                    print(dy)
                    print(dz)
                }
                if(colliding && (x.pgo.getID() != y.pgo.getID())){
                    print("x:")
                    print(x.pgo.getID())
                    print("y:")
                    print(y.pgo.getID())
                }
            }
        }
    }
}
struct SphereParameters{
    var centerPosition: float3
    var sphereRadius:   Float
    var pgo: GameObject
    
}
