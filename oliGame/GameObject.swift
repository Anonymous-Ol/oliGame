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
    var cubeMapRenderPipelineStateType: RenderPipelineStateTypes { return .BasicCubemap}
    var time: Float = 0
    private var _modelConstants = ModelConstants()
    private var _material: Material? = nil
    private var _baseColorTextureType: TextureTypes = TextureTypes.None
    private var _normalMapTextureType: TextureTypes = TextureTypes.None
            var  cubeMapTexture: MTLTexture! = nil
    private var _mesh: Mesh!
    private var _reflectionIndex: Int! = nil
    private var _usePreRenderedReflections: Bool = false
    
    init(name: String, meshType: MeshTypes){
        super.init(name: name)
        _mesh = Assets.Meshes[meshType]
    }

    override func update(deltaTime: Float){
        time += deltaTime
        _modelConstants.modelMatrix = self.modelMatrix
        camFrustum = SceneManager.currentScene._cameraManager.currentCamera.cameraFrustum
        doCullTest()
        super.update(deltaTime: deltaTime)
    }

}

extension GameObject: Renderable{
    func doCubeMapRender(renderCommandEncoder: MTLRenderCommandEncoder) {
        if(!self.preventRender){
            renderCommandEncoder.setVertexBytes(&_modelConstants, length: ModelConstants.stride, index: 2)
            if(Renderer.currnetPipelineState != cubeMapRenderPipelineStateType){
                renderCommandEncoder.setRenderPipelineState(Graphics.RenderPipelineStates[cubeMapRenderPipelineStateType])
                Renderer.currnetPipelineState = cubeMapRenderPipelineStateType
            }
            renderCommandEncoder.setDepthStencilState(Graphics.DepthStencilStates[.Less])
            renderCommandEncoder.setFragmentSamplerState(Graphics.SamplerStates[.Linear], index: 0)
            
            
            _mesh.drawCubemapPrimitives(renderCommandEncoder,
                                        baseColorTextureType: _baseColorTextureType,
                                        material: _material,
                                        normalMapTextureType: _normalMapTextureType)
        }
    }
    
    func doRender(renderCommandEncoder: MTLRenderCommandEncoder) {
        if(!self.preventRender && !self.culled || !self.cullable){
            renderCommandEncoder.setVertexBytes(&_modelConstants, length: ModelConstants.stride, index: 2)
            if(Renderer.currnetPipelineState != renderPipelineStateType){
                renderCommandEncoder.setRenderPipelineState(Graphics.RenderPipelineStates[renderPipelineStateType])
                Renderer.currnetPipelineState = renderPipelineStateType
            }
            renderCommandEncoder.setDepthStencilState(Graphics.DepthStencilStates[.Less])
            renderCommandEncoder.setFragmentSamplerState(Graphics.SamplerStates[.Linear], index: 0)
            if(_reflectionIndex == nil){
                _reflectionIndex = 0
            }else{
                _reflectionIndex += 1
            }
            renderCommandEncoder.setFragmentBytes(&_reflectionIndex, length: Int32.stride, index: 5)
            renderCommandEncoder.setFragmentBytes(&_usePreRenderedReflections, length: Bool.stride, index: 6)
            _mesh.drawPrimitives(renderCommandEncoder,
                                 baseColorTextureType: _baseColorTextureType,
                                 material: _material,
                                 normalMapTextureType: _normalMapTextureType,
                                 cubeMapTexture: cubeMapTexture)
            _reflectionIndex = nil
        }
    }
    func doShadowRender(renderCommandEncoder: MTLRenderCommandEncoder){
        renderCommandEncoder.setVertexBytes(&_modelConstants, length: ModelConstants.stride, index: 1)
        if(Renderer.currnetPipelineState != shadowRenderPipelineStateType){
            renderCommandEncoder.setRenderPipelineState(Graphics.RenderPipelineStates[shadowRenderPipelineStateType])
            Renderer.currnetPipelineState = shadowRenderPipelineStateType
        }
        renderCommandEncoder.setDepthStencilState(Graphics.DepthStencilStates[.Less])
        _mesh.drawPrimitives(renderCommandEncoder,
                             baseColorTextureType: _baseColorTextureType,
                             material: _material,
                             normalMapTextureType: _normalMapTextureType)
    }
    func doReflectionRender() {
        self.preventRender = true
        _reflectionIndex = _mesh.renderReflections(position: self.getPosition())
        self.preventRender = false
    }
    func doCullTest(){
        if(!camFrustum.sphereInFrustum(p: self.getPosition(), radius: self.radius)){
            culled = true
        }else{
            culled = false
        }
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
    public func usePredeterminedCubeMap(_ trueOrFalse: Bool){
        _usePreRenderedReflections = trueOrFalse
    }

    
}

