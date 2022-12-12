//
//  File.swift
//  oliGame
//
//  Created by Oliver Crumrine on 11/26/22.
//

import Foundation

class CameraManager{
    private var _cameras: [CameraTypes : Camera] = [:]
    
    public var currentCamera: Camera!
    
    public func registerCamera(camera: Camera){
        self._cameras.updateValue(camera, forKey: camera.cameraType)
    }
    
    public func setCamera(_ camerType: CameraTypes){
        self.currentCamera = _cameras[camerType]
    }
    internal func update(deltaTime: Float){
        for camera in _cameras.values{
            camera.update(deltaTime: deltaTime)
        }
    }

}
