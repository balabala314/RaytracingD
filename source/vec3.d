module vec3;

import std.math;
import std.random : uniform;
import tk;

// Alias for geometric clarity
alias Point3 = Vec3;

struct Vec3
{ // @suppress(dscanner.style.phobos_naming_convention)
    double[3] e = [0.0, 0.0, 0.0];

    this(double e0, double e1, double e2)
    {
        e[0] = e0;
        e[1] = e1;
        e[2] = e2;
    }

    double x() const
    {
        return e[0];
    }

    double y() const
    {
        return e[1];
    }

    double z() const
    {
        return e[2];
    }

    double opIndex(size_t i) const
    {
        return e[i];
    }

    ref double opIndex(size_t i)
    {
        return e[i];
    }

    Vec3 opUnary(string op)() const if (op == "-")
    {
        return Vec3(-e[0], -e[1], -e[2]);
    }

    // Vec3 + Vec3, -=, *= (component-wise)
    ref Vec3 opOpAssign(string op)(const Vec3 v)
    {
        static if (op == "+")
        {
            e[] += v.e[];
        }
        else static if (op == "-")
        {
            e[] -= v.e[];
        }
        else static if (op == "*")
        {
            e[] *= v.e[];
        }
        else
            static assert(0);
        return this;
    }

    // Vec3 *= double
    ref Vec3 opOpAssign(string op)(double t)
    {
        static if (op == "*")
        {
            e[] *= t;
        }
        else static if (op == "/")
        {
            return this *= (1.0 / t);
        }
        else
            static assert(0);
        return this;
    }

    // Vec3 * double
    Vec3 opBinary(string op)(double t) const if (op == "*")
    {
        return Vec3(e[0] * t, e[1] * t, e[2] * t);
    }

    // Vec3 / double
    Vec3 opBinary(string op)(double t) const if (op == "/")
    {
        return Vec3(e[0] / t, e[1] / t, e[2] / t);
    }

    Vec3 opBinary(string op)(Vec3 t) const if (op == "+")
    {
        return Vec3(e[0] + t[0], e[1] + t[1], e[2] + t[2]);
    }
    /*Unecessary here.
    Vec3 opBinaryRight(string op)(Vec3 t) const if (op == "+") {
        return Vec3(e[0]+t[0], e[1]+t[1], e[2]+t[2]);
    }*/

    Vec3 opBinary(string op)(Vec3 t) const if (op == "-")
    {
        return Vec3(e[0] - t[0], e[1] - t[1], e[2] - t[2]);
    }

    // double * Vec3
    Vec3 opBinaryRight(string op)(double t) const if (op == "*")
    {
        return Vec3(t * e[0], t * e[1], t * e[2]);
    }

    Vec3 opBinary(string op)(Vec3 t) const if (op == "*")
    {
        return Vec3(t.x * e[0], t.y * e[1], t.z * e[2]);
    }

    double length() const
    {
        return sqrt(length_squared());
    }

    double length_squared() const
    {
        return e[0] * e[0] + e[1] * e[1] + e[2] * e[2];
    }

    void toString(scope void delegate(const(char)[]) sink) const
    {
        import std.format : format;

        sink(format("%.6g %.6g %.6g", e[0], e[1], e[2]));
    }

    bool near_zero() const
    {
        // Return true if the vector is close to zero in all dimensions.
        immutable s = 1e-8;
        return (abs(e[0]) < s) &&
            (abs(e[1]) < s) &&
            (abs(e[2]) < s);
    }
}

// Vec3 + Vec3
Vec3 opBinary(string op)(in Vec3 u, in Vec3 v) if (op == "+")
{
    return Vec3(u.e[0] + v.e[0], u.e[1] + v.e[1], u.e[2] + v.e[2]);
}

Vec3 opBinary(string op)(in Vec3 u, in Vec3 v) if (op == "-")
{
    return Vec3(u.e[0] - v.e[0], u.e[1] - v.e[1], u.e[2] - v.e[2]);
}

Vec3 opBinary(string op)(in Vec3 u, in Vec3 v) if (op == "*")
{
    return Vec3(u.e[0] * v.e[0], u.e[1] * v.e[1], u.e[2] * v.e[2]);
}

// dot product
double dot(in Vec3 u, in Vec3 v)
{
    return u.e[0] * v.e[0] + u.e[1] * v.e[1] + u.e[2] * v.e[2];
}

Vec3 random()
{
    return Vec3(uniform(0.0, 1.0), uniform(0.0, 1.0), uniform(0.0, 1.0));
}

Vec3 random(in double min, in double max)
{
    return Vec3(uniform(min, max), uniform(min, max), uniform(min, max));
}

double min_val = sqrt(double.min_normal) * 10;
// 确保向量均匀分布于圆内
Vec3 random_unit_vector()
{
    while (true)
    {
        auto p = random(-1.0, 1.0);
        auto lensq = p.length_squared();
        if (min_val < lensq && lensq <= 1)
            return p / sqrt(lensq);
    }
}

Vec3 random_on_hemisphere(in Vec3 normal)
{
    Vec3 on_unit_sphere = random_unit_vector();
    if (dot(on_unit_sphere, normal) > 0.0) // In the same hemisphere as the normal
        return on_unit_sphere;
    else
        return -on_unit_sphere;
}
// cross product
Vec3 cross(in Vec3 u, in Vec3 v)
{
    return Vec3(
        u.e[1] * v.e[2] - u.e[2] * v.e[1],
        u.e[2] * v.e[0] - u.e[0] * v.e[2],
        u.e[0] * v.e[1] - u.e[1] * v.e[0]
    );
}

// unit vector
Vec3 unit_vector(in Vec3 v)
{
    return v / v.length();
}

Vec3 reflect(in Vec3 v, in Vec3 n)
{
    return v - 2 * dot(v, n) * n;
}

Vec3 refract(in Vec3 uv, in Vec3 n, double etai_over_etat)
{
    auto cos_theta = min(dot(-uv, n), 1.0);
    Vec3 r_out_perp = etai_over_etat * (uv + cos_theta * n);
    Vec3 r_out_parallel = -sqrt(abs(1.0 - r_out_perp.length_squared())) * n;
    return r_out_perp + r_out_parallel;
}

Vec3 random_in_unit_disk()
{
    while (true)
    {
        Vec3 p = Vec3(uniform(-1.0, 1.0), uniform(-1.0, 1.0), 0);
        if (p.length_squared() < 1)
            return p;
    }
}
