//
//  FirstPersonCamera.swift
//  oliGame
//
//  Created by Oliver Crumrine on 1/14/23.
//
import simd
class FirstPersonCamera: Camera{
    private  var   _zoom:                  Float  =        45.0
    private  var   _pitch:                 Float  =        0
    private  var   _yaw:                   Float  =        0
    private  var   _near:                  Float  =        0.1
    private  var   _far:                   Float  =        1000
    private  var   _aspectRatio:           Float  =        1
    private  var   _fov:                   Float  =        45.0
    private  var   _fovY:                  Float  =        0.0
    private  var   _front:                 float3 = float3(0,0,0)
    private  var   _worldUp:               float3 = float3(0,1,0)
    private  var   _up:                    float3 = float3(0,0,0)
    private  var   _right:                 float3 = float3(0,0,0)
    private  var   _projectionMatrix              = matrix_identity_float4x4
    private  var   _projectionMatrixHalf          = matrix_identity_float4x4
    private  var   _cameraFrustum:         FrustumR
    private var    _testFov:               Float = 45
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
        //Created to supress an error
        let bogusPlan = Plan(normal: float3(0,0,0), distance: 0)
        _cameraFrustum = FrustumR()
        
        super.init(name: "Debug", cameraType: .debugCamera)
        _aspectRatio = Renderer.AspectRation
        _projectionMatrix = matrix_float4x4.perspective(degreesFov: _fov, aspectRation: _aspectRatio, near: _near, far: _far)
        //_projectionMatrixHalf = matrix_float4x4.perspective(degreesFov: _fov/2, aspectRation: _aspectRatio, near: _near, far: _far)
        _fovY = 2*atan(tan(_fov/2)/_aspectRatio)*180/3.14159
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
        if(Keyboard.IsKeyPressed(.w)){
            self._testFov += GameTime.DeltaTime * _moveSpeed * 5
            //self.moveZ(GameTime.DeltaTime * _moveSpeed)
        }
        if(Keyboard.IsKeyPressed(.s)){
            self._testFov -= GameTime.DeltaTime * _moveSpeed * 5
            //self.moveZ(-GameTime.DeltaTime * _moveSpeed)
        }
        if(Keyboard.IsKeyPressed(.upArrow)){
            self.moveY(GameTime.DeltaTime * _moveSpeed)
        }
        if(Keyboard.IsKeyPressed(.downArrow)){
            self.moveY(-GameTime.DeltaTime * _moveSpeed)
        }
        self.moveZ(-Mouse.GetDWheel() * 0.1)
//        updateCameraVectors()
        _projectionMatrixHalf = matrix_float4x4.perspective(degreesFov: _testFov, aspectRation: _aspectRatio, near: _near, far: _far)
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
//    func createFrustumFromCamera(cam: FirstPersonCamera) -> Frustum{
//        let aspectRatio: Float = cam._aspectRatio;
//
//        let y_scale: Float = 1.0 / tan((cam._testFov / 2.0).toRadians)
//        let x_scale: Float = y_scale * aspectRatio
//
//        let near_x: Float = cam._near * x_scale
//        let near_y: Float = cam._near * y_scale
//
//        let far_x: Float = cam._far * x_scale
//        let far_y: Float = cam._far * y_scale
//
//        let FAR_PLANE = cam._far
//
//        let left_bottom_near: float3  = float3(-near_x, -near_y, FAR_PLANE)
//        let right_bottom_near: float3 = float3( near_x, -near_y, FAR_PLANE)
//        let left_top_near: float3     = float3(-near_x,  near_y, FAR_PLANE)
//        let right_top_near: float3    = float3( near_x,  near_y, FAR_PLANE)
//
//        let left_bottom_far: float3  = float3(-far_x, -far_y, FAR_PLANE)
//        let right_bottom_far: float3 = float3( far_x, -far_y, FAR_PLANE)
//        let left_top_far: float3     = float3(-far_x,  far_y, FAR_PLANE)
//        let right_top_far: float3    = float3( far_x,  far_y, FAR_PLANE)
//
//
//        let left_bottom_near_transformed = float3((float4(left_bottom_near, 1) * cam.viewMatrix).x, (float4(left_bottom_near, 1) * cam.viewMatrix).y, (float4(left_bottom_near, 1) * cam.viewMatrix).z)
//        let right_bottom_near_transformed = float3((float4(right_bottom_near, 1) * cam.viewMatrix).x, (float4(right_bottom_near, 1) * cam.viewMatrix).y, (float4(right_bottom_near, 1) * cam.viewMatrix).z)
//        let left_top_near_transformed = float3((float4(left_top_near, 1) * cam.viewMatrix).x, (float4(left_top_near, 1) * cam.viewMatrix).y, (float4(left_top_near, 1) * cam.viewMatrix).z)
//        let right_top_near_transformed = float3((float4(right_top_near, 1) * cam.viewMatrix).x, (float4(right_top_near, 1) * cam.viewMatrix).y, (float4(right_top_near, 1) * cam.viewMatrix).z)
//
//        let left_bottom_far_transformed = float3((float4(left_bottom_far, 1) * cam.viewMatrix).x, (float4(left_bottom_far, 1) * cam.viewMatrix).y, (float4(left_bottom_far, 1) * cam.viewMatrix).z)
//        let right_bottom_far_transformed = float3((float4(right_bottom_far, 1) * cam.viewMatrix).x, (float4(right_bottom_far, 1) * cam.viewMatrix).y, (float4(right_bottom_far, 1) * cam.viewMatrix).z)
//        let left_top_far_transformed = float3((float4(left_top_far, 1) * cam.viewMatrix).x, (float4(left_top_far, 1) * cam.viewMatrix).y, (float4(left_top_far, 1) * cam.viewMatrix).z)
//        let right_top_far_transformed = float3((float4(right_top_far, 1) * cam.viewMatrix).x, (float4(right_top_far, 1) * cam.viewMatrix).y, (float4(right_top_far, 1) * cam.viewMatrix).z)
//
//        let bogusPlan = Plan(normal: float3(0,0,0), distance: 0)
//        var camFrustum: Frustum = Frustum(topFace: bogusPlan, bottomFace: bogusPlan, rightFace: bogusPlan, leftFace: bogusPlan, farFace: bogusPlan, nearFace: bogusPlan)
//
//        camFrustum.leftFace   = equation_plane(p1: left_bottom_near_transformed, p2: left_top_near_transformed,    p3: left_bottom_far_transformed  )
//        camFrustum.nearFace   = equation_plane(p1: left_bottom_near_transformed, p2: left_top_near_transformed,    p3: right_bottom_near_transformed)
//        camFrustum.farFace    = equation_plane(p1: left_bottom_far_transformed,  p2: left_top_far_transformed,     p3: right_top_far_transformed    )
//        camFrustum.bottomFace = equation_plane(p1: left_bottom_far_transformed,  p2: left_bottom_near_transformed, p3: right_bottom_near_transformed)
//        camFrustum.rightFace  = equation_plane(p1: right_bottom_far_transformed, p2: right_bottom_near_transformed,p3: right_top_far_transformed    )
//        camFrustum.farFace    = equation_plane(p1: right_top_far_transformed,    p2: right_bottom_far_transformed, p3: left_bottom_far_transformed  )
//
//        return camFrustum
//    }
    func equation_plane(p1: float3, p2: float3, p3: float3) -> Plan{
        var x1 = p1.x
        var x2 = p2.x
        var x3 = p3.x
        var y1 = p1.y
        var y2 = p2.y
        var y3 = p3.y
        var z1 = p1.z
        var z2 = p2.z
        var z3 = p3.z
        var a1 = x2 - x1;
        var b1 = y2 - y1;
        var c1 = z2 - z1;
        var a2 = x3 - x1;
        var b2 = y3 - y1;
        var c2 = z3 - z1;
        var a = b1 * c2 - b2 * c1;
        var b = a2 * c1 - a1 * c2;
        var c = a1 * b2 - b1 * a2;
        var d = (-a * x1 - b * y1 - c * z1);
        var plan: Plan = Plan(normal: float3(0,0,0), distance: 0)
        plan.normal = float3(a,b,c)
        plan.distance = d
        return plan
    }
    func createFrustumFromCamera(cam: FirstPersonCamera) -> FrustumR{
        var inverse = cam.viewMatrix.inverse
        var lap     = inverse * float4(0,0,-1,1)
        print(lap)
        var camFrustum = FrustumR()
        camFrustum.setCamInternals(angle: cam._fov, ratio: cam._aspectRatio, nearD: cam._near, farD: cam._far)
        camFrustum.setCamDef(p: cam.getPosition(), l: float3(lap.x, lap.y, lap.z), u: float3(0,1,0))
        
//        let bogusPlan = Plan(normal: float3(0,0,0), distance: 0)
//        var camFrustum: Frustum = Frustum(topFace: bogusPlan, bottomFace: bogusPlan, rightFace: bogusPlan, leftFace: bogusPlan, farFace: bogusPlan, nearFace: bogusPlan)
//        let mvpMatrix = cam._projectionMatrixHalf * cam._viewMatrix
//
//        var row1: float4 = float4(mvpMatrix[0])
//        var row2: float4 = float4(mvpMatrix[1])
//        var row3: float4 = float4(mvpMatrix[2])
//        var row4: float4 = float4(mvpMatrix[3])
//
//        var p1:   float4 = row4 + row1
//        var p2:   float4 = row4 - row1
//        var p3:   float4 = row4 + row2
//        var p4:   float4 = row4 - row2
//        var p5:   float4 = row4 + row3
//        var p6:   float4 = row4 - row3
//
//
//        camFrustum.rightFace.normal.x = p2.x
//        camFrustum.rightFace.normal.y = p2.y
//        camFrustum.rightFace.normal.z = p2.z
//        camFrustum.rightFace.normal   = normalize(camFrustum.rightFace.normal)
//        camFrustum.rightFace.distance = p2.w
//
//        camFrustum.leftFace.normal.x = p1.x
//        camFrustum.leftFace.normal.y = p1.y
//        camFrustum.leftFace.normal.z = p1.z
//        camFrustum.leftFace.normal   = normalize(camFrustum.leftFace.normal)
//        camFrustum.leftFace.distance = p1.w
//
//        //print("rightface")
//        //print(camFrustum.rightFace.normal)
//        //print(camFrustum.rightFace.distance)
//        //print("leftface")
//        //print(camFrustum.leftFace.normal)
//        //print(camFrustum.leftFace.distance)
//        //print("fov")
//        //print(_testFov)
//
//        camFrustum.topFace.normal.x = p4.x
//        camFrustum.topFace.normal.y = p4.y
//        camFrustum.topFace.normal.z = p4.z
//        camFrustum.topFace.normal    = normalize(camFrustum.topFace.normal)
//        camFrustum.topFace.distance = p4.w
//
//        camFrustum.bottomFace.normal.x = p3.x
//        camFrustum.bottomFace.normal.y = p3.y
//        camFrustum.bottomFace.normal.z = p3.z
//        camFrustum.bottomFace.normal   = normalize(camFrustum.bottomFace.normal)
//        camFrustum.bottomFace.distance = p3.w
//
//        camFrustum.farFace.normal.x = p6.x
//        camFrustum.farFace.normal.y = p6.y
//        camFrustum.farFace.normal.z = p6.z
//        camFrustum.farFace.normal   = normalize(camFrustum.farFace.normal)
//        camFrustum.farFace.distance = p6.w
//
//        camFrustum.nearFace.normal.x = p5.x
//        camFrustum.nearFace.normal.y = p5.y
//        camFrustum.nearFace.normal.z = p5.z
//        camFrustum.nearFace.normal   = normalize(camFrustum.nearFace.normal)
//        camFrustum.nearFace.distance = p5.w

        return camFrustum
    }
//    func updateCameraVectors(){
//        var front: float3 = float3(0,0,0)
//        _worldUp = float3(0,1,0)
//        front.x = cos(_yaw) * cos(_pitch)
//        front.y = sin(_pitch)
//        front.z = sin(_yaw) * cos(_pitch)
//        _front = normalize(front);
//        // also re-calculate the Right and Up vector
//        _right = normalize(cross(_front, _worldUp))  // normalize the vectors, because their length gets closer to 0 the more you look up or down which results in slower movement.
//        _up    = normalize(cross(_right, _front));
//    }
    
//    func createFrustumFromCamera(cam: FirstPersonCamera) -> Frustum
//    {
//        //Created to get rid of an error
//        let bogusPlan = Plan(normal: float3(0,0,0), distance: 0)
//        var frustum: Frustum = Frustum(topFace: bogusPlan, bottomFace: bogusPlan, rightFace: bogusPlan, leftFace: bogusPlan, farFace: bogusPlan, nearFace: bogusPlan);
//
//        var halfVSide: Float = cam._near * tanf(cam._fovY * 0.5);
//        var halfHSide: Float = halfVSide * cam._aspectRatio;
//        var frontMultFar: float3 = cam._far * cam._front;
//        let p1 = cam.getPosition()
//
//
//
//        frustum.nearFace = createPlan(p1: p1 + float3(repeating: cam._near) * cam._front, norm: cam._front)
//        frustum.farFace = createPlan(p1: p1 + frontMultFar, norm: -cam._front)
//        frustum.rightFace = createPlan(p1: p1, norm: cross(cam._up, frontMultFar + cam._right * halfHSide))
//        frustum.leftFace = createPlan(p1: p1, norm: cross(frontMultFar - cam._right * halfHSide, cam._up)) //Same as right face
//        frustum.topFace = createPlan(p1: p1, norm: cross(cam._right, frontMultFar - cam._up * halfVSide))
//        frustum.bottomFace = createPlan(p1: p1, norm: cross(frontMultFar + cam._up * halfVSide, cam._right))
//
//        return frustum;
//    }
//    func createPlan(p1: float3, norm: float3) -> Plan{
//        var plan = Plan()
//        plan.normal = normalize(norm)
//        plan.distance = dot(plan.normal, p1)
//        return plan
//    }

    
}
