//
//  ColorUtil.swift
//  oliGame
//
//  Created by Oliver Crumrine on 11/26/22.
//

import simd

class ColorUtils{
    public static var randomColor: float4{
        return float4(Float.randomZeroToOne, Float.randomZeroToOne, Float.randomZeroToOne, 1.0)
    }
}
