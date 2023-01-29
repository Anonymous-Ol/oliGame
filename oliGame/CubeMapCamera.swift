//
//  CubeMapCamera.swift
//  oliGame
//
//  Created by Oliver Crumrine on 12/31/22.
//

import simd

class CubeMapCamera: Camera{
    private  var _projectionMatrix = matrix_identity_float4x4
    private var _pitch: Float = 0
    private var _yaw: Float = 0
    override var projectionMatrix: matrix_float4x4{
        return _projectionMatrix
    }
    
    init(){
        super.init(name: "CubeMapCamera", cameraType: .debugCamera)
        _projectionMatrix = matrix_float4x4.perspective(degreesFov: 90, aspectRation: Renderer.AspectRation, near: 0.1, far: 1000)
    }
    override func switchToFace(faceIndex: Int) {
            switch (faceIndex) {
            case 0:
                _pitch = 0
                _yaw = 90
                break
            case 1:
                _pitch = 0
                _yaw = -90
                break
            case 2:
                _pitch = -90
                _yaw = 180
                break
            case 3:
                _pitch = 90
                _yaw = 180
                break
            case 4:
                _pitch = 0
                _yaw = 180
                break
            case 5:
                _pitch = 0
                _yaw = 0
                break
            default:
                break
            }
            updateModelMatrix()
        }
    override func updateModelMatrix() {
        _viewMatrix = matrix_identity_float4x4
        _viewMatrix.translate(direction: -getPosition())
        _viewMatrix.rotate(angle: _pitch, axis: X_AXIS)
        _viewMatrix.rotate(angle: _yaw, axis: Y_AXIS)
        _viewMatrix.rotate(angle: 180, axis: Z_AXIS)
    }
    
    
}
