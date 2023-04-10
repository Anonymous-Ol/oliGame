//
//  RenderPipelineDescriptorLibrary.swift
//  oliGame
//
//  Created by Oliver Crumrine on 11/26/22.
//

import MetalKit

enum RenderPipelineStateTypes{
    case Basic
    case BasicSkinned
    case BasicShadow
    case SkinnedShadow
    case BasicCubemap
    case SkinnedCubemap
    case Instanced
    case InstancedSkinned
    case InstancedShadow
    case InstancedSkinnedShadow
    case InstancedCubemap
    case InstancedSkinnedCubemap
    case SkySphere
    case SkySphereCubemap
    case Final
}


class RenderPipelineStateLibrary: Library<RenderPipelineStateTypes, MTLRenderPipelineState> {
    private var _library: [RenderPipelineStateTypes : RenderPipelineState] = [:]
        
    override func fillLibrary(){
        _library.updateValue(basicRenderPipelineState(), forKey: .Basic)
        _library.updateValue(skinnedRenderPipelineState(), forKey: .BasicSkinned)
        _library.updateValue(basicShadowRenderPipelineState(), forKey: .BasicShadow)
        _library.updateValue(skinnedShadowRenderPipelineState(), forKey: .SkinnedShadow)
        _library.updateValue(basicCubemapRenderPipelineState(), forKey: .BasicCubemap)
        _library.updateValue(skinnedCubemapRenderPipelineState(), forKey: .SkinnedCubemap)

        
        _library.updateValue(instancedRenderPipelineState(), forKey: .Instanced)
        _library.updateValue(skinnedInstancedRenderPipelineState(), forKey: .InstancedSkinned)
        _library.updateValue(instancedShadowRenderPipelineState(), forKey: .InstancedShadow)
        _library.updateValue(skinnedInstancedShadowRenderPipelineState(), forKey: .InstancedSkinnedShadow)
        _library.updateValue(instancedCubemapRenderPipelineState(), forKey: .InstancedCubemap)
        _library.updateValue(skinnedInstancedCubemapRenderPipelineState(), forKey: .InstancedSkinnedCubemap)
        
        
        _library.updateValue(SkySphereRenderPipelineState(), forKey: .SkySphere)
        _library.updateValue(SkySphereCubemapRenderPipelineState(), forKey: .SkySphereCubemap)
        _library.updateValue(finalRenderPipelineState(), forKey: .Final)
    }
    override subscript(_ type: RenderPipelineStateTypes) -> MTLRenderPipelineState {
        return _library[type]!.renderPipelineState
    }
}
class RenderPipelineState{
    var renderPipelineState: MTLRenderPipelineState!
    init(_ renderPipelineDescriptor: MTLRenderPipelineDescriptor){
        do{
            renderPipelineState = try Engine.Device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
        }catch let error as NSError{
            print(error)
        }
    }
}
class basicRenderPipelineState: RenderPipelineState{
    
    init(){
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = Preferences.MainPixelFomat
        
        renderPipelineDescriptor.depthAttachmentPixelFormat = Preferences.MainDethPixelFomat
        
        renderPipelineDescriptor.vertexFunction = Graphics.Shaders[.VertexBasic]
        renderPipelineDescriptor.fragmentFunction = Graphics.Shaders[.FragmentBasic]
        
        renderPipelineDescriptor.vertexDescriptor = Graphics.VertexDescriptors[.Basic]
        
        renderPipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
        
        renderPipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .one
        renderPipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        renderPipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
          
        renderPipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .one
        renderPipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        renderPipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add
        
        super.init(renderPipelineDescriptor)
    }
}
class skinnedRenderPipelineState: RenderPipelineState{
    init(){
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = Preferences.MainPixelFomat
        
        renderPipelineDescriptor.depthAttachmentPixelFormat = Preferences.MainDethPixelFomat
        
        renderPipelineDescriptor.vertexFunction = Graphics.Shaders[.VertexSkinned]
        renderPipelineDescriptor.fragmentFunction = Graphics.Shaders[.FragmentBasic]
        
        renderPipelineDescriptor.vertexDescriptor = Graphics.VertexDescriptors[.Basic]
        
        renderPipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
        
        renderPipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .one
        renderPipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        renderPipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
          
        renderPipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .one
        renderPipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        renderPipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add
        
        super.init(renderPipelineDescriptor)
    }
}
class basicShadowRenderPipelineState: RenderPipelineState{
    init(){
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()

        renderPipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        
        renderPipelineDescriptor.vertexFunction = Graphics.Shaders[.VertexBasicShadow]
        renderPipelineDescriptor.fragmentFunction = nil
        
        renderPipelineDescriptor.vertexDescriptor = Graphics.VertexDescriptors[.Basic]
        
        renderPipelineDescriptor.inputPrimitiveTopology = .triangle
        
        
        super.init(renderPipelineDescriptor)
    }
}
class skinnedShadowRenderPipelineState: RenderPipelineState{
    init(){
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()

        renderPipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        
        renderPipelineDescriptor.vertexFunction = Graphics.Shaders[.VertexSkinnedShadow]
        renderPipelineDescriptor.fragmentFunction = nil
        
        renderPipelineDescriptor.vertexDescriptor = Graphics.VertexDescriptors[.Basic]
        
        renderPipelineDescriptor.inputPrimitiveTopology = .triangle
        
        
        super.init(renderPipelineDescriptor)
    }
}
class basicCubemapRenderPipelineState: RenderPipelineState{
    
    init(){
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = Preferences.MainPixelFomat
        
        renderPipelineDescriptor.depthAttachmentPixelFormat = Preferences.MainDethPixelFomat
        
        renderPipelineDescriptor.vertexFunction = Graphics.Shaders[.VertexBasicCubemap]
        renderPipelineDescriptor.fragmentFunction = Graphics.Shaders[.FragmentCubemap]
        
        renderPipelineDescriptor.vertexDescriptor = Graphics.VertexDescriptors[.Basic]
        
        renderPipelineDescriptor.inputPrimitiveTopology = .triangle
        
        renderPipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
        
        renderPipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .one
        renderPipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        renderPipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
          
        renderPipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .one
        renderPipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        renderPipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add
        
        super.init(renderPipelineDescriptor)
    }
}
class skinnedCubemapRenderPipelineState: RenderPipelineState{
    
    init(){
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = Preferences.MainPixelFomat
        
        renderPipelineDescriptor.depthAttachmentPixelFormat = Preferences.MainDethPixelFomat
        
        renderPipelineDescriptor.vertexFunction = Graphics.Shaders[.VertexSkinnedCubemap]
        renderPipelineDescriptor.fragmentFunction = Graphics.Shaders[.FragmentCubemap]
        
        renderPipelineDescriptor.vertexDescriptor = Graphics.VertexDescriptors[.Basic]
        
        renderPipelineDescriptor.inputPrimitiveTopology = .triangle
        
        renderPipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
        
        renderPipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .one
        renderPipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        renderPipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
          
        renderPipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .one
        renderPipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        renderPipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add
        
        super.init(renderPipelineDescriptor)
    }
}
class instancedRenderPipelineState: RenderPipelineState{
    init(){
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = Preferences.MainPixelFomat
        
        renderPipelineDescriptor.depthAttachmentPixelFormat = Preferences.MainDethPixelFomat
        
        renderPipelineDescriptor.vertexFunction = Graphics.Shaders[.VertexInstanced]
        renderPipelineDescriptor.fragmentFunction = Graphics.Shaders[.FragmentBasic]
        
        renderPipelineDescriptor.vertexDescriptor = Graphics.VertexDescriptors[.Basic]
        
        renderPipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
        
        renderPipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .one
        renderPipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        renderPipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
          
        renderPipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .one
        renderPipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        renderPipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add
        
        super.init(renderPipelineDescriptor)
    }
}
class skinnedInstancedRenderPipelineState: RenderPipelineState{
    init(){
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = Preferences.MainPixelFomat
        
        renderPipelineDescriptor.depthAttachmentPixelFormat = Preferences.MainDethPixelFomat
        
        renderPipelineDescriptor.vertexFunction = Graphics.Shaders[.VertexInstancedSkinned]
        renderPipelineDescriptor.fragmentFunction = Graphics.Shaders[.FragmentBasic]
        
        renderPipelineDescriptor.vertexDescriptor = Graphics.VertexDescriptors[.Basic]
        
        renderPipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
        
        renderPipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .one
        renderPipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        renderPipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
          
        renderPipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .one
        renderPipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        renderPipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add
        
        super.init(renderPipelineDescriptor)
    }
}
class instancedShadowRenderPipelineState: RenderPipelineState{
    init(){
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        
        renderPipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        
        renderPipelineDescriptor.vertexFunction = Graphics.Shaders[.VertexInstancedShadow]
        renderPipelineDescriptor.fragmentFunction = nil
        
        renderPipelineDescriptor.vertexDescriptor = Graphics.VertexDescriptors[.Basic]
        
        renderPipelineDescriptor.inputPrimitiveTopology = .triangle
        
        super.init(renderPipelineDescriptor)
    }
}
class skinnedInstancedShadowRenderPipelineState: RenderPipelineState{
    init(){
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        
        renderPipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        
        renderPipelineDescriptor.vertexFunction = Graphics.Shaders[.VertexInstancedSkinnedShadow]
        renderPipelineDescriptor.fragmentFunction = nil
        
        renderPipelineDescriptor.vertexDescriptor = Graphics.VertexDescriptors[.Basic]
        
        renderPipelineDescriptor.inputPrimitiveTopology = .triangle
        
        super.init(renderPipelineDescriptor)
    }
}
class instancedCubemapRenderPipelineState: RenderPipelineState{
    init(){
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = Preferences.MainPixelFomat
        
        renderPipelineDescriptor.depthAttachmentPixelFormat = Preferences.MainDethPixelFomat
        
        renderPipelineDescriptor.vertexFunction = Graphics.Shaders[.VertexInstancedCubemap]
        renderPipelineDescriptor.fragmentFunction = Graphics.Shaders[.FragmentCubemap]
        
        renderPipelineDescriptor.vertexDescriptor = Graphics.VertexDescriptors[.Basic]
        
        renderPipelineDescriptor.inputPrimitiveTopology = .triangle
        
        renderPipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
        
        renderPipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .one
        renderPipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        renderPipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
          
        renderPipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .one
        renderPipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        renderPipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add
        
        super.init(renderPipelineDescriptor)
    }
}
class skinnedInstancedCubemapRenderPipelineState: RenderPipelineState{
    init(){
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = Preferences.MainPixelFomat
        
        renderPipelineDescriptor.depthAttachmentPixelFormat = Preferences.MainDethPixelFomat
        
        renderPipelineDescriptor.vertexFunction = Graphics.Shaders[.VertexInstancedSkinnedCubemap]
        renderPipelineDescriptor.fragmentFunction = Graphics.Shaders[.FragmentCubemap]
        
        renderPipelineDescriptor.vertexDescriptor = Graphics.VertexDescriptors[.Basic]
        
        renderPipelineDescriptor.inputPrimitiveTopology = .triangle
        
        renderPipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
        
        renderPipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .one
        renderPipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        renderPipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
          
        renderPipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .one
        renderPipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        renderPipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add
        
        super.init(renderPipelineDescriptor)
    }
}
class SkySphereRenderPipelineState: RenderPipelineState{
    
    init(){
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = Preferences.MainPixelFomat
        
        renderPipelineDescriptor.depthAttachmentPixelFormat = Preferences.MainDethPixelFomat
        
        renderPipelineDescriptor.vertexFunction = Graphics.Shaders[.VertexSkySphere]
        renderPipelineDescriptor.fragmentFunction = Graphics.Shaders[.FragmentSkySphere]
        
        renderPipelineDescriptor.vertexDescriptor = Graphics.VertexDescriptors[.Basic]
        
        super.init(renderPipelineDescriptor)
    }
}
class SkySphereCubemapRenderPipelineState: RenderPipelineState{
    
    init(){
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = Preferences.MainPixelFomat
        
        renderPipelineDescriptor.depthAttachmentPixelFormat = Preferences.MainDethPixelFomat
        
        renderPipelineDescriptor.vertexFunction = Graphics.Shaders[.VertexSkySphereCubemap]
        renderPipelineDescriptor.fragmentFunction = Graphics.Shaders[.FragmentSkySphereCubemap]
        
        renderPipelineDescriptor.vertexDescriptor = Graphics.VertexDescriptors[.Basic]
        
        renderPipelineDescriptor.inputPrimitiveTopology = .triangle
        
        super.init(renderPipelineDescriptor)
    }
}
class finalRenderPipelineState: RenderPipelineState{
    
    init(){
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = Preferences.MainPixelFomat

        
        renderPipelineDescriptor.vertexFunction = Graphics.Shaders[.VertexFinal]
        renderPipelineDescriptor.fragmentFunction = Graphics.Shaders[.FragmentFinal]
        
        renderPipelineDescriptor.vertexDescriptor = Graphics.VertexDescriptors[.Basic]
        
        renderPipelineDescriptor.inputPrimitiveTopology = .triangle
        
        super.init(renderPipelineDescriptor)
    }
}


