//
//  TopLevelObjectLibrary.swift
//  oliGame
//
//  Created by Oliver Crumrine on 4/5/23.
//

import Foundation
import ModelIO
import MetalKit
class TopLevelObjectLibrary{
    private static var randomAsset = MDLAsset()
    static var TopLevelObjects = [String : MDLAsset]()
    static func genIGO(modelName: String, instanceCount: Int) -> InstancedGameObject{
        let IGO = createMeshFromModelInstanced(asset: TopLevelObjects[modelName] ?? randomAsset, modelName: modelName).0
        IGO.postInit(instanceCount: instanceCount)
        return IGO
    }
    static func genIGOWithSkeleton(modelName: String, instanceCount: Int) -> InstancedGameObject{
        let (baseIGO, indentifiers) = createMeshFromModelInstancedSkinned(asset: TopLevelObjects[modelName] ?? randomAsset, modelName: modelName)
        baseIGO.postInit(instanceCount: instanceCount)
        var gameObject: GameObject = GameObject(name: "urmom")
        for i in 0..<instanceCount{
            gameObject = createMeshFromModel(asset: TopLevelObjects[modelName] ?? randomAsset, modelName: modelName)
            for x in 1..<indentifiers{
                baseIGO.findIndentifier(indentifier: x)?._nodes[i].skinner = gameObject.findIndentifier(indentifier: x)?.skinner
            }
        }
        baseIGO.referenceJointLength = UInt(gameObject.skinner?.skeleton.getRequiredBufferLength() ?? 28)
        baseIGO.nodesAreSkinned = true
        return baseIGO
    }
    static func genGameObject(modelName: String) -> GameObject{
        return createMeshFromModel(asset: TopLevelObjects[modelName] ?? randomAsset, modelName: modelName)
    }
    static func genWeirdGameObject(modelName: String, exampleObject: GameObject) -> GameObject{
        return createMeshFromWeirdGameObject(asset: TopLevelObjects[modelName] ?? randomAsset, modelName: modelName, exampleNode: exampleObject)
    }
    private static func createMeshFromModelInstancedSkinned(asset: MDLAsset, modelName: String) -> (InstancedGameObject, Int){

       asset.loadTextures()
       
       let topLevelCount = asset.count
       
       let topLevelObjects = (0..<topLevelCount).map { asset.object(at: $0) }
       var objectQueue = [MDLObject](topLevelObjects)
       
       let instancedRootNode = InstancedGameObject(name: modelName)
       
       var instancedParentQueue = [InstancedGameObject?](repeating: nil, count: topLevelCount)
        var x = 1
       while !objectQueue.isEmpty {
          let mdlObject = objectQueue.removeFirst()
          let instancedParentNode = instancedParentQueue.removeFirst() ?? instancedRootNode
          let instancedNode = InstancedGameObject(name: mdlObject.name)
           instancedNode.nodesAreSkinned = true
           instancedNode.indentifier = x
           x += 1
          
          if let mdlMesh = mdlObject as? MDLMesh {
              instancedNode._mesh = TopLevelObjectLibrary.createMeshFromMDLMesh(mdlMesh: mdlMesh)
          }
          
          instancedParentNode.addChild(instancedNode)
          
          objectQueue.append(contentsOf: mdlObject.children.objects)

          instancedParentQueue.append(contentsOf: [InstancedGameObject](repeating: instancedNode, count: mdlObject.children.count))
       }
        return (instancedRootNode, x)
    }
    private static func createMeshFromModelInstanced(asset: MDLAsset, modelName: String) -> (InstancedGameObject, Int){

       asset.loadTextures()
       
       let topLevelCount = asset.count
       
       let topLevelObjects = (0..<topLevelCount).map { asset.object(at: $0) }
       var objectQueue = [MDLObject](topLevelObjects)
       
       let instancedRootNode = InstancedGameObject(name: modelName)
       
       var instancedParentQueue = [InstancedGameObject?](repeating: nil, count: topLevelCount)
        var x = 1
       while !objectQueue.isEmpty {
          let mdlObject = objectQueue.removeFirst()
          let instancedParentNode = instancedParentQueue.removeFirst() ?? instancedRootNode
          let instancedNode = InstancedGameObject(name: mdlObject.name)
           instancedNode.indentifier = x
           x += 1
          
          if let mdlMesh = mdlObject as? MDLMesh {
              instancedNode._mesh = TopLevelObjectLibrary.createMeshFromMDLMesh(mdlMesh: mdlMesh)
          }
          
          instancedParentNode.addChild(instancedNode)
          
          objectQueue.append(contentsOf: mdlObject.children.objects)

          instancedParentQueue.append(contentsOf: [InstancedGameObject](repeating: instancedNode, count: mdlObject.children.count))
       }
        return (instancedRootNode, x)
    }
    private static func createMeshFromWeirdGameObject(asset: MDLAsset, modelName: String, exampleNode: GameObject) -> GameObject{
       var skeletons = [String : Skeleton]()
       let skeletonForMDLSkeleton: (MDLSkeleton) -> Skeleton = { mdlSkeleton in
           var cachedSkeleton: Skeleton! = skeletons[mdlSkeleton.name]
           if cachedSkeleton == nil {
               cachedSkeleton = Skeleton(mdlSkeleton)
               skeletons[mdlSkeleton.name] = cachedSkeleton
           }else{
              
           }
           return cachedSkeleton
       }
       
       asset.loadTextures()
       
       let topLevelCount = asset.count
       
       let topLevelObjects = (0..<topLevelCount).map { asset.object(at: $0) }
       var objectQueue = [MDLObject](topLevelObjects)
       var parentQueue = [GameObject?](repeating: nil, count: topLevelCount)
       let rootNode = exampleNode.returnSelf(name: modelName)
       
       
       while !objectQueue.isEmpty {
          let mdlObject = objectQueue.removeFirst()
          let parentNode = parentQueue.removeFirst() ?? rootNode
           let node = exampleNode.returnSelf(name: mdlObject.name)
          
          if let mdlMesh = mdlObject as? MDLMesh {
             let comp = mdlMesh.componentConforming(to: MDLComponent.self) as? MDLAnimationBindComponent
             if(comp != nil){
                node.setSkinner(skinner: Skinner(skeletonForMDLSkeleton((comp?.skeleton)!)))
                
             }
             node._mesh = createMeshFromMDLMesh(mdlMesh: mdlMesh)
          }
          
          if let animationBinding = mdlObject.animationBind {
              if animationBinding.jointPaths != nil {
                  print("Warning: Animation bindings with explicit joint paths are not currently supported")
              }

              if let mdlAnimation = animationBinding.jointAnimation as? MDLPackedJointAnimation {
                 let animation = JointAnimation(mdlAnimation)
                 AnimationsLibrary.animations.append((animation, node))
              }

              if let mdlSkeleton = animationBinding.skeleton {
                  node.skinner = Skinner(skeletonForMDLSkeleton(mdlSkeleton), float4x4(animationBinding.geometryBindTransform))
              }
          }

          
          if let mdlSkeleton = mdlObject as? MDLSkeleton {
             node.setSkinner(skinner: Skinner(skeletonForMDLSkeleton(mdlSkeleton)))
          }
          parentNode.addChild(node)
          
          objectQueue.append(contentsOf: mdlObject.children.objects)
          
          parentQueue.append(contentsOf: [GameObject](repeating: node, count: mdlObject.children.count))
       }
        return rootNode
    }
    private static func createMeshFromModel(asset: MDLAsset, modelName: String) -> GameObject{
       var skeletons = [String : Skeleton]()
       let skeletonForMDLSkeleton: (MDLSkeleton) -> Skeleton = { mdlSkeleton in
           var cachedSkeleton: Skeleton! = skeletons[mdlSkeleton.name]
           if cachedSkeleton == nil {
               cachedSkeleton = Skeleton(mdlSkeleton)
               skeletons[mdlSkeleton.name] = cachedSkeleton
           }else{
              
           }
           return cachedSkeleton
       }
       
       asset.loadTextures()
       
       let topLevelCount = asset.count
       
       let topLevelObjects = (0..<topLevelCount).map { asset.object(at: $0) }
       var objectQueue = [MDLObject](topLevelObjects)
       var parentQueue = [GameObject?](repeating: nil, count: topLevelCount)
       let rootNode = GameObject(name: modelName)
       rootNode.topLevelObject = true
       
        var x = 1
       
       while !objectQueue.isEmpty {
          let mdlObject = objectQueue.removeFirst()
          let parentNode = parentQueue.removeFirst() ?? rootNode
          let node = GameObject(name: mdlObject.name)
           node.indentifier = x
           x += 1
          
          if let mdlMesh = mdlObject as? MDLMesh {
             let comp = mdlMesh.componentConforming(to: MDLComponent.self) as? MDLAnimationBindComponent
             if(comp != nil){
                node.setSkinner(skinner: Skinner(skeletonForMDLSkeleton((comp?.skeleton)!)))
                
             }
             node._mesh = createMeshFromMDLMesh(mdlMesh: mdlMesh)
          }
          
          if let animationBinding = mdlObject.animationBind {
              if animationBinding.jointPaths != nil {
                  print("Warning: Animation bindings with explicit joint paths are not currently supported")
              }

              if let mdlAnimation = animationBinding.jointAnimation as? MDLPackedJointAnimation {
                 let animation = JointAnimation(mdlAnimation)
                 AnimationsLibrary.animations.append((animation, node))
              }

              if let mdlSkeleton = animationBinding.skeleton {
                  node.skinner = Skinner(skeletonForMDLSkeleton(mdlSkeleton), float4x4(animationBinding.geometryBindTransform))
              }
          }

          
          if let mdlSkeleton = mdlObject as? MDLSkeleton {
             node.setSkinner(skinner: Skinner(skeletonForMDLSkeleton(mdlSkeleton)))
          }
          parentNode.addChild(node)
          
          objectQueue.append(contentsOf: mdlObject.children.objects)
          
          parentQueue.append(contentsOf: [GameObject](repeating: node, count: mdlObject.children.count))
       }
        return rootNode
    }
    private static func createMeshFromMDLMesh(mdlMesh: MDLMesh) -> Mesh {
       var mtkMesh: MTKMesh! = nil
       let descriptor = MTKModelIOVertexDescriptorFromMetal(Graphics.VertexDescriptors[.Basic])
       (descriptor.attributes[0] as! MDLVertexAttribute).name = MDLVertexAttributePosition
       (descriptor.attributes[1] as! MDLVertexAttribute).name = MDLVertexAttributeColor
       (descriptor.attributes[2] as! MDLVertexAttribute).name = MDLVertexAttributeTextureCoordinate
       (descriptor.attributes[3] as! MDLVertexAttribute).name = MDLVertexAttributeNormal
       (descriptor.attributes[4] as! MDLVertexAttribute).name = MDLVertexAttributeTangent
       (descriptor.attributes[5] as! MDLVertexAttribute).name = MDLVertexAttributeBitangent
       (descriptor.attributes[6] as! MDLVertexAttribute).name = MDLVertexAttributeJointIndices
       (descriptor.attributes[7] as! MDLVertexAttribute).name = MDLVertexAttributeJointWeights
       
          mdlMesh.addTangentBasis(forTextureCoordinateAttributeNamed: MDLVertexAttributeTextureCoordinate,
                                  tangentAttributeNamed: MDLVertexAttributeTangent,
                                  bitangentAttributeNamed: MDLVertexAttributeBitangent)
          mdlMesh.vertexDescriptor = descriptor
          do{
             
             mtkMesh = try MTKMesh(mesh:mdlMesh, device: Engine.Device)
          }catch{
             print("error leading mdlmesh")
          }
       
       let newMesh = Mesh()
       newMesh._vertexBuffer = mtkMesh.vertexBuffers[0].buffer
       newMesh._vertexCount = mtkMesh.vertexCount
       for i in 0..<mtkMesh.submeshes.count{
          let mtkSubmesh = mtkMesh.submeshes[i]
          let mdlSubmesh = mdlMesh.submeshes![i] as! MDLSubmesh
          let submesh = Submesh(mtkSubmesh: mtkSubmesh,
                                mdlSubmesh: mdlSubmesh)
          
          newMesh.addSubmesh(submesh)
       }
       return newMesh
       
    }
}
