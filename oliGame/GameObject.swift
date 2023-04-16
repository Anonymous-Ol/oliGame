//
//  GameObject.swift
//  oliGame
//
//  Created by Oliver Crumrine on 11/26/22.
//

import MetalKit


class GameObject: Node{
    var renderPipelineStateType: RenderPipelineStateTypes { return .Basic }
    var skinnedRenderPipelineStateType: RenderPipelineStateTypes { return .BasicSkinned }
    var shadowRenderPipelineStateType: RenderPipelineStateTypes { return .BasicShadow}
    var cubeMapRenderPipelineStateType: RenderPipelineStateTypes { return .BasicCubemap}
    var skinnedShadowRenderPipelineStateType: RenderPipelineStateTypes { return .SkinnedShadow }
    var skinnedCubemapRenderPipelineStateType: RenderPipelineStateTypes { return .SkinnedCubemap }
    var time: Float = 0
    var _modelConstants = ModelConstants()
    var _material: Material? = nil
    var _baseColorTextureType: TextureTypes = TextureTypes.None
    var _normalMapTextureType: TextureTypes = TextureTypes.None
            var  cubeMapTexture: MTLTexture! = nil
            var _mesh: Mesh!
    var indentifier = 0
    private var _reflectionIndex: Int! = nil
    var _usePreRenderedReflections: Bool = false
    var _jointsBuffer: MTLBuffer!
    var bufferMade: Bool = false
    
    var outline: GameObjectOutline{
        var outline: GameObjectOutline = GameObjectOutline()
        outline._modelConstants = self._modelConstants
        outline._usePreRenderedReflections = self._usePreRenderedReflections
        outline.cubeMapTexture = self.cubeMapTexture
        outline._baseColorTextureType = self._baseColorTextureType
        outline._material = self._material
        outline._topLevelObject = self.topLevelObject
        outline._mesh = self._mesh
        outline._name = self.getName()
        for _child in _children{
            if let childGameObject = _child as? GameObject{
                outline._children.append(childGameObject.outline)
            }
        }
        return outline
    }

    
    init(name: String, meshType: MeshTypes){
        super.init(name: name)
        _mesh = Assets.Meshes[meshType]
    }
    override init(name: String){
        super.init(name: name)
    }
    func createBuffers(size: Int){
        _jointsBuffer = Engine.Device.makeBuffer(length: ModelConstants.stride(size), options: [])
    }
    func makeCollisionHappen(){
        print(self.getName())
        print("Collision!!!!!!")
        print(self.getID())
    }
    
    init(outline: GameObjectOutline){
        super.init(name: outline._name)
        _mesh = outline._mesh
        self._modelConstants = outline._modelConstants
        self._material = outline._material
        self._baseColorTextureType = outline._baseColorTextureType
        self.cubeMapTexture = outline.cubeMapTexture
        self._usePreRenderedReflections = outline._usePreRenderedReflections
        self.topLevelObject = outline._topLevelObject
        self.setName(outline._name)
        for child in outline._children{
            let childGameObject = GameObject(outline: child)
            self.addChild(childGameObject)
        }
    }
    func returnSelf(name: String) -> GameObject{
        return GameObject(name: name)
    }
    func findIndentifier(indentifier: Int) -> GameObject?{
        let recursive = true
        if let child = _children.first(where: { ($0 as? GameObject)?.indentifier == indentifier } ) {
            return child as? GameObject
        } else if recursive {
            for child in _children {
                if let grandchild = (child as? GameObject)?.findIndentifier(indentifier: indentifier) {
                    return grandchild
                }
            }
        }
        return nil
    }
    func addAllVertices(object: Int){
        if(object == 1){
        }
    }
    override func update(deltaTime: Float){
        time += deltaTime
        _modelConstants.modelMatrix = self.modelMatrix
        camFrustum = SceneManager.currentScene._cameraManager.currentCamera.cameraFrustum
        doCullTest()
        if(self.topLevelObject){
            
            let sphereStuff: SphereParameters = SphereParameters(centerPosition: self.getModelMatrixPosition(), sphereRadius: self.radius, pgo: self)
            SphereCollision.addGameObject(object: sphereStuff)
        }
        super.update(deltaTime: deltaTime)
    }

}

extension GameObject: Renderable{
    func doCubeMapRender(renderCommandEncoder: MTLRenderCommandEncoder) {
        if(!self.preventRender){
            renderCommandEncoder.setVertexBytes(&_modelConstants, length: ModelConstants.stride, index: 2)
            if(self.skinner != nil){
                RenderUtilities.advancedSetRenderPipelineState(pipelineState: skinnedCubemapRenderPipelineStateType, commandEncoder: renderCommandEncoder)
            }else{
                RenderUtilities.advancedSetRenderPipelineState(pipelineState: cubeMapRenderPipelineStateType,         commandEncoder: renderCommandEncoder)
            }
            renderCommandEncoder.setDepthStencilState(Graphics.DepthStencilStates[.Less])
            renderCommandEncoder.setFragmentSamplerState(Graphics.SamplerStates[.Linear], index: 0)
            if(self.skinner != nil){
                if(!bufferMade){
                    createBuffers(size: 4)
                    bufferMade = true
                }
                if((self.skinner?.skeleton.getRequiredBufferLength())! > _jointsBuffer.length/ModelConstants.size){
                    createBuffers(size: (self.skinner?.skeleton.getRequiredBufferLength())!)
                }
                self.skinner?.skeleton.copyTransforms(into: _jointsBuffer)

                renderCommandEncoder.setVertexBuffer(_jointsBuffer, offset: 0, index: 4)
            }
            if(_mesh != nil){
                _mesh.drawCubemapPrimitives(renderCommandEncoder,
                                            baseColorTextureType: _baseColorTextureType,
                                            material: _material,
                                            normalMapTextureType: _normalMapTextureType)
            }
        }
    }
    
    func doRender(renderCommandEncoder: MTLRenderCommandEncoder) {
        if(!self.preventRender && !self.culled || !self.isCullable()){
            renderCommandEncoder.setVertexBytes(&_modelConstants, length: ModelConstants.stride, index: 2)
            if(self.skinner != nil){
                RenderUtilities.advancedSetRenderPipelineState(pipelineState: skinnedRenderPipelineStateType, commandEncoder: renderCommandEncoder)
            }else{
                RenderUtilities.advancedSetRenderPipelineState(pipelineState: renderPipelineStateType,        commandEncoder: renderCommandEncoder)
            }
            renderCommandEncoder.setDepthStencilState(Graphics.DepthStencilStates[.Less])
            renderCommandEncoder.setFragmentSamplerState(Graphics.SamplerStates[.Linear], index: 0)
            if(_reflectionIndex == nil){
                _reflectionIndex = 0
            }else{
                _reflectionIndex += 1
            }
            if(self.skinner != nil){
                if(!bufferMade){
                    createBuffers(size: 4)
                    bufferMade = true
                }
                if((self.skinner?.skeleton.getRequiredBufferLength())! > _jointsBuffer.length/ModelConstants.size){
                    createBuffers(size: (self.skinner?.skeleton.getRequiredBufferLength())!)
                }
                self.skinner?.skeleton.copyTransforms(into: _jointsBuffer)

                renderCommandEncoder.setVertexBuffer(_jointsBuffer, offset: 0, index: 4)
            }
            renderCommandEncoder.setFragmentBytes(&_reflectionIndex, length: Int32.stride, index: 5)
            renderCommandEncoder.setFragmentBytes(&_usePreRenderedReflections, length: Bool.stride, index: 6)
            if(_mesh != nil){
                _mesh.drawPrimitives(renderCommandEncoder,
                                     baseColorTextureType: _baseColorTextureType,
                                     material: _material,
                                     normalMapTextureType: _normalMapTextureType,
                                     cubeMapTexture: cubeMapTexture)
            }
            _reflectionIndex = nil
        }
    }
    func doShadowRender(renderCommandEncoder: MTLRenderCommandEncoder){
        renderCommandEncoder.setVertexBytes(&_modelConstants, length: ModelConstants.stride, index: 1)
        if(self.skinner != nil){
            RenderUtilities.advancedSetRenderPipelineState(pipelineState: skinnedShadowRenderPipelineStateType, commandEncoder: renderCommandEncoder)
        }else{
            RenderUtilities.advancedSetRenderPipelineState(pipelineState: shadowRenderPipelineStateType, commandEncoder: renderCommandEncoder)
        }
        renderCommandEncoder.setDepthStencilState(Graphics.DepthStencilStates[.Less])
        if(self.skinner != nil){
            if(!bufferMade){
                createBuffers(size: 4)
                bufferMade = true
            }
            if((self.skinner?.skeleton.getRequiredBufferLength())! > _jointsBuffer.length/ModelConstants.size){
                createBuffers(size: (self.skinner?.skeleton.getRequiredBufferLength())!)
            }
            self.skinner?.skeleton.copyTransforms(into: _jointsBuffer)

            renderCommandEncoder.setVertexBuffer(_jointsBuffer, offset: 0, index: 4)
        }
        if(_mesh != nil){
            _mesh.drawPrimitives(renderCommandEncoder,
                                 baseColorTextureType: _baseColorTextureType,
                                 material: _material,
                                 normalMapTextureType: _normalMapTextureType)
        }
    }
    func setupRender(cameraPos: float3) -> setupRenderReturn {
        var gameObjectSetupRenderReturn: setupRenderReturn = setupRenderReturn(doRenderFunction: doRender(renderCommandEncoder:))
        if(_mesh != nil){
            gameObjectSetupRenderReturn.isTransparent = _mesh.queryTransparent() || _material?.color.w ?? 1 < 1
        }else{
            gameObjectSetupRenderReturn.isTransparent = false
        }
        gameObjectSetupRenderReturn.distanceFromCamera = sqrt(pow((getModelMatrixPosition().x-cameraPos.x), 2) + pow((getModelMatrixPosition().y-cameraPos.y), 2) + pow((getModelMatrixPosition().z-cameraPos.z), 2))
        gameObjectSetupRenderReturn.name = self.getName()
        return gameObjectSetupRenderReturn
    }
    func doReflectionRender() {
        self.preventRender = true
        if(_mesh != nil){
            _reflectionIndex = _mesh.renderReflections(position: self.getModelMatrixPosition())
        }
        self.preventRender = false
    }
    func doCullTest(){
        if(!camFrustum.sphereInFrustum(p: self.getModelMatrixPosition(), radius: self.radius * reduce_max(getModelMatrixScale()))){
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

struct GameObjectOutline{
    var _modelConstants = ModelConstants()
    var _material: Material? = nil
    var _baseColorTextureType: TextureTypes = TextureTypes.None
    var _normalMapTextureType: TextureTypes = TextureTypes.None
    var  cubeMapTexture: MTLTexture! = nil
    var _mesh: Mesh!
    var _skeleton: MDLSkeleton!
    var _topLevelObject: Bool = false
    var _usePreRenderedReflections: Bool = false
    var _name: String = "Node"
    var _children: [GameObjectOutline] = []
}

