module sphere;

import vec3;
import hit;
import ray;
import interval;

import std.math:fmax,fmin,sqrt;

class sphere: hit.hittable{ // @suppress(dscanner.style.phobos_naming_convention)
    vec3.point3 center;
    double radius;
    this(in vec3.point3 center, double radius){
        this.center = center;
        this.radius = fmax(0, radius);
    }
    bool hit(in ray.ray r, in interval.interval ray_t, out hit_record rec) const {
        vec3.vec3 oc = center - r.origin();
        double a = r.direction().length_squared();
        double h = dot(r.direction, oc);
        double c = oc.length_squared - radius*radius;

        double discriminant = h*h - a*c; 
        if (discriminant < 0)
            return false;

        double sqrtd = sqrt(discriminant);

        // Find the nearest root that lies in the acceptable range. 
        double root = (h - sqrtd) / a;
        if (!ray_t.if_contains(root)) {
            root = (h + sqrtd) / a;
            if (!ray_t.if_contains(root))
                return false;
        }

        rec.t = root;
        rec.p = r.at(rec.t);
        vec3.vec3 outward_normal = (rec.p - center) / radius; 
        rec.set_face_normal(r, outward_normal);

        return true;
    }
}