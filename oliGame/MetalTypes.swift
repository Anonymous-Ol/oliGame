//
//  Types.swift
//  oliGame
//
//  Created by Oliver Crumrine on 11/26/22.
//
import simd
import MetalKit

public typealias float2 = SIMD2<Float>
public typealias float3 = SIMD3<Float>
public typealias float4 = SIMD4<Float>

//Multiple variable initizlization
prefix operator <-
prefix func <-<T>(_ v: T) -> (T, T) { (v, v) }
prefix func <-<T>(_ v: T) -> (T, T, T) { (v, v, v) }
prefix func <-<T>(_ v: T) -> (T, T, T, T) { (v, v, v, v) }
prefix func <-<T>(_ v: T) -> (T, T, T, T, T, T, T, T, T, T, T, T) { (v, v, v, v, v, v, v, v, v, v, v, v) }

protocol sizeable{

}

extension sizeable {
    static var size: Int{
        return MemoryLayout<Self>.size
    }
    static var stride: Int{
        return MemoryLayout<Self>.stride
    }
    static func stride(_ count: Int)->Int{
        return MemoryLayout<Self>.stride * count
    }
    static func size(_ count: Int)->Int{
        return MemoryLayout<Self>.size * count
    }
}

    enum planeTypes: Int{
        case TOP = 0
        case BOTTOM = 1
        case LEFT = 2
        case RIGHT = 3
        case NEARP = 4
        case FARP = 5
    }


extension UInt32:   sizeable{}
extension float3:   sizeable{}
extension Float:    sizeable{}
extension float4:   sizeable{}
extension float2:   sizeable{}
extension Int32:    sizeable{}
extension Bool:     sizeable{}
extension float4x4: sizeable{}
extension UInt:     sizeable{}

struct Vertex: sizeable{
    var position: float3
    var color: float4
    var textureCoordinate: float2
    var normal: float3
    
    var tangent: float3
    var bitangent: float3
    
    var indices: simd_ushort4
    var weights: float4
}

struct ModelConstants: sizeable{
    var modelMatrix = matrix_identity_float4x4
}
struct SceneConstants: sizeable {
    var totalGameTime: Float = 0
    var viewMatrix = matrix_identity_float4x4
    var skyViewMatrix = matrix_identity_float4x4
    var projectionMatrix = matrix_identity_float4x4
    var cameraPosition: float3 = float3(0,0,0)
    var lookAtPosition: float3 = float3(0,0,0)
}
struct Material: sizeable{
    var color = float4(0.8,0.8,0.8,1.0)
    var isLit: Bool = true
    var useBaseTexture: Bool = false
    var useNormalMapTexture: Bool = false
    
    var ambient: float3 =  float3(0.3, 0.3,0.3)
    var diffuse: float3 =  float3(1,1,1)
    var specular: float3 = float3(1,1,1)
    var shininess: Float = 50
    
    var reflectivity: Float = 0
}
struct LightData: sizeable{
    var position: float3 =    float3(0,0,0)
    var color: float3 =       float3(1,1,1)
    var brightness:           Float  =  1.0
    var ambientInensity:      Float  =  1.0
    var diffuseIntensity:     Float  =  1.0
    var specularIntensity:    Float  =  1.0
    var lookAtPosition:float3=float3(0,0,0)
    var orthoSize:            Float  =   35
    var near:                 Float  =  0.1
    var far:                  Float  = 1000
    
    
}


