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
    case Quad
    case SkySphere
    
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
    
}

class MeshLibrary: Library<MeshTypes, Mesh>{
    private var _library: [MeshTypes:Mesh] = [:]
    override func fillLibrary() {
        _library.updateValue(Triangle_CustomMesh(), forKey: .Triangle_Custom)
        _library.updateValue(Quad_CustomMesh(), forKey: .Quad_Custom)
        _library.updateValue(Cube_CustomMesh(), forKey: .Cube_Custom)
        _library.updateValue(Mesh(modelName: "cruiser"), forKey: .Cruiser)
        _library.updateValue(Mesh(modelName: "Sphere"), forKey: .Sphere)
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
        
        

    }
    override subscript(type: MeshTypes) -> Mesh? {
        return _library[type]!
    }
    
    
}

class NoMesh: Mesh{

}

class Mesh{
    private var _vertexBuffer: MTLBuffer!
    private var _indexBuffer: MTLBuffer!
    private var _vertices: [Vertex] = []
    private var _instanceCount: Int = 1
    private var _submeshes: [Submesh] = []
    private var _vertexCount: Int = 0
    
    init(){
        
        createMesh()
        
        createBuffer()
    }
    init(modelName: String){
        createMeshFromModel(modelName: modelName)
    }
    func createMesh() {}
    
    func createBuffer(){
        if(_vertexCount > 0){
            _vertexBuffer = Engine.Device.makeBuffer(bytes: _vertices, length: Vertex.stride(_vertices.count), options: [])
        }
        
    }
    private func createMeshFromModel(modelName: String){
        guard let assetURL = Bundle.main.url(forResource: modelName, withExtension: "obj") else{
            fatalError()
        }
        let descriptor = MTKModelIOVertexDescriptorFromMetal(Graphics.VertexDescriptors[.Basic])
        (descriptor.attributes[0] as! MDLVertexAttribute).name = MDLVertexAttributePosition
        (descriptor.attributes[1] as! MDLVertexAttribute).name = MDLVertexAttributeColor
        (descriptor.attributes[2] as! MDLVertexAttribute).name = MDLVertexAttributeTextureCoordinate
        (descriptor.attributes[3] as! MDLVertexAttribute).name = MDLVertexAttributeNormal
        (descriptor.attributes[4] as! MDLVertexAttribute).name = MDLVertexAttributeTangent
        (descriptor.attributes[5] as! MDLVertexAttribute).name = MDLVertexAttributeBitangent
        
        let bufferAllocator = MTKMeshBufferAllocator(device: Engine.Device)
        let asset: MDLAsset = MDLAsset(url: assetURL,
                            vertexDescriptor: descriptor,
                            bufferAllocator: bufferAllocator)
        asset.loadTextures()
        
        var mtkMeshes: [MTKMesh] = []
        var mdlMeshes: [MDLMesh] = []
        do {
            mdlMeshes = try MTKMesh.newMeshes(asset: asset, device: Engine.Device).modelIOMeshes
        }catch{
            print("error loading mesh")
        }
        
        for mdlMesh in mdlMeshes{
            mdlMesh.addTangentBasis(forTextureCoordinateAttributeNamed: MDLVertexAttributeTextureCoordinate,
                                    tangentAttributeNamed: MDLVertexAttributeTangent,
                                    bitangentAttributeNamed: MDLVertexAttributeBitangent)
            mdlMesh.vertexDescriptor = descriptor
            do{
                let mtkMesh = try MTKMesh(mesh:mdlMesh, device: Engine.Device)
                mtkMeshes.append(mtkMesh)
            }catch{
                print("error leading mdlmesh")
            }
        }
        
        
        let mdlMesh = mdlMeshes[0]
        let mtkMesh = mtkMeshes[0]
        self._vertexBuffer = mtkMesh.vertexBuffers[0].buffer
        self._vertexCount = mtkMesh.vertexCount
        for i in 0..<mtkMesh.submeshes.count{
            let mtkSubmesh = mtkMesh.submeshes[i]
            let mdlSubmesh = mdlMesh.submeshes![i] as! MDLSubmesh
            let submesh = Submesh(mtkSubmesh: mtkSubmesh,
                                  mdlSubmesh: mdlSubmesh)
            addSubmesh(submesh)
        }
        
        
    }
    
    func setInstanceCount(_ instanceCount: Int) {
        self._instanceCount = instanceCount
    }
    func addSubmesh(_ submesh: Submesh){
        _submeshes.append(submesh)
    }

    
    func addVertex(position: float3,
                   color:float4 = float4(1,0,1,1),
                   textureCoordinate: float2 = float2(0),
                   normal: float3 = float3(0,1,0),
                   tangent: float3 = float3(1,1,1),
                   bitangent: float3 = float3(1,1,1)){
        _vertices.append(Vertex(position:position,
                                color: color,
                                textureCoordinate: textureCoordinate,
                                normal: normal,
                                tangent:tangent,
                                bitangent: bitangent))
    }


    func drawPrimitives(_ renderCommandEncoder: MTLRenderCommandEncoder,
                        baseColorTextureType: TextureTypes = .None,
                        material: Material? = nil,
                        normalMapTextureType: TextureTypes = .None){
        if(_vertexBuffer != nil){
            renderCommandEncoder.setVertexBuffer(_vertexBuffer, offset: 0, index: 0)

            if(_submeshes.count > 0){
                for  submesh in _submeshes{
                    submesh.applyTextures(renderCommandEncoder: renderCommandEncoder,
                                          customBaseColorTextureType: baseColorTextureType,
                                          customNormalMapTextureType: normalMapTextureType)
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
    
    private var _material = Material()
    
    
    
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
        if let ambient = mdlMaterial.property(with:. emission)?.float3Value { _material.ambient = ambient }
        if let diffuse = mdlMaterial.property(with:. baseColor)?.float3Value { _material.diffuse = diffuse }
        if let specular = mdlMaterial.property(with:. specular)?.float3Value{ _material.ambient = specular}
        if let shininess=mdlMaterial.property(with:. specularExponent)?.floatValue{_material.shininess = shininess}
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
                       customNormalMapTextureType:TextureTypes) {
        _material.useBaseTexture = customBaseColorTextureType != .None || _baseColorTExture != nil
        _material.useNormalMapTexture = customNormalMapTextureType != .None || _normalMapTexture != nil
        
        
        if(_material.useBaseTexture || _material.useNormalMapTexture){
            renderCommandEncoder.setFragmentSamplerState(Graphics.SamplerStates[.Linear], index:0)
        }
        
        renderCommandEncoder.setFragmentSamplerState(Graphics.SamplerStates[.Linear], index: 0)
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

class Triangle_CustomMesh: Mesh{
    override func createMesh(){
            addVertex(position: float3( 0, 1,0),   color: float4(1,0,0,1))
            addVertex(position: float3(-1,-1,0), color: float4(0,1,0,1))
            addVertex(position: float3( 1,-1,0), color: float4(0,0,1,1))
    }
}
class Quad_CustomMesh: Mesh{
    override func createMesh(){
        addVertex(position: float3(1, 1,0), color: float4(1,0,0,1), textureCoordinate: float2(1,0), normal: float3(0,0,1))
        addVertex(position: float3(-1, 1,0), color: float4(0,1,0,1), textureCoordinate: float2(0,0), normal: float3(0,0,1))
        addVertex(position: float3(-1,-1,0), color: float4(0,0,1,1), textureCoordinate: float2(0,1), normal: float3(0,0,1))
        
        addVertex(position: float3( 1,-1,0), color: float4(0,0,1,1), textureCoordinate: float2(1,1), normal: float3(0,0,1))
        
        addSubmesh(Submesh(indices: [
        0,1,2,   0,2,3
        ]))
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
