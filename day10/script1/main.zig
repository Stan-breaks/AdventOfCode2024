const std = @import("std");

const Position = struct {
    i: usize,
    j: usize,
    value: usize,
};

fn findTailHead(map: [][]u8, num: Position) i32 {
    var current = Position{ .i = num.i, .j = num.j, .value = num.value };
    while (current.i > -1 and current.i < map.len and current.j > -1 and current.j < map[current.i].len) {
        if (current.value == 9) {
            return 1;
        }
        if (current.i > 0 and map[current.i - 1][current.j] == current.value + 1) {
            current.i -= 1;
            current.value += 1;
        } else if (current.j > 0 and map[current.i][current.j - 1] == current.value + 1) {
            current.j -= 1;
            current.value += 1;
        } else if (current.i < map.len - 1 and map[current.i + 1][current.j] == current.value + 1) {
            current.i += 1;
            current.value += 1;
        } else if (current.j < map[current.i].len - 1 and map[current.i][current.j + 1] == current.value + 1) {
            current.j += 1;
            current.value += 1;
        } else {
            return 0;
        }
    }
    return 0;
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
        const mutableLine = try allocator.alloc(u8, line.len);
        @memcpy(mutableLine, line);
        try map.append(mutableLine);
    }
    var result: i32 = 0;
    for (0..map.items.len) |i| {
        for (0..map.items[i].len) |j| {
            if (map.items[i][j] == '0') {
                const num = Position{
                    .i = i,
                    .j = j,
                    .value = 0,
                };
                result += findTailHead(map.items, num);
            }
        }
    }
    try stdout.print("tailheads: {d}", .{result});
}
