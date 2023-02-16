//
//  SamplerStateLibrary.swift
//  oliGame
//
//  Created by Oliver Crumrine on 11/27/22.
//

import MetalKit

enum SamplerStateTypes{
    case None
    case Linear
}
class SamplerStateLibrary: Library<SamplerStateTypes, MTLSamplerState> {
    private var library: [SamplerStateTypes : SamplerState] = [:]
    
    override func fillLibrary(){
        library.updateValue(Linear_SamperState(), forKey: .Linear)
    }
    override subscript(type: SamplerStateTypes) -> MTLSamplerState {
        return (library[type]?.samplerState!)!
    }
}

protocol SamplerState{
    var name: String {get}
    var samplerState: MTLSamplerState! {get}
}

class Linear_SamperState: SamplerState{
    var name: String = "Linear Sampler State"
    var samplerState: MTLSamplerState!
    init(){
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.minFilter = .linear
        samplerDescriptor.magFilter = .linear
        samplerDescriptor.mipFilter = .linear
        samplerDescriptor.normalizedCoordinates = true
        samplerDescriptor.label = name

        samplerState = Engine.Device.makeSamplerState(descriptor: samplerDescriptor)
    }
}
