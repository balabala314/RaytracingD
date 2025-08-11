module color;

import vec3;
import std.math:sqrt;
import std.stdio;
import interval;


const intensity = interval.interval(0.000,0.999);
alias color = vec3.vec3;

double linear_to_gamma(double linear_component){
    pragma(inline, true);
    if (linear_component > 0)
        return sqrt(linear_component);
    return 0;
}

void write_color(in color pixel_color){
    double r = pixel_color.x;
    double g = pixel_color.y;
    double b = pixel_color.z;

    r=linear_to_gamma(r);
    g=linear_to_gamma(g);
    b=linear_to_gamma(b);

    int rbyte = cast(int)(255.999*intensity.clamp(r));
	int gbyte = cast(int)(255.999*intensity.clamp(g));
	int bbyte = cast(int)(255.999*intensity.clamp(b));

    stdout.writefln("%s %s %s", rbyte, gbyte, bbyte);
}
