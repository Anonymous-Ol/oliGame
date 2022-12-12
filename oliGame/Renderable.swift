//
//  Renderable.swift
//  oliGame
//
//  Created by Oliver Crumrine on 11/26/22.
//

import MetalKit

protocol Renderable{
    func doRender(renderCommandEncoder: MTLRenderCommandEncoder)
}
