const std = @import("std");
var gpa = std.heap.GeneralPurposeAllocator(.{}){};

const wind = @import("winding_number.zig");

const polygon = @embedFile("../assets/polys_mashhad.json");
const Polygon = []struct {
    id: u32,
    counts: u32,
    coords: [][2]f32,
};
const opts = std.json.ParseOptions{ .allocator = &gpa.allocator };

pub fn main() anyerror!void {
    const polys = x: {
        var stream = std.json.TokenStream.init(polygon);
        break :x try std.json.parse(Polygon, &stream, opts);
    };
    defer std.json.parseFree(Polygon, polys, opts);

    const pins = try parseCSV("assets/pins_mashhad.csv", &gpa.allocator);

    for (polys) |poly| {
        var counts: u32 = 0;

        var points = std.ArrayList(wind.Point).init(&gpa.allocator);
        for (poly.coords[1..]) |coord|
            try points.append(wind.Point{ .x = coord[0], .y = coord[1] });
        for (pins.items) |pin| {
            if (wind.pointInPolygon(pin, points.items) == 0)
                counts += 1;
        }
        std.debug.print("{}: {}\n", .{ poly.id, counts });
    }
}

fn parseCSV(name: []const u8, alloc: *std.mem.Allocator) anyerror!std.ArrayList(wind.Point) {
    var pins = std.ArrayList(wind.Point).init(alloc);
    var file = try std.fs.cwd().openFile(name, .{});
    defer file.close();

    var in_stream = std.io.bufferedReader(file.reader()).reader();
    var buf: [20]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var points_it = std.mem.tokenize(line, ",");
        const p = wind.Point{
            .x = try std.fmt.parseFloat(f32, points_it.next().?),
            .y = try std.fmt.parseFloat(f32, points_it.next().?),
        };
        try pins.append(p);
    }
    return pins;
}
