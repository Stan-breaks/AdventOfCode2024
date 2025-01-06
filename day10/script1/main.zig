const std = @import("std");

const Position = struct {
    i: usize,
    j: usize,
    value: u8,
};

fn findPath(map: [][]u8, pos: Position, visited: *std.AutoHashMap(u64, void), peaks: *std.AutoHashMap(u64, void)) i32 {
    if (pos.value == '9') {
        const peak = @as(u64, pos.i) << 32 | pos.j;
        if (peaks.contains(peak)) return 0;
        peaks.put(peak, {}) catch return 0;
        return 1;
    }
    const key = @as(u64, pos.i) << 32 | pos.j;
    if (visited.contains(key)) return 0;
    visited.put(key, {}) catch return 0;
    const moves = [_][2]i32{ .{ 1, 0 }, .{ 0, 1 }, .{ -1, 0 }, .{ 0, -1 } };
    var totalPath: i32 = 0;
    for (moves) |move| {
        const intI = @as(i32, @intCast(pos.i)) + move[0];
        const intJ = @as(i32, @intCast(pos.j)) + move[1];
        if (intI >= 0 and intJ >= 0 and intI < map.len and intJ < map[0].len and map[@intCast(intI)][@intCast(intJ)] == pos.value + 1) {
            const newPos = Position{
                .i = @intCast(intI),
                .j = @intCast(intJ),
                .value = pos.value + 1,
            };
            totalPath += findPath(map, newPos, visited, peaks);
        }
    }
    return totalPath;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const file = try std.fs.cwd().openFile("advent_input.txt", .{});
    defer file.close();

    const content = try file.readToEndAlloc(allocator, 1024 * 1024);
    defer allocator.free(content);
    const stdout = std.io.getStdOut().writer();

    var map = std.ArrayList([]u8).init(allocator);
    defer {
        for (map.items) |item| {
            allocator.free(item);
        }
        map.deinit();
    }

    var visited = std.AutoHashMap(u64, void).init(allocator);
    defer visited.deinit();

    var peaks = std.AutoHashMap(u64, void).init(allocator);
    defer peaks.deinit();

    var lineTokenizer = std.mem.tokenize(u8, content, "\n");
    while (lineTokenizer.next()) |line| {
        const mutableLine = try allocator.alloc(u8, line.len);
        @memcpy(mutableLine, line);
        try map.append(mutableLine);
    }
    var result: i32 = 0;
    for (0..map.items.len) |i| {
        for (0..map.items[i].len) |j| {
            if (map.items[i][j] == '0') {
                peaks.clearRetainingCapacity();
                visited.clearRetainingCapacity();
                const path = findPath(map.items, Position{ .i = i, .j = j, .value = '0' }, &visited, &peaks);
                if (path > 0) {
                    result += path;
                }
            }
        }
    }
    try stdout.print("tailheads: {d}\n", .{result});
}
