//
//  Renderable.swift
//  oliGame
//
//  Created by Oliver Crumrine on 11/26/22.
//

import MetalKit

protocol Renderable{
    func doRender(renderCommandEncoder: MTLRenderCommandEncoder)
    func doShadowRender(renderCommandEncoder: MTLRenderCommandEncoder)
    func doReflectionRender()
    func doCubeMapRender(renderCommandEncoder: MTLRenderCommandEncoder)
    func setupRender(cameraPos: float3) -> setupRenderReturn
}

struct setupRenderReturn{
    var isTransparent: Bool = false
    var distanceFromCamera: Float = 0
    var doRenderFunction: (MTLRenderCommandEncoder)->()
    var name: String = ""
}
