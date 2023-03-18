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
    private var joints = [jointNode]()
    init(_ mdlSkeleton: MDLSkeleton) {
        name = mdlSkeleton.name
        jointPaths = mdlSkeleton.jointPaths
        inverseBindTransforms = mdlSkeleton.jointBindTransforms.float4x4Array.map { $0.inverse }
        restTransforms = mdlSkeleton.jointRestTransforms.float4x4Array
        joints = makeSkeletonHierarchy(from: jointPaths)
        for (jointIndex, joint) in zip(0..., joints) {
            joint.transform = restTransforms[jointIndex]
        }
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
        var jointBufferPointer = buffer.contents().bindMemory(to: ModelConstants.self, capacity: joints.count)
        _ = zip(0..., joints).map { index, joint in
            jointBufferPointer.pointee.modelMatrix = joint.worldTransform * inverseBindTransforms[index]
            jointBufferPointer = jointBufferPointer.advanced(by: 1)
        }
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
    private(set) var childNodes = [jointNode]()
    var name = ""
    var transform: float4x4 = matrix_identity_float4x4
    var worldTransform: float4x4 {
        if let parent = parentNode {
            return parent.worldTransform * transform
        } else {
            return transform
        }
    }
    weak var parentNode: jointNode?
    func addChildNode(_ node: jointNode) {
        childNodes.append(node)
        node.parentNode = self
    }
}
