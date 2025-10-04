module ray;

import vec3;

struct Ray
{ // @suppress(dscanner.style.phobos_naming_convention)
    private Point3 orig;
    private Vec3 dir;
    this(in Point3 orig, in Vec3 dir)
    {
        this.orig = orig;
        this.dir = dir;
    }

    Vec3 direction() const
    {
        return this.dir;
    }

    Point3 origin() const
    {
        return this.orig;
    }

    Point3 at(double t) const
    {
        return orig + t * dir;
    }
}
