const std = @import("std");

const Position = struct {
    i: usize,
    j: usize,
    value: u8,
};

fn findPath(map: [][]u8, pos: Position) i32 {
    if (pos.value == '9') {
        return 1;
    }
    const moves = [_][2]i32{ .{ 1, 0 }, .{ 0, 1 }, .{ -1, 0 }, .{ 0, -1 } };
    var totalPaths: i32 = 0;
    for (moves) |move| {
        const newI = @as(i32, @intCast(pos.i)) + move[0];
        const newJ = @as(i32, @intCast(pos.j)) + move[1];
        if (newI >= 0 and newJ >= 0 and newI < map.len and newJ < map[0].len and map[@intCast(newI)][@intCast(newJ)] == pos.value + 1) {
            const newPos = Position{
                .i = @intCast(newI),
                .j = @intCast(newJ),
                .value = pos.value + 1,
            };
            totalPaths += findPath(map, newPos);
        }
    }
    return totalPaths;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const file = try std.fs.cwd().openFile("test_input.txt", .{});
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
    var lineTokenizer = std.mem.tokenize(u8, content, "\n");
    while (lineTokenizer.next()) |line| {
        const mutableLine = allocator.alloc(u8, line.len);
        @memcpy(mutableLine, line);
        map.append(mutableLine);
    }
    var result: i32 = 0;
    for (0..map.items.len) |i| {
        for (0..map.items[i].len) |j| {
            if (map.items[i][j] == '0') {
                const path = findPath(map.items, Position{ .i = i, .j = j, .value = '0' });
                if (path > 0) {
                    result += path;
                }
            }
        }
    }
    try stdout.print("tails: {d}\n", .{result});
}
