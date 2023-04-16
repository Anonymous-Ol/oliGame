//
//  MeshLibrary.swift
//  oliGame
//
//  Created by Oliver Crumrine on 11/26/22.
//

import MetalKit

enum MeshTypes{
   case None
   case Triangle_Custom
   case Quad_Custom
   case Cube_Custom
   case Cruiser
   case Sphere
   case TheSuzannes
   case Chest
   case RandomCube
   case Quad
   case SkySphere
   case RegSphere
   case TransparentCube
   //Terrain
   case GroundGrass
   
   //Trees
   case TreePineB
   case TreePineC
   case TreePineA
   
   //Flowers
   case flower_purple
   case flower_red
   case flower_yellow
   
   case BunnyCharacter
   
}

class MeshLibrary: Library<MeshTypes, Mesh>{
   private var _library: [MeshTypes:Mesh] = [:]
   override func fillLibrary() {
      _library.updateValue(Triangle_CustomMesh(), forKey: .Triangle_Custom)
      _library.updateValue(Quad_CustomMesh(), forKey: .Quad_Custom)
      _library.updateValue(Cube_CustomMesh(), forKey: .Cube_Custom)
      _library.updateValue(Mesh(modelName: "cruiser"), forKey: .Cruiser)
      _library.updateValue(Mesh(modelName: "sphereMetallic"), forKey: .Sphere)
      _library.updateValue(Mesh(modelName: "TheSuzannes"), forKey: .TheSuzannes)
      _library.updateValue(Mesh(modelName: "chest"), forKey: .Chest)
      _library.updateValue(Mesh(modelName: "quad"), forKey: .Quad)
      _library.updateValue(Mesh(modelName: "skysphere"), forKey: .SkySphere)
      _library.updateValue(NoMesh(), forKey: .None)
      
      
      _library.updateValue(Mesh(modelName: "ground_grass"), forKey: .GroundGrass)
      
      _library.updateValue(Mesh(modelName: "tree_pineTallA_detailed"), forKey: .TreePineA)
      _library.updateValue(Mesh(modelName: "tree_pineDefaultB"), forKey: .TreePineB)
      _library.updateValue(Mesh(modelName: "tree_pineRoundC"), forKey: .TreePineC)
      
      _library.updateValue(Mesh(modelName: "flower_redA"), forKey: .flower_red)
      _library.updateValue(Mesh(modelName: "flower_purpleA"), forKey: .flower_purple)
      _library.updateValue(Mesh(modelName: "flower_yellowA"), forKey: .flower_yellow)
      
      _library.updateValue(Mesh(modelName: "untitled"), forKey: .RegSphere)
      _library.updateValue(Mesh(modelName: "untitled2"), forKey: .TransparentCube)
      
      _library.updateValue(Mesh(modelName: "Character", fileExtension: "usdz"), forKey: .BunnyCharacter)
      
      _library.updateValue(Mesh(modelName: "randomCube"), forKey: .RandomCube)
      
      
   }
   override subscript(type: MeshTypes) -> Mesh? {
      return _library[type]!
   }
   
   
}


class Mesh{
           var _vertexBuffer: MTLBuffer!
   private var _indexBuffer: MTLBuffer!
   private var _vertices: [Vertex] = []
   private var _instanceCount: Int = 1
   private var _submeshes: [Submesh] = []
           var _vertexCount: Int = 0
   private var _name: String = ""
   var topLevelObjectCount: Int = 0
   var gameObject: GameObject!
   var instancedGameObject: InstancedGameObject!
   
   init(){
      
      createMesh()
      
      createBuffer()
   }
   init(modelName: String, fileExtension: String = "obj"){
      createMeshFromModel(modelName: modelName, fileExtension: fileExtension)
   }
   func setName(name: String){
      _name = name
   }
   func createMesh() {}

   func createBuffer(){
      if(_vertices.count > 0){
         _vertexBuffer = Engine.Device.makeBuffer(bytes: _vertices, length: Vertex.stride(_vertices.count), options: [])
      }
      
   }
   private func createMeshFromModel(modelName: String, fileExtension: String){
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
      guard let assetURL = Bundle.main.url(forResource: modelName, withExtension: fileExtension) else{
         fatalError()
      }
      let descriptor = MTKModelIOVertexDescriptorFromMetal(Graphics.VertexDescriptors[.Basic])
      (descriptor.attributes[0] as! MDLVertexAttribute).name = MDLVertexAttributePosition
      (descriptor.attributes[1] as! MDLVertexAttribute).name = MDLVertexAttributeColor
      (descriptor.attributes[2] as! MDLVertexAttribute).name = MDLVertexAttributeTextureCoordinate
      (descriptor.attributes[3] as! MDLVertexAttribute).name = MDLVertexAttributeNormal
      (descriptor.attributes[4] as! MDLVertexAttribute).name = MDLVertexAttributeTangent
      (descriptor.attributes[5] as! MDLVertexAttribute).name = MDLVertexAttributeBitangent
      (descriptor.attributes[6] as! MDLVertexAttribute).name = MDLVertexAttributeJointIndices
      (descriptor.attributes[7] as! MDLVertexAttribute).name = MDLVertexAttributeJointWeights
      
      
      
      let bufferAllocator = MTKMeshBufferAllocator(device: Engine.Device)
      let asset: MDLAsset = MDLAsset(url: assetURL,
                                     vertexDescriptor: descriptor,
                                     bufferAllocator: bufferAllocator)
      asset.loadTextures()
      
      let topLevelCount = asset.count
      
      let topLevelObjects = (0..<topLevelCount).map { asset.object(at: $0) }
      var objectQueue = [MDLObject](topLevelObjects)
      var parentQueue = [GameObject?](repeating: nil, count: topLevelCount)
      let rootNode = GameObject(name: modelName)
      
      TopLevelObjectLibrary.TopLevelObjects.updateValue(asset, forKey: modelName)
      
      let instancedRootNode = InstancedGameObject(name: modelName)
      
      var instancedParentQueue = [InstancedGameObject?](repeating: nil, count: topLevelCount)
      while !objectQueue.isEmpty {
         let mdlObject = objectQueue.removeFirst()
         let instancedParentNode = instancedParentQueue.removeFirst() ?? instancedRootNode
         let parentNode = parentQueue.removeFirst() ?? rootNode
         let node = GameObject(name: mdlObject.name)
         let instancedNode = InstancedGameObject(name: mdlObject.name)
         
         if let mdlMesh = mdlObject as? MDLMesh {
            let comp = mdlMesh.componentConforming(to: MDLComponent.self) as? MDLAnimationBindComponent
            if(comp != nil){
               node.setSkinner(skinner: Skinner(skeletonForMDLSkeleton((comp?.skeleton)!)))
               //node.mdlSkeleton = comp?.skeleton
               
            }
            node._mesh = createMeshFromMDLMesh(mdlMesh: mdlMesh)
            instancedNode._mesh = createMeshFromMDLMesh(mdlMesh: mdlMesh)
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
                //node.mdlSkeleton = mdlSkeleton
                 node.skinner = Skinner(skeletonForMDLSkeleton(mdlSkeleton), float4x4(animationBinding.geometryBindTransform))
             }
         }

         
         if let mdlSkeleton = mdlObject as? MDLSkeleton {
            //node.mdlSkeleton = mdlSkeleton
            node.setSkinner(skinner: Skinner(skeletonForMDLSkeleton(mdlSkeleton)))
         }
         parentNode.addChild(node)
         instancedParentNode.addChild(instancedNode)
         
         objectQueue.append(contentsOf: mdlObject.children.objects)
         
         parentQueue.append(contentsOf: [GameObject](repeating: node, count: mdlObject.children.count))
         instancedParentQueue.append(contentsOf: [InstancedGameObject](repeating: instancedNode, count: mdlObject.children.count))
      }
   gameObject = rootNode
   instancedGameObject = instancedRootNode
   }
   private func createMeshFromMDLMesh(mdlMesh: MDLMesh) -> Mesh {
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
   func setInstanceCount(_ instanceCount: Int) {
      self._instanceCount = instanceCount
   }
   func addSubmesh(_ submesh: Submesh){
      _submeshes.append(submesh)
   }
   
   
   func addVertex(position: float3,
                  color:float4 = float4(1,0,1,1),
                  textureCoordinate: float2 = float2(repeating: 0),
                  normal: float3 = float3(0,1,0),
                  tangent: float3 = float3(1,1,1),
                  bitangent: float3 = float3(1,1,1),
                  indices: simd_ushort4 = simd_ushort4(1, 1, 1, 1),
                  weights: float4 = float4(1,1,1,1)) {
      _vertices.append(Vertex(position:position,
                              color: color,
                              textureCoordinate: textureCoordinate,
                              normal: normal,
                              tangent:tangent,
                              bitangent: bitangent,
                              indices: indices,
                              weights: weights))
   }
   
   
   func drawPrimitives(_ renderCommandEncoder: MTLRenderCommandEncoder,
                       baseColorTextureType: TextureTypes = .None,
                       material: Material? = nil,
                       normalMapTextureType: TextureTypes = .None,
                       cubeMapTexture: MTLTexture? = nil){
      if(_vertexBuffer != nil){
         renderCommandEncoder.setVertexBuffer(_vertexBuffer, offset: 0, index: 0)
         
         if(_submeshes.count > 0){
            for  submesh in _submeshes{
               submesh.applyTextures(renderCommandEncoder: renderCommandEncoder,
                                     customBaseColorTextureType: baseColorTextureType,
                                     customNormalMapTextureType: normalMapTextureType,
                                     cubeMapTexture: cubeMapTexture)
               
               submesh.applyMaterials(renderCommandEncoder: renderCommandEncoder, customMaterial: material)
               renderCommandEncoder.drawIndexedPrimitives(type: submesh.primitiveType,
                                                          indexCount: submesh.indexCount,
                                                          indexType: submesh.indexType,
                                                          indexBuffer: submesh.indexBuffer,
                                                          indexBufferOffset: submesh.indexBufferOffset,
                                                          instanceCount: _instanceCount)
               
            }
         }else{
            renderCommandEncoder.drawPrimitives(type: .triangle,
                                                vertexStart: 0,
                                                vertexCount: _vertices.count,
                                                instanceCount: _instanceCount)
         }
      }

   }
   func drawCubemapPrimitives(_ renderCommandEncoder: MTLRenderCommandEncoder,
                              baseColorTextureType: TextureTypes = .None,
                              material: Material? = nil,
                              normalMapTextureType: TextureTypes = .None,
                              cubeMapTexture: MTLTexture? = nil){
      if(_vertexBuffer != nil){
         renderCommandEncoder.setVertexBuffer(_vertexBuffer, offset: 0, index: 0)
         var isReflective = false
         for _submesh in _submeshes {
            if(_submesh._material.reflectivity > 0){
               
               isReflective = true
            }
            if(material?.reflectivity ?? 0 > 0){
               isReflective = true
            }
         }
         
         if(_submeshes.count > 0 && !isReflective){
            
            for  submesh in _submeshes{
               submesh.applyMaterials(renderCommandEncoder: renderCommandEncoder, customMaterial: material)
               submesh.applyTextures(renderCommandEncoder: renderCommandEncoder,
                                     customBaseColorTextureType: baseColorTextureType,
                                     customNormalMapTextureType: normalMapTextureType,
                                     cubeMapTexture: cubeMapTexture)
               
               for i in 0...6*RenderVariables.reflectionPositions.count - 1{
                  var iInt32: Int32 = Int32(i)
                  renderCommandEncoder.setVertexBytes(&iInt32, length: Int32.stride, index: 3)
                  renderCommandEncoder.drawIndexedPrimitives(type: submesh.primitiveType,
                                                             indexCount: submesh.indexCount,
                                                             indexType: submesh.indexType,
                                                             indexBuffer: submesh.indexBuffer,
                                                             indexBufferOffset: submesh.indexBufferOffset,
                                                             instanceCount: _instanceCount)
                  
               }
            }
         }else{
            for i in 0...6*RenderVariables.reflectionPositions.count - 1{
               var iInt32: Int32 = Int32(i)
               renderCommandEncoder.setVertexBytes(&iInt32, length: Int32.stride, index: 3)
               renderCommandEncoder.drawPrimitives(type: .triangle,
                                                   vertexStart: 0,
                                                   vertexCount: _vertices.count,
                                                   instanceCount: _instanceCount)
            }
         }
      }
   }
   func renderReflections(material: Material? = nil,
                          position: float3) -> Int!{
      if(_vertexBuffer != nil){
         for _submesh in _submeshes {
            if(_submesh._material.reflectivity > 0){
               
            }else{
               return nil
            }
            if(material?.reflectivity ?? 1 > 0){
               
            }else{
               return nil
            }
         }
         RenderVariables.currentReflectionIndex += 1
         RenderVariables.reflectionPositions.append(position)
         return Int(RenderVariables.currentReflectionIndex - 1)
      }
      
      return nil
   }
   func queryTransparent() -> Bool{
      for _submesh in _submeshes{
         if(_submesh._material.color.w < 1){
            return true
         }
      }
      return false
   }
   
   
}
class Submesh{
   private var  _indices: [UInt32] = []
   
   private var  _indexCount: Int = 0
   public  var   indexCount: Int { return _indexCount}
   
   private var _indexBuffer: MTLBuffer!
   public  var  indexBuffer: MTLBuffer { return _indexBuffer }
   
   private var _primitiveType: MTLPrimitiveType = .triangle
   public  var  primitiveType: MTLPrimitiveType { return _primitiveType}
   
   private var _indexType: MTLIndexType = .uint32
   public  var  indexType: MTLIndexType { return _indexType }
   
   private var _indexBufferOffset: Int = 0
   public  var  indexBufferOffset: Int { return _indexBufferOffset}
   
   private var _baseColorTExture: MTLTexture!
   private var _normalMapTexture: MTLTexture!
   
   var _material = Material()
   
   private var _trueReflections: MTLTexture!
   
   
   
   init(mtkSubmesh: MTKSubmesh,
        mdlSubmesh: MDLSubmesh){
      _indexBuffer = mtkSubmesh.indexBuffer.buffer
      _indexBufferOffset = mtkSubmesh.indexBuffer.offset
      _indexCount = mtkSubmesh.indexCount
      _indexType = mtkSubmesh.indexType
      _primitiveType = mtkSubmesh.primitiveType
      
      createTexture(mdlSubmesh.material!)
      createMaterial(mdlSubmesh.material!)
      
   }
   private func texture(for semantic: MDLMaterialSemantic,
                        in material: MDLMaterial?,
                        textureOrigin: MTKTextureLoader.Origin) -> MTLTexture? {
      let textureLoader = MTKTextureLoader(device: Engine.Device)
      guard let materialProperty = material?.property(with: semantic) else { return nil }
      guard let sourceTexture    = materialProperty.textureSamplerValue?.texture else { return nil }
      let options: [MTKTextureLoader.Option : Any] = [
         MTKTextureLoader.Option.origin : textureOrigin as Any,
         MTKTextureLoader.Option.generateMipmaps : true
      ]
      let tex = try? textureLoader.newTexture(texture: sourceTexture, options:options)
      return tex
   }
   private func createTexture(_ mdlMaterial: MDLMaterial){
      _baseColorTExture = texture(for:.baseColor,
                                  in:mdlMaterial,
                                  textureOrigin: .bottomLeft)
      _normalMapTexture = texture(for:.tangentSpaceNormal,
                                  in:mdlMaterial,
                                  textureOrigin: .bottomLeft)
   }
   private func createMaterial(_ mdlMaterial: MDLMaterial){
      if let ambient      = mdlMaterial.property(with:. emission)?        .float3Value { _material.ambient      = ambient     }
      if let diffuse      = mdlMaterial.property(with:. baseColor)?       .float3Value { _material.diffuse      = diffuse     }
      if let specular     = mdlMaterial.property(with:. specular)?        .float3Value { _material.specular     = specular    }
      if let shininess    = mdlMaterial.property(with:. specularExponent)?.floatValue  { _material.shininess    = shininess   }
      if let reflectivity = mdlMaterial.property(with: .metallic)?        .floatValue  { _material.reflectivity = reflectivity}
      if let alpha        = mdlMaterial.property(with: .opacity)?         .floatValue  { _material.color.w      = alpha       }
   }
   init(indices: [UInt32]){
      self._indices = indices
      self._indexCount = indices.count
      createIndexBuffer()
   }
   
   private func createIndexBuffer(){
      if(_indices.count > 0){
         _indexBuffer = Engine.Device.makeBuffer(bytes: _indices,
                                                 length: UInt32.stride(indexCount),
                                                 options: [])
      }
   }
   func applyTextures(renderCommandEncoder: MTLRenderCommandEncoder,
                      customBaseColorTextureType: TextureTypes,
                      customNormalMapTextureType:TextureTypes,
                      cubeMapTexture: MTLTexture?) {
      _material.useBaseTexture = customBaseColorTextureType != .None || _baseColorTExture != nil
      _material.useNormalMapTexture = customNormalMapTextureType != .None || _normalMapTexture != nil
      
      if(_material.useBaseTexture || _material.useNormalMapTexture){
         renderCommandEncoder.setFragmentSamplerState(Graphics.SamplerStates[.Linear], index:0)
      }
      
      renderCommandEncoder.setFragmentSamplerState(Graphics.SamplerStates[.Linear], index: 0)
      
      if(cubeMapTexture != nil){
         renderCommandEncoder.setFragmentTexture(cubeMapTexture, index: 4)
      }else{
         renderCommandEncoder.setFragmentTexture(nil, index: 4)
      }
      let baseColorTex = customBaseColorTextureType == .None ? _baseColorTExture : Assets.Textures[customBaseColorTextureType]
      if(baseColorTex != nil){
         renderCommandEncoder.setFragmentTexture(baseColorTex, index: 0)
      }
      let normalMapTex = customNormalMapTextureType == .None ? _normalMapTexture : Assets.Textures[customNormalMapTextureType]
      if(baseColorTex != nil){
         renderCommandEncoder.setFragmentTexture(normalMapTex, index: 1)
      }
      
   }
   func applyMaterials(renderCommandEncoder: MTLRenderCommandEncoder,
                       customMaterial: Material?){
      var mat = customMaterial == nil ? _material : customMaterial
      renderCommandEncoder.setFragmentBytes(&mat, length: Material.stride, index: 1)
   }
   
}
//To be removed

class Triangle_CustomMesh: Mesh{
   override func createMesh(){
      addVertex(position: float3( 0, 1,0),   color: float4(1,0,0,1))
      addVertex(position: float3(-1,-1,0), color: float4(0,1,0,1))
      addVertex(position: float3( 1,-1,0), color: float4(0,0,1,1))
   }
}
class Quad_CustomMesh: Mesh{
   override func createMesh(){
      addVertex(position: float3(1, 1,0), color: float4(1,0,0,1), textureCoordinate: float2(1,1), normal: float3(0,0,1))
      addVertex(position: float3(-1, 1,0), color: float4(0,1,0,1), textureCoordinate: float2(0,1), normal: float3(0,0,1))
      addVertex(position: float3(-1,-1,0), color: float4(0,0,1,1), textureCoordinate: float2(0,0), normal: float3(0,0,1))
      
      addVertex(position: float3( 1,-1,0), color: float4(0,0,1,1), textureCoordinate: float2(1,0), normal: float3(0,0,1))
      
      addSubmesh(Submesh(indices: [
         0,1,2,   0,2,3
      ]))
      setName(name: "Quad")
   }
}
class Cube_CustomMesh: Mesh{
   override func createMesh() {
      //Left
      addVertex(position: float3(-1,-1,-1), color: float4(0,0,1,1))
      addVertex(position: float3(-1,-1, 1), color: float4(0,0,1,1))
      addVertex(position: float3(-1, 1, 1), color: float4(0,0,1,1))
      addVertex(position: float3(-1,-1,-1), color: float4(0,0,1,1))
      addVertex(position: float3(-1, 1, 1), color: float4(0,0,1,1))
      addVertex(position: float3(-1, 1,-1), color: float4(0,0,1,1))
      
      //Right
      addVertex(position: float3( 1, 1, 1), color: float4(0,1,1,1))
      addVertex(position: float3( 1,-1,-1), color: float4(0,1,1,1))
      addVertex(position: float3( 1, 1,-1), color: float4(0,1,1,1))
      addVertex(position: float3( 1,-1,-1), color: float4(0,1,1,1))
      addVertex(position: float3( 1, 1, 1), color: float4(0,1,1,1))
      addVertex(position: float3( 1,-1, 1), color: float4(0,1,1,1))
      
      //Top
      addVertex(position: float3( 1, 1, 1), color: float4(1,0,1,1))
      addVertex(position: float3( 1, 1,-1), color: float4(1,0,1,1))
      addVertex(position: float3(-1, 1,-1), color: float4(1,0,1,1))
      addVertex(position: float3( 1, 1, 1), color: float4(1,0,1,1))
      addVertex(position: float3(-1, 1,-1), color: float4(1,0,1,1))
      addVertex(position: float3(-1, 1, 1), color: float4(1,0,1,1))
      
      //Bottom
      addVertex(position: float3( 1,-1, 1), color: float4(1,1,0,1))
      addVertex(position: float3(-1,-1,-1), color: float4(1,1,0,1))
      addVertex(position: float3( 1,-1,-1), color: float4(1,1,0,1))
      addVertex(position: float3( 1,-1, 1), color: float4(1,1,0,1))
      addVertex(position: float3(-1,-1, 1), color: float4(1,1,0,1))
      addVertex(position: float3(-1,-1,-1), color: float4(1,1,0,1))
      
      //Back
      addVertex(position: float3( 1, 1,-1), color: float4(1,0,0,1))
      addVertex(position: float3(-1,-1,-1), color: float4(1,0,0,1))
      addVertex(position: float3(-1, 1,-1), color: float4(1,0,0,1))
      addVertex(position: float3( 1, 1,-1), color: float4(1,0,0,1))
      addVertex(position: float3( 1,-1,-1), color: float4(1,0,0,1))
      addVertex(position: float3(-1,-1,-1), color: float4(1,0,0,1))
      
      //Front
      addVertex(position: float3(-1, 1, 1), color: float4(0,0,0,1))
      addVertex(position: float3(-1,-1, 1), color: float4(0,0,0,1))
      addVertex(position: float3( 1,-1, 1), color: float4(0,0,0,1))
      addVertex(position: float3( 1, 1, 1), color: float4(0,0,0,1))
      addVertex(position: float3(-1, 1, 1), color: float4(0,0,0,1))
      addVertex(position: float3( 1,-1, 1), color: float4(0,0,0,1))
   }
}
class NoMesh: Mesh{
   
}
