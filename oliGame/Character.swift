//
//  Character.swift
//  oliGame
//
//  Created by Oliver Crumrine on 4/10/23.
//

import Foundation
class Character: GameObject{
    var characterAABB: AABB!
    var motionEnabled = true
    init(){
        super.init(name:"Character")

        let character = TopLevelObjectLibrary.genGameObject(modelName: "Character")
        addChild(character)
        characterAABB = AABB(name: "aabbForCharacter", xLength: 2.5, zLength: 2.5, yLength: 4, origin: float3(-1.25,0.0,-1.25), parentGameObject: self)
        addChild(characterAABB)
        
        
    }
    override func update(deltaTime: Float) {
        if(!motionEnabled){
            AABBCollision.addMovingGameObject(object: characterAABB.AABBParams)
        }else{
            AABBCollision.addStaticGameObject(object: characterAABB.AABBParams)
        }
        if(motionEnabled){
            if(Keyboard.IsKeyPressed(.w)){
                self.moveZ(GameTime.DeltaTime * 5)
            }
            if(Keyboard.IsKeyPressed(.s)){
                self.moveZ(-GameTime.DeltaTime * 5)
            }
            if(Keyboard.IsKeyPressed(.a)){
                self.moveX(GameTime.DeltaTime * 5)
            }
            if(Keyboard.IsKeyPressed(.d)){
                self.moveX(-GameTime.DeltaTime * 5)
            }
        }
        
        super.update(deltaTime: deltaTime)
    }
}
