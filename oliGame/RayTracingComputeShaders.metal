//
//  RayTracingComputeShaders.metal
//  oliGame
//
//  Created by Oliver Crumrine on 4/16/23.
//
#pragma once
#include <metal_stdlib>
//#include "RayTracingClasses.metal"
#include "loki_header.metal"
#define M_PI 3.14159265358979323846

using namespace metal;


class ray{
public:
    float3 origin;
    float3 direction;
    ray(const float3 orig, const float3 dir){
        origin = orig;
        direction = dir;
    }
    ray(){
        origin = float3(0,0,0);
        direction = float3(0,0,0);
    }
    float3 rayAtPoint(float t){
        return origin + t*direction;
    }
};
class camera {
public:
    camera() {
        float aspectRatio = 16.0 / 9.0;
        float cameraHeight = 2;
        float cameraWidth = aspectRatio * cameraHeight;
        float focalLength = 1.0;
        
        origin = float3(0, 0, 0);
        horizontal = float3(cameraWidth, 0.0, 0.0);
        vertical = float3(0.0, cameraHeight, 0.0);
        lower_left_corner = origin - horizontal/2 - vertical/2 - float3(0, 0, focalLength);
    }
    
    ray get_ray(float u, float v){
        return ray(origin, lower_left_corner + u*horizontal + v*vertical - origin);
    }
    
private:
    float3 origin;
    float3 lower_left_corner;
    float3 horizontal;
    float3 vertical;
};

struct hit_record {
    float3 p;
    float3 normal;
    float t;
    bool front_face;
    
    void set_face_normal(ray r, float3 outward_normal) {
        front_face = dot(r.direction, outward_normal) < 0;
        normal = front_face ? outward_normal :-outward_normal;
    }
};
struct hit_return{
    bool hit;
    hit_record rec;
};

class sphere{
public:
    sphere() {
        exists = false;
    }
    sphere(float3 cen, float r){
        exists = true;
        center = cen;
        radius = r;
        
    };
    
    hit_return hit(ray r, float t_min, float t_max);
    
public:
    bool exists = false;
    float3 center;
    float radius;
};
float rand(int x, int y, int z)
{
    int seed = x + y * 57 + z * 241;
    seed= (seed<< 13) ^ seed;
    return (( 1.0 - ( (seed * (seed * seed * 15731 + 789221) + 1376312589) & 2147483647) / 1073741824.0f) + 1.0f) / 2.0f;
}
int simpleRand(int x, int y, int z){
    return ((x + y + z) % 499);
}
float random_double(float min, float max, int x, int y, int z) {
    // Returns a random real in [min,max).
    return min + (max-min)*rand(x, y, z);
}
float3 random_float3(int x, int y, int z){
    return float3(rand(x,y,z), rand(y,x,z), rand(z,x,y));
}
float3 random_float3(float min, float max, int x, int y, int z){
    return float3(random_double(min, max, x, y, z), random_double(min, max, y, z, x), random_double(min, max, x, z, y));
}
float3 random_in_unit_sphere(int x, int y, int z){
    while (true) {
        auto p = random_float3(-1,1, x, y, z);
        if (pow(length(p), 2) >= 1) continue;
        return p;
    }
}
float hash(float3 p) {
    return fract(sin(dot(p, float3(12.9898, 78.233, 45.5432))) * 43758.5453);
}

float3 random_point_in_unit_sphere(float2 seed) {
    float3 p = float3(fract(sin(dot(seed, float2(127.1, 311.7))) * 43758.5453),
                      fract(sin(dot(seed, float2(269.5, 183.3))) * 43758.5453),
                      fract(sin(dot(seed, float2(419.2, 371.9))) * 43758.5453));
    return normalize(p);
}
float3 randomPointInUnitSphere(float x, float y, float z) {
    float3 point;
    float r = rand(x, y, z); // generate random value between 0 and 1
    float theta = rand(y, z, x) * 2.0 * M_PI; // generate random angle between 0 and 2pi
    float phi = acos(2.0 * rand(z, x, y) - 1.0); // generate random angle between 0 and pi
    point.x = r * sin(phi) * cos(theta);
    point.y = r * sin(phi) * sin(theta);
    point.z = r * cos(phi);
    return point;
}
hit_return sphere::hit(ray r, float t_min, float t_max){
    hit_record rec;
    hit_return ret;
    
    float3 oc = r.origin - center;
    auto a = pow(length(r.direction),2);
    auto half_b = dot(oc, r.direction);
    auto c = pow(length(oc),2) - radius*radius;
    
    
    auto discriminant = half_b*half_b - a*c;
    if (discriminant < 0){
        ret.hit = false;
        return ret;
    }
    auto sqrtd = sqrt(discriminant);
    
    // Find the nearest root that lies in the acceptable range.
    auto root = (-half_b - sqrtd) / a;
    if (root < t_min || t_max < root) {
        root = (-half_b + sqrtd) / a;
        if (root < t_min || t_max < root)
            ret.hit = false;
            return ret;
        
    }
    
    rec.t = root;
    rec.p = r.rayAtPoint(rec.t);
    float3 outward_normal = (rec.p - center) / radius;
    rec.set_face_normal(r, outward_normal);
    ret.rec = rec;
    ret.hit = true;
    return ret;
}


class hittable_list {
public:
    hittable_list(){
        maxObjects = 2;
        objectsUpTo = 0;
        for(int i = 0; i < 100; i++){
            exits[i] = false;
        }
    }
    
    void add(sphere object) {
        objects[objectsUpTo] = object;
        exits[objectsUpTo] = true;
        objectsUpTo++;
    }
    
    hit_return hit(ray r, float t_min, float t_max);
    
public:
    int    maxObjects = 2;
    int    objectsUpTo = 0;
    bool   exits[100];
    sphere objects[100];
    
};
hit_return hittable_list::hit(ray r, float t_min, float t_max) {
    hit_record rec;
    hit_record temp_rec;
    hit_return ret;
    bool hit_anything = false;
    auto closest_so_far = t_max;
    //For some reason if I just set it to maxObjects gpu time goes up to ~25ms (~35fps)
    int funcMaxObjects = maxObjects;
    
    
    //
    for (int i = 0; i < 2; i++) {
            if ((ret = objects[i].hit(r, t_min, closest_so_far)).hit) {
                temp_rec = ret.rec;
                hit_anything = true;
                closest_so_far = temp_rec.t;
                rec = temp_rec;
            }
    }
    
    hit_return returnn;
    returnn.hit = hit_anything;
    returnn.rec = rec;
    return returnn;
}

half hit_sphere(float3 center, float radius, ray r) {
    float3 oc = r.origin - center;
    auto a = pow(length(r.direction),2);
    auto half_b = dot(oc, r.direction);
    auto c = pow(length(oc),2) - radius*radius;
    auto discriminant = half_b*half_b - a*c;
    if (discriminant < 0) {
        return -1.0;
        
    } else {
        return (-half_b - sqrt(discriminant) ) / a;
    }
}
float3 unit_vector(float3 v){
    return v / length(v);
}
float3 ray_color(ray r, hittable_list world, int depth, int x, int y, int z){
    hit_return ret;
    hit_record rec;
    float3 finalColor = float3(0,0,0);
    for(int i = 0; i < 2; i++){
        
        if ((ret = world.hit(r, 0, 1000)).hit) {
            rec = ret.rec;
            finalColor +=  (0.5 * (rec.normal + float3(1,1,1))) / 2;
        }
        
        half3 unit_dir = half3(unit_vector(r.direction));
        auto t = 0.5*(unit_dir.y + 1.0);
        finalColor += (((1-t)*float3(1.0,1.0,1.0) + t*float3(0.5, 0.7, 1.0)))/2;
    }
    return finalColor;
}
//float3 ray_color2(ray r, sphere world, int depth, int x, int y, int z){
//        return float3(0,0,0);
//}
//float3 ray_color1(ray r, sphere world, int depth, int x, int y, int z){
//    hit_record rec;
//    hit_return ret;
//    if(depth <= 0){
//        return float3(0.5,0.5,0.5);
//    }
//    ret = screwinAroundWithHitSphere(r, 0 ,1000, 0.5, float3(0,0,-1));
//    return float3(0.5, 0.5, 0.5*ret.rec.p.x);
//    if ((ret = hitSphere(r, 0, 1000, 0.5, float3(0,0,-1))).hit) {
//        return float3(0.5,0.5,0.5);
//        rec = ret.rec;
//        float3 target = rec.p + rec.normal + random_in_unit_sphere(x, y, z);
//        return 0.5 * ray_color2(ray(rec.p, target - rec.p), world, (depth - 1), (x*2), (y*2), (z*2));
//    }
//    half3 unit_dir = half3(unit_vector(r.direction));
//    auto t = 0.5*(unit_dir.y + 1.0);
//    return ((1-t)*float3(1.0,1.0,1.0) + t*float3(0.5, 0.7, 1.0));
//}
//float3 ray_color0(ray r, sphere world, int depth, int x, int y, int z){
//    hit_record rec;
//    hit_return ret;
//    bool hit = false;
//    float3 target = float3(0,0,0);
//    if(depth <= 0){
//        return float3(0,0,0);
//    }
//    if ((ret = hitSphere(r, 0, 1000, 0.5, float3(0,0,-1))).hit) {
//        rec = ret.rec;
//        target = rec.p + rec.normal + random_in_unit_sphere(x, y, z);
//        hit = true;
//    }
//    if(!hit){
//
//        half3 unit_dir = half3(unit_vector(r.direction));
//        auto t = 0.5*(unit_dir.y + 1.0);
//        return ((1-t)*float3(1.0,1.0,1.0) + t*float3(0.5, 0.7, 1.0));
//    }
//    return 0.5 * ray_color1(ray(rec.p, target - rec.p), world, (depth - 1), (x*2), (y*2), (z*2));
//}
float3 ray_color_iterative(ray r, hittable_list world, int depth, int x, int y, int z, constant float3 *points){
    ray cur_ray = r;
    float cur_attenuation = 1.0;
    for (int i = 0; i < 50; i++){
        hit_return ret;
        hit_record rec;
        if((ret = world.hit(cur_ray, 0.1, 1000)).hit){
            rec = ret.rec;
            float3 target = rec.p + rec.normal + points[static_cast<int>(rand(x * i, y * i, z * i) * 500)];
            cur_attenuation *= 0.5;
            cur_ray = ray(rec.p, target - rec.p);
        }else{
            float3 unit_direction = unit_vector(cur_ray.direction);
            float t = 0.5 * (unit_direction.y + 1);
            float3 c = (1.0-t)*float3(1.0, 1.0, 1.0) + t*float3(0.5, 0.7, 1.0);
            return cur_attenuation * c;
        }
    }
    return float3(0,0,0);
}

kernel void raytrace(uint2 pixel [[thread_position_in_grid]],
                     texture2d<half, access::write> texture [[texture(1)]],
                     texture2d<half, access::write> texture2 [[texture(2)]],
                     constant float3 *points [[buffer(1)]],
                     constant float  &randomSeed [[buffer(2)]]){
    
    //Image
    half aspectRatio = 16.0/9.0;
    uint16_t imageWidth  = 2560;
    uint16_t imageHeight = imageWidth / aspectRatio;
    uint16_t samplesPerPixel = 4;
    
    camera cam;
    float3 color(0,0,0);

        //Scene
        hittable_list scene;
        sphere s(float3(0,0,-1), 0.5);
        sphere sTwo(float3(0,-100.5,-1), 100);
        scene.add(s);
        scene.add(sTwo);
    for(int i = 0; i < samplesPerPixel; i++){
        
        float u = (half(pixel.x) + rand(i, pixel.y, pixel.x)) / (imageWidth - 1);
        float v = (half(pixel.y) + rand(pixel.x, pixel.y, i)) / (imageHeight - 1);
        ray r = cam.get_ray(u, v);
        color += ray_color_iterative(r, scene, 2, pixel.x, pixel.y, i, points);
        
        
        
    }
    uint2 newPixel = uint2(pixel.x, ((pixel.y-720)*-1)+720);
    color /= samplesPerPixel;
    texture.write(half4(float4(color, 1)), newPixel);
}

