module material;

import ray;
import hit;
import color;
import vec3;
import tk;
import std.math : abs, sqrt, pow;
import std.random : uniform;

class Material
{
    abstract bool scatter(in Ray r_in, in hit_record rec, ref Color attenuation, ref Ray scattered) const;
}

class lambertian : Material
{
    private Color albedo;

    this(Color albedo)
    {
        this.albedo = albedo;
    }

    override bool scatter(in Ray r_in, in hit_record rec, ref Color attenuation, ref Ray scattered) const
    {
        auto scatter_direction = rec.normal + random_unit_vector();

        if (scatter_direction.near_zero())
        {
            scatter_direction = rec.normal;
        }

        scattered = Ray(rec.p, scatter_direction);
        attenuation = albedo;
        return true;
    }
}

class metal : Material
{
    this(Color albedo, double fuzz)
    {
        this.albedo = albedo;
        this.fuzz = abs(fuzz) > 1 ? 1 : abs(fuzz);

    }

    override bool scatter(in Ray r_in, in hit_record rec, ref Color attenuation, ref Ray scattered) const
    {
        Vec3 reflected = vec3.reflect(r_in.direction(), rec.normal);
        reflected = unit_vector(reflected) + (fuzz * random_unit_vector());
        scattered = Ray(rec.p, reflected);
        attenuation = albedo;
        return (dot(scattered.direction(), rec.normal) > 0);
    }

    private
    {
        Color albedo;
        double fuzz;
    }
}

class dielectric : Material
{
    this(double refraction_index)
    {
        this.refraction_index = refraction_index;
    }

    override bool scatter(in Ray r_in, in hit_record rec, ref Color attenuation, ref Ray scattered) const
    {
        attenuation = Color(1.0, 1.0, 1.0); // TODO:make it customizable
        double ri = rec.front_face ? (1.0 / refraction_index) : refraction_index;
        Vec3 unit_direction = unit_vector(r_in.direction());
        Vec3 refracted = refract(unit_direction, rec.normal, ri);
        scattered = Ray(rec.p, refracted);

        double cos_theta = min(dot(-unit_direction, rec.normal), 1.0);
        double sin_theta = sqrt(1.0 - cos_theta * cos_theta);
        bool cannot_refract = ri * sin_theta > 1.0;
        Vec3 direction;
        if (cannot_refract || reflectance(cos_theta, ri) > uniform(0.0, 1.0))
        {
            direction = reflect(unit_direction, rec.normal);
        }
        else
        {
            direction = refract(unit_direction, rec.normal, ri);
        }
        scattered = Ray(rec.p, direction);

        return true;
    }

    private
    {
        // Refractive index in vacuum or air, or the ratio of the material's refractive index over
        // the refractive index of the enclosing media
        double refraction_index;
    }
    static double reflectance(double cosine, double refraction_index)
    {
        // Use Schlick's approximation for reflectance.
        auto r0 = (1 - refraction_index) / (1 + refraction_index);
        r0 = r0 * r0;
        return r0 + (1 - r0) * pow((1 - cosine), 5);
    }
}

class PureColor : Material
{
    this(Color albedo)
    {
        this.albedo = albedo;

    }

    override bool scatter(in Ray r_in, in hit_record rec, ref Color attenuation, ref Ray scattered) const
    {
        scattered = Ray();
        attenuation = albedo;
        return false;
    }

    private
    {
        Color albedo;
    }
}
