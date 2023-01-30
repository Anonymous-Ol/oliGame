//
//  FrustumStuff.swift
//  oliGame
//
//  Created by Oliver Crumrine on 1/30/23.
//
import simd

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
        var (nc,fc) = <-float3(0,0,0)

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

        pl[planeTypes.TOP.rawValue].set3Points(v1: ntr,v2: ntl,v3: ftl);
        pl[planeTypes.BOTTOM.rawValue].set3Points(v1: nbl,v2: nbr,v3: fbr);
        pl[planeTypes.LEFT.rawValue].set3Points(v1: ntl,v2: nbl,v3: fbl);
        pl[planeTypes.RIGHT.rawValue].set3Points(v1: nbr,v2: ntr,v3: fbr);

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
    func sphereInFrustum(p: float3, radius: Float) -> Bool {
        
        var d = Float(0.0);
        var (az,ax,ay) = <-Float(0.0);
        var result: Bool = true;
        
        var v = p-camPos;
        
        az = innerProduct(x: v, v: -Z)
        if (az > farD + radius || az < nearD-radius){
            return(false);
        }
        if (az > farD - radius || az < nearD+radius){
            result = true;
        }
        
        ay = innerProduct(x: v, v: Y)
        d = sphereFactorY * radius;
        az *= tang;
        if (ay > az+d || ay < -az-d){
            return(false);
        }
        if (ay > az-d || ay < -az+d){
            result = true;
        }
        
        ax = innerProduct(x: v, v: X)
        az *= ratio;
        d = sphereFactorX * radius;
        if (ax > az+d || ax < -az-d){
            return(false);
        }
        if (ax > az-d || ax < -az+d){
            result = true;
        }
        
        return(result);
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
