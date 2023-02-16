//
//  InstancedGameObject.swift
//  oliGame
//
//  Created by Oliver Crumrine on 11/27/22.
//

import MetalKit

class InstancedGameObject: Node{
    private var _mesh: Mesh!
    private var _material = Material()
    
    internal var _nodes: [Node] = []
    private var _modelConstantsBuffer: MTLBuffer!
    private var _reflectionsBuffer: MTLBuffer!
    private var _reflectionPosition: float3
    private var _reflectionIndex: Int! = nil

    
    init(name: String, meshType: MeshTypes, instanceCount: Int){
        self._reflectionPosition = float3(0,0,0)
        super.init(name: name)
        self._mesh = Assets.Meshes[meshType]
        self._mesh.setInstanceCount(instanceCount)
        self.generateInstances(instanceCount)
        self.createBuffers(instanceCount)
        
    }
    func updateNodes(_ updateNodeFunction: (Node, Int)->()){
        for (index, node) in _nodes.enumerated(){
            updateNodeFunction(node, index)
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
            if(doCullTest(p: node.getPosition(), radius: node.radius)){
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
            if(Renderer.currnetPipelineState != .InstancedCubemap){
                renderCommandEncoder.setRenderPipelineState(Graphics.RenderPipelineStates[.InstancedCubemap])
                Renderer.currnetPipelineState = .InstancedCubemap
            }
            
            renderCommandEncoder.setDepthStencilState(Graphics.DepthStencilStates[.Less])
            
            renderCommandEncoder.setVertexBuffer(_reflectionsBuffer, offset: 0, index: 2)
            
            renderCommandEncoder.setFragmentBytes(&_material, length: Material.stride, index: 1)
            
            _mesh.drawCubemapPrimitives(renderCommandEncoder)
        }
    }
    
    
    func doRender(renderCommandEncoder: MTLRenderCommandEncoder){
        if(!self.preventRender){
            if(Renderer.currnetPipelineState != .Instanced){
                renderCommandEncoder.setRenderPipelineState(Graphics.RenderPipelineStates[.Instanced])
                Renderer.currnetPipelineState = .Instanced
            }
            
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
            
            
            //Use the fragment shader
            renderCommandEncoder.setFragmentBytes(&_material, length: Material.stride, index: 1)
            
            //Draw the mesh
            _mesh.drawPrimitives(renderCommandEncoder)
            
            _reflectionIndex = nil
        }
    }
    func doShadowRender(renderCommandEncoder: MTLRenderCommandEncoder){
        if(Renderer.currnetPipelineState != .InstancedShadow){
            renderCommandEncoder.setRenderPipelineState(Graphics.RenderPipelineStates[.InstancedShadow])
            Renderer.currnetPipelineState = .InstancedShadow
        }

        //Depth Stencil
        renderCommandEncoder.setDepthStencilState(Graphics.DepthStencilStates[.Less])
        
        //Vertex Shading
        renderCommandEncoder.setVertexBuffer(_reflectionsBuffer, offset: 0, index: 1)
        
        //Draw the mesh
        _mesh.drawPrimitives(renderCommandEncoder)
    }
    // WARNING: This could get out of hand if there are too many objects to be reflectionrendered
    func doReflectionRender() {
        self.preventRender = true
        _reflectionIndex = _mesh.renderReflections(position: _reflectionPosition)
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
}
