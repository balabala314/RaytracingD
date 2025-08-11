module vec3;

import std.math;
import std.random: uniform;


// Alias for geometric clarity
alias point3 = vec3;

struct vec3 { // @suppress(dscanner.style.phobos_naming_convention)
    double[3] e = [0.0, 0.0, 0.0];

    this(double e0, double e1, double e2) {
        e[0] = e0;
        e[1] = e1;
        e[2] = e2;
    }

    double x() const { return e[0]; }
    double y() const { return e[1]; }
    double z() const { return e[2]; }

    double opIndex(size_t i) const { return e[i]; }
    ref double opIndex(size_t i) { return e[i]; }

    vec3 opUnary(string op)() const if (op == "-") {
        return vec3(-e[0], -e[1], -e[2]);
    }

    // vec3 + vec3, -=, *= (component-wise)
    ref vec3 opOpAssign(string op)(const vec3 v) {
        static if (op == "+") { e[] += v.e[]; }
        else static if (op == "-") { e[] -= v.e[]; }
        else static if (op == "*") { e[] *= v.e[]; }
        else static assert(0);
        return this;
    }

    // vec3 *= double
    ref vec3 opOpAssign(string op)(double t) {
        static if (op == "*") { e[] *= t; }
        else static if (op == "/") { return this *= (1.0 / t); }
        else static assert(0);
        return this;
    }

    // vec3 * double
    vec3 opBinary(string op)(double t) const if (op == "*") {
        return vec3(e[0]*t, e[1]*t, e[2]*t);
    }

    // vec3 / double
    vec3 opBinary(string op)(double t) const if (op == "/") {
        return vec3(e[0]/t, e[1]/t, e[2]/t);
    }

    vec3 opBinary(string op)(vec3 t) const if (op == "+") {
        return vec3(e[0]+t[0], e[1]+t[1], e[2]+t[2]);
    }
    /*Unecessary here.
    vec3 opBinaryRight(string op)(vec3 t) const if (op == "+") {
        return vec3(e[0]+t[0], e[1]+t[1], e[2]+t[2]);
    }*/

    vec3 opBinary(string op)(vec3 t) const if (op == "-") {
        return vec3(e[0]-t[0], e[1]-t[1], e[2]-t[2]);
    }

    // double * vec3
    vec3 opBinaryRight(string op)(double t) const if (op == "*") {
        return vec3(t*e[0], t*e[1], t*e[2]);
    }

    double length() const {
        return sqrt(length_squared());
    }

    double length_squared() const {
        return e[0]*e[0] + e[1]*e[1] + e[2]*e[2];
    }

    void toString(scope void delegate(const(char)[]) sink) const {
        import std.format : format;
        sink(format("%.6g %.6g %.6g", e[0], e[1], e[2]));
    }
}

// vec3 + vec3
vec3 opBinary(string op)(in vec3 u, in vec3 v) if (op == "+") {
    return vec3(u.e[0]+v.e[0], u.e[1]+v.e[1], u.e[2]+v.e[2]);
}

vec3 opBinary(string op)(in vec3 u, in vec3 v) if (op == "-") {
    return vec3(u.e[0]-v.e[0], u.e[1]-v.e[1], u.e[2]-v.e[2]);
}

vec3 opBinary(string op)(in vec3 u, in vec3 v) if (op == "*") {
    return vec3(u.e[0]*v.e[0], u.e[1]*v.e[1], u.e[2]*v.e[2]);
}

// dot product
double dot(in vec3 u, in vec3 v) {
    return u.e[0]*v.e[0] + u.e[1]*v.e[1] + u.e[2]*v.e[2];
}

vec3 random(){
    return vec3(uniform(0.0,1.0), uniform(0.0,1.0), uniform(0.0,1.0));
}

vec3 random(in double min, in double max){
    return vec3(uniform(min,max), uniform(min,max), uniform(min,max));
}
double min_val = sqrt(double.min_normal) * 10;
// 确保向量均匀分布于圆内
vec3 random_unit_vector() {
    while (true) {
        auto p = random(-1.0,1.0);
        auto lensq = p.length_squared(); 
        if (min_val < lensq && lensq <= 1)
            return p / sqrt(lensq);
    }
}
vec3 random_on_hemisphere(in vec3 normal) {
    vec3 on_unit_sphere = random_unit_vector();
    if (dot(on_unit_sphere, normal) > 0.0) // In the same hemisphere as the normal
        return on_unit_sphere;
    else
        return -on_unit_sphere;
}
// cross product
vec3 cross(in vec3 u, in vec3 v) {
    return vec3(
        u.e[1]*v.e[2] - u.e[2]*v.e[1],
        u.e[2]*v.e[0] - u.e[0]*v.e[2],
        u.e[0]*v.e[1] - u.e[1]*v.e[0]
    );
}

// unit vector
vec3 unit_vector(in vec3 v) {
    return v / v.length();  
}