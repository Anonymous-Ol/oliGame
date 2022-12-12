//
//  GameTime.swift
//  oliGame
//
//  Created by Oliver Crumrine on 11/27/22.
//

import MetalKit

class GameTime {
    private static var _totalGameTime: Float = 0.0
    private static var _deltaTime: Float = 0.0
    public static func UpdateTime(_deltaTime: Float){
        self._deltaTime = _deltaTime
        self._totalGameTime += _deltaTime
    }
}
extension GameTime {
    public static var TotalGameTime: Float{
        return self._totalGameTime
    }
    public static var DeltaTime: Float{
        return self._deltaTime
    }
}
