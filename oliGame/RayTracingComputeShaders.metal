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
#include <simd/simd.h>
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

//MARK: RANDOM NUMBER GENERATION
uint32_t pcg_hash(uint32_t input)
{
    uint32_t state = input * 747796405u + 2891336453u;
    uint32_t word = ((state >> ((state >> 28u) + 4u)) ^ state) * 277803737u;
    return (word >> 22u) ^ word;
}
float pcg_hash_float(uint32_t input)
{
    uint32_t max = 4294967295;
    uint32_t state = input * 747796405u + 2891336453u;
    uint32_t word = ((state >> ((state >> 28u) + 4u)) ^ state) * 277803737u;
    return (((word >> 22u) ^ word) / static_cast<float>(max));
}
float rand(int x, int y, int z)
{
    int seed = x + y * 57 + z * 241;
    seed= (seed<< 13) ^ seed;
    return (( 1.0 - ( (seed * (seed * seed * 15731 + 789221) + 1376312589) & 2147483647) / 1073741824.0f) + 1.0f) * 0.5f;
}
float rand2(int x, int y, int z)
{
    int seed = x + y * 57 + z * 241;
    seed = (seed << 13) ^ seed;
    return 1.0 - (fmod(fma(seed * seed * seed + 15731.0 * seed + 789221.0, seed, 1376312589.0), 2147483647.0) / 1073741824.0) * 0.5;
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
    for (int i = 0; i < 15; i++) {
        auto p = random_float3(-1,1, x + i, y - i, z * i);
        if (dot(p, p) >= 1) continue;
        return p;
    }
    return float3(0.1, 0.1, 0.1);
}
float3 random_in_unit_sphere2(int seed_x, int seed_y, int seed_z)
{
    for (int i = 0; i < 1000; i++) {
        
        
        int seed = seed_x + seed_y * 57 + seed_z * 241;
        seed = (seed << 13) ^ seed;
        float3 rand_vec = float3(
                                 ((seed * (seed * seed * 15731 + 789221) + 1376312589) & 0x7fffffff) / float(0x7fffffff),
                                 ((seed * (seed * seed * 16807 + 2147483647) + 1376312589) & 0x7fffffff) / float(0x7fffffff),
                                 ((seed * (seed * seed * 48271 + 2147483647) + 1376312589) & 0x7fffffff) / float(0x7fffffff)
                                 );
        if (dot(rand_vec, rand_vec) >= 1) continue;
        return rand_vec;
    }
    return float3(0.1, 0.1, 0.1);
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
uint rand3(uint x, uint y, uint z) {
    uint seed = x + y * 57u + z * 241u;
    seed ^= seed << 13u;
    seed ^= seed >> 17u;
    seed ^= seed << 5u;
    return seed;
}
float fast_random(uint2 seed) {
    // This is a simple implementation of a linear congruential generator (LCG).
    // It has good statistical properties and is very fast.
    // The LCG algorithm uses a fixed set of coefficients (a, c, and m) to
    // generate a sequence of pseudorandom numbers. The current value of the seed
    // is multiplied by a, added to c, and then taken modulo m to get the next
    // value in the sequence.
    
    const ulong a = 1664525u;
    const ulong c = 1013904223u;
    const ulong m = 4294967296u;
    
    ulong x = dot(float2(seed), float2(a, c));
    seed = uint2(x, x >> 32u);
    return float(x) / float(m);
}
float random_double3(float min, float max, uint x, uint y, uint z) {
    // Returns a random real in [min,max).
    uint randVal = rand3(x, y, z);
    return fma(float(randVal & 0x7fffffffu), 1.0f / 2147483648.0f, min) * (max - min);
}

float3 random_float33(float min, float max, uint x, uint y, uint z){
    return float3(random_double3(min, max, x, y, z), random_double3(min, max, y, z, x), random_double3(min, max, x, z, y));
}
float3 random_in_unit_sphere4(int x, int y, int z) {
    int runs = 0;
    float3 p;
    int limit = 15;
    do {
        runs++;
        float3 randVec = float3(
            1.0f - rand(x + runs, z, y),
            1.0f - rand(x + runs, y, z),
            1.0f - rand(x + runs, z, y)
        ) * 2.0f - 1.0f;
        p = randVec * (1.0f / sqrt(dot(randVec, randVec)));
    } while (dot(p, p) >= 1.0f && --limit > 0);
    return p;
}

float3 random_in_unit_sphere3(uint x, uint y, uint z){
    for (uint i = 0; i < 15u; i++) {
        auto p = random_float33(-1.0f, 1.0f, x + i, y - i, z * i);
        if (dot(p, p) >= 1.0f) continue;
        return p;
    }
    return float3(0.1f, 0.1f, 0.1f);
}
//MARK: END OF RANDOM NUMBER GENERATION

hit_return sphere::hit(ray r, float t_min, float t_max){
    hit_record rec;
    hit_return ret;
    
    float3 oc = r.origin - center;
    auto a = length_squared(r.direction);
    auto half_b = dot(oc, r.direction);
    auto c = length_squared(oc) - radius*radius;
    
    
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
    hit_return temp_ret;
    bool hit_anything = false;
    auto closest_so_far = t_max;
    
    
    
    
    for (int i = 0; i < 2; i++) {
        if ((temp_ret = objects[i].hit(r, t_min, closest_so_far)).hit) {
            temp_rec = temp_ret.rec;
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

float3 ray_color_iterative(ray r, thread hittable_list* world, int depth, int x, int y, int z, constant float3 *points){
    ray cur_ray = r;
    float cur_attenuation = 1.0;
    for (int i = 0; i < 5; i++){
        hit_return ret;
        hit_record rec;

        if((ret = world->hit(cur_ray, 0.001, 100000000000)).hit){
            rec = ret.rec;
            float3 target = rec.p + rec.normal + random_in_unit_sphere(x * (i + 1), y * (i + 1), z - (i + 1));
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
                     constant float2 &randomSeed [[buffer(2)]]){
    
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
    float2 newRandomSeed = randomSeed;
    for(int i = 0; i < samplesPerPixel; i++){
        newRandomSeed.x *= i;
        newRandomSeed.y /= i;
        newRandomSeed.x += pixel.x;
        newRandomSeed.y += pixel.y;
        float u = (half(pixel.x) + pcg_hash_float((uint32_t) randomSeed.x)) / (imageWidth - 1);
        float v = (half(pixel.y) + pcg_hash_float((uint32_t) randomSeed.y)) / (imageHeight - 1);
        ray r = cam.get_ray(u, v);
        color += ray_color_iterative(r, &scene, 1,  pixel.x + randomSeed.x * 2, pixel.y - randomSeed.y, i + randomSeed.y, points);
        //
        //
        //
    }
    uint2 newPixel = uint2(pixel.x, ((pixel.y-720)*-1)+720);
    color /= samplesPerPixel;
    texture.write(half4(float4(color, 1)), newPixel);
}

