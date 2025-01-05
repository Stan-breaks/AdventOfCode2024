const std = @import("std");

const Position = struct {
    i: usize,
    j: usize,
    value: usize,
};

fn findTailHead(map: [][]u8, num: Position) bool {
    var i: usize = num.i;
    var j: usize = num.j;
    var value: usize = num.value;
    while (true) {
        std.io.getStdOut().writer().print("i:{d},j:{d},value:{d}\n", .{ i, j, value }) catch {
            return false;
        };
        if (value == 9) {
            return true;
        } else if (i > 0 and map[i - 1][j] == value + 1) {
            i -= 1;
            value += 1;
        } else if (j > 0 and map[i][j - 1] == value + 1) {
            j -= 1;
            value += 1;
        } else if (i < map.len - 1 and map[i + 1][j] == value + 1) {
            i += 1;
            value += 1;
        } else if (j < map[i].len - 1 and map[i][j + 1] == value + 1) {
            j += 1;
            value += 1;
        } else {
            break;
        }
    }

    return false;
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
                if (findTailHead(map.items, Position{ .i = i, .j = j, .value = 0 })) {
                    result += 1;
                }
            }
        }
    }
    try stdout.print("tailheads: {d}\n", .{result});
}
