//
//  Node.swift
//  oliGame
//
//  Created by Oliver Crumrine on 11/26/22.
//

import MetalKit

class Node{

    private var _name: String = "Node"
    private var _id: String!
    
    private var currentAnimation: JointAnimation! = nil
    var lastPos: float3 = float3(0,0,0)
    var printMD: Bool = false
    var movementDelta: float3 = float3(0,0,0)
    private var _position: float3 = float3(repeating: 0)
    private var _scale: float3 = float3(repeating: 1)
    private var _rotation: float3 = float3(repeating: 0)
            var _children: [Node] = []
    var camFrustum: FrustumR = FrustumR()
    private var _cullable:   Bool = true
    var radius:     Float  = 1
    var culled = false
    var reflective = false
    var preventRender = false
    var topLevelObject = false

    var skinner: Skinner?
    var transform = matrix_identity_float4x4 //Extra modelMatrix for skelatal animation //Shut up previous me its frickin useless //Shut up previous me its actually useful //Shut up previous me it actually is useless //Actually its useful for some stuff that hadnt been added when I said it was useless //Hmmmm i wonder what this is actually useful for anyway ill just trust my previous self
    var parentModelMatrix = matrix_identity_float4x4
    private var _modelMatrix = matrix_identity_float4x4
    var modelMatrix: matrix_float4x4{
        return matrix_multiply(matrix_multiply(transform, _modelMatrix), parentModelMatrix)
    }
    func addAABB(){
        //To be overriden
    }
    func printChildren(level: Int = 0){
        for _ in 0...level*4{
            print(" ", terminator: "")
        }
        print(self.getName())
        for _ in 0...level*4{
            print(" ", terminator: "")
        }
        print(self.topLevelObject)
        for _ in 0...level*4{
            print(" ", terminator: "")
        }
        print("skinner joints count:")
        for _ in 0...level*4{
            print(" ", terminator: "")
        }
        print(self.skinner?.skeleton.joints.count)
         
//        for joint in self.skinner?.skeleton.joints ?? []{
//            for _ in 0...level*4{
//                print(" ", terminator: "")
//            }
//            print(joint.getName())
//            for _ in 0...level*4{
//                print(" ", terminator: "")
//            }
//            print("parent:")
//            for _ in 0...level*4{
//                print(" ", terminator: "")
//            }
//            print(joint.parentNode?.getName())
//            for _ in 0...level*4{
//                print(" ", terminator: "")
//            }
//            print("parentID:")
//            for _ in 0...level*4{
//                print(" ", terminator: "")
//            }
//            print(joint.parentNode?.id.uuidString)
//        }
        for _ in 0...level*4{
            print(" ", terminator: "")
        }
        print("children:")
        for child in _children{
            child.printChildren(level: level + 1)
        }
        for _ in 0...level*4{
            print(" ", terminator: "")
        }
        print("done")
    }
    func updateModelMatrix(){
        _modelMatrix = matrix_identity_float4x4
        _modelMatrix.translate(direction: _position)
        _modelMatrix.scale(axis: _scale)
        _modelMatrix.rotate(angle: _rotation.x, axis: X_AXIS)
        _modelMatrix.rotate(angle: _rotation.y, axis: Y_AXIS)
        _modelMatrix.rotate(angle: _rotation.z, axis: Z_AXIS)
    }
    
    init(name: String){
        self._name = name
        self._id =   UUID().uuidString
    }
    
    func addChild(_ child: Node){
        _children.append(child)
    }
    func afterRotation(){}
    func afterTranslation(){}
    func afterScale(){}
    func doUpdate() {}
    func onCollision(newPos: float3){
        self.move(-movementDelta.x, -movementDelta.y, -movementDelta.z)
    }
    func update(deltaTime: Float){
        movementDelta = self.getPosition() - lastPos
        if(printMD){
            print(movementDelta)
        }
        doUpdate()
        updateAnimation(at: TimeInterval(GameTime.TotalGameTime))
        for child in _children{

            child.parentModelMatrix = self.modelMatrix
            child.update(deltaTime: deltaTime)
        }
        lastPos = self.getPosition()
        
    }

    func updateAnimation(at time: TimeInterval) {
        if let animation: JointAnimation = currentAnimation, let skinner = skinner {
            let localTime = max(0, time - animation.startTime)
            let loopTime = fmod(localTime, animation.duration)
            skinner.skeleton.apply(animation: animation, at: loopTime)
        }
    }
    func childNode(named name: String, recursive: Bool = true) -> Node? {
        if let child = _children.first(where: { $0.getName() == name } ) {
            return child
        } else if recursive {
            for child in _children {
                if let grandchild = child.childNode(named: name) {
                    return grandchild
                }
            }
        }
        return nil
    }
    func setupRender(renderCommandEncoder: MTLRenderCommandEncoder){
        for child in _children{
            child.setupRender(renderCommandEncoder: renderCommandEncoder)
        }
        if let renderable = self as? Renderable{
            RenderVariables.stuffToRender.append(renderable.setupRender(cameraPos: SceneManager.currentScene._cameraManager.currentCamera.getPosition()))
        }
    }
    func shadowRender(renderCommandEncoder: MTLRenderCommandEncoder){
        renderCommandEncoder.pushDebugGroup("Rendering \(_name) Shadows")
        for child in _children{
            child.shadowRender(renderCommandEncoder: renderCommandEncoder)
        }
        if let renderable = self as? Renderable{
            renderable.doShadowRender(renderCommandEncoder: renderCommandEncoder)
        }
        renderCommandEncoder.popDebugGroup()
    }
    func reflectionRender(){
        for child in _children{
            child.reflectionRender()
        }
        if let renderable = self as? Renderable{
            renderable.doReflectionRender()
        }
    }
    func cubeMapRender(renderCommandEncoder: MTLRenderCommandEncoder){
        renderCommandEncoder.pushDebugGroup("Rendering \(_name) CubeMap")
        for child in _children{
            child.cubeMapRender(renderCommandEncoder: renderCommandEncoder)
        }
        if let renderable = self as? Renderable{
            renderable.doCubeMapRender(renderCommandEncoder: renderCommandEncoder)
        }
        renderCommandEncoder.popDebugGroup()
    }


}

extension Node {
    //Naming
    func setName(_ name: String){ self._name = name }
    func getName()->String{ return _name }
    func getID()->String { return _id }
    
    func setRadius(radius: Float){
        self.radius = radius
    }
    //Positioning and Movement
    func setPosition(_ position: float3){
        self._position = position
        updateModelMatrix()
        afterTranslation()
    }
    func setPosition(_ x: Float,_ y: Float,_ z:Float){setPosition(float3(x,y,z))}
    func setPositionX(_ xPosition: Float) {
        self._position.x = xPosition
        updateModelMatrix()
    }
    func setPositionY(_ yPosition: Float) {
        self._position.y = yPosition
        updateModelMatrix()
    }
    func setPositionZ(_ zPosition: Float) {
        self._position.z = zPosition
        updateModelMatrix()
    }
    func getPosition()->float3 { return self._position }
    func getPositionX()->Float { return self._position.x }
    func getPositionY()->Float { return self._position.y }
    func getPositionZ()->Float { return self._position.z }
    func move(_ x: Float, _ y: Float, _ z: Float){ self._position += float3(x,y,z) }
    func moveX(_ delta: Float){
        self._position.x += delta
        updateModelMatrix()
    }
    func moveY(_ delta: Float){
        self._position.y += delta
        updateModelMatrix()
    }
    func moveZ(_ delta: Float){
        self._position.z += delta
        updateModelMatrix()
    }
    
    //Rotating
    func setRotation(_ rotation: float3) {
        self._rotation = rotation
        updateModelMatrix()
        afterRotation()
    }
    func setRotation(_ x: Float,_ y: Float,_ z: Float){setRotation(float3(x,y,z))}
    func setRotationX(_ xRotation: Float) {
        self._rotation.x = xRotation
        updateModelMatrix()
    }
    func setRotationY(_ yRotation: Float) {
        self._rotation.y = yRotation
        updateModelMatrix()
    }
    func setRotationZ(_ zRotation: Float) {
        self._rotation.z = zRotation
        updateModelMatrix()
    }
    func addRotationX(_ xRotation: Float) {
        self._rotation.x += xRotation
        updateModelMatrix()
    }
    func addRotationY(_ yRotation: Float) {
        self._rotation.y += yRotation
        updateModelMatrix()
    }
    func addRotationZ(_ zRotation: Float) {
        self._rotation.z += zRotation
        updateModelMatrix()
    }
    func getRotation()->float3 { return self._rotation }
    func getRotationX()->Float { return self._rotation.x }
    func getRotationY()->Float { return self._rotation.y }
    func getRotationZ()->Float { return self._rotation.z }
    func getModelMatrixPosition() -> float3 { return float3(self.modelMatrix[3][0], self.modelMatrix[3][1], self.modelMatrix[3][2]) }
    func rotate(_ x: Float, _ y: Float, _ z: Float){ self._rotation += float3(x,y,z) }
    func rotateX(_ delta: Float){
        self._rotation.x += delta
        updateModelMatrix()
    }
    func rotateY(_ delta: Float){
        self._rotation.y += delta
        updateModelMatrix()
    }
    func rotateZ(_ delta: Float){
        self._rotation.z += delta
        updateModelMatrix()
    }
    
    //Scaling
    func setScale(_ scale: float3){
        self._scale = scale
        updateModelMatrix()
        afterScale()
    }
    func setScale(_ scale: Float){
        setScale(float3(scale, scale, scale))
        updateModelMatrix()
    }
    func setSclae(_ x: Float,_ y: Float,_ z: Float){
        setScale(float3(x,y,z))
        updateModelMatrix()
    }
    func setScaleX(_ scaleX: Float){
        self._scale.x = scaleX
        updateModelMatrix()
    }
    func setScaleY(_ scaleY: Float){
        self._scale.y = scaleY
        updateModelMatrix()
    }
    func setScaleZ(_ scaleZ: Float){
        self._scale.z = scaleZ
        self.radius = self.radius * reduce_max(getModelMatrixScale())
        updateModelMatrix()
    }
    func getScale()->float3 { return self._scale }
    func getScaleX()->Float { return self._scale.x }
    func getScaleY()->Float { return self._scale.y }
    func getScaleZ()->Float { return self._scale.z }
    func getModelMatrixScale()->float3 {
        var scaleX: Float = sqrt(pow(self.modelMatrix[0][0],2) + pow(self.modelMatrix[0][1],2) + pow(self.modelMatrix[0][2], 2))
        var scaleY: Float = sqrt(pow(self.modelMatrix[1][0],2) + pow(self.modelMatrix[1][1],2) + pow(self.modelMatrix[1][2], 2))
        var scaleZ: Float = sqrt(pow(self.modelMatrix[2][0],2) + pow(self.modelMatrix[2][1],2) + pow(self.modelMatrix[2][2], 2))
        return float3(scaleX, scaleY, scaleZ)
    }
    func scaleX(_ delta: Float){
        self._scale.x += delta
        updateModelMatrix()

    }
    func scaleY(_ delta: Float){
        self._scale.y += delta
        updateModelMatrix()
    }
    func scaleZ(_ delta: Float){
        self._scale.z += delta
        updateModelMatrix()
    }
    
    func setCullable(_ cullable: Bool){
        self._cullable = cullable
        for child in _children{
            child._cullable = cullable
        }
    }
    func isCullable() -> Bool{
        return self._cullable
    }
    func setSkinner(skinner: Skinner){
        self.skinner = skinner
        for child in _children{
            setSkinner(skinner: skinner)
        }
    }
    
    func runAnimation(_ animation: JointAnimation) {
        self.currentAnimation = animation
    }
    func printAnimation(){
        if(self.currentAnimation != nil){
            print(self.currentAnimation.name)
        }
        for child in _children{
            child.printAnimation()
        }
    }
}
