//
//  Renderer.swift
//  oliGame
//
//  Created by Oliver Crumrine on 11/26/22.
//

import MetalKit


class Renderer: NSObject{
    public static var currnetPipelineState: RenderPipelineStateTypes? = nil
    public static var reflectionsBeingRendered: Bool = false
    public static var ScreenSize: float2 = float2(repeating: 0)
    public static var shadowRenders: [MTLTexture] =  []
    public static var currentReflectionPosition: float3 = float3(0,0,0)
    private var _baseRenderPassDescriptor:   MTLRenderPassDescriptor!
    static  var _reflectionRenderPassDescriptor: MTLRenderPassDescriptor!
    static var shadowRenderPassDescriptor: MTLRenderPassDescriptor!
    private var _firstDraw: Bool = true
    public static var AspectRation: Float{
        return ScreenSize.x/ScreenSize.y
    }
    init(_ mtkView: MTKView){
        super.init()
        updateScreenSize(view: mtkView)
        SceneManager.SetScene(.Forest)

    }
    static func createReflectionRenderPassDescriptor(_ arrayLength: Int32){
        
        let reflectionTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm_srgb,
                                                                                   width: 300,
                                                                                   height: 300,
                                                                                   mipmapped: false)
        
        
        reflectionTextureDescriptor.textureType = .typeCubeArray
        reflectionTextureDescriptor.storageMode = .private
        reflectionTextureDescriptor.usage = [.renderTarget, .shaderRead]
        reflectionTextureDescriptor.arrayLength = Int(arrayLength)
        
        let reflectionDepthTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .depth32Float,
                                                                                        width: 300,
                                                                                        height: 300,
                                                                                        mipmapped: false)
        
        
        reflectionDepthTextureDescriptor.textureType = .typeCubeArray
        reflectionDepthTextureDescriptor.storageMode = .private
        reflectionDepthTextureDescriptor.usage = [.renderTarget, .shaderRead]
        reflectionDepthTextureDescriptor.arrayLength = Int(arrayLength)
        
        Assets.Textures.setTexture(textureType: .ReflectionRender,
                        texture:Engine.Device.makeTexture(descriptor: reflectionTextureDescriptor)!)
        let depthTexture: MTLTexture = Engine.Device.makeTexture(descriptor: reflectionDepthTextureDescriptor)!
        
        
        
        Renderer._reflectionRenderPassDescriptor = MTLRenderPassDescriptor()
        
        
        Renderer._reflectionRenderPassDescriptor.colorAttachments[0].texture = Assets.Textures[.ReflectionRender]
        Renderer._reflectionRenderPassDescriptor.colorAttachments[0].loadAction =  .clear
        Renderer._reflectionRenderPassDescriptor.colorAttachments[0].storeAction = .store
        
        Renderer._reflectionRenderPassDescriptor.depthAttachment.texture = depthTexture
        
        Renderer._reflectionRenderPassDescriptor.renderTargetArrayLength = 6*Int(arrayLength)
        
        
        
        
    }
    private func createBaseRenderPassDescriptor(view: MTKView){
        ///Base Color Texture 0
        let base0TextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: Preferences.MainPixelFomat,
                                                                             width: 1920,
                                                                             height: 1080,
                                                                             mipmapped: false)

        
        base0TextureDescriptor.usage = [.renderTarget, .shaderRead]
        Assets.Textures.setTexture(textureType: .BaseColorRender_0,
                        texture: Engine.Device.makeTexture(descriptor: base0TextureDescriptor)!)
        
        
        
        ///Base Depth Texture 0
        let depthTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: Preferences.MainDethPixelFomat,
                                                                              width: 1920,
                                                                              height: 1080,
                                                                              mipmapped: false)
        

        depthTextureDescriptor.usage = [.renderTarget]
        depthTextureDescriptor.storageMode = .private

        
        Assets.Textures.setTexture(textureType: .BaseDepthRender,
                        texture: Engine.Device.makeTexture(descriptor: depthTextureDescriptor)!)
        
        
        self._baseRenderPassDescriptor = MTLRenderPassDescriptor()
        self._baseRenderPassDescriptor.colorAttachments[0].texture = Assets.Textures[.BaseColorRender_0]!
        self._baseRenderPassDescriptor.colorAttachments[0].storeAction = .store
        self._baseRenderPassDescriptor.colorAttachments[0].loadAction = .clear
        
        self._baseRenderPassDescriptor.depthAttachment.texture = Assets.Textures[.BaseDepthRender]

        
    }
}

extension Renderer: MTKViewDelegate{
    public func updateScreenSize(view: MTKView){
        Renderer.ScreenSize = float2(Float(view.currentDrawable!.texture.width), Float(view.currentDrawable!.texture.height))
    }
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        updateScreenSize(view: view)
        createBaseRenderPassDescriptor(view: view)
    }
    func copyShadowTextureData(commandBuffer: MTLCommandBuffer){
        let blitCommandEncoder = commandBuffer.makeBlitCommandEncoder()
        blitCommandEncoder?.label = "Shadow Blit COMMAND ENCODER"
        blitCommandEncoder?.pushDebugGroup("Starting Copy")
        SceneManager.CopyShadowData(blitCommandEncoder: blitCommandEncoder!)
        blitCommandEncoder?.popDebugGroup()
        blitCommandEncoder?.endEncoding()
    }
    func cubeMapRenderPass(commandBuffer: MTLCommandBuffer){
            let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: _baseRenderPassDescriptor)
            renderCommandEncoder?.label = "Cube Map Render Command Encoder"
            renderCommandEncoder?.pushDebugGroup("Starting Render")
            //renderCommandEncoder?.setCullMode(.front)
            renderCommandEncoder?.popDebugGroup()
            renderCommandEncoder?.endEncoding()

        
    }
    func baseRenderPass(commandBuffer: MTLCommandBuffer){
            let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: _baseRenderPassDescriptor)
            renderCommandEncoder?.label = "Base RENDER COMMAND ENCODER"
            renderCommandEncoder?.pushDebugGroup("Starting Render")
            //renderCommandEncoder?.setCullMode(.back)
            SceneManager.Render(renderCommandEncoder: renderCommandEncoder!)
            renderCommandEncoder?.popDebugGroup()
            renderCommandEncoder?.endEncoding()

        
    }
    func finalRenderPass(view: MTKView, commandBuffer: MTLCommandBuffer){
        view.currentDrawable?.layer.allowsNextDrawableTimeout = false
            let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: view.currentRenderPassDescriptor!)
            renderCommandEncoder?.label = "Final RENDER COMMAND ENCODER"
            renderCommandEncoder?.pushDebugGroup("Starting Render")
            
        renderCommandEncoder?.setRenderPipelineState(Graphics.RenderPipelineStates[.Final])
            Renderer.currnetPipelineState = .Final
            renderCommandEncoder?.setFragmentTexture(Assets.Textures[.BaseColorRender_0], index: 0)
            
            Assets.Meshes[.Quad]?.drawPrimitives(renderCommandEncoder!)
            
            renderCommandEncoder?.popDebugGroup()
            renderCommandEncoder?.endEncoding()
    }
    func draw( in view: MTKView){
        SceneManager.Update(deltaTime:  1 / Float(view.preferredFramesPerSecond))
        if(_firstDraw){
            //createReflectionRenderPassDescriptor()
            createBaseRenderPassDescriptor(view: view)
            _firstDraw = false
        }
        let shadowCommandBuffer = Engine.CommandQueue.makeCommandBuffer()
        shadowCommandBuffer?.label = "Shadow Command Buffer"
        SceneManager.doShadowRender(commandBuffer: shadowCommandBuffer!)
        //copyShadowTextureData(commandBuffer: shadowCommandBuffer!)
        shadowCommandBuffer?.commit()
        let reflectionsCommandBuffer = Engine.CommandQueue.makeCommandBuffer()
        reflectionsCommandBuffer?.label = "Reflections Command Buffer"
        SceneManager.doReflectionRender()
        SceneManager.ReflectionRender(commandBuffer: reflectionsCommandBuffer!)
        reflectionsCommandBuffer?.commit()
        let baseCommandBuffer = Engine.CommandQueue.makeCommandBuffer()
        baseCommandBuffer?.label = "Base Command Buffer"
        baseRenderPass(commandBuffer: baseCommandBuffer!)
        finalRenderPass(view: view, commandBuffer: baseCommandBuffer!)
        
        baseCommandBuffer?.present(view.currentDrawable!)
        baseCommandBuffer?.commit()
    }
}
