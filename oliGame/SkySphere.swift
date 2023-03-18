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
    init(s: GameObjectOutline, skySphereTextureType: TextureTypes){
        super.init(name: s._name)
        createBuffers(size: 4)
        _mesh = s._mesh
        self._modelConstants = s._modelConstants
        self._material = s._material
        self._baseColorTextureType = s._baseColorTextureType
        self.cubeMapTexture = s.cubeMapTexture
        self._usePreRenderedReflections = s._usePreRenderedReflections
        self.setName(s._name)
        _skySphereTextureType = skySphereTextureType
        
        //useBaseColorTexture(_skySphereTextureType)
        setCullable(false)
        setScale(500)
        for child in s._children{
            var mutableChild = child
            mutableChild._name = "SkySphere"
            let childSkySphereGameObject = SkySphere(s: mutableChild, skySphereTextureType: skySphereTextureType, true: true)
            self.addChild(childSkySphereGameObject)
        }
    }
    init(s: GameObjectOutline, skySphereTextureType: TextureTypes, true: Bool){
        super.init(name: s._name)
        _mesh = s._mesh
        self._modelConstants = s._modelConstants
        self._material = s._material
        self._baseColorTextureType = s._baseColorTextureType
        self.cubeMapTexture = s.cubeMapTexture
        self._usePreRenderedReflections = s._usePreRenderedReflections
        self.setName(s._name)
        _skySphereTextureType = skySphereTextureType
        
        //useBaseColorTexture(_skySphereTextureType)
        setCullable(false)
        for child in s._children{
            var mutableChild = child
            mutableChild._name = "SkySphere"
            let childSkySphereGameObject = SkySphere(s: mutableChild, skySphereTextureType: skySphereTextureType, true: true)
            self.addChild(childSkySphereGameObject)
        }
    }
//    convenience init(skySphereTextureType: TextureTypes, s: GameObjectOutline){
//        var modifiableS = s
//        
//        modifiableS._name = "SkySphere"
//        
//        _skySphereTextureType = skySphereTextureType
//        
//        useBaseColorTexture(_skySphereTextureType)
//        
//        setScale(500)
//        
//        self.init(s: modifiableS)
//
//    }
    override func setupRender(renderCommandEncoder : MTLRenderCommandEncoder) {
        renderCommandEncoder.setFragmentTexture(Assets.Textures[_skySphereTextureType], index: 10)
        super.setupRender(renderCommandEncoder: renderCommandEncoder)
    }
    override func cubeMapRender(renderCommandEncoder: MTLRenderCommandEncoder) {
        renderCommandEncoder.setFragmentTexture(Assets.Textures[_skySphereTextureType], index: 10)
        super.cubeMapRender(renderCommandEncoder: renderCommandEncoder)
    }
}
