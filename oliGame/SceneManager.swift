//
//  SceneManager.swift
//  oliGame
//
//  Created by Oliver Crumrine on 11/26/22.
//

import MetalKit

enum SceneTypes{
    case Sandbox
    case Forest
}

class SceneManager{
    private static var _currentScene: Scene!
    
    public static func SetScene(_ sceneType: SceneTypes){
        switch sceneType{
        case .Sandbox:
            _currentScene = SandboxScene(name: "SandboxScene")
        case .Forest:
            _currentScene = ForestScene(name:"ForestScene")
        }
        
    }
    public static func Update(deltaTime: Float){
        GameTime.UpdateTime(_deltaTime: deltaTime)
        _currentScene.updateCameras(deltaTime: deltaTime)
        _currentScene.update(deltaTime: deltaTime)
    }
    public static func Render(renderCommandEncoder: MTLRenderCommandEncoder){

        _currentScene.render(renderCommandEncoder: renderCommandEncoder)
    }

}
