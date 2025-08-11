module interval;

struct interval{
    double min,max = double.infinity;
    this(double min, double max){
        this.min = min;
        this.max = max;
    }
    double size() const{
        return max - min;
    }
    bool if_contains(in double x) const{
        return min <= x && x <= max;
    }
    bool if_surrounds(in double x) const{
        return min < x && x < max;
    }
    double clamp(in double x) const{
        if (x<min) return min;
        if (x>max) return max;
        return x;
    }
    static const empty = interval(+double.infinity, -double.infinity);
    static const universe = interval(-double.infinity, +double.infinity);
}