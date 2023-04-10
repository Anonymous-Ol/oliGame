//
//  ShaderLibrary.swift
//  oliGame
//
//  Created by Oliver Crumrine on 11/29/22.
//

import MetalKit
enum ShaderTypes{
    case VertexBasic
    case VertexSkinned
    case VertexBasicShadow
    case VertexSkinnedShadow
    case VertexBasicCubemap
    case VertexSkinnedCubemap
    
    case VertexInstanced
    case VertexInstancedSkinned
    case VertexInstancedShadow
    case VertexInstancedSkinnedShadow
    case VertexInstancedCubemap
    case VertexInstancedSkinnedCubemap
    
    case VertexSkySphere
    case VertexSkySphereCubemap
    
    case VertexFinal

    case FragmentBasic
    case FragmentBasicShadow
    case FragmentCubemap
    case FragmentSkySphere
    case FragmentSkySphereCubemap
    case FragmentFinal

}

class ShaderLibrary:  Library<ShaderTypes, MTLFunction>{
    private var _library: [ShaderTypes: Shader] = [:]
    override func fillLibrary(){
        //Basic and Instanced Vertex Shaders
        _library.updateValue(Shader(name: "Basic Vertex Shader", functionName: "basic_vertex_shader"), forKey: .VertexBasic)
        _library.updateValue(Shader(name: "Skinned Vertex Shader", functionName: "skinned_vertex_shader"), forKey: .VertexSkinned)
        _library.updateValue(Shader(name: "Basic Shadow Vertex Shader", functionName: "vertex_shadow"), forKey: .VertexBasicShadow)
        _library.updateValue(Shader(name: "Skinned Shadow Vertex Shader", functionName: "skinned_vertex_shadow"), forKey: .VertexSkinnedShadow)
        _library.updateValue(Shader(name: "Basic Cubemap Vertex Shader", functionName: "cubemap_vertex_shader"), forKey: .VertexBasicCubemap)
        _library.updateValue(Shader(name: "Skinned Cubemap Vertex Shader", functionName: "cubemap_skinned_vertex_shader"), forKey: .VertexSkinnedCubemap)
        _library.updateValue(Shader(name: "Instanced Vertex Shader", functionName: "instanced_vertex_shader"), forKey: .VertexInstanced)
        _library.updateValue(Shader(name: "Skinned Instanced Vertex Shader", functionName: "skinned_instanced_vertex_shader"), forKey: .VertexInstancedSkinned)
        _library.updateValue(Shader(name: "Instanced Shadow Vertex Shader", functionName: "instanced_vertex_shadow"), forKey: .VertexInstancedShadow)
        _library.updateValue(Shader(name: "Skinned Instanced Shadow Vertex Shader", functionName: "skinned_instanced_vertex_shadow"), forKey: .VertexInstancedSkinnedShadow)
        _library.updateValue(Shader(name: "Instanced Cubemap Vertex Shader", functionName: "cubemap_instanced_vertex_shader"), forKey: .VertexInstancedCubemap)
        _library.updateValue(Shader(name: "Instanced Cubemap Skinned Vertex Shader", functionName: "skinned_cubemap_instanced_vertex_shader"), forKey: .VertexInstancedSkinnedCubemap)
        
        //SkySphere Vertex Shaders
        _library.updateValue(Shader(name: "SkySphere Vertex Shader", functionName: "skysphere_vertex_shader"), forKey: .VertexSkySphere)
        _library.updateValue(Shader(name: "SkySphere Cubemap Vertex Shader", functionName: "skysphere_cubemap_vertex_shader"), forKey: .VertexSkySphereCubemap)
        
        //Final Vertex Shader
        _library.updateValue(Shader(name: "Final Vertex Shader", functionName: "final_vertex_shader"), forKey: .VertexFinal)
        
        
        
        //Basic Fragment Shaders
        _library.updateValue(Shader(name: "Basic Fragment Shader", functionName: "basic_fragment_shader"), forKey: .FragmentBasic)
        _library.updateValue(Shader(name: "Basic Shadow Fragment Shader", functionName: "basic_shadow_frag"), forKey: .FragmentBasicShadow)
        _library.updateValue(Shader(name: "Basic Cubemap Fragment Shader", functionName: "cubemap_fragment_shader"), forKey: .FragmentCubemap)
        
        //SkySphere Fragment Shaders
        _library.updateValue(Shader(name: "SkySphere Fragment Shader", functionName: "skysphere_fragment_shader"), forKey: .FragmentSkySphere)
        _library.updateValue(Shader(name: "SkySphere Cubemap Fragment Shader", functionName: "skysphere_cubemap_fragment_shader"), forKey: .FragmentSkySphereCubemap)

        //Final Fragment Shader
        _library.updateValue(Shader(name: "Final Fragment Shader", functionName: "final_fragment_shader"), forKey: .FragmentFinal)
        
    }
    override subscript(_ type: ShaderTypes)->MTLFunction{
        return (_library[type]?.function)!
    }
}
class Shader{
    var function: MTLFunction!
    init(name: String, functionName: String){
        self.function = Engine.DefaultLibrary.makeFunction(name: functionName)
        self.function.label = name

    }
}

