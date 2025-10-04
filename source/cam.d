module cam;
import hit;
import ray;
import vec3;
import interval;
import color;
import tk;
import image;

import std.random : uniform;
import std.math : tan;
import core.thread;
import std.parallelism;
import std.conv : to;

import std.stdio;

struct CamTask
{
    Camera camera;
    int line;
    Image image;
    void work()
    {
        camera.threadWorker(image, line);
    }
}

struct WorkList
{
    Camera camera;
    Image image;
    size_t count = 0;
    int _start, _end;
    this(size_t end)
    {
        _start = 0;
        _end = to!int(end);
    }

    this(size_t start, size_t end)
    {
        _start = to!int(start);
        _end = to!int(end);
    }
    // 必需属性：空判断
    @property bool empty() const
    {
        return _start >= _end;
    }

    // 必需属性：前元素
    @property CamTask front()
    {
        return CamTask(camera, _start, image);
    }

    // 必需方法：弹出前元素
    void popFront()
    {
        writefln("pop: %s", _start);
        ++_start;
    }

    // 双向范围：后元素
    @property CamTask back()
    {
        return CamTask(camera, _end, image);
    }

    // 双向范围：弹出后元素
    void popBack()
    {
        --_end;
    }

    // 随机访问：通过索引访问
    CamTask opIndex(size_t index)
    {
        count++;
        if (count % 10 == 0)
        {
            writefln("Progress: %s/%s", count, this.length());
        }
        return CamTask(camera, to!int(index), image);
    }

    // 随机访问：赋值通过索引
    void opIndexAssign(CamTask value, size_t index)
    {
        return;
    }

    // 随机访问：长度
    @property size_t length() const
    {
        return _end - _start;
    }

    // 随机访问：切片操作
    auto opSlice(size_t from, size_t to) const
    {
        return WorkList(from, to);
    }

    // 保存状态（用于范围算法）
    @property WorkList save() const
    {
        return WorkList(_start, _end);
    }

    // 字符串表示
    string toString() const
    {
        return "WorkList";
    }
}

class Camera
{
    double aspect_ratio = 1.0;
    int image_width = 400;
    int samples_per_pixel = 10;
    double vfov = 90;
    string o_path;
    Point3 lookfrom = Point3(0, 0, 0); // Point camera is looking from
    Point3 lookat = Point3(0, 0, -1); // Point camera is looking at
    Vec3 vup = Vec3(0, 1, 0); // Camera-relative "up" direction
    int max_depth = 10;
    double defocus_angle = 0; // Variation angle of rays through each pixel
    double focus_dist = 10; // Distance from camera lookfrom point to plane of perfect focus

    private
    {
        int image_height; // Rendered image height
        Point3 center; // Camera center
        Point3 pixel00_loc; // Location of pixel 0, 0
        Vec3 pixel_delta_u; // Offset to pixel to the right
        Vec3 pixel_delta_v; // Offset to pixel below
        double pixel_samples_scale; // Color scale factor for a sum of pixel samples
        Vec3 u, v, w; // Camera frame basis vectors
        Vec3 defocus_disk_u; // Defocus disk horizontal radius
        Vec3 defocus_disk_v; // Defocus disk vertical radius
        hittable world;

    }
    void render(hittable world)
    {
        initialize();
        this.world = world;

        Image outImg = new Image(image_width, image_height);
        WorkList lt = WorkList(image_height);
        lt.camera = this;
        lt.image = outImg;
        writeln("start");
        foreach (i; parallel(lt))
        {
            // 并行处理
            i.work();
        }
        writeln("end");
        outImg.saveAs(o_path);
        writeln("Done!");

    }

    void threadWorker(Image output, int targetLine)
    {

        for (int x = 0; x < image_width; x++)
        {
            Color pixel_color = Color(0, 0, 0);
            for (int sample = 0; sample < samples_per_pixel; sample++)
            {
                Ray r = get_ray(x, targetLine);
                pixel_color += ray_color(r, this.world);
            }
            output.setAt(x, targetLine, pixel_samples_scale * pixel_color);
        }
    }

    private void initialize()
    {
        image_height = cast(int)(image_width / aspect_ratio);
        image_height = (image_height < 1) ? 1 : image_height;

        center = lookfrom;
        pixel_samples_scale = 1.0 / samples_per_pixel;

        // Camera
        // Determine viewport dimensions.
        double theta = degrees_to_radians(vfov);
        double h = tan(theta / 2);
        double viewport_height = 2 * h * focus_dist;
        double viewport_width = viewport_height * (double(image_width) / image_height);

        // Calculate the u,v,w unit basis vectors for the camera coordinate frame.
        w = unit_vector(lookfrom - lookat);
        u = unit_vector(cross(vup, w));
        v = cross(w, u);

        // Calculate the vectors across the horizontal and down the vertical viewport edges.
        Vec3 viewport_u = viewport_width * u; // Vector across viewport horizontal edge
        Vec3 viewport_v = viewport_height * -v; // Vector down viewport vertical edge
        // Calculate the horizontal and vertical delta vectors from pixel to pixel.
        pixel_delta_u = viewport_u / image_width;
        pixel_delta_v = viewport_v / image_height;

        // Calculate the location of the upper left pixel.
        // pixel00_loc is the upper left corner pixel's position.
        Vec3 viewport_upper_left = center - (focus_dist * w) - viewport_u / 2 - viewport_v / 2;
        pixel00_loc = viewport_upper_left + 0.5 * (pixel_delta_u + pixel_delta_v);

        // Calculate the camera defocus disk basis vectors.
        double defocus_radius = focus_dist * tan(degrees_to_radians(defocus_angle / 2));
        defocus_disk_u = u * defocus_radius;
        defocus_disk_v = v * defocus_radius;
    }

    Ray get_ray(int i, int j) const
    {
        // Construct a camera ray originating from the defocus disk and directed at a randomly
        // sampled point around the pixel location i, j.

        auto offset = sample_square();
        auto pixel_sample = pixel00_loc
            + ((i + offset.x) * pixel_delta_u)
            + (
                (j + offset.y) * pixel_delta_v);

        auto ray_origin = (defocus_angle <= 0) ? center : defocus_disk_sample();
        auto ray_direction = pixel_sample - ray_origin;

        return Ray(ray_origin, ray_direction);
    }

    Vec3 sample_square() const
    {
        // Returns the vector to a random point in the [-.5,-.5]-[+.5,+.5] unit square.
        return Vec3(uniform(0.0, 1.0) - 0.5, uniform(0.0, 1.0) - 0.5, 0);
    }

    private Color ray_color(in Ray r, hittable world, int depth = 1)
    {
        hit_record rec;
        if (depth > 1)
        {
            //writeln("Depth:", depth);
        }

        if (depth >= max_depth)
        {
            // writeln("Beyond Depth");
            return Color(0, 0, 0);
        }

        if (world.hit(r, Interval(0.0001, double.infinity), rec))
        {
            Ray scattered;
            Color attenuation;
            if (rec.mat.scatter(r, rec, attenuation, scattered))
            {
                return attenuation * ray_color(scattered, world, depth + 1);
            }
            //return Color(0, 0, 0);
            return attenuation;
        }
        Vec3 unit_direction = unit_vector(r.direction);
        auto a = 0.5 * (unit_direction.y + 1.0);
        return (1.0 - a) * Color(1.0, 1.0, 1.0) + a * Color(0.5, 0.7, 1.0);
        //return Color(0, 0, 0);
    }

    Point3 defocus_disk_sample() const
    {
        // Returns a random point in the camera defocus disk.
        auto p = random_in_unit_disk();
        return center + (p[0] * defocus_disk_u) + (p[1] * defocus_disk_v);
    }
}
