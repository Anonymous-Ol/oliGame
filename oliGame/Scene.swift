//
//  Scene.swift
//  oliGame
//
//  Created by Oliver Crumrine on 11/26/22.
//

import MetalKit

class Scene: Node{
    
            var _cameraManager = CameraManager()
    private var _sceneConstants = SceneConstants()
    private var _cubeMapSceneConstants: MTLBuffer!
    private var _cameraPos: MTLBuffer!
    private var _shadowSceneConstants = SceneConstants()
    private var _lightManager = LightManager()
    private var _reflectionRender: MTLTexture!
    private var _combinedShadowTexture: MTLTexture!
    private var _reflectionRenderPassDescriptor: MTLRenderPassDescriptor!
    private var _renderingReflections: Bool = false
    private var _reflectionPitch: Float = 0
    private var _reflectionYaw:   Float = 0
    private var _reflectionRoll:  Float = 0
    
    
    override init(name: String){
        super.init(name: name)
        _cubeMapSceneConstants = Engine.Device.makeBuffer(length: SceneConstants.stride(6), options: [])
        _cameraPos = Engine.Device.makeBuffer(length: float3.stride(6), options: [])
        buildScene()
    }
    func buildScene(){
        
    }
    func  addCamera(_ camera: Camera, _ isCurrentCamera: Bool = true){
        _cameraManager.registerCamera(camera: camera)
        if(isCurrentCamera){
            _cameraManager.setCamera(camera.cameraType)
        }
    }
    func addLight(_ lightObject: LightObject){
        self.addChild(lightObject)
        _lightManager.addLightObject(lightObject)
    }
    
    func updateCameras(deltaTime: Float){
        _cameraManager.update(deltaTime: deltaTime)
    }
    
    func createReflectionRenderPassDescriptor(){
        
        let reflectionTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm_srgb,
                                                                                   width: 300,
                                                                                   height: 300,
                                                                                   mipmapped: false)
        
        
        reflectionTextureDescriptor.textureType = .typeCube
        reflectionTextureDescriptor.storageMode = .private
        reflectionTextureDescriptor.usage = [.renderTarget, .shaderRead]
        //reflectionTextureDescriptor.arrayLength = 6
        
        let reflectionDepthTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .depth32Float,
                                                                                        width: 300,
                                                                                        height: 300,
                                                                                        mipmapped: false)
        
        
        reflectionDepthTextureDescriptor.textureType = .typeCube
        reflectionDepthTextureDescriptor.storageMode = .private
        reflectionDepthTextureDescriptor.usage = [.renderTarget, .shaderRead]
        //reflectionDepthTextureDescriptor.arrayLength = 6
        
        _reflectionRender = Engine.Device.makeTexture(descriptor: reflectionTextureDescriptor)!
        var depthTexture: MTLTexture = Engine.Device.makeTexture(descriptor: reflectionDepthTextureDescriptor)!
        
        
        
        self._reflectionRenderPassDescriptor = MTLRenderPassDescriptor()
        
        
        self._reflectionRenderPassDescriptor.colorAttachments[0].texture = _reflectionRender
        self._reflectionRenderPassDescriptor.colorAttachments[0].loadAction =  .clear
        self._reflectionRenderPassDescriptor.colorAttachments[0].storeAction = .store
        
        self._reflectionRenderPassDescriptor.depthAttachment.texture = depthTexture
        
        self._reflectionRenderPassDescriptor.renderTargetArrayLength = 6
        
        
        
        
    }
    
    override func update(deltaTime: Float){
        _sceneConstants.totalGameTime = GameTime.TotalGameTime
        _sceneConstants.viewMatrix = _cameraManager.currentCamera.viewMatrix
        _sceneConstants.skyViewMatrix = _sceneConstants.viewMatrix
        _sceneConstants.skyViewMatrix[3][0] = 0
        _sceneConstants.skyViewMatrix[3][1] = 0
        _sceneConstants.skyViewMatrix[3][2] = 0
        _sceneConstants.projectionMatrix = _cameraManager.currentCamera.projectionMatrix
        
        super.update(deltaTime:  deltaTime)
        
    }
    
    override func render(renderCommandEncoder: MTLRenderCommandEncoder) {
        if(!_renderingReflections){
            renderCommandEncoder.setVertexBytes(&_sceneConstants, length: SceneConstants.stride, index: 1)
            renderCommandEncoder.setFragmentBytes(&_sceneConstants.cameraPosition, length: float3.stride, index: 4)
            _lightManager.setLightData(renderCommandEncoder)
            super.render(renderCommandEncoder: renderCommandEncoder)
        }
    }
    func copyShadowData(blitCommandEncoder: MTLBlitCommandEncoder){
        _lightManager.copyShadowTextureData(blitCommandEncoder: blitCommandEncoder)
    }
    override func shadowRender(renderCommandEncoder: MTLRenderCommandEncoder) {
        super.shadowRender(renderCommandEncoder: renderCommandEncoder)
    }
    func doReflectionRender(commandBuffer: MTLCommandBuffer) {
        
        super.reflectionRender(commandBuffer: commandBuffer)
    }
    func ReflectionRender(commandBuffer: MTLCommandBuffer, position: float3) -> MTLTexture{
        _renderingReflections = true
        generateCubeMapSceneConstants(position: position)
        createReflectionRenderPassDescriptor()
        let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: _reflectionRenderPassDescriptor)
        renderCommandEncoder?.label = "Reflection Render Command Encoder"
        renderCommandEncoder?.pushDebugGroup("Starting Reflection Render")
        _lightManager.setLightData(renderCommandEncoder!)
        renderCommandEncoder?.setVertexBuffer(_cubeMapSceneConstants, offset: 0, index: 1)
        renderCommandEncoder?.setFragmentBuffer(_cameraPos, offset:0, index: 4)
        super.cubeMapRender(renderCommandEncoder: renderCommandEncoder!)
        renderCommandEncoder?.popDebugGroup()
        renderCommandEncoder?.endEncoding()
        _renderingReflections = false
        return(_reflectionRender)
    }
    override func cubeMapRender(renderCommandEncoder: MTLRenderCommandEncoder) {
        
    }
    func doShadowRender(commandBuffer: MTLCommandBuffer){
        _lightManager.shadowRender(commandBuffer: commandBuffer)
    }
    static func calculate_lookAt_matrix(position: float3, target: float3, worldUp: float3) -> float4x4
    {
        // 1. Position = known
        // 2. Calculate cameraDirection
        let zaxis = normalize(position - target);
        // 3. Get positive right axis vector
        let xaxis = normalize(cross(normalize(worldUp), zaxis));
        // 4. Calculate camera up vector
        let yaxis = cross(zaxis, xaxis);

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

    static func ortho(
    left: Float,
        right: Float,
        bottom: Float,
        top: Float,
        zNear: Float,
        zFar: Float
    ) -> float4x4
    {
        var Result: float4x4 = matrix_identity_float4x4;
        Result[0][0] = (2) / (right - left);
        Result[1][1] = (2) / (top - bottom);
        Result[2][2] = -(2) / (zFar - zNear);
        Result[3][0] = -(right + left) / (right - left);
        Result[3][1] = -(top + bottom) / (top - bottom);
        Result[3][2] = -(zFar + zNear) / (zFar - zNear);
        return Result;
    }
    func generateCubeMapSceneConstants(position: float3){
        var cubeMapSceneConstantsPointer = _cubeMapSceneConstants.contents().bindMemory(to: SceneConstants.self, capacity: 6)
        var cameraPosPointer = _cameraPos.contents().bindMemory(to: float3.self, capacity: 6)
        for i in 0...6{
            switchToFace(faceIndex: i)
            let projectionMatrix = matrix_float4x4.perspective(degreesFov: 90, aspectRation: 1, near: 0.1, far: 1000)
            var translation: float4x4 = matrix_identity_float4x4; // Identity matrix by default
            translation[3][0] = -position.x; // Third column, first row
            translation[3][1] = -position.y;
            translation[3][2] = -position.z;
            var rotation: float4x4 = matrix_identity_float4x4;
            rotation.rotate(angle: _reflectionPitch, axis: X_AXIS)
            rotation.rotate(angle: _reflectionYaw, axis: Y_AXIS)
            rotation.rotate(angle: 0, axis: Z_AXIS)
            let viewMatrix = rotation * translation;

            var faceConstants: SceneConstants = SceneConstants()
            faceConstants.totalGameTime = GameTime.TotalGameTime
            faceConstants.viewMatrix = viewMatrix
            faceConstants.skyViewMatrix = viewMatrix
            faceConstants.skyViewMatrix[3][0] = 0
            faceConstants.skyViewMatrix[3][1] = 0
            faceConstants.skyViewMatrix[3][2] = 0
            faceConstants.projectionMatrix = projectionMatrix
            faceConstants.cameraPosition = float3(0,2,0)
            cubeMapSceneConstantsPointer.pointee = faceConstants
            cameraPosPointer.pointee = faceConstants.cameraPosition
            cubeMapSceneConstantsPointer = cubeMapSceneConstantsPointer.advanced(by: 1)
            cameraPosPointer = cameraPosPointer.advanced(by: 1)
        }
    }
    func switchToFace(faceIndex: Int) {
        switch (faceIndex) {
        case 0:
            _reflectionPitch = Float(0).toRadians
            _reflectionYaw = Float(-90).toRadians
            _reflectionRoll = Float(180).toRadians
            break
        case 1:
            _reflectionPitch = Float(0).toRadians
            _reflectionYaw = Float(90).toRadians
            _reflectionRoll = Float(180).toRadians
            break
        case 2:
            _reflectionPitch = Float(-90).toRadians
            _reflectionYaw = Float(180).toRadians
            _reflectionRoll = Float(180).toRadians
            break
        case 3:
            _reflectionPitch = Float(90).toRadians
            _reflectionYaw = Float(180).toRadians
            _reflectionRoll = Float(180).toRadians
            break
        case 4:
            _reflectionPitch = Float(0).toRadians
            _reflectionYaw = Float(180).toRadians
            _reflectionRoll = Float(180).toRadians
            break
        case 5:
            _reflectionPitch = Float(0).toRadians
            _reflectionYaw = Float(0).toRadians
            _reflectionRoll = Float(180).toRadians
            break
        default:
            break
        }
        }
}

