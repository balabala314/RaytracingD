module ray;

import vec3;

struct ray{ // @suppress(dscanner.style.phobos_naming_convention)
    private vec3.point3 orig;
    private vec3.vec3 dir;
    this(in vec3.point3 orig, in vec3.vec3 dir){
        this.orig = orig;
        this.dir = dir;
    }
    vec3.vec3 direction() const{
        return this.dir;
    }
    vec3.point3 origin() const{
        return this.orig;
    }
    point3 at(double t) const{
        return orig + t * dir;
    }
}
