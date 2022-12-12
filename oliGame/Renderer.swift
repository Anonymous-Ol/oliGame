//
//  Renderer.swift
//  oliGame
//
//  Created by Oliver Crumrine on 11/26/22.
//

import MetalKit

class Renderer: NSObject{
    public static var ScreenSize: float2 = float2(0)
    private var _baseRenderPassDescriptor: MTLRenderPassDescriptor!
    private var _firstDraw: Bool = true
    public static var AspectRation: Float{
        return ScreenSize.x/ScreenSize.y
    }
    init(_ mtkView: MTKView){
        super.init()
        updateScreenSize(view: mtkView)
        SceneManager.SetScene(.Forest)
    }
    private func createBaseRenderPassDescriptor(view: MTKView){
        ///Base Color Texture 0
        let base0TextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: Preferences.MainPixelFomat,
                                                                             width: view.currentDrawable!.texture.width,
                                                                             height: view.currentDrawable!.texture.height,
                                                                             mipmapped: false)

        
        base0TextureDescriptor.usage = [.renderTarget, .shaderRead]
        Assets.Textures.setTexture(textureType: .BaseColorRender_0,
                        texture: Engine.Device.makeTexture(descriptor: base0TextureDescriptor)!)
        
        ///Base Color Texutre 1
        let base1TextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: Preferences.MainPixelFomat,
                                                                             width: view.currentDrawable!.texture.width,
                                                                             height: view.currentDrawable!.texture.height,
                                                                             mipmapped: false)

        
        base1TextureDescriptor.usage = [.renderTarget, .shaderRead]
        Assets.Textures.setTexture(textureType: .BaseColorRender_1,
                        texture: Engine.Device.makeTexture(descriptor: base1TextureDescriptor)!)
        
        
        ///Base Depth Texture 0
        let depthTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: Preferences.MainDethPixelFomat,
                                                                              width: view.currentDrawable!.texture.width,
                                                                              height: view.currentDrawable!.texture.height,
                                                                              mipmapped: false)
        

        depthTextureDescriptor.usage = [.renderTarget]
        depthTextureDescriptor.storageMode = .private

        
        Assets.Textures.setTexture(textureType: .BaseDepthRender,
                        texture: Engine.Device.makeTexture(descriptor: depthTextureDescriptor)!)
        
        
        self._baseRenderPassDescriptor = MTLRenderPassDescriptor()
        self._baseRenderPassDescriptor.colorAttachments[0].texture = Assets.Textures[.BaseColorRender_0]!
        self._baseRenderPassDescriptor.colorAttachments[0].storeAction = .store
        self._baseRenderPassDescriptor.colorAttachments[0].loadAction = .clear
        
        self._baseRenderPassDescriptor.colorAttachments[1].texture = Assets.Textures[.BaseColorRender_1]!
        self._baseRenderPassDescriptor.colorAttachments[1].storeAction = .store
        self._baseRenderPassDescriptor.colorAttachments[1].loadAction = .clear
        
        
        self._baseRenderPassDescriptor.depthAttachment.texture = Assets.Textures[.BaseDepthRender]

        
    }
}

extension Renderer: MTKViewDelegate{
    public func updateScreenSize(view: MTKView){
        Renderer.ScreenSize = float2(Float(view.currentDrawable!.texture.width), Float(view.currentDrawable!.texture.height))

    }
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
       updateScreenSize(view: view)
    }
    func baseRenderPass(commandBuffer: MTLCommandBuffer){
            
            let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: _baseRenderPassDescriptor)
            renderCommandEncoder?.label = "Base RENDER COMMAND ENCODER"
            renderCommandEncoder?.pushDebugGroup("Starting Render")
            SceneManager.Render(renderCommandEncoder: renderCommandEncoder!)
            renderCommandEncoder?.popDebugGroup()
            renderCommandEncoder?.endEncoding()

        
    }
    func finalRenderPass(view: MTKView, commandBuffer: MTLCommandBuffer){
            let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: view.currentRenderPassDescriptor!)
            renderCommandEncoder?.label = "Final RENDER COMMAND ENCODER"
            renderCommandEncoder?.pushDebugGroup("Starting Render")
            
            renderCommandEncoder?.setRenderPipelineState(Graphics.RenderPipelineStates[.Final])
            renderCommandEncoder?.setFragmentTexture(Assets.Textures[.BaseColorRender_0], index: 0)
            
            Assets.Meshes[.Quad]?.drawPrimitives(renderCommandEncoder!)
            
            renderCommandEncoder?.popDebugGroup()
            renderCommandEncoder?.endEncoding()
    }
    func draw( in view: MTKView){
        SceneManager.Update(deltaTime:  1 / Float(view.preferredFramesPerSecond))
        if(_firstDraw){
            createBaseRenderPassDescriptor(view: view)
        }
        guard let sceneRenderPassDescriptor = view.currentRenderPassDescriptor else {return}
        let commandBuffer = Engine.CommandQueue.makeCommandBuffer()
        commandBuffer?.label = "Command Buffer"
        
        baseRenderPass(commandBuffer: commandBuffer!)
        finalRenderPass(view: view, commandBuffer: commandBuffer!)

        
        
        commandBuffer?.present(view.currentDrawable!)
        commandBuffer?.commit()
    }
}