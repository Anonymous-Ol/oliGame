//
//  LightManager.swift
//  oliGame
//
//  Created by Oliver Crumrine on 11/27/22.
//

import MetalKit

class LightManager{

    private var _lightObjects:  [LightObject] = []
    private var  _shadowRenderPassDescriptor: MTLRenderPassDescriptor!
    private var _shadowRenders: [MTLTexture] = []
    private var _setUpShadowData: Bool = false
    private var _combinedShadowTexture: MTLTexture!
    
    func addLightObject(_ lightObject: LightObject){
        self._lightObjects.append(lightObject)
    }
    private func gatherLightData()->[LightData]{
        var result: [LightData] = []
        for lightObject in _lightObjects {
            result.append(lightObject.lightData)
        }
        return result
    }
    func createShadowRenderPassDescriptor(index: Int){

        let shadowDepthTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .depth32Float,
                                                                                    width: Int(Renderer.ScreenSize.x),
                                                                                    height: Int(Renderer.ScreenSize.y),
                                                                                    mipmapped: false)
        

        
        shadowDepthTextureDescriptor.storageMode = .private
        shadowDepthTextureDescriptor.usage = [.renderTarget, .shaderRead]
        
        _shadowRenders.insert(Engine.Device.makeTexture(descriptor: shadowDepthTextureDescriptor)!, at: index)
        
        
        self._shadowRenderPassDescriptor = MTLRenderPassDescriptor()
        
        
        self._shadowRenderPassDescriptor.depthAttachment.texture = _shadowRenders[index]
        self._shadowRenderPassDescriptor.depthAttachment.loadAction =  .clear
        self._shadowRenderPassDescriptor.depthAttachment.clearDepth = 1.0
        self._shadowRenderPassDescriptor.depthAttachment.storeAction = .store


        
    }
    func setLightData(_ renderCommandEncoder: MTLRenderCommandEncoder){
        var lightDatas = gatherLightData()
        var lightCount = lightDatas.count
        renderCommandEncoder.setFragmentBytes(&lightCount,
                                              length: Int32.size,
                                              index: 2)
        renderCommandEncoder.setFragmentBytes(&lightDatas,
                                              length: LightData.stride(lightDatas.count),
                                              index: 3)
        renderCommandEncoder.setFragmentTexture(_combinedShadowTexture, index:2)
    }
    func copyShadowTextureData(blitCommandEncoder: MTLBlitCommandEncoder){
        let finalTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: Preferences.MainDethPixelFomat,
                                                                              width: _shadowRenders[0].width,
                                                                              height: _shadowRenders[0].height,
                                                                              mipmapped: false)
        finalTextureDescriptor.arrayLength = _shadowRenders.count
        finalTextureDescriptor.textureType = .type2DArray
        finalTextureDescriptor.storageMode = .private
        _combinedShadowTexture = Engine.Device.makeTexture(descriptor: finalTextureDescriptor)!
        for i in 0..<_shadowRenders.count{
            blitCommandEncoder.copy(from: _shadowRenders[i], sourceSlice: 0, sourceLevel: 0, to: _combinedShadowTexture, destinationSlice: i, destinationLevel: 0, sliceCount:1, levelCount: 1)
        }
    }
    func passShadowData(renderCommandEncoder: MTLRenderCommandEncoder){
//        var argumentEncoder: MTLArgumentEncoder = Graphics.Shaders[.FragmentBasic].makeArgumentEncoder(bufferIndex: 6)
//        var argumentBuffer:  MTLBuffer          = Engine.Device.makeBuffer(length: argumentEncoder.encodedLength, options:[.storageModeManaged])!
//        for (index, object) in _shadowRenders.enumerated() {
//            print(argumentEncoder.encodedLength * index)
//            argumentEncoder.setArgumentBuffer(argumentBuffer, offset: argumentEncoder.encodedLength * index)
//            argumentEncoder.setTexture(object, index:1)
//        }
//        var shadowsCount = _shadowRenders.count
//        renderCommandEncoder.setFragmentBytes (&shadowsCount , length: Int32.size, index: 5)
//        renderCommandEncoder.setFragmentBuffer(argumentBuffer, offset: 0, index: 6)

        let shadowTextureCount: CountableRange = 0..<_shadowRenders.count
        renderCommandEncoder.setFragmentTextures(_shadowRenders, range: shadowTextureCount)

    }
    func shadowRender(commandBuffer: MTLCommandBuffer){
        _shadowRenders = []
        let lightDatas = gatherLightData()
        for (index, light) in lightDatas.enumerated(){
            createShadowRenderPassDescriptor(index: index)
            let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: _shadowRenderPassDescriptor)
            renderCommandEncoder?.label = "Shadow RENDER COMMAND ENCODER"
            renderCommandEncoder?.pushDebugGroup("Starting Shadow Render")
            renderCommandEncoder?.setCullMode(.front)
            var mutatableLight = light
            renderCommandEncoder?.setVertexBytes(&mutatableLight, length: LightData.stride, index: 2)
            SceneManager.ShadowRender(renderCommandEncoder: renderCommandEncoder!)
            renderCommandEncoder?.popDebugGroup()
            renderCommandEncoder?.endEncoding()
        }
        
    }
    static func calculate_lookAt_matrix(position: float3, target: float3, worldUp: float3) -> float4x4
    {
        // 1. Position = known
        // 2. Calculate cameraDirection
        let zaxis: float3 = normalize(position - target);
        // 3. Get positive right axis vector
        let xaxis: float3 = normalize(cross(normalize(worldUp), zaxis));
        // 4. Calculate camera up vector
        let yaxis: float3 = cross(zaxis, xaxis);

        // Create translation and rotation matrix
        // In glm we access elements as mat[col][row] due to column-major layout
        var translation: float4x4 = matrix_identity_float4x4; // Identity matrix by default
        translation[3][0] = -position.x; // Third column, first row
        translation[3][1] = -position.y;
        translation[3][2] = -position.z;
        var rotation: float4x4 = matrix_identity_float4x4;
        rotation[0][0] = xaxis.x; // First column, first row
        rotation[1][0] = xaxis.y;
        rotation[2][0] = xaxis.z;
        rotation[0][1] = yaxis.x; // First column, second row
        rotation[1][1] = yaxis.y;
        rotation[2][1] = yaxis.z;
        rotation[0][2] = zaxis.x; // First column, third row
        rotation[1][2] = zaxis.y;
        rotation[2][2] = zaxis.z;

        // Return lookAt matrix as combination of translation and rotation matrix
        return rotation * translation; // Remember to read from right to left (first translation then rotation)
    }

}
