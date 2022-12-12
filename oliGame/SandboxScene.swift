//
//  SandboxScene.swift
//  oliGame
//
//  Created by Oliver Crumrine on 11/26/22.
//


class SandboxScene: Scene{
    var debugCamera = DebugCamera()
    var quad = Quad()
    var sun = Sun()
    override func buildScene(){
    
        
        
        sun.setPosition(0,2,0)
        sun.sunMaterial.isLit = false
        sun.sunMaterial.color = float4(1,1,1,1)
        sun.setLightColor(1,1,1)
        sun.setLightBrightness(1)
        sun.setLightAmbientIntensity(0.11)
        addLight(sun)
    
        let skySphere = SkySphere(skySphereTextureType: .Clouds)
        addChild(skySphere)

        addChild(quad)
        
        addCamera(debugCamera)
        debugCamera.setPositionZ(5)

    }
    override func doUpdate(){
        if(Mouse.IsMouseButtonPressed(button: .LEFT)){
            quad.rotateX(Mouse.GetDY()*GameTime.DeltaTime)
            quad.rotateY(Mouse.GetDX()*GameTime.DeltaTime)
        }

    }

}

