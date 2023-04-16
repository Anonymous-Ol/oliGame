//
//  AABBCollision.swift
//  oliGame
//
//  Created by Oliver Crumrine on 4/15/23.
//
import simd

class AABBCollision{
    private static var staticAABBs: [AABBParameters] = []
    private static var movingAABBs: [AABBParameters] = []
    static func addStaticGameObject(object: AABBParameters){
        staticAABBs.append(object)
    }
    static func addMovingGameObject(object: AABBParameters){
        movingAABBs.append(object)
    }
    static func clearList(){
        staticAABBs = []
        movingAABBs = []
    }
    static func checkAllCollisions(){
        for x in staticAABBs{
            if(x.pgoInstanced != nil){
                print(x.pgoInstanced.id)
            }
            for y in movingAABBs{
                
                let colliding: Bool = intersect(a: x, b: y)
                if(colliding){
                    let (direction, magnitude) = compareAABBCenterPoint(a: x, b: y)
                    print(GameTime.TotalGameTime)
                    if(direction == "X"){
                        if(!y.useInstanced){
                            y.pgo.moveX(magnitude)
                        }else{
                            y.pgoInstanced.moveX(magnitude)
                        }
                    }else if(direction == "Y"){
                        if(!y.useInstanced){
                            y.pgo.moveY(magnitude)
                        }else{
                            y.pgoInstanced.moveY(magnitude)
                        }
                    }else if(direction == "Z"){
                        if(!y.useInstanced){
                            y.pgo.moveZ(magnitude)
                        }else{
                            y.pgoInstanced.moveZ(magnitude)
                        }
                    }
                }
            }
        }
    }
    static func compareAABBCenterPoint(a: AABBParameters, b: AABBParameters) -> (String, Float){
        let aX = (a.minX + a.maxX)/2
        let aY = (a.minY + a.maxY)/2
        let aZ = (a.minZ + a.maxZ)/2
        let bX = (b.minX + b.maxX)/2
        let bY = (b.minY + b.maxY)/2
        let bZ = (b.minZ + b.maxZ)/2
        let diffX = aX - bX
        let diffY = aY - bY
        let diffZ = aZ - bZ
        let xLen = (a.xLength+b.xLength)/2
        let yLen = (a.yLength+b.yLength)/2
        let zLen = (a.zLength+b.zLength)/2
        if (abs(diffX) >= abs(diffY) && abs(diffX) >= abs(diffZ)){
            if(abs(diffX-xLen) < abs(diffX+xLen)){
                //print(diffX-2.5)
                return("X", (diffX-xLen))
            }else{
                //print(diffX+2.5)
                return("X", (diffX+xLen))
            }
        }

        if (abs(diffY) >= abs(diffX) && abs(diffY) >= abs(diffZ)){
            if(abs(diffY-yLen) < abs(diffY+yLen)){
                //print(diffY-2.5)
                return("Y", (diffZ-yLen))
            }else{
                //print(diffY+2.5)
                return("Y", (diffY+yLen))
            }
        }

        if (abs(diffZ) >= abs(diffX) && abs(diffZ) >= abs(diffY)){
            if(abs(diffZ-zLen) < abs(diffZ+zLen)){
                //print(diffZ-2.5)
                return("Z", (diffZ-zLen))
            }else{
                //print(diffZ+2.5)
                return("Z", (diffZ+zLen))
            }
            
        }
        return("X", 0)
    }
    static func intersect(a: AABBParameters, b: AABBParameters) -> Bool{
        var collisionIsHappening: Bool = false
        collisionIsHappening = (
            a.minX <= b.maxX &&
            a.maxX >= b.minX &&
            a.minY <= b.maxY &&
            a.maxY >= b.minY &&
            a.minZ <= b.maxZ &&
            a.maxZ >= b.minZ
        )
        return collisionIsHappening
    }
}
