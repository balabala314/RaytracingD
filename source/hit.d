module hit;

import vec3;
import ray;
import interval;
import material;

// A struct to record hit.
struct hit_record
{ // @suppress(dscanner.style.phobos_naming_convention)
    Point3 p;
    Vec3 normal;
    Material mat;
    double t;
    bool front_face;

    void set_face_normal(in Ray r, in Vec3 outward_normal)
    {
        front_face = dot(r.direction(), outward_normal) < 0;
        normal = front_face ? outward_normal : -outward_normal;
    }
}

interface hittable
{
    bool hit(in Ray r, in Interval ray_t, out hit_record rec);
}
