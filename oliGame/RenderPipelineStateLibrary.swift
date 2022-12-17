//
//  RenderPipelineDescriptorLibrary.swift
//  oliGame
//
//  Created by Oliver Crumrine on 11/26/22.
//

import MetalKit

enum RenderPipelineStateTypes{
    case Basic
    case BasicShadow
    case Instanced
    case InstancedShadow
    case SkySphere
    case Final
}


class RenderPipelineStateLibrary: Library<RenderPipelineStateTypes, MTLRenderPipelineState> {
    private var _library: [RenderPipelineStateTypes : RenderPipelineState] = [:]
        
    override func fillLibrary(){
        _library.updateValue(basicRenderPipelineState(), forKey: .Basic)
        _library.updateValue(basicShadowRenderPipelineState(), forKey: .BasicShadow)

        
        _library.updateValue(instancedRenderPipelineState(), forKey: .Instanced)
        _library.updateValue(instancedShadowRenderPipelineState(), forKey: .InstancedShadow)
        
        
        _library.updateValue(SkySphereRenderPipelineState(), forKey: .SkySphere)
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
        renderPipelineDescriptor.colorAttachments[1].pixelFormat = Preferences.MainPixelFomat
        
        renderPipelineDescriptor.depthAttachmentPixelFormat = Preferences.MainDethPixelFomat
        
        renderPipelineDescriptor.vertexFunction = Graphics.Shaders[.VertexBasic]
        renderPipelineDescriptor.fragmentFunction = Graphics.Shaders[.FragmentBasic]
        
        renderPipelineDescriptor.vertexDescriptor = Graphics.VertexDescriptors[.Basic]
        
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
        
        super.init(renderPipelineDescriptor)
    }
}
class instancedRenderPipelineState: RenderPipelineState{
    init(){
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = Preferences.MainPixelFomat
        renderPipelineDescriptor.colorAttachments[1].pixelFormat = Preferences.MainPixelFomat
        
        renderPipelineDescriptor.depthAttachmentPixelFormat = Preferences.MainDethPixelFomat
        
        renderPipelineDescriptor.vertexFunction = Graphics.Shaders[.VertexInstanced]
        renderPipelineDescriptor.fragmentFunction = Graphics.Shaders[.FragmentBasic]
        
        renderPipelineDescriptor.vertexDescriptor = Graphics.VertexDescriptors[.Basic]
        
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
        
        super.init(renderPipelineDescriptor)
    }
}
class SkySphereRenderPipelineState: RenderPipelineState{
    
    init(){
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = Preferences.MainPixelFomat
        renderPipelineDescriptor.colorAttachments[1].pixelFormat = Preferences.MainPixelFomat
        
        renderPipelineDescriptor.depthAttachmentPixelFormat = Preferences.MainDethPixelFomat
        
        renderPipelineDescriptor.vertexFunction = Graphics.Shaders[.VertexSkySphere]
        renderPipelineDescriptor.fragmentFunction = Graphics.Shaders[.FragmentSkySphere]
        
        renderPipelineDescriptor.vertexDescriptor = Graphics.VertexDescriptors[.Basic]
        
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
        
        super.init(renderPipelineDescriptor)
    }
}


