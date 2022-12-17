//
//  GameObject.swift
//  oliGame
//
//  Created by Oliver Crumrine on 11/26/22.
//

import MetalKit


class GameObject: Node{
    var renderPipelineStateType: RenderPipelineStateTypes { return .Basic }
    var shadowRenderPipelineStateType: RenderPipelineStateTypes { return .BasicShadow}
    var time: Float = 0;
    private var _modelConstants = ModelConstants()
    private var _material: Material? = nil
    private var _baseColorTextureType: TextureTypes = TextureTypes.None
    private var _normalMapTextureType: TextureTypes = TextureTypes.None
    private var _mesh: Mesh!
    
    init(name: String, meshType: MeshTypes){
        super.init(name: name)
        _mesh = Assets.Meshes[meshType]
    }

    override func update(deltaTime: Float){
        time += deltaTime
        _modelConstants.modelMatrix = self.modelMatrix
        super.update(deltaTime: deltaTime)
        
    }
}

extension GameObject: Renderable{
    func doRender(renderCommandEncoder: MTLRenderCommandEncoder) {
        renderCommandEncoder.setVertexBytes(&_modelConstants, length: ModelConstants.stride, index: 2)
        renderCommandEncoder.setRenderPipelineState(Graphics.RenderPipelineStates[renderPipelineStateType])
        renderCommandEncoder.setDepthStencilState(Graphics.DepthStencilStates[.Less])
        renderCommandEncoder.setFragmentSamplerState(Graphics.SamplerStates[.Linear], index: 0)
        
        
        _mesh.drawPrimitives(renderCommandEncoder,
                             baseColorTextureType: _baseColorTextureType,
                             material: _material,
                             normalMapTextureType: _normalMapTextureType)
    }
    func doShadowRender(renderCommandEncoder: MTLRenderCommandEncoder){
        renderCommandEncoder.setVertexBytes(&_modelConstants, length: ModelConstants.stride, index: 1)
        renderCommandEncoder.setRenderPipelineState(Graphics.RenderPipelineStates[shadowRenderPipelineStateType])
        renderCommandEncoder.setDepthStencilState(Graphics.DepthStencilStates[.Less])
        _mesh.drawPrimitives(renderCommandEncoder,
                             baseColorTextureType: _baseColorTextureType,
                             material: _material,
                             normalMapTextureType: _normalMapTextureType)
    }
}
///Material Properties
extension GameObject {

    
    public func useBaseColorTexture(_ textureType: TextureTypes){
        self._baseColorTextureType = textureType
    }
    public func useNormalMapTexture(_ textureType: TextureTypes){
        self._normalMapTextureType = textureType
    }
    public func useMaterial(_ material: Material){
        _material = material
    }

    
}

