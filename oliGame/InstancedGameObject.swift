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
    
    internal var _nodes: [jointNode] = []
    private var _modelConstantsBuffer: MTLBuffer!
    private var _jointsBuffer: MTLBuffer!
    private var _allJointsBuffer: MTLBuffer!
    private var _jointArray: [ModelConstants] = []
    private var _allJointsArray: [ModelConstants] = []
    private var _jointArrayLength: [UInt] = []
    private var _reflectionsBuffer: MTLBuffer!
    private var _reflectionPosition: float3
    private var _reflectionIndex: Int! = nil
    private var _usePreRenderedReflections: Bool = false
    private var jointBufferMade = false
    var referenceJointLength: UInt = UInt(28)
    var nodesAreSkinned: Bool = false
    var indentifier = 0
    
    init(name: String, meshType: MeshTypes, instanceCount: Int){
        self._reflectionPosition = float3(0,0,0)
        super.init(name: name)
        self._mesh = Assets.Meshes[meshType]
        self._mesh.setInstanceCount(instanceCount)
        self.generateModelConstantInstances(instanceCount)
        self.createBuffers(instanceCount)
        
    }
    override func printChildren(level: Int = 0){
        for _ in 0...level*4{
            print(" ", terminator: "")
        }
        print(self.getName())
        for _ in 0...level*4{
            print(" ", terminator: "")
        }
        print("nodes: ")
        for node in _nodes{
            for _ in 0...level*4{
                print(" ", terminator: "")
            }
            print(node.name)
            for _ in 0...level*4{
                print(" ", terminator: "")
            }
            if(node.skinner != nil){
                print(node.skinner.skeleton.name)
            }else{
                print("nil")
            }
        }
        for _ in 0...level*4{
            print(" ", terminator: "")
        }
        print("end nodes")
        for _ in 0...level*4{
            print(" ", terminator: "")
        }
        print("children:")
        for child in _children{
            child.printChildren(level: level + 1)
        }
        for _ in 0...level*4{
            print(" ", terminator: "")
        }
        print("done")
    }
    override init(name: String){
        self._reflectionPosition = float3(0,0,0)
        super.init(name: name)
    }
    func postInit(instanceCount: Int, parents: [jointNode] = []){
        if(_mesh != nil){
            self._mesh.setInstanceCount(instanceCount)
        }
        self.generateModelConstantInstances(instanceCount, parents: parents)
        self.createBuffers(instanceCount)
        for child in self._children{
            if let IGO = child as? InstancedGameObject{
                IGO.postInit(instanceCount: instanceCount, parents: _nodes)
            }
        }
    }
    func findIndentifier(indentifier: Int) -> InstancedGameObject?{
        let recursive = true
        if let child = _children.first(where: { ($0 as? InstancedGameObject)?.indentifier == indentifier } ) {
            return child as? InstancedGameObject
        } else if recursive {
            for child in _children {
                if let grandchild = (child as? InstancedGameObject)?.findIndentifier(indentifier: indentifier) {
                    return grandchild
                }
            }
        }
        return nil
    }
    func updateNodes(_ updateNodeFunction: (jointNode, Int)->()){
        for (index, node) in _nodes.enumerated(){
            updateNodeFunction(node, index)
        }
        for child in _children{
            if let instancedChild = child as? InstancedGameObject{
                instancedChild.updateNodes(updateNodeFunction)
            }
        }
    }
    func continualUpdateNodes(_ updateNodeFunction: @escaping (jointNode, Int)->(), time: Int){
        DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: DispatchTimeInterval.seconds(time)), execute: {
            self.updateNodes(updateNodeFunction)
            self.continualUpdateNodes(updateNodeFunction, time: time)
        })
    }
    func generateModelConstantInstances(_ instanceCount: Int, parents: [jointNode] = []){
        for i in 0..<instanceCount{
            let newNode = jointNode()
            newNode.skinner = self.skinner
            newNode.name = "\(getName())_Instanced_Node_\(i)"
            if(parents.count > i){
                newNode.parentNode = parents[i]
            }
            _nodes.append(newNode)
        }
    }
    func setTopLevelObjects(){
        for _node in _nodes {
            _node.topLevelObject = true
        }
    }
    func createBuffers(_ instanceCount: Int){
        _modelConstantsBuffer = Engine.Device.makeBuffer(length: ModelConstants.stride(instanceCount), options: [])
        _reflectionsBuffer    = Engine.Device.makeBuffer(length: ModelConstants.stride(instanceCount), options: [])
    }
    func createJointBuffer(size: Int){
        _jointsBuffer =         Engine.Device.makeBuffer(length: ModelConstants.stride(     size    ), options: [])
        _allJointsBuffer =         Engine.Device.makeBuffer(length: ModelConstants.stride(     size    ), options: [])
    }
    func getRequiredJointBufferLength() -> Int{
        var jointCount = 0
        for _node in _nodes {
            if(_node.skinner != nil){
                jointCount += _node.skinner.skeleton.getRequiredBufferLength()
            }
        }
        return jointCount
    }
    func updateNodeList(){
        if(!jointBufferMade){
            createJointBuffer(size: 4)
            
            jointBufferMade = true
        }
        var pointer = _modelConstantsBuffer.contents().bindMemory(to: ModelConstants.self, capacity: _nodes.count)
        var allPointer = _reflectionsBuffer.contents().bindMemory(to: ModelConstants.self, capacity: _nodes.count)
        if(self.nodesAreSkinned){
            if(getRequiredJointBufferLength() * _nodes.count > (_jointsBuffer.length/ModelConstants.size)){
                createJointBuffer(size: getRequiredJointBufferLength())
            }
        }
        var jointBufferPointer = _jointsBuffer.contents().bindMemory(to: ModelConstants.self, capacity: _jointsBuffer.length/ModelConstants.size * _nodes.count)
        var allJointsBufferPointer = _allJointsBuffer.contents().bindMemory(to: ModelConstants.self, capacity: _jointsBuffer.length/ModelConstants.size * _nodes.count)
        
        _jointArray = []
        _allJointsArray = []
        camFrustum = SceneManager.currentScene._cameraManager.currentCamera.cameraFrustum
        for node in _nodes{

            if(doCullTest(p: node.getModelMatrixPosition(), radius: node.radius)){
                node.culled = true
            }else{
                node.culled = false
            }
            if(!node.culled){
                pointer.pointee.modelMatrix = node.worldTransform
                pointer = pointer.advanced(by: 1)
                if(node.skinner != nil){
                    var newArray = node.skinner.skeleton.copyTransformsArray()
                    _jointArray.append(contentsOf: newArray)
                }
            }
            if(node.skinner != nil){
                _allJointsArray.append(contentsOf: node.skinner.skeleton.copyTransformsArray())
            }
            allPointer.pointee.modelMatrix = node.worldTransform
            allPointer = allPointer.advanced(by: 1)


        }
        if(self.nodesAreSkinned){
            for x in _jointArray{
                jointBufferPointer.pointee = x
                jointBufferPointer = jointBufferPointer.advanced(by: 1)
            }
            for x in _allJointsArray{
                allJointsBufferPointer.pointee = x
                allJointsBufferPointer = allJointsBufferPointer.advanced(by: 1)
            }
        }
    }
    override func update(deltaTime: Float){
        updateNodeList()
        for node in _nodes{
            node.updateAnimation(at: TimeInterval(GameTime.TotalGameTime))
        }
        for child in _children{
            child.parentModelMatrix = self.modelMatrix
            child.update(deltaTime: deltaTime)
            
        }
    }
    
}
extension InstancedGameObject: Renderable{
    func doCubeMapRender(renderCommandEncoder: MTLRenderCommandEncoder) {
        if(!self.preventRender){
            if(self.nodesAreSkinned){
                RenderUtilities.advancedSetRenderPipelineState(pipelineState: .InstancedSkinnedCubemap, commandEncoder: renderCommandEncoder)
            }else{
                RenderUtilities.advancedSetRenderPipelineState(pipelineState: .InstancedCubemap,        commandEncoder: renderCommandEncoder)
            }

            
            renderCommandEncoder.setDepthStencilState(Graphics.DepthStencilStates[.Less])
            
            if(self.nodesAreSkinned){
                renderCommandEncoder.setVertexBuffer(_allJointsBuffer, offset: 0, index: 4)
                renderCommandEncoder.setVertexBytes(&referenceJointLength, length: UInt.stride, index: 5)
            }
            
            renderCommandEncoder.setVertexBuffer(_reflectionsBuffer, offset: 0, index: 2)
            
            renderCommandEncoder.setFragmentBytes(&_material, length: Material.stride, index: 1)
            if(_mesh != nil){
                _mesh.drawCubemapPrimitives(renderCommandEncoder)
            }
        }
    }
    
    
    func doRender(renderCommandEncoder: MTLRenderCommandEncoder){
        if(!self.preventRender){
            if(self.nodesAreSkinned){
                RenderUtilities.advancedSetRenderPipelineState(pipelineState: .InstancedSkinned, commandEncoder: renderCommandEncoder)
            }else{
                RenderUtilities.advancedSetRenderPipelineState(pipelineState: .Instanced,        commandEncoder: renderCommandEncoder)
            }
            
            //Depth Stencil
            renderCommandEncoder.setDepthStencilState(Graphics.DepthStencilStates[.Less])
            
            //Vertex Shading
            renderCommandEncoder.setVertexBuffer(_modelConstantsBuffer, offset: 0, index: 2)
            
            if(self.nodesAreSkinned){
                renderCommandEncoder.setVertexBuffer(_jointsBuffer, offset: 0, index: 4)
                renderCommandEncoder.setVertexBytes(&referenceJointLength, length: UInt.stride, index: 5)
            }
            
            
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
        if(self.nodesAreSkinned){
            RenderUtilities.advancedSetRenderPipelineState(pipelineState: .InstancedSkinnedShadow, commandEncoder: renderCommandEncoder)
        }else{
            RenderUtilities.advancedSetRenderPipelineState(pipelineState: .InstancedShadow,        commandEncoder: renderCommandEncoder)
        }

        
        if(self.nodesAreSkinned){
            renderCommandEncoder.setVertexBuffer(_allJointsBuffer, offset: 0, index: 4)
            renderCommandEncoder.setVertexBytes(&referenceJointLength, length: UInt.stride, index: 5)
        }
        
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
    /// WARNING: This only takes in one position for all of the objects to be reflectionRendered
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
