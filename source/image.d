module image;
import color;
import core.memory;
import std.stdio;

class Image
{
    private
    {
        int width, height;
        Color* buffer;
    }
    this(int width, int height)
    {
        this.width = width;
        this.height = height;
        makeBuffer();
    }

    ~this()
    {
        if (buffer !is null)
        {
            GC.free(cast(void*) buffer);
        }
    }

    void makeBuffer()
    {
        if (buffer !is null)
        {
            GC.free(cast(void*) buffer);
        }
        buffer = cast(Color*) GC.calloc(width * height * Color.sizeof);
    }

    Color* getAt(int x, int y)
    {
        assert(x < this.width && x >= 0);
        assert(y < this.height && y >= 0);
        return buffer + y * width + x;
    }

    void setAt(int x, int y, in Color color)
    {
        assert(x < this.width && x >= 0);
        assert(y < this.height && y >= 0);
        (*getAt(x, y)) = color;
    }

    void print() const
    {
        writefln("Pointer: %s", buffer);
        writefln("Size: (%s, %s)", width, height);
    }

    void saveAs(in string path) const
    {
        auto ofile = File(path, "w");
        //PPM Header
        ofile.writeln("P3");
        ofile.writefln("%s %s", width, height);
        ofile.writeln("255");
        for (int index = 0; index < width * height; index++)
        {
            const Color* pixel_color = buffer + index;
            double r = pixel_color.x;
            double g = pixel_color.y;
            double b = pixel_color.z;

            r = linear_to_gamma(r);
            g = linear_to_gamma(g);
            b = linear_to_gamma(b);

            int rbyte = cast(int)(255.999 * intensity.clamp(r));
            int gbyte = cast(int)(255.999 * intensity.clamp(g));
            int bbyte = cast(int)(255.999 * intensity.clamp(b));

            ofile.writefln("%s %s %s", rbyte, gbyte, bbyte);
        }
    }
}
