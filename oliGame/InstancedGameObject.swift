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
    
    init(name: String, meshType: MeshTypes, instanceCount: Int){
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
    }
    override func update(deltaTime: Float){
        var pointer = _modelConstantsBuffer.contents().bindMemory(to: ModelConstants.self, capacity: _nodes.count)
        
        for node in _nodes{
            pointer.pointee.modelMatrix = node.modelMatrix
            
            pointer = pointer.advanced(by: 1)
        }
        
        super.update(deltaTime: deltaTime)
    }

    
}
extension InstancedGameObject: Renderable{
    func doRender(renderCommandEncoder: MTLRenderCommandEncoder){
        renderCommandEncoder.setRenderPipelineState(Graphics.RenderPipelineStates[.Instanced])
        
        //Depth Stencil
        renderCommandEncoder.setDepthStencilState(Graphics.DepthStencilStates[.Less])
        
        //Vertex Shading
        renderCommandEncoder.setVertexBuffer(_modelConstantsBuffer, offset: 0, index: 2)
        
        //Use the fragment shader
        renderCommandEncoder.setFragmentBytes(&_material, length: Material.stride, index: 1)
        
        //Draw the mesh
        _mesh.drawPrimitives(renderCommandEncoder)
    }

}

extension InstancedGameObject {
    public  func setColor(_ color: float4){
        self._material.color = color
    }
}
