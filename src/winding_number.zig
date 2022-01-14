const std = @import("std");

const EPS = 3e-9;

pub const Point = struct {
    x: f32,
    y: f32,
};

pub fn isCounterClockWise(poly: []const Point) bool {
    var seq: f32 = 0;
    for (poly) |a, idx| {
        const b = poly[(idx + 1) % poly.len];
        seq += (b.x - a.x) * (b.y + a.y);
    }
    return if (seq < 0) true else false;
}

/// Checks if the point `p` lies on the left, or right side of the line AB
/// return: -1: right side
///          0: on the line
///          1: left side
pub fn pointLineDirection(a: Point, b: Point, p: Point) i2 {
    const nom = (p.y - a.y) * (b.x - a.x);
    const dom = (p.x - a.x) * (b.y - a.y);

    if (std.math.absFloat(nom - dom) < EPS) {
        return 0;
    } else if (nom > dom) return 1 else return -1;
}

/// Checks if point `p` resides inside, on, or outside the closed polygon `poly`
/// return: -1: outside
///          0: on
///          1: inside
pub fn pointInPolygon(p: Point, poly: []const Point) i2 {
    var wm: i32 = 0;
    for (poly) |a, idx| {
        const b = poly[(idx + 1) % poly.len];
        const in_line = pointLineDirection(a, b, p);

        // P lies on AB (and therefore POLY)
        if (in_line == 0) return 0;

        if (a.y <= p.y) {
            if ((b.y > p.y) and (in_line == 1)) wm += 1;
        } else if ((b.y < p.y) and (in_line == -1)) wm -= 1;
    }
    return if (wm != 0) 1 else -1;
}

const expect = @import("std").testing.expect;

// https://i.imgur.com/7VeyP0C.png
test "direction int" {
    const a = Point{ .x = 0, .y = 0 };
    const b = Point{ .x = 0, .y = 4 };

    const p_left = Point{ .x = -1, .y = 3 };
    const p_right = Point{ .x = 3, .y = 1 };
    const p_on = Point{ .x = 0, .y = 2 };

    try expect(pointLineDirection(a, b, p_left) == 1);
    try expect(pointLineDirection(a, b, p_right) == -1);
    try expect(pointLineDirection(a, b, p_on) == 0);
}

// https://i.imgur.com/LCjoSFw.png
test "direction float" {
    const a = Point{ .x = 51.41115357611, .y = 35.7190335556 };
    const b = Point{ .x = 51.41141214984, .y = 35.71968303418 };

    const p_left = Point{ .x = 51.41104409394, .y = 35.71947343327 };
    const p_right = Point{ .x = 51.41155781799, .y = 35.71922272608 };
    const p_on = Point{ .x = 51.41124340764, .y = 35.71925919263 };

    try expect(pointLineDirection(a, b, p_left) == 1);
    try expect(pointLineDirection(a, b, p_right) == -1);
    try expect(pointLineDirection(a, b, p_on) == 0);
}

// https://i.imgur.com/9dDG7DG.png
test "in polygon int" {
    const poly = [_]Point{
        .{ .x = -2, .y = -1 },
        .{ .x = 1, .y = -1 },
        .{ .x = 2, .y = 1 },
        .{ .x = -1, .y = 1 },
    };
    const p_in = Point{ .x = 0, .y = 0 };
    const p_out = Point{ .x = 2, .y = 0 };
    const p_on = Point{ .x = 0, .y = 1 };

    try expect(pointInPolygon(p_in, poly[0..]) == 1);
    try expect(pointInPolygon(p_out, poly[0..]) == -1);
    try expect(pointInPolygon(p_on, poly[0..]) == 0);
}

// https://i.imgur.com/OrFLrs0.png
test "in polygon float" {
    const poly = [_]Point{
        .{ .x = 51.41469955416, .y = 35.72200728582 },
        .{ .x = 51.41348706955, .y = 35.7213489078 },
        .{ .x = 51.4137390144, .y = 35.72041566362 },
        .{ .x = 51.41422715756, .y = 35.71981480199 },
        .{ .x = 51.41542389562, .y = 35.72070970064 },
        .{ .x = 51.41506172489, .y = 35.72106765728 },
        .{ .x = 51.41429014377, .y = 35.72081197413 },
        .{ .x = 51.41463656795, .y = 35.71954633044 },
        .{ .x = 51.41606950431, .y = 35.71895824674 },
        .{ .x = 51.4166836199, .y = 35.72002574329 },
        .{ .x = 51.4171560165, .y = 35.72024307617 },
        .{ .x = 51.41743945447, .y = 35.71973809593 },
        .{ .x = 51.41747094757, .y = 35.71904773801 },
        .{ .x = 51.41683321216, .y = 35.71889432433 },
        .{ .x = 51.41632932245, .y = 35.7201791548 },
        .{ .x = 51.41718750961, .y = 35.72198171784 },
        .{ .x = 51.41663638024, .y = 35.72199450183 },
        .{ .x = 51.41550262839, .y = 35.7213489078 },
    };
    const p_out = [_]Point{
        .{ .x = 51.41658156842, .y = 35.72015209299 },
        .{ .x = 51.41373037219, .y = 35.7217090877 },
    };
    const p_in = [_]Point{
        .{ .x = 51.41448139071, .y = 35.7213258319 },
        .{ .x = 51.41477106929, .y = 35.72068997161 },
        .{ .x = 51.41571520686, .y = 35.71994086942 },
    };
    const p_on = [_]Point{
        .{ .x = 51.4171560165, .y = 35.72024307617 },
        .{ .x = 51.41743945447, .y = 35.71973809593 },
        .{ .x = 51.41747094757, .y = 35.71904773801 },
    };

    for (p_out) |p|
        try expect(pointInPolygon(p, poly[0..]) == -1);
    for (p_in) |p|
        try expect(pointInPolygon(p, poly[0..]) == 1);
    for (p_on) |p|
        try expect(pointInPolygon(p, poly[0..]) == 0);
}
