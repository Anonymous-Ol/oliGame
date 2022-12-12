//
//  Keyboard.swift
//  oliGame
//
//  Created by Oliver Crumrine on 11/26/22.
//

import MetalKit
class Keyboard{
    private static var KEY_COUNT: Int = 256
    private static var keys = [Bool].init(repeating: false, count: KEY_COUNT)
    
    public static func SetKeyPressed(_ keyCode: UInt16, isOn: Bool){
        keys[Int(keyCode)] = isOn
    }
    
    public static func IsKeyPressed(_ keyCode: Keycode) -> Bool{
        return keys[Int(keyCode.rawValue)]
    }
}
