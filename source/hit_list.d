module hit_list;

import hit; 
import ray;
import interval;



class hittable_list : hittable {
    // 使用动态数组存储可击中的对象（类似 std::vector<shared_ptr<Hittable>>）
    hittable[] objects;

    // 构造函数
    this() {
        objects = [];
    }

    this(hittable obj) {
        this();
        objects ~= (obj);
    }

    // 清空列表
    void clear() {
        objects.length = 0; // 或 objects = [];
    }

    // 添加一个可击中对象
    void add(hittable obj) {
        objects ~= obj; // D 中的动态数组追加
    }

    // 实现 Hittable 接口的 hit 方法
    override bool hit(in ray.ray r, in interval.interval ray_t, out hit_record rec) const {
        hit_record tempRec;
        bool hitAnything = false;
        double closestSoFar = ray_t.max;

        foreach (obj; objects) {
            if (obj.hit(r, interval.interval(ray_t.min, closestSoFar), tempRec)) {
                hitAnything = true;
                closestSoFar = tempRec.t;
                rec = tempRec;
            }
        }

        return hitAnything;
    }
}