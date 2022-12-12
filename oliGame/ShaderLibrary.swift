//
//  ShaderLibrary.swift
//  oliGame
//
//  Created by Oliver Crumrine on 11/29/22.
//

import MetalKit
enum ShaderTypes{
    case VertexBasic
    case VertexInstanced
    case VertexSkySphere
    case VertexFinal

    case FragmentBasic
    case FragmentSkySphere
    case FragmentFinal
}

class ShaderLibrary:  Library<ShaderTypes, MTLFunction>{
    private var _library: [ShaderTypes: Shader] = [:]
    override func fillLibrary(){
        _library.updateValue(Shader(name: "Basic Vertex Shader", functionName: "basic_vertex_shader"), forKey: .VertexBasic)
        _library.updateValue(Shader(name: "Instanced Vertex Shader", functionName: "instanced_vertex_shader"), forKey: .VertexInstanced)
        
        
        _library.updateValue(Shader(name: "SkySphere Vertex Shader", functionName: "skysphere_vertex_shader"), forKey: .VertexSkySphere)
        _library.updateValue(Shader(name: "Final Vertex Shader", functionName: "final_vertex_shader"), forKey: .VertexFinal)
        
        
        
        
        
        
        
        _library.updateValue(Shader(name: "Basic Fragment Shader", functionName: "basic_fragment_shader"), forKey: .FragmentBasic)

        
        
        _library.updateValue(Shader(name: "SkySphere Fragment Shader", functionName: "skysphere_fragment_shader"), forKey: .FragmentSkySphere)
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

