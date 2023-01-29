//
//  DepthStencilStateLibrary.swift
//  oliGame
//
//  Created by Oliver Crumrine on 11/26/22.
//

import MetalKit

enum DepthStencilStateTypes{
    case Less
    case More
}

class DepthStencilStateLibrary: Library<DepthStencilStateTypes, MTLDepthStencilState>{
    private var _library: [DepthStencilStateTypes: DepthStencilState] = [:]
    
    override func fillLibrary() {
        _library.updateValue(Less_DepthStencilState(), forKey: .Less)
        _library.updateValue(More_DepthStencilState(), forKey: .More)
    }
    
    override subscript(type: DepthStencilStateTypes) -> MTLDepthStencilState {
        return _library[type]!.depthStencilState
    }
    

}
protocol DepthStencilState {
    var depthStencilState: MTLDepthStencilState! { get }
}

class Less_DepthStencilState: DepthStencilState{
    var depthStencilState: MTLDepthStencilState!
    
    init(){
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.isDepthWriteEnabled = true
        depthStencilDescriptor.depthCompareFunction = .less
        depthStencilState = Engine.Device.makeDepthStencilState(descriptor: depthStencilDescriptor)
    }
}
class More_DepthStencilState: DepthStencilState{
    var depthStencilState: MTLDepthStencilState!
    
    init(){
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.isDepthWriteEnabled = true
        depthStencilDescriptor.depthCompareFunction = .greater
        depthStencilState = Engine.Device.makeDepthStencilState(descriptor: depthStencilDescriptor)
    }
}
