//
//  Engine.swift
//  oliGame
//
//  Created by Oliver Crumrine on 11/26/22.
//

import Foundation
import MetalKit

class Engine{
    public static var Device: MTLDevice!
    public static var CommandQueue: MTLCommandQueue!
    public static var DefaultLibrary: MTLLibrary!
    
    public static func Ignite(device: MTLDevice){
        self.Device = device
        self.DefaultLibrary = Device.makeDefaultLibrary()
        self.CommandQueue = Device.makeCommandQueue()
        
        Graphics.initialize()
        Assets.initialize()
        
        
    }

}
