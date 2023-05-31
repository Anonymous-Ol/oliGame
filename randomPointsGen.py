import random
import math

class Vec3:
    def __init__(self, x=0, y=0, z=0):
        self.x = x
        self.y = y
        self.z = z

    def __add__(self, other):
        return Vec3(self.x + other.x, self.y + other.y, self.z + other.z)

    def __sub__(self, other):
        return Vec3(self.x - other.x, self.y - other.y, self.z - other.z)

    def __mul__(self, other):
        return Vec3(self.x * other, self.y * other, self.z * other)

    def length_squared(self):
        return self.x * self.x + self.y * self.y + self.z * self.z

    def length(self):
        return math.sqrt(self.length_squared())

    @staticmethod
    def random(min_val, max_val):
        return Vec3(random.uniform(min_val, max_val),
                    random.uniform(min_val, max_val),
                    random.uniform(min_val, max_val))

def random_in_unit_sphere():
    while True:
        p = Vec3.random(-1, 1)
        if p.length_squared() >= 1:
            continue
        return p

# Generate 500 random points in a unit sphere
points = [random_in_unit_sphere() for _ in range(500)]

# Output the points as a C array
print("var points: [float3] = [")
for p in points:
    print(f"    float3({p.x:.6f}, {p.y:.6f}, {p.z:.6f}),")
print("]")