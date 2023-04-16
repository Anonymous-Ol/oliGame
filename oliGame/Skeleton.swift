//
//  Skeleton.swift
//  oliGame
//
//  Created by Oliver Crumrine on 2/20/23.
//

import ModelIO
import MetalKit
import simd


class Skeleton {
    let name: String
    let jointPaths: [String]
    let inverseBindTransforms: [float4x4]
    let restTransforms: [float4x4]
    var jointCount: Int {
        return joints.count
    }
    var joints = [jointNode]()
    init(_ mdlSkeleton: MDLSkeleton) {
        name = mdlSkeleton.name
        jointPaths = mdlSkeleton.jointPaths
        inverseBindTransforms = mdlSkeleton.jointBindTransforms.float4x4Array.map { $0.inverse }
        restTransforms = mdlSkeleton.jointRestTransforms.float4x4Array
        joints = makeSkeletonHierarchy(from: jointPaths)
        for (jointIndex, joint) in zip(0..., joints) {
//            print(jointIndex)
//            print(joint.name)
//            print(restTransforms[jointIndex])
            joint.transform = restTransforms[jointIndex]
        }
    }
    func printJoints(level: Int = 0){
        for _ in 0...level*4{
            print(" ", terminator: "")
        }
        print(self.name)

        for _ in 0...level*4{
            print(" ", terminator: "")
        }
        print("joints:")
        for joint in joints {
            joint.printJoints(level: level + 1)
        }
        for _ in 0...level*4{
            print(" ", terminator: "")
        }
        print("done")
    }
    
    

    func apply(animation: JointAnimation, at time: TimeInterval) {
        // Get the animated local transforms of the joints affected by the animation
        let animatedTransforms = animation.jointTransforms(at: time)
        // Since animations may not affect every joint, the loop below has two indices:
        // one holding the index of the joint in this skeleton, and one holding the
        // index of the joint in the animation's joints list. If a joint in this skeleton
        // does not appear in the animation, we reset it to its rest transformation.
        for (skeletonJointIndex, jointPath) in zip(0..., jointPaths) {
            if let animationJointIndex = animation.jointPaths.firstIndex(of: jointPath) {
                joints[skeletonJointIndex].transform = animatedTransforms[animationJointIndex] 
            } else {
                joints[skeletonJointIndex].transform = restTransforms[skeletonJointIndex]
            }
        }
        //print(animation.name)
    }
    func makeSkeletonHierarchy(from jointPaths: [String]) -> [jointNode] {
        var joints = [jointNode]()
        var jointsForPaths = [String : jointNode]()
        for jointPath in jointPaths {
            let joint = jointNode()
            joint.name = name
            jointsForPaths[jointPath] = joint
            joints.append(joint)
        }
        for jointPath in jointPaths {
            let child = jointsForPaths[jointPath]!
            let parentPath = (jointPath as NSString).deletingLastPathComponent as String
            let parent = jointsForPaths[parentPath]
            child.name = (jointPath as NSString).lastPathComponent as String
            parent?.addChildNode(child)
        }
        return joints
    }
    func copyTransforms(into buffer: MTLBuffer) {
        var jointBufferPointer: UnsafeMutablePointer = buffer.contents().bindMemory(to: ModelConstants.self, capacity: joints.count)
        _ = zip(0..., joints).map { index, joint in
            jointBufferPointer.pointee.modelMatrix = joint.worldTransform * inverseBindTransforms[index]
            jointBufferPointer = jointBufferPointer.advanced(by: 1)
        }
    }
    func copyTransformsArray() -> [ModelConstants]{
        var modelConstArray: [ModelConstants] = []
        _ = zip(0..., joints).map { index, joint in
            modelConstArray.append(ModelConstants(modelMatrix:joint.worldTransform * inverseBindTransforms[index]))
        }
        return modelConstArray
    }
    func getRequiredBufferLength() -> Int{
        return joints.count + 1
    }
}

struct Skinner {
    let skeleton: Skeleton
    let geometryBindTransform: float4x4

    init(_ skeleton: Skeleton,
         _ geometryBindTransform: float4x4 = matrix_identity_float4x4)
    {
        self.skeleton = skeleton
        self.geometryBindTransform = geometryBindTransform
    }
}
class jointNode{
    var position: float3 = float3(repeating: 0)
    var scale: float3 = float3(repeating: 1)
    var rotation: float3 = float3(repeating: 0)
    var id: UUID = UUID()
    var skinner: Skinner!
    private(set) var childNodes = [jointNode]()
    var radius: Float = 1
    var culled = false
    var cullable = true
    var topLevelObject = false
    var name = ""
    var instancedGameObjectNode = false
    var staticObject = true
    var transform: float4x4 = matrix_identity_float4x4
    var aabb: AABBInstanced!
    private var currentAnimation: JointAnimation! = nil
    init(){
        
    }
    func printJoints(level: Int = 0){
        for _ in 0...level*4{
            print(" ", terminator: "")
        }
        print(self.name)

        for _ in 0...level*4{
            print(" ", terminator: "")
        }
        print("joints:")
        for joint in childNodes {
            joint.printJoints(level: level + 1)
        }
        for _ in 0...level*4{
            print(" ", terminator: "")
        }
        print("done")
    }
    var worldTransform: float4x4 {
        if let parent = parentNode {
//            print(self.getName())
//            print("parent:")
//            print(parent.getName())
//            print(parent.worldTransform)
            return parent.worldTransform * transform
        } else {
            return transform
        }
    }

    func updateTransform(){
        transform = matrix_identity_float4x4
        transform.translate(direction: position)
        transform.scale(axis: scale)
        transform.rotate(angle: rotation.x, axis: X_AXIS)
        transform.rotate(angle: rotation.y, axis: Y_AXIS)
        transform.rotate(angle: rotation.z, axis: Z_AXIS)
        
    }
    func updateAnimation(at time: TimeInterval) {
        if let animation: JointAnimation = currentAnimation, let skinner = skinner {
            let localTime = max(0, time - animation.startTime)
            let loopTime = fmod(localTime, animation.duration)
            skinner.skeleton.apply(animation: animation, at: loopTime)
        }
        if(aabb != nil){
            aabb.update()
        }
        if(instancedGameObjectNode && topLevelObject && aabb != nil){
            if(staticObject){
                print(staticObject)
                AABBCollision.addStaticGameObject(object: aabb.AABBParams)
            }else{
                print(staticObject)
                AABBCollision.addMovingGameObject(object: aabb.AABBParams)
            }
        }
    }
    func afterRotation(){}
    func afterTranslation(){}
    func afterScale(){}

    weak var parentNode: jointNode?
    func addChildNode(_ node: jointNode) {
        childNodes.append(node)
        node.parentNode = self
    }
}
extension jointNode {
    //Naming
    func setName(_ name: String){ self.name = name }
    func getName()->String{ return name }
    
    func setRadius(radius: Float){
        self.radius = radius
    }
    //Positioning and Movement
    func setPosition(_ position: float3){
        self.position = position
        updateTransform()
        afterTranslation()
    }
    func setPosition(_ x: Float,_ y: Float,_ z:Float){setPosition(float3(x,y,z))}
    func setPositionX(_ xPosition: Float) {
        self.position.x = xPosition
        updateTransform()
    }
    func setPositionY(_ yPosition: Float) {
        self.position.y = yPosition
        updateTransform()
    }
    func setPositionZ(_ zPosition: Float) {
        self.position.z = zPosition
        updateTransform()
    }
    func getPosition()->float3 { return self.position }
    func getPositionX()->Float { return self.position.x }
    func getPositionY()->Float { return self.position.y }
    func getPositionZ()->Float { return self.position.z }
    func move(_ x: Float, _ y: Float, _ z: Float){ self.position += float3(x,y,z) }
    func moveX(_ delta: Float){
        self.position.x += delta
        updateTransform()
    }
    func moveY(_ delta: Float){
        self.position.y += delta
        updateTransform()
    }
    func moveZ(_ delta: Float){
        self.position.z += delta
        updateTransform()
    }
    
    //Rotating
    func setRotation(_ rotation: float3) {
        self.rotation = rotation
        updateTransform()
        afterRotation()
    }
    func setRotation(_ x: Float,_ y: Float,_ z: Float){setRotation(float3(x,y,z))}
    func setRotationX(_ xRotation: Float) {
        self.rotation.x = xRotation
        updateTransform()
    }
    func setRotationY(_ yRotation: Float) {
        self.rotation.y = yRotation
        updateTransform()
    }
    func setRotationZ(_ zRotation: Float) {
        self.rotation.z = zRotation
        updateTransform()
    }
    func addRotationX(_ xRotation: Float) {
        self.rotation.x += xRotation
        updateTransform()
    }
    func addRotationY(_ yRotation: Float) {
        self.rotation.y += yRotation
        updateTransform()
    }
    func addRotationZ(_ zRotation: Float) {
        self.rotation.z += zRotation
        updateTransform()
    }
    func getRotation()->float3 { return self.rotation }
    func getRotationX()->Float { return self.rotation.x }
    func getRotationY()->Float { return self.rotation.y }
    func getRotationZ()->Float { return self.rotation.z }
    func getModelMatrixPosition() -> float3 { return float3(self.worldTransform[3][0], self.worldTransform[3][1], self.worldTransform[3][2]) }
    func rotate(_ x: Float, _ y: Float, _ z: Float){ self.rotation += float3(x,y,z) }
    func rotateX(_ delta: Float){
        self.rotation.x += delta
        updateTransform()
    }
    func rotateY(_ delta: Float){
        self.rotation.y += delta
        updateTransform()
    }
    func rotateZ(_ delta: Float){
        self.rotation.z += delta
        updateTransform()
    }
    
    //Scaling
    func setScale(_ scale: float3){
        self.scale = scale
        updateTransform()
        afterScale()
    }
    func setScale(_ scale: Float){
        setScale(float3(scale, scale, scale))
        updateTransform()
    }
    func setSclae(_ x: Float,_ y: Float,_ z: Float){
        setScale(float3(x,y,z))
        updateTransform()
    }
    func setScaleX(_ scaleX: Float){
        self.scale.x = scaleX
        updateTransform()
    }
    func setScaleY(_ scaleY: Float){
        self.scale.y = scaleY
        updateTransform()
    }
    func setScaleZ(_ scaleZ: Float){
        self.scale.z = scaleZ
        self.radius = self.radius * reduce_max(getModelMatrixScale())
        updateTransform()
    }
    func getScale()->float3 { return self.scale }
    func getScaleX()->Float { return self.scale.x }
    func getScaleY()->Float { return self.scale.y }
    func getScaleZ()->Float { return self.scale.z }
    func getModelMatrixScale()->float3 {
        let scaleX: Float = sqrt(pow(self.worldTransform[0][0],2) + pow(self.worldTransform[0][1],2) + pow(self.worldTransform[0][2], 2))
        let scaleY: Float = sqrt(pow(self.worldTransform[1][0],2) + pow(self.worldTransform[1][1],2) + pow(self.worldTransform[1][2], 2))
        let scaleZ: Float = sqrt(pow(self.worldTransform[2][0],2) + pow(self.worldTransform[2][1],2) + pow(self.worldTransform[2][2], 2))
        return float3(scaleX, scaleY, scaleZ)
    }
    func scaleX(_ delta: Float){
        self.scale.x += delta
        updateTransform()

    }
    func scaleY(_ delta: Float){
        self.scale.y += delta
        updateTransform()
    }
    func scaleZ(_ delta: Float){
        self.scale.z += delta
        updateTransform()
    }
    
    func setCullable(_ cullable: Bool){
        self.cullable = cullable
        for child in childNodes{
            child.cullable = cullable
        }
    }
    func isCullable() -> Bool{
        return self.cullable
    }
    func setSkinner(skinner: Skinner){
        self.skinner = skinner
        for child in childNodes{
            setSkinner(skinner: skinner)
        }
    }
    func runAnimation(_ animation: JointAnimation) {
        self.currentAnimation = animation
    }
}
class JointAnimation {
    let name: String
    let jointPaths: [String]
    let startTime: TimeInterval
    let duration: TimeInterval
    let translations: MDLAnimatedVector3Array
    let rotations: MDLAnimatedQuaternionArray
    let scales: MDLAnimatedVector3Array

    init(_ animation: MDLPackedJointAnimation) {
        name = animation.name
        jointPaths = animation.jointPaths
        translations = animation.translations
        rotations = animation.rotations
        scales = animation.scales

        startTime = animation.minimumTime
        duration = animation.maximumTime - startTime
    }

    func jointTransforms(at time: TimeInterval) -> [float4x4] {
        let translationsAtTime = translations.float3Array(atTime: time)
        let rotationsAtTime = rotations.floatQuaternionArray(atTime: time)
        let scalesAtTime = scales.float3Array(atTime: time)
        return zip(translationsAtTime, zip(rotationsAtTime, scalesAtTime)).map {
            let (translation, (orientation, scale)) = $0
            return getTranslationMatrix(translation: translation, orientation: orientation, scale: scale)
        }
    }
    private func getTranslationMatrix(translation: SIMD3<Float>, orientation: simd_quatf, scale: SIMD3<Float>) -> float4x4 {
        let R = float3x3(orientation)
        return (float4x4(SIMD4<Float>(scale.x * R.columns.0, 0), SIMD4<Float>(scale.y * R.columns.1, 0), SIMD4<Float>(scale.z * R.columns.2, 0), SIMD4<Float>(translation, 1))
            
        )
    }
}
extension MDLPackedJointAnimation {
  var minimumTime: TimeInterval {
    return [translations, rotations, scales]
     .reduce(TimeInterval.greatestFiniteMagnitude) { return min($0, $1.minimumTime) }
  }
  var maximumTime: TimeInterval {
    return [translations, rotations, scales]
      .reduce(-TimeInterval.greatestFiniteMagnitude) { return max($0, $1.maximumTime) }
  }
}
extension MDLObject {
  var animationBind: MDLAnimationBindComponent? {
    return components.filter({
      $0 is MDLAnimationBindComponent
    }).first as? MDLAnimationBindComponent
  }
}
