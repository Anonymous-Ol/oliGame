//
//  Camera.swift
//  oliGame
//
//  Created by Oliver Crumrine on 11/26/22.
//

import simd
enum CameraTypes {
    case debugCamera
    case cubeMapCamera
}

class Camera: Node {
    var cameraType: CameraTypes!
    var _viewMatrix = matrix_identity_float4x4
    var cameraFrustum: FrustumR
    
    
    var viewMatrix: matrix_float4x4 {
        return _viewMatrix
    }
    var projectionMatrix: matrix_float4x4 {
        return matrix_identity_float4x4
    }
    func switchToFace(faceIndex: Int){
        //To be overrided
    }
    init(name: String, cameraType: CameraTypes){
        //Created to suppress an error
        let bogusPlan = Plan(normal: float3(0,0,0), distance: 0)
        cameraFrustum = FrustumR()
        
        super.init(name: name)
        self.cameraType = cameraType
    }
    override func updateModelMatrix() {
        _viewMatrix = matrix_identity_float4x4
        _viewMatrix.translate(direction: -getPosition())
        _viewMatrix.rotate(angle: self.getRotationX(), axis: X_AXIS)
        _viewMatrix.rotate(angle: self.getRotationY(), axis: Y_AXIS)
        _viewMatrix.rotate(angle: self.getRotationZ(), axis: Z_AXIS)
        //print(self.getRotation())
        //rint(self.getPosition())
    }

}


