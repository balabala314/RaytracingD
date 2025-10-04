module tk;
import std.math;
import std.random;

double degrees_to_radians(double degrees)
{
    pragma(inline, true);
    return degrees * PI / 180.0;
}

double min(double a, double b)
{
    return a < b ? a : b;
}

double max(double a, double b)
{
    return a > b ? a : b;
}
