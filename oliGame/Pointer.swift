//
//  Player.swift
//  oliGame
//
//  Created by Oliver Crumrine on 11/26/22.
//

import MetalKit

class Pointer: GameObject{
    private var camera: Camera
    init(camera: Camera){
        self.camera = camera
        super.init(name: "Pointer", meshType: .Triangle_Custom)

    }
    override func doUpdate(){
        self.rotateZ(-atan2(Mouse.GetMouseViewportPosition().x - getPositionX() + camera.getPositionX(),                            Mouse.GetMouseViewportPosition().y - getPositionX() + camera.getPositionY()))
    }

}
