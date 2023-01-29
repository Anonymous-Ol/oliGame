//
//  ShaderLibrary.swift
//  oliGame
//
//  Created by Oliver Crumrine on 11/29/22.
//

import MetalKit
enum ShaderTypes{
    case VertexBasic
    case VertexBasicShadow
    case VertexBasicCubemap
    case VertexInstanced
    case VertexInstancedShadow
    case VertexInstancedCubemap
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
        _library.updateValue(Shader(name: "Basic Vertex Shader", functionName: "basic_vertex_shader"), forKey: .VertexBasic)
        _library.updateValue(Shader(name: "Basic Shadow Vertex Shader", functionName: "vertex_shadow"), forKey: .VertexBasicShadow)
        _library.updateValue(Shader(name: "Basic Cubemap Vertex Shader", functionName: "cubemap_vertex_shader"), forKey: .VertexBasicCubemap)
        _library.updateValue(Shader(name: "Instanced Vertex Shader", functionName: "instanced_vertex_shader"), forKey: .VertexInstanced)
        _library.updateValue(Shader(name: "Instanced Shadow Vertex Shader", functionName: "instanced_vertex_shadow"), forKey: .VertexInstancedShadow)
        _library.updateValue(Shader(name: "Instanced Cubemap Vertex Shader", functionName: "cubemap_instanced_vertex_shader"), forKey: .VertexInstancedCubemap)
        
        
        _library.updateValue(Shader(name: "SkySphere Vertex Shader", functionName: "skysphere_vertex_shader"), forKey: .VertexSkySphere)
        _library.updateValue(Shader(name: "SkySphere Cubemap Vertex Shader", functionName: "skysphere_cubemap_vertex_shader"), forKey: .VertexSkySphereCubemap)
        _library.updateValue(Shader(name: "Final Vertex Shader", functionName: "final_vertex_shader"), forKey: .VertexFinal)
        
        
        
        
        
        
        
        _library.updateValue(Shader(name: "Basic Fragment Shader", functionName: "basic_fragment_shader"), forKey: .FragmentBasic)
        _library.updateValue(Shader(name: "Basic Shadow Fragment Shader", functionName: "basic_shadow_frag"), forKey: .FragmentBasicShadow)
        _library.updateValue(Shader(name: "Basic Cubemap Fragment Shader", functionName: "cubemap_fragment_shader"), forKey: .FragmentCubemap)
        
    
        
        _library.updateValue(Shader(name: "SkySphere Fragment Shader", functionName: "skysphere_fragment_shader"), forKey: .FragmentSkySphere)
        _library.updateValue(Shader(name: "SkySphere Cubemap Fragment Shader", functionName: "skysphere_cubemap_fragment_shader"), forKey: .FragmentSkySphereCubemap)

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

