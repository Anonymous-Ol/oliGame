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
//MATERIAL TYPES
//0: SOME KIND OF ERROR OR PROBLEM. 0 WON'T BE INTERSECTED
//1: LAMBERTIAN. ALBEDO MUST BE SPECIFIED
//2: METAL. ALBEDO MUST BE SPECIFIED
struct material{
    int type = 0;
    float3 albedo;
};
struct hit_return{
    bool hit;
    hit_record rec;
    material mat;
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
    sphere(float3 cen, float r, material material){
        exists = true;
        center = cen;
        radius = r;
        mat = material;
    }
    
    hit_return hit(ray r, float t_min, float t_max);
    
public:
    material mat;
    bool exists = false;
    float3 center;
    float radius;
};
float2 hash22(float2 p) {
    float3 p3 = fract(float3(p.xyx) * float3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yzx+33.33);
    return fract((p3.xx+p3.yz)*p3.zy);

}
float3 hash32(float2 p) {
    float3 p3 = fract(float3(p.xyx) * float3(0.1031, 0.1030, 0.0973));
    p3 += dot(p3, p3.yxz+33.33);
    p3 = fract((p3.xxy+p3.yzz)*p3.zyx);
    p3 *= fract(p.xxy + 0.1);
    p3 = fract(p3 * 123.456);
    
    float2 px = p * 2.3282 + float2(120, 120);
    float3 p3x = fract(float3(px.xyx) * float3(0.1031, 0.1030, 0.0973));
    p3x += dot(p3x, p3x.yxz+33.33);
    p3x = fract((p3x.xxy+p3.yzz)*p3x.zyx);
    p3x *= fract(px.xxy + 0.1);
    p3x = fract(p3x * 123.456);
    return mix(p3, p3x, 0.5);
}

float3 random_in_unit_sphere_newnew(float2 p) {
    float3 rand = hash32(p);
    float phi = 2.0 * 3.14159f * rand.x;
    float cosTheta = 2.0 * rand.y - 1.0;
    float u = rand.z;

    float theta = acos(cosTheta);
    float r = pow(u, 1.0 / 3.0);

    float x = r * sin(theta) * cos(phi);
    float y = r * sin(theta) * sin(phi);
    float z = r * cos(theta);

    return float3(x, y, z);
}
float3 random_in_hemisphere(float2 p, float3 normal){
    float3 in_unit_sphere = random_in_unit_sphere_newnew(p);
    if (dot(in_unit_sphere, normal) > 0.0) // In the same hemisphere as the normal
        return in_unit_sphere;
    else
        return -in_unit_sphere;
}


float pcg_hash_float(uint32_t seed)
{
    uint32_t max = 4294967295;
    seed = (seed ^ 61) ^ (seed >> 16);
    seed *= 9;
    seed = seed ^ (seed >> 4);
    seed *= 0x27d4eb2d;
    seed = seed ^ (seed >> 15);
    return (seed / static_cast<float>(max));
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
float random_doubleNewRand(float min, float max, int x) {
    // Returns a random real in [min,max).
    return min + (max-min)*pcg_hash_float(x);
}
float3 random_float3(int x, int y, int z){
    return float3(rand(x,y,z), rand(y,x,z), rand(z,x,y));
}
float3 random_float3(float min, float max, int x, int y, int z){
    return float3(random_double(min, max, x, y, z), random_double(min, max, y, z, x), random_double(min, max, x, z, y));
}
float3 random_float3NewRand(float min, float max, int x){
    return float3(random_doubleNewRand(min, max, x*2), random_doubleNewRand(min, max, x + 50), random_doubleNewRand(min, max, x * 3));
}
float3 random_in_unit_sphere(int x, int y, int z){
    for (int i = 0; i < 5; i++) {
        auto p = random_float3(-1,1, x + i, y - i, z * i);
        if (dot(p, p) >= 1) continue;
        return p;
    }
    return float3(0.1, 0.1, 0.1);
}
float3 random_in_unit_sphereNewRand(int x){
    for (int i = 0; i < 15; i++) {
        auto p = random_float3NewRand(-1,1, x * (i + 1));
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
float random_float(float2 seed) {
    // Hash the seed value to generate two random numbers
    uint2 hash = (uint2) (seed * 43758.5453);
    uint random1 = (uint) (hash.x ^ hash.y);
    uint random2 = (uint) (hash.y ^ hash.x);
    
    // Combine the two random numbers to generate a float between 0 and 1
    uint combined = (random1 << 16) | (random2 >> 16);
    float result = (float) (combined & 0x007FFFFF) / (float) 0x7FFFFF;
    
    return result;
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
    material mat;
    bool hit_anything = false;
    auto closest_so_far = t_max;
    
    
    
    
    for (int i = 0; i < 4; i++) {
        if ((temp_ret = objects[i].hit(r, t_min, closest_so_far)).hit) {
            temp_rec = temp_ret.rec;
            hit_anything = true;
            closest_so_far = temp_rec.t;
            rec = temp_rec;
            mat = objects[i].mat;
        }
    }
    
    hit_return returnn;
    returnn.hit = hit_anything;
    returnn.rec = rec;
    returnn.mat = mat;
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
bool near_zero(float3 x) {
    // Return true if the vector is close to zero in all dimensions.
    const auto s = 1e-8;
    return (x.x < s) && (x.y < s) && (x.z < s);
}
ray scatter(thread ray* ray_in, thread hit_return* hit_ret, thread float3* attenuation, thread ray* scattered, float2 seed, float3 normal, float3 p){
    int type = hit_ret->mat.type;
    switch(type){
        case 0:
            return ray();
            break;
        case 1: {
            hit_record rec;
            rec = hit_ret->rec;
            float3 target = rec.p + rec.normal + random_in_unit_sphere_newnew(seed * 999.0 + float2(type, type + 1));
            *attenuation = hit_ret->mat.albedo;
            return ray(rec.p, target - rec.p);
            break;
        }
        case 2:{
            float3 reflected = reflect(unit_vector(ray_in->direction), hit_ret->rec.normal);
            *attenuation = hit_ret->mat.albedo;
            return ray(hit_ret->rec.p, reflected);
            break;
        }
    }


            

    return ray();
}
ray testScatter(thread hit_return* ret, float2 seed){
    switch(ret->mat.type){
        case 0:
            return ray();
        case 1:
            hit_record rec;
            rec = ret->rec;
            float3 target = rec.p + rec.normal + random_in_hemisphere(seed * 999.0 + float2(5 * 9, 5 * 9), rec.normal);
            return ray(rec.p, target - rec.p);
    }

}
float3 ray_color_iterative(ray r, thread hittable_list* world, int depth, float2 seed){
    ray cur_ray = r;
    float3 cur_attenuation(1.0, 1.0, 1.0);
    
    for (int i = 0; i < 15; i++){
        hit_return ret;
        hit_record rec;

        if((ret = world->hit(cur_ray, 0.001, 100000000000)).hit){
            rec = ret.rec;
            float3 target = rec.p + rec.normal + random_in_hemisphere(seed * 999.0 + float2(depth * 9, depth * 9), rec.normal);
            float3 attenuation;
            ray scattered;
            scattered = scatter(&cur_ray, &ret, &attenuation, &scattered, seed, rec.normal, rec.p);
                cur_attenuation *= attenuation;
                cur_ray = scattered;
            //cur_attenuation *= 0.5;
            //cur_ray = testScatter(&ret, seed);
        }else{
            float3 unit_direction = unit_vector(cur_ray.direction);
            float t = 0.5 * (unit_direction.y + 1);
            float3 c = (1.0-t)*float3(1.0, 1.0, 1.0) + t*float3(0.5, 0.7, 1.0);
            return cur_attenuation * c;
        }
    }
    return float3(0,0,0);
}

float3 msaaRayColor3x(ray r, thread hittable_list* world, int depth, float2 seed){
    float3 color(0,0,0);
    color += ray_color_iterative(r, world, 5, seed * 1);
    color += ray_color_iterative(r, world, 5, seed * 2);
    color += ray_color_iterative(r, world, 5, seed * 3);
    return color / 3;
}
kernel void raytrace(uint2 pixel [[thread_position_in_grid]],
                     texture2d<half, access::write> texture [[texture(1)]],
                     texture2d<half, access::write> texture2 [[texture(2)]],
                     constant float2 *randomSeeds [[buffer(2)]],
                     constant float2 &randomSeed2 [[buffer(3)]]){
    
    //Image
    half aspectRatio = 16.0/9.0;
    uint16_t imageWidth  = 2560;
    uint16_t imageHeight = imageWidth / aspectRatio;
    
    camera cam;
    float3 color(0,0,0);

    
    //Scene
    hittable_list scene;
    material sphereOne;
    sphereOne.type = 1;
    sphereOne.albedo = float3(0.7,0.3,0.3);
    
    material sphereTwo;
    sphereTwo.type = 1;
    sphereTwo.albedo = float3(0.8, 0.8, 0.0);
    
    material sphereThree;
    sphereThree.type = 2;
    sphereThree.albedo = float3(0.8, 0.8, 0.8);
    
    material sphereFour;
    sphereFour.type = 2;
    sphereFour.albedo = float3(0.8, 0.6, 0.2);
    
    
    sphere s(float3(0,0,-1), 0.5, sphereOne);
    sphere sTwo(float3(0,-100.5,-1), 100, sphereTwo);
    sphere sThree(float3(-1, 0, -1), 0.5, sphereThree);
    sphere sFour(float3(1, 0, -1), 0.5, sphereFour);
    scene.add(s);
    scene.add(sTwo);
    scene.add(sThree);
    scene.add(sFour);
        float u = (half(pixel.x) + hash22(randomSeed2).x) / (imageWidth - 1);
        float v = (half(pixel.y) + hash22(randomSeed2).y) / (imageHeight - 1);
        ray r = cam.get_ray(u, v);
        
        float3 p3 = fract(float3(float2(u,v).xyx) * float3(.1031, .1030, .0973));
        p3 += dot(p3, p3.yzx+33.33);
        float2 uTwo = fract((p3.xx+p3.yz)*p3.zy);

        
 
        color = msaaRayColor3x(r, &scene, 1, float2(u + uTwo.x, v + uTwo.y));

    
    uint2 newPixel = uint2(pixel.x, ((pixel.y-720)*-1)+720);
    texture.write(half4(float4(color, 1)), newPixel);
}

