import std.stdio;
import std.math;
import vec3;
import color;
import ray;
import hit;
import hit_list;
import sphere;
import interval;
import thecamera;




double degrees_to_radians(double degrees) {
	pragma(inline, true);
    return degrees * PI / 180.0;
}


void main(){
    hittable_list world = new hittable_list();

    world.add(new sphere.sphere(point3(0,0,-1), 0.5)); 
    world.add(new sphere.sphere(point3(0,-100.5,-1), 100));

	camera cam = new camera();

	cam.aspect_ratio = 16.0 / 9.0; 
    cam.image_width  = 400;
    cam.samples_per_pixel = 20;

	cam.render(world);


}
