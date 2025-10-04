module triangle;

import vec3;
import hit;
import ray;
import interval;
import material;

import std.math : fmax, fmin, sqrt, abs;

class Triangle : hit.hittable
{
    Material mat;
    private
    {
        Point3 p0, p1, p2;
        Vec3 normal;
    }
    this(in Point3 p0, in Point3 p1, in Point3 p2, Material mat)
    {
        this.p0 = p0;
        this.p1 = p1;
        this.p2 = p2;
        this.mat = mat;
        this.calc();
    }

    bool hit(in Ray r, in Interval ray_t, out hit_record rec)
    {
        double u, v;
        Vec3 E1 = p1 - p0;
        Vec3 E2 = p2 - p0;
        Vec3 P = cross(r.direction, E2); // P = D × E2
        double det = dot(P, E1);

        // 如果行列式接近0，光线与三角形平面平行
        if (abs(det) < 1e-8) // 使用一个极小的epsilon值
            return false;

        double invDet = 1.0 / det;

        Vec3 T = r.origin - p0;
        u = dot(P, T) * invDet; // 计算u参数

        // 检查u是否在三角形外
        if (u < 0.0 || u > 1.0)
            return false;

        Vec3 Q = cross(T, E1); // Q = T × E1
        v = dot(Q, r.direction) * invDet; // 计算v参数

        // 检查v是否在三角形外，以及u+v是否超过1
        if (v < 0.0 || (u + v) > 1.0)
            return false;

        // 计算t
        rec.t = dot(Q, E2) * invDet;

        // 最后检查t是否在光线的有效范围内
        // (你需要自己定义 tMin 和 tMax，例如 tMin=0.001, tMax=FLT_MAX)
        if (!ray_t.if_contains(rec.t))
            return false;

        rec.p = r.at(rec.t);
        rec.set_face_normal(r, normal);
        rec.mat = mat;

        return true; // 找到一个有效的交点！

    }

    void calc()
    {
        normal = cross(p1 - p0, p2 - p1);
    }
}
