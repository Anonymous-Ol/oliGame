//
//  Preferences.swift
//  oliGame
//
//  Created by Oliver Crumrine on 11/26/22.
//

import Foundation
import MetalKit

public enum ClearColors{
    static let White  = MTLClearColor(red:1.0, green:1.0, blue:1.0, alpha:1.0)
    static let Green  = MTLClearColor(red:0.22, green:0.55, blue:0.34, alpha: 1.0)
    static let Grey   = MTLClearColor(red:0.5, green: 0.5, blue: 0.5, alpha: 1.0)
    static let Black  = MTLClearColor(red:0, green: 0, blue: 0, alpha: 1)
    static let Orange = MTLClearColor(red: 1.0, green: 0.5, blue: 0.25, alpha: 1.0)
    static let DarkGrey = MTLClearColor(red:0.02, green: 0.02, blue: 0.02, alpha: 1.0)
    static let SkyBlue = MTLClearColor(red:0.3, green: 0.4, blue: 0.8, alpha: 1.0)
}

class Preferences {
    public static var clearColor: MTLClearColor = ClearColors.SkyBlue
    public static var MainPixelFomat: MTLPixelFormat = MTLPixelFormat.bgra8Unorm_srgb
    public static var MainDethPixelFomat: MTLPixelFormat = MTLPixelFormat.depth32Float
    public static var StartingSceneType: SceneTypes = SceneTypes.Forest
}
