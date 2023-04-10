//
//  SphereCollision.swift
//  oliGame
//
//  Created by Oliver Crumrine on 4/10/23.
//

import Foundation

class SphereCollision{
    private static var spheres: [SphereParameters] = []
    static func addGameObject(object: SphereParameters){
        spheres.append(object)
    }
    static func clearList(){
        spheres = []
    }
    static func checkAllCollisions(){
        for x in spheres{
            for y in spheres{
                var dx = x.centerPosition.x - y.centerPosition.x
                var dy = x.centerPosition.y - y.centerPosition.y
                var dz = x.centerPosition.z - y.centerPosition.z
                var distance = sqrt(dx * dx + dy * dy)
                
                var colliding: Bool = distance < x.sphereRadius + y.sphereRadius
                if(colliding){
                    
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
