//
//  Types.swift
//  oliGame
//
//  Created by Oliver Crumrine on 11/26/22.
//
import simd
import MetalKit

public typealias float2 = SIMD2<Float>
public typealias float3 = SIMD3<Float>
public typealias float4 = SIMD4<Float>

//Multiple variable initizlization
prefix operator <-
prefix func <-<T>(_ v: T) -> (T, T) { (v, v) }
prefix func <-<T>(_ v: T) -> (T, T, T) { (v, v, v) }
prefix func <-<T>(_ v: T) -> (T, T, T, T) { (v, v, v, v) }
prefix func <-<T>(_ v: T) -> (T, T, T, T, T, T, T, T, T, T, T, T) { (v, v, v, v, v, v, v, v, v, v, v, v) }

protocol sizeable{

}

extension sizeable {
    static var size: Int{
        return MemoryLayout<Self>.size
    }
    static var stride: Int{
        return MemoryLayout<Self>.stride
    }
    static func stride(_ count: Int)->Int{
        return MemoryLayout<Self>.stride * count
    }
    static func size(_ count: Int)->Int{
        return MemoryLayout<Self>.size * count
    }
}

    enum planeTypes: Int{
        case TOP = 0
        case BOTTOM = 1
        case LEFT = 2
        case RIGHT = 3
        case NEARP = 4
        case FARP = 5
    }


extension UInt32: sizeable{}
extension float3: sizeable{}
extension Float:  sizeable{}
extension float4: sizeable{}
extension float2: sizeable{}
extension Int32:  sizeable{}
extension Bool:   sizeable{}

struct Vertex: sizeable{
    var position: float3
    var color: float4
    var textureCoordinate: float2
    var normal: float3
    
    var tangent: float3
    var bitangent: float3
}

struct ModelConstants: sizeable{
    var modelMatrix = matrix_identity_float4x4
}
struct SceneConstants: sizeable {
    var totalGameTime: Float = 0
    var viewMatrix = matrix_identity_float4x4
    var skyViewMatrix = matrix_identity_float4x4
    var projectionMatrix = matrix_identity_float4x4
    var cameraPosition: float3 = float3(0,0,0)
}
struct Material: sizeable{
    var color = float4(0.8,0.8,0.8,1.0)
    var isLit: Bool = true
    var useBaseTexture: Bool = false
    var useNormalMapTexture: Bool = false
    
    var ambient: float3 =  float3(0.3, 0.3,0.3)
    var diffuse: float3 =  float3(1,1,1)
    var specular: float3 = float3(1,1,1)
    var shininess: Float = 50
    
    var reflectivity: Float = 0
}
struct LightData: sizeable{
    var position: float3 =    float3(0,0,0)
    var color: float3 =       float3(1,1,1)
    var brightness:           Float  =  1.0
    var ambientInensity:      Float  =  1.0
    var diffuseIntensity:     Float  =  1.0
    var specularIntensity:    Float  =  1.0
    var lookAtPosition:float3=float3(0,0,0)
    var orthoSize:            Float  =   35
    var near:                 Float  =  0.1
    var far:                  Float  = 1000
    
    
}

struct Plan
{
    // unit vector
    var normal: float3 = float3(0.0, 1.0, 0.0)

    // distance from origin to the nearest point in the plan
    var distance: Float = 0.0
    
    func getSignedDistanceToPlan(point: float3) -> Float{
        return dot(normal, point) - distance
    }
    func HalfSpace(v: float3) -> Float{
        return (normal.x*v.x) + (normal.y*v.y) + (normal.z*v.z) + distance
        //let n: float3 = normal
        //return dot(n, v) - distance
    }
    

}
class FrustumR{

    var pl = [Plane(), Plane(), Plane(), Plane(), Plane(), Plane()]
    var (ntl,ntr,nbl,nbr,ftl,ftr,fbl,fbr,X,Y,Z,camPos) = <-SIMD3<Float>(0,0,0)
    var (nearD, farD, ratio, angle) = <-Float(0)
    var (sphereFactorX, sphereFactorY) = <-Float(0)
    var tang: Float = Float(0)
    var (nw,nh,fw,fh) = <-Float(0)
    init(){
    
    }
    
    func setCamInternals(angle: Float, ratio: Float, nearD: Float, farD: Float) {

        // store the information
        self.ratio = ratio
        self.angle = angle * (3.14159265358979323846/360.0)
        self.nearD = nearD
        self.farD = farD

        // compute width and height of the near and far plane sections
        tang = tan(self.angle)
        sphereFactorY = 1.0/cos(self.angle)//tang * sin(this->angle) + cos(this->angle);

        let anglex: Float = atan(tang*ratio)
        sphereFactorX = 1.0/cos(anglex) //tang*ratio * sin(anglex) + cos(anglex);

        self.nh = nearD * tang
        self.nw = nh * ratio

        self.fh = farD * tang
        self.fw = fh * ratio

    }
    func setCamDef(p: float3, l: float3, u: float3) {
        var (dir,nc,fc) = <-float3(0,0,0)

        self.camPos = p

        // compute the Z axis of camera
        self.Z = p - l
        self.Z = normalize(self.Z)

        // X axis of camera of given "up" vector and Z axis
        self.X = cross(u,Z)
        self.X = normalize(self.X)

        // the real "up" vector is the cross product of Z and X
        self.Y = cross(self.Z, self.X);

        // compute the center of the near and far planes
        nc = p - self.Z * self.nearD
        fc = p - self.Z * self.farD

        // compute the 8 corners of the frustum
        self.ntl = nc + self.Y * self.nh - self.X * self.nw
        self.ntr = nc + self.Y * self.nh + self.X * self.nw
        self.nbl = nc - self.Y * self.nh - self.X * self.nw
        self.nbr = nc - self.Y * self.nh + self.X * self.nw

        self.ftl = fc + self.Y * self.fh - self.X * self.fw
        self.fbr = fc - self.Y * self.fh + self.X * self.fw
        self.ftr = fc + self.Y * self.fh + self.X * self.fw
        self.fbl = fc - self.Y * self.fh - self.X * self.fw

        // compute the six planes
        // the function set3Points asssumes that the points
        // are given in counter clockwise order
        pl[planeTypes.TOP.rawValue].set3Points(v1: ntr,v2: ntl,v3: ftl);
        pl[planeTypes.BOTTOM.rawValue].set3Points(v1: nbl,v2: nbr,v3: fbr);
        pl[planeTypes.LEFT.rawValue].set3Points(v1: ntl,v2: nbl,v3: fbl);
        pl[planeTypes.RIGHT.rawValue].set3Points(v1: nbr,v2: ntr,v3: fbr);
    //    pl[NEARP].set3Points(ntl,ntr,nbr);
    //    pl[FARP].set3Points(ftr,ftl,fbl);

        pl[planeTypes.NEARP.rawValue].setNormalAndPoint(normal: -Z,point: nc)
        pl[planeTypes.FARP.rawValue].setNormalAndPoint(normal: Z,point: fc)

        var (aux,normal) = <-float3(0,0,0)

        aux = (nc + Y*nh) - p;
        normal = aux * X;
        pl[planeTypes.TOP.rawValue].setNormalAndPoint(normal: normal,point: nc+Y*nh);

        aux = (nc - Y*nh) - p;
        normal = X * aux;
        pl[planeTypes.BOTTOM.rawValue].setNormalAndPoint(normal: normal,point: nc-Y*nh);
        
        aux = (nc - X*nw) - p;
        normal = aux * Y;
        pl[planeTypes.LEFT.rawValue].setNormalAndPoint(normal: normal,point: nc-X*nw);

        aux = (nc + X*nw) - p;
        normal = Y * aux;
        pl[planeTypes.RIGHT.rawValue].setNormalAndPoint(normal: normal,point: nc+X*nw);
    }
    func pointInFrustum(p: float3) -> Bool{

        var (pcz,pcx,pcy,aux) = <-Float(0.0)

        // compute vector from camera position to p
        var v: float3 = p-camPos

        // compute and test the Z coordinate
        pcz = innerProduct(x: v, v: -Z)
        if (pcz > farD || pcz < nearD){
            return false
        }

        // compute and test the Y coordinate
        pcy = innerProduct(x: v, v: Y)
        aux = pcz * tang
        if (pcy > aux || pcy < -aux){
            return false
        }
            
        // compute and test the X coordinate
        pcx = innerProduct(x: v, v: X)
        aux = aux * ratio
        if (pcx > aux || pcx < -aux){
            return false
        }


        return true

        
    }
}
class Plane{
    var normal: float3
    var point:  float3
    var d:      Float
    init(v1: float3? = nil, v2: float3? = nil, v3: float3? = nil){
        normal = float3(0,0,0)
        point  = float3(0,0,0)
        d      = 0
        if(v1 == nil || v2 == nil || v2 == nil){
        }else{
            self.set3Points(v1: v1!, v2: v2!, v3: v3!)
        }
    }
    func set3Points(v1: float3, v2: float3, v3: float3) {


        var aux1: float3
        var aux2: float3

        aux1 = v1 - v2
        aux2 = v3 - v2

        normal = aux2 * aux1;

        normal = normalize(normal)
        point = v2
        d = -(innerProduct(x: normal,v: point))

    }
    func setNormalAndPoint(normal: float3, point: float3) {

        self.normal = normal
        self.normal = normalize(self.normal)
        d = -(innerProduct(x: normal, v: point))
    }
    func setCoefficients(a: Float, b: Float, c: Float, d: Float) {

        // set the normal vector
        normal = float3(a,b,c)
        //compute the lenght of the vector
        var l: Float = length(normal)
        // normalize the vector
        normal = float3(a/l,b/l,c/l)
        // and divide d by th length as well
        self.d = d/l
    }
    func distance(p: float3) -> Float{

        return (d + innerProduct(x: normal, v: p));
    }
}

func innerProduct(x: float3, v: float3) -> Float{
    return (x.x * v.x + x.y * v.y + x.z * v.z)
}
func length(x: float3) -> Float{
    return (sqrt(x.x*x.x + x.y*x.y + x.z*x.z))
}

struct Frustum
{
    var topFace: Plan
    var bottomFace: Plan

    var rightFace: Plan
    var leftFace: Plan

    var farFace: Plan
    var nearFace: Plan
}

struct Sphere{
    var center: float3 = float3(repeating: 0)
    var radius: Float = 0
    
    func isOnOrForwardPlan(plan: Plan) -> Bool{
        return plan.getSignedDistanceToPlan(point: center) > -radius
    }
}
    
