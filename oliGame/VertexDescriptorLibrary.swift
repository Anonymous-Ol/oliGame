//
//  VertexDescriptorLibrary.swift
//  oliGame
//
//  Created by Oliver Crumrine on 11/26/22.
//

import MetalKit

enum VertexDescriptorTypes{
    case Basic
}

class VertexDescriptoryLibrary: Library<VertexDescriptorTypes, MTLVertexDescriptor>{
    private var _library: [VertexDescriptorTypes: VertexDescriptor] = [:]
    
    override func fillLibrary() {
        _library.updateValue(basicVertexDescriptor(), forKey: .Basic)
    }
    override subscript(type: VertexDescriptorTypes) -> MTLVertexDescriptor {
        return _library[type]!.vertexDescriptor!
    }
    
}

protocol VertexDescriptor{
    var name: String {get}
    var vertexDescriptor: MTLVertexDescriptor! {get}
}

public struct basicVertexDescriptor: VertexDescriptor{
    var name: String = "Basic Vertex Descriptor"
    
    var vertexDescriptor: MTLVertexDescriptor!
    init(){
        
        var offset: Int = 0;
        ///Position
        vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].bufferIndex =  0
        vertexDescriptor.attributes[0].offset =       offset
        offset += float3.size
        ///Color
        vertexDescriptor.attributes[1].format = .float4
        vertexDescriptor.attributes[1].bufferIndex =  0
        vertexDescriptor.attributes[1].offset =       offset
        offset += float4.size
        ///Texture Coodinate
        vertexDescriptor.attributes[2].format = .float2
        vertexDescriptor.attributes[2].bufferIndex =  0
        vertexDescriptor.attributes[2].offset =       offset
        
        offset += float3.size
        
        vertexDescriptor.attributes[3].format = .float3
        vertexDescriptor.attributes[3].bufferIndex =  0
        vertexDescriptor.attributes[3].offset =       offset
        
        offset += float3.size
        
        vertexDescriptor.attributes[4].format = .float3
        vertexDescriptor.attributes[4].bufferIndex =  0
        vertexDescriptor.attributes[4].offset =       offset
        
        offset += float3.size
        
        vertexDescriptor.attributes[5].format = .float3
        vertexDescriptor.attributes[5].bufferIndex =  0
        vertexDescriptor.attributes[5].offset =       offset
        
        offset += float3.size
        //Joint Indices
        vertexDescriptor.attributes[6].format = .ushort4
        vertexDescriptor.attributes[6].bufferIndex =  0
        vertexDescriptor.attributes[6].offset =       offset
        
        offset += MemoryLayout<simd_ushort4>.size
        
        vertexDescriptor.attributes[7].format = .float4
        vertexDescriptor.attributes[7].bufferIndex =  0
        vertexDescriptor.attributes[7].offset =       offset
        
        
        
        
        vertexDescriptor.layouts[0].stride = Vertex.stride
        
    }
}
