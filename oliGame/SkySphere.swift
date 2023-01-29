//
//  SkySphere.swift
//  oliGame
//
//  Created by Oliver Crumrine on 12/1/22.
//

import MetalKit
class SkySphere: GameObject{
    override var renderPipelineStateType: RenderPipelineStateTypes { return .SkySphere }
    override var cubeMapRenderPipelineStateType: RenderPipelineStateTypes { return .SkySphereCubemap }
    private var _skySphereTextureType: TextureTypes!
    init(skySphereTextureType: TextureTypes){
        super.init(name: "SkySphere", meshType: .SkySphere)
        
        _skySphereTextureType = skySphereTextureType
        
        setScale(500)
        
        useBaseColorTexture(_skySphereTextureType)
    }
    override func render(renderCommandEncoder: MTLRenderCommandEncoder) {
        renderCommandEncoder.setFragmentTexture(Assets.Textures[_skySphereTextureType], index: 10)
        super.render(renderCommandEncoder: renderCommandEncoder)
    }
    override func cubeMapRender(renderCommandEncoder: MTLRenderCommandEncoder) {
        renderCommandEncoder.setFragmentTexture(Assets.Textures[_skySphereTextureType], index: 10)
        super.cubeMapRender(renderCommandEncoder: renderCommandEncoder)
    }
}
