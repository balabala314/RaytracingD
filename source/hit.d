module hit;

import vec3;
import ray;
import interval;

// A struct to record hit.
struct hit_record{ // @suppress(dscanner.style.phobos_naming_convention)
    vec3.point3 p;
    vec3.vec3 normal;
    double t;
    bool front_face;

    void set_face_normal(in ray.ray r, in vec3.vec3 outward_normal){
        front_face = dot(r.direction(), outward_normal) < 0; 
        normal = front_face ? outward_normal : -outward_normal;
    }
}

interface hittable{ // @suppress(dscanner.style.phobos_naming_convention)
    bool hit(in ray.ray r, in interval.interval ray_t, out hit_record rec) const;
}