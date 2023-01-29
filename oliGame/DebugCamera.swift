//
//  DebugCamera.swift
//  oliGame
//
//  Created by Oliver Crumrine on 11/26/22.
//
import simd

class DebugCamera: Camera{
    private var _zoom: Float = 45.0
    private var _projectionMatrix = matrix_identity_float4x4
    override var projectionMatrix: matrix_float4x4{
        return _projectionMatrix
    }
    
    init(){
        super.init(name: "Debug", cameraType: .debugCamera)
        _projectionMatrix = matrix_float4x4.perspective(degreesFov: 45.0, aspectRation: Renderer.AspectRation, near: 0.1, far: 1000)
    }
    private var _moveSpeed: Float = 4.0
    private var _turnSpeed: Float = 1.0
     
    override func doUpdate(){
        if(Mouse.IsMouseButtonPressed(button: .RIGHT)){
            self.rotateY(Mouse.GetDX() * GameTime.DeltaTime * _turnSpeed)
            self.rotateX(Mouse.GetDY() * GameTime.DeltaTime * _turnSpeed)

        }
        if(Mouse.IsMouseButtonPressed(button: .CENTER)){
            self.moveX(-Mouse.GetDX() * GameTime.DeltaTime * _moveSpeed)
            self.moveY( Mouse.GetDY() * GameTime.DeltaTime * _moveSpeed)

        }
        if(Keyboard.IsKeyPressed(.rightArrow)){
            self.moveX(GameTime.DeltaTime * _moveSpeed)
            
        }
        if(Keyboard.IsKeyPressed(.leftArrow)){
            self.moveX(-GameTime.DeltaTime * _moveSpeed)
        }
        if(Keyboard.IsKeyPressed(.w)){
            self.moveZ(GameTime.DeltaTime * _moveSpeed)
        }
        if(Keyboard.IsKeyPressed(.s)){
            self.moveZ(-GameTime.DeltaTime * _moveSpeed)
        }
        if(Keyboard.IsKeyPressed(.upArrow)){
            self.moveY(GameTime.DeltaTime * _moveSpeed)
        }
        if(Keyboard.IsKeyPressed(.downArrow)){
            self.moveY(-GameTime.DeltaTime * _moveSpeed)
        }
        self.moveZ(-Mouse.GetDWheel() * 0.1)
    }
    
    
}
