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
    
    private var _position: float3 = float3(0)
    private var _scale: float3 = float3(1)
    private var _rotation: float3 = float3(0)
    private var _children: [Node] = []
    
    var parentModelMatrix = matrix_identity_float4x4
    private var _modelMatrix = matrix_identity_float4x4
    var modelMatrix: matrix_float4x4{
        return matrix_multiply(parentModelMatrix, _modelMatrix)
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
    func update(deltaTime: Float){
        doUpdate()
        for child in _children{
            child.parentModelMatrix = self.modelMatrix
            child.update(deltaTime: deltaTime)
        }
    }
    func render(renderCommandEncoder: MTLRenderCommandEncoder){
        renderCommandEncoder.pushDebugGroup("Rendering \(_name)")
        for child in _children{
            child.render(renderCommandEncoder: renderCommandEncoder)
        }
        if let renderable = self as? Renderable{
            renderable.doRender(renderCommandEncoder: renderCommandEncoder)
        }
        renderCommandEncoder.popDebugGroup()
    }

}

extension Node {
    //Naming
    func setName(_ name: String){ self._name = name }
    func getName()->String{ return _name }
    func getID()->String { return _id }
    
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
    func getRotation()->float3 { return self._rotation }
    func getRotationX()->Float { return self._rotation.x }
    func getRotationY()->Float { return self._rotation.y }
    func getRotationZ()->Float { return self._rotation.z }
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
        updateModelMatrix()
    }
    func getScale()->float3 { return self._scale }
    func getScaleX()->Float { return self._scale.x }
    func getScaleY()->Float { return self._scale.y }
    func getScaleZ()->Float { return self._scale.z }
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
}
