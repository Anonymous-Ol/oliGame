//
//  FirstPersonCamera.swift
//  oliGame
//
//  Created by Oliver Crumrine on 1/14/23.
//
import simd
class FirstPersonCamera: Camera{
    private  var   _pitch:                 Float  =        0
    private  var   _yaw:                   Float  =        0
    private  var   _near:                  Float  =        0.1
    private  var   _far:                   Float  =        1000
    private  var   _aspectRatio:           Float  =        1
    private  var   _fov:                   Float  =        45.0
    //private  var   _front:                 float3 = float3(0,0,0)
    //private  var   _worldUp:               float3 = float3(0,1,0)
    //private  var   _up:                    float3 = float3(0,0,0)
    //private  var   _right:                 float3 = float3(0,0,0)
    private  var   _projectionMatrix              = matrix_identity_float4x4
    //private  var   _projectionMatrixHalf          = matrix_identity_float4x4
    private  var   _cameraFrustum:         FrustumR
    //private var    _testFov:               Float = 45
    override var    projectionMatrix:      matrix_float4x4{
        return     _projectionMatrix
    }

    override var    cameraFrustum:         FrustumR {
        get{
            return _cameraFrustum
        }
        set{
            
        }
    }
    
    init(){
        _cameraFrustum = FrustumR()
        
        super.init(name: "Debug", cameraType: .debugCamera)
        _aspectRatio = Renderer.AspectRation
        _projectionMatrix = matrix_float4x4.perspective(degreesFov: _fov, aspectRation: _aspectRatio, near: _near, far: _far)
    }
    private var _moveSpeed: Float = 4.0
    private var _turnSpeed: Float = 1.0
     
    override func doUpdate(){
        if(Mouse.IsMouseButtonPressed(button: .RIGHT)){
            var mouseXPos = Mouse.GetDX()
            var mouseYPos = Mouse.GetDY()
            self.rotateY(mouseXPos * GameTime.DeltaTime * _turnSpeed)
            self._yaw += mouseXPos * GameTime.DeltaTime * _turnSpeed
            self.rotateX(mouseYPos * GameTime.DeltaTime * _turnSpeed)
            self._pitch += mouseYPos * GameTime.DeltaTime * _turnSpeed

        }
        if(Mouse.IsMouseButtonPressed(button: .CENTER)){
            self.moveX(-Mouse.GetDX() * GameTime.DeltaTime * _moveSpeed)
            self.moveY( Mouse.GetDY() * GameTime.DeltaTime * _moveSpeed)

        }
        if(Keyboard.IsKeyPressed(.rightArrow)){
            self.moveX(GameTime.DeltaTime * _moveSpeed)
            
        }
        if(Keyboard.IsKeyPressed(.leftArrow)){
            self.moveX(-GameTime.DeltaTime * _moveSpeed)
        }

        if(Keyboard.IsKeyPressed(.upArrow)){
            self.moveY(GameTime.DeltaTime * _moveSpeed)
        }
        if(Keyboard.IsKeyPressed(.downArrow)){
            self.moveY(-GameTime.DeltaTime * _moveSpeed)
        }
        self.moveZ(-Mouse.GetDWheel() * 0.1)
        _cameraFrustum = createFrustumFromCamera(cam: self)
        
    }
    override func updateModelMatrix() {
        var translation: float4x4 = matrix_identity_float4x4; // Identity matrix by default
        translation[3][0] = -self.getPosition().x; // Third column, first row
        translation[3][1] = -self.getPosition().y;
        translation[3][2] = -self.getPosition().z;
        var rotation: float4x4 = matrix_identity_float4x4;
        rotation.rotate(angle: _pitch, axis: X_AXIS)
        rotation.rotate(angle: _yaw, axis: Y_AXIS)
        rotation.rotate(angle: 0, axis: Z_AXIS)

        let combinedMatrix = rotation * translation;
        
        _viewMatrix = combinedMatrix
    }

    func createFrustumFromCamera(cam: FirstPersonCamera) -> FrustumR{
        var inverse = cam.viewMatrix.inverse
        var lap     = inverse * float4(0,0,-1,1)
        var camFrustum = FrustumR()
        camFrustum.setCamInternals(angle: cam._fov, ratio: cam._aspectRatio, nearD: cam._near, farD: cam._far)
        camFrustum.setCamDef(p: cam.getPosition(), l: float3(lap.x, lap.y, lap.z), u: float3(0,1,0))


        return camFrustum
    }

    
}
