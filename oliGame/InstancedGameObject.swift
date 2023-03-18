//
//  InstancedGameObject.swift
//  oliGame
//
//  Created by Oliver Crumrine on 11/27/22.
//

import MetalKit

class InstancedGameObject: Node{
            var _mesh: Mesh!
    private var _material = Material()
    
    internal var _nodes: [Node] = []
    private var _modelConstantsBuffer: MTLBuffer!
    private var _reflectionsBuffer: MTLBuffer!
    private var _reflectionPosition: float3
    private var _reflectionIndex: Int! = nil
    private var _usePreRenderedReflections: Bool = false

    
    init(name: String, meshType: MeshTypes, instanceCount: Int){
        self._reflectionPosition = float3(0,0,0)
        super.init(name: name)
        self._mesh = Assets.Meshes[meshType]
        self._mesh.setInstanceCount(instanceCount)
        self.generateInstances(instanceCount)
        self.createBuffers(instanceCount)
        
    }
    override init(name: String){
        self._reflectionPosition = float3(0,0,0)
        super.init(name: name)
    }
    func postInit(instanceCount: Int){
        if(_mesh != nil){
            self._mesh.setInstanceCount(instanceCount)
        }
        self.generateInstances(instanceCount)
        self.createBuffers(instanceCount)
        for child in self._children{
            if let IGO = child as? InstancedGameObject{
                IGO.postInit(instanceCount: instanceCount)
            }
        }
    }
    func updateNodes(_ updateNodeFunction: (Node, Int)->()){
        for (index, node) in _nodes.enumerated(){
            updateNodeFunction(node, index)
        }
        for child in _children{
            if let instancedChild = child as? InstancedGameObject{
                instancedChild.updateNodes(updateNodeFunction)
            }
        }
    }
    func generateInstances(_ instanceCount: Int){
        for _ in 0..<instanceCount{
            _nodes.append(Node(name: "\(getName())_Instanced_Node"))
        }
    }
    func createBuffers(_ instanceCount: Int){
        _modelConstantsBuffer = Engine.Device.makeBuffer(length: ModelConstants.stride(instanceCount), options: [])
        _reflectionsBuffer    = Engine.Device.makeBuffer(length: ModelConstants.stride(instanceCount), options: [])
    }
    func updateNodeList(){
        var pointer = _modelConstantsBuffer.contents().bindMemory(to: ModelConstants.self, capacity: _nodes.count)
        var allPointer = _reflectionsBuffer.contents().bindMemory(to: ModelConstants.self, capacity: _nodes.count)
        camFrustum = SceneManager.currentScene._cameraManager.currentCamera.cameraFrustum
        for node in _nodes{
            if(doCullTest(p: node.getModelMatrixPosition(), radius: node.radius)){
                node.culled = true
            }else{
                node.culled = false
            }
            if(!node.culled){
                pointer.pointee.modelMatrix = node.modelMatrix
                pointer = pointer.advanced(by: 1)
            }
            allPointer.pointee.modelMatrix = node.modelMatrix
            allPointer = allPointer.advanced(by: 1)

        }
    }
    override func update(deltaTime: Float){
        updateNodeList()
        
        super.update(deltaTime: deltaTime)
    }

    
}
extension InstancedGameObject: Renderable{
    func doCubeMapRender(renderCommandEncoder: MTLRenderCommandEncoder) {
        if(!self.preventRender){
            RenderUtilities.advancedSetRenderPipelineState(pipelineState: .InstancedCubemap, commandEncoder: renderCommandEncoder)
            
            renderCommandEncoder.setDepthStencilState(Graphics.DepthStencilStates[.Less])
            
            renderCommandEncoder.setVertexBuffer(_reflectionsBuffer, offset: 0, index: 2)
            
            renderCommandEncoder.setFragmentBytes(&_material, length: Material.stride, index: 1)
            if(_mesh != nil){
                _mesh.drawCubemapPrimitives(renderCommandEncoder)
            }
        }
    }
    
    
    func doRender(renderCommandEncoder: MTLRenderCommandEncoder){
        if(!self.preventRender){
            RenderUtilities.advancedSetRenderPipelineState(pipelineState: .Instanced, commandEncoder: renderCommandEncoder)
            
            //Depth Stencil
            renderCommandEncoder.setDepthStencilState(Graphics.DepthStencilStates[.Less])
            
            //Vertex Shading
            renderCommandEncoder.setVertexBuffer(_modelConstantsBuffer, offset: 0, index: 2)
            
            
            //A zero passed to the fragment shader will indicate no reflections
            if(_reflectionIndex == nil){
                _reflectionIndex = 0
            }else{
                _reflectionIndex += 1
            }
            renderCommandEncoder.setFragmentBytes(&_reflectionIndex, length: Int32.stride, index: 5)
            renderCommandEncoder.setFragmentBytes(&_usePreRenderedReflections, length: Bool.stride, index: 6)
            
            
            //Use the fragment shader
            renderCommandEncoder.setFragmentBytes(&_material, length: Material.stride, index: 1)

            //Draw the mesh
            if(_mesh != nil){
                _mesh.drawPrimitives(renderCommandEncoder)
            }
            
            _reflectionIndex = nil
        }
    }
    func doShadowRender(renderCommandEncoder: MTLRenderCommandEncoder){
        RenderUtilities.advancedSetRenderPipelineState(pipelineState: .InstancedShadow, commandEncoder: renderCommandEncoder)

        //Depth Stencil
        renderCommandEncoder.setDepthStencilState(Graphics.DepthStencilStates[.Less])
        
        //Vertex Shading
        renderCommandEncoder.setVertexBuffer(_reflectionsBuffer, offset: 0, index: 1)
        
        //Draw the mesh
        if(_mesh != nil){
            _mesh.drawPrimitives(renderCommandEncoder)
        }
    }
    func setupRender(cameraPos: float3) -> setupRenderReturn {
        var gameObjectSetupRenderReturn: setupRenderReturn = setupRenderReturn(doRenderFunction: doRender(renderCommandEncoder:))
        if(_mesh != nil){
            gameObjectSetupRenderReturn.isTransparent = _mesh.queryTransparent() || _material.color.w < 1
        }else{
            gameObjectSetupRenderReturn.isTransparent = false
        }
        gameObjectSetupRenderReturn.distanceFromCamera = sqrt(pow((getModelMatrixPosition().x-cameraPos.x), 2) + pow((getModelMatrixPosition().y-cameraPos.y), 2) + pow((getModelMatrixPosition().z-cameraPos.z), 2))
        gameObjectSetupRenderReturn.name = self.getName()
        return gameObjectSetupRenderReturn
    }
    // WARNING: This could get out of hand if there are too many objects to be reflectionrendered
    func doReflectionRender() {
        self.preventRender = true
        if(_mesh != nil){
            _reflectionIndex = _mesh.renderReflections(position: _reflectionPosition)
        }
        self.preventRender = false
    }
    func doCullTest(p: float3, radius: Float) -> Bool{
            if(!camFrustum.sphereInFrustum(p: p, radius: radius)){
                return true
            }else{
                return false
            }
    }

}

extension InstancedGameObject {
    public func setColor(_ color: float4){
        self._material.color = color
    }
    public func setReflectionPosition(_ position: float3){
        self._reflectionPosition = position
    }
    public func usePredeterminedCubeMap(_ trueOrFalse: Bool){
        _usePreRenderedReflections = trueOrFalse
    }
}
