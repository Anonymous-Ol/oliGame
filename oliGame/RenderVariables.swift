//
//  ReflectionVariables.swift
//  oliGame
//
//  Created by Oliver Crumrine on 2/12/23.
//

import Foundation

class RenderVariables{
    public static var currentReflectionIndex: Int32 = 0
    public static var lastReflectionIndex: Int32 = 0
    public static var reflectionPositions: [float3] = []
    public static var bufferLength: Int32 = 6
    public static var lastBufferLength: Int32 = 0
    public static var stuffToRender: [setupRenderReturn] = []
}
