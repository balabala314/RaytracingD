import std.stdio;
import std.math;
import vec3;
import color;
import ray;
import hit;
import hit_list;
import sphere;
import interval;
import cam;
import material;
import triangle;
import image;
import std.random : uniform;

pragma(lib, "bcrypt.lib");
void scene1()
{
    writeln("0");
    hittable_list world = new hittable_list();

    auto ground_material = new lambertian(Color(0.5, 0.5, 0.5));
    world.add(new Sphere(Point3(0, -1000, 0), 1000, ground_material));
    int counter = 0;
    writeln("1");

    for (int a = -11; a < 11; a++)
    {
        for (int b = -11; b < 11; b++)
        {
            double choose_mat = uniform(0.0, 1.0);
            Point3 center = Point3(a + 0.9 * uniform(0.0, 1.0), 0.2, b + 0.9 * uniform(0.0, 1.0));

            if ((center - Point3(4, 0.2, 0)).length > 0.9)
            {
                Material sphere_material;

                if (choose_mat < 0.8)
                {
                    // diffuse
                    Color albedo = vec3.random * vec3.random;
                    sphere_material = new lambertian(albedo);
                    world.add(new Sphere(center, 0.2, sphere_material));
                    counter++;
                }
                else if (choose_mat < 0.95)
                {
                    // metal
                    Color albedo = vec3.random(0.5, 1);
                    double fuzz = uniform(0, 0.5);
                    sphere_material = new metal(albedo, fuzz);
                    world.add(new Sphere(center, 0.2, sphere_material));
                    counter++;
                }
                else
                {
                    // glass
                    sphere_material = new dielectric(1.5);
                    world.add(new Sphere(center, 0.2, sphere_material));
                    counter++;
                }
            }
        }
    }
    writeln("2");
    auto material1 = new dielectric(1.5);
    world.add(new Sphere(Point3(0, 1, 0), 1.0, material1));

    auto material2 = new lambertian(Color(0.4, 0.2, 0.1));
    world.add(new Sphere(Point3(-4, 1, 0), 1.0, material2));

    auto material3 = new metal(Color(0.7, 0.6, 0.5), 0.0);
    world.add(new Sphere(Point3(4, 1, 0), 1.0, material3));

    Camera cam = new Camera();

    cam.aspect_ratio = 16.0 / 9.0;
    cam.image_width = 1200;
    cam.samples_per_pixel = 10;
    cam.max_depth = 20;

    cam.vfov = 20;
    cam.lookfrom = Point3(13, 2, 3);
    cam.lookat = Point3(0, 0, 0);
    cam.vup = Vec3(0, 1, 0);

    cam.defocus_angle = 0.6;
    cam.focus_dist = 10.0;
    cam.o_path = "./img/one.ppm";

    cam.render(world);

}

void testImage()
{
    char[] a;
    writeln(Color.sizeof);
    readln(a);
    auto photo = new Image(1000, 2000);
    readln(a);
    photo.setAt(99, 199, Color(1, 1, 1));
    photo.saveAs("out.ppm");
}

void main()
{
    writeln("hello");
    switch (1)
    {
    case 1:
        scene1();
        break;
    case 2:
        testImage();
        break;
    default:
        break;
    }

}
