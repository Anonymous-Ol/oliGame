//
//  Scene.swift
//  oliGame
//
//  Created by Oliver Crumrine on 11/26/22.
//

import MetalKit

class Scene: Node{
    
    private var _cameraManager = CameraManager()
    private var _sceneConstants = SceneConstants()
    private var _lightManager = LightManager()
    
    override init(name: String){
        super.init(name: name)
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

    override func update(deltaTime: Float){
        _sceneConstants.totalGameTime = GameTime.TotalGameTime
        _sceneConstants.viewMatrix = _cameraManager.currentCamera.viewMatrix
        _sceneConstants.skyViewMatrix = _sceneConstants.viewMatrix
        _sceneConstants.skyViewMatrix[3][0] = 0
        _sceneConstants.skyViewMatrix[3][1] = 0
        _sceneConstants.skyViewMatrix[3][2] = 0
        _sceneConstants.projectionMatrix = _cameraManager.currentCamera.projectionMatrix
        _sceneConstants.cameraPosition = _cameraManager.currentCamera.getPosition()
        super.update(deltaTime:  deltaTime)
        
    }
    
    override func render(renderCommandEncoder: MTLRenderCommandEncoder) {
        renderCommandEncoder.setVertexBytes(&_sceneConstants, length: SceneConstants.stride, index: 1)
        renderCommandEncoder.setFragmentBytes(&_sceneConstants.cameraPosition, length: float3.stride, index: 4)
        _lightManager.setLightData(renderCommandEncoder)
        super.render(renderCommandEncoder: renderCommandEncoder)
    }
    override func shadowRender(renderCommandEncoder: MTLRenderCommandEncoder) {
        _lightManager.setShadowLightData(renderCommandEncoder)
        super.shadowRender(renderCommandEncoder: renderCommandEncoder)
    }
    static func calculate_lookAt_matrix(position: float3, target: float3, worldUp: float3) -> float4x4
    {
        // 1. Position = known
        // 2. Calculate cameraDirection
        var zaxis = normalize(position - target);
        // 3. Get positive right axis vector
        var xaxis = normalize(cross(normalize(worldUp), zaxis));
        // 4. Calculate camera up vector
        var yaxis = cross(zaxis, xaxis);

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
}

