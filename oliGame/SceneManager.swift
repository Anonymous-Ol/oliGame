//
//  SceneManager.swift
//  oliGame
//
//  Created by Oliver Crumrine on 11/26/22.
//

import MetalKit

enum SceneTypes{
    //case Sandbox
    case Forest
}

class SceneManager{
    static var currentScene: Scene!
    public static func SetScene(_ sceneType: SceneTypes){
        switch sceneType{
//        case .Sandbox:
//            currentScene = SandboxScene(name: "SandboxScene")
        case .Forest:
            currentScene = ForestScene(name:"ForestScene")
        }
        
    }

    public static func Update(deltaTime: Float){
        GameTime.UpdateTime(_deltaTime: deltaTime)
        currentScene.updateCameras(deltaTime: deltaTime)
        currentScene.update(deltaTime: deltaTime)
    }
    public static func setupRender(renderCommandEncoder: MTLRenderCommandEncoder){

        currentScene.setupRender(renderCommandEncoder: renderCommandEncoder)
    }
    public static func CopyShadowData(blitCommandEncoder: MTLBlitCommandEncoder){
        currentScene.copyShadowData(blitCommandEncoder: blitCommandEncoder)
    }
    public static func ShadowRender(renderCommandEncoder: MTLRenderCommandEncoder){
        currentScene.shadowRender(renderCommandEncoder: renderCommandEncoder)
    }
    public static func doShadowRender(commandBuffer: MTLCommandBuffer){
        currentScene.doShadowRender(commandBuffer:  commandBuffer)
    }
    public static func doReflectionRender(){
        currentScene.doReflectionRender()
    }
    public static func ReflectionRender(commandBuffer: MTLCommandBuffer){
        if(RenderVariables.currentReflectionIndex > 0){
            currentScene.ReflectionRender(commandBuffer: commandBuffer)
        }
    }
}
