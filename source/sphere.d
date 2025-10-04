module sphere;

import vec3;
import hit;
import ray;
import interval;
import material;

import std.math : fmax, fmin, sqrt;

class Sphere : hit.hittable
{ // @suppress(dscanner.style.phobos_naming_convention)
    Point3 center;
    double radius;
    Material mat;
    this(in Point3 center, double radius, Material mat)
    {
        this.center = center;
        this.radius = fmax(0, radius);
        this.mat = mat;
        // TODO: Initialize the material pointer `mat`.
    }

    bool hit(in Ray r, in Interval ray_t, out hit_record rec)
    {
        Vec3 oc = center - r.origin();
        double a = r.direction().length_squared();
        double h = dot(r.direction, oc);
        double c = oc.length_squared - radius * radius;

        double discriminant = h * h - a * c;
        if (discriminant < 0)
            return false;

        double sqrtd = sqrt(discriminant);

        // Find the nearest root that lies in the acceptable range.
        double root = (h - sqrtd) / a;
        if (!ray_t.if_contains(root))
        {
            root = (h + sqrtd) / a;
            if (!ray_t.if_contains(root))
                return false;
        }

        rec.t = root;
        rec.p = r.at(rec.t);
        Vec3 outward_normal = (rec.p - center) / radius;
        rec.set_face_normal(r, outward_normal);
        rec.mat = mat;

        return true;
    }
}
