const std = @import("std");

const Frequency = struct {
    i: usize,
    j: usize,
    type: u8,
};

fn checkForFrequencies(map: [][]u8, frequencies: *std.AutoHashMap(Frequency, void), current: Frequency) !void {
    var i = current.i + 1;
    while (i < map.len) : (i += 1) {
        var j: usize = 0;
        while (j < map[i].len) : (j += 1) {
            if (map[i][j] == current.type) {
                const diffI = i - current.i;
                if (current.j > j) {
                    if (current.j + (current.j - j) < map[i].len and current.i >= diffI) {
                        var innerI: i32 = @intCast(current.i - diffI);
                        var innerJ: i32 = @intCast(current.j + (current.j - j));
                        if (innerI == 0) {
                            const antinode = Frequency{
                                .i = @as(usize, @intCast(innerI)),
                                .j = @as(usize, @intCast(innerJ)),
                                .type = '#',
                            };
                            try frequencies.put(antinode, {});
                        }
                        while (innerI > 0 and innerJ < map[i].len) {
                            const antinode = Frequency{
                                .i = @as(usize, @intCast(innerI)),
                                .j = @as(usize, @intCast(innerJ)),
                                .type = '#',
                            };
                            try frequencies.put(antinode, {});
                            innerI -= @as(i32, @intCast(diffI));
                            innerJ += @as(i32, @intCast((current.j - j)));
                        }
                    }
                    if (j >= (current.j - j) and i + diffI < map.len) {
                        var innerI: i32 = @intCast(i + diffI);
                        var innerJ: i32 = @intCast(j - (current.j - j));
                        if (innerJ == 0) {
                            const antinode = Frequency{
                                .i = @as(usize, @intCast(innerI)),
                                .j = @as(usize, @intCast(innerJ)),
                                .type = '#',
                            };
                            try frequencies.put(antinode, {});
                        }
                        while (innerI < map.len and innerJ > 0) {
                            const antinode = Frequency{
                                .i = @as(usize, @intCast(innerI)),
                                .j = @as(usize, @intCast(innerJ)),
                                .type = '#',
                            };
                            try frequencies.put(antinode, {});
                            innerI += @as(i32, @intCast(diffI));
                            innerJ -= @as(i32, @intCast(current.j - j));
                        }
                    }
                } else {
                    if (current.j >= (j - current.j) and current.i >= diffI) {
                        var innerI: i32 = @intCast(current.i - diffI);
                        var innerJ: i32 = @intCast(current.j - (j - current.j));
                        while (innerI > 0 and innerJ > 0) {
                            const antinode = Frequency{
                                .i = @as(usize, @intCast(innerI)),
                                .j = @as(usize, @intCast(innerJ)),
                                .type = '#',
                            };
                            try frequencies.put(antinode, {});

                            innerI -= @as(i32, @intCast(diffI));
                            innerJ -= @as(i32, @intCast(j - current.j));
                        }
                    }
                    if (j + (j - current.j) < map[i].len and i + diffI < map.len) {
                        var innerI: i32 = @intCast(i + diffI);
                        var innerJ: i32 = @intCast(j + (j - current.j));
                        while (innerI < map.len and innerJ < map[i].len) {
                            const antinode = Frequency{
                                .i = @as(usize, @intCast(innerI)),
                                .j = @as(usize, @intCast(innerJ)),
                                .type = '#',
                            };
                            try frequencies.put(antinode, {});
                            innerI += @as(i32, @intCast(diffI));
                            innerJ += @as(i32, @intCast(j - current.j));
                        }
                    }
                }
            }
        }
    }
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
    var frequencies = std.AutoHashMap(Frequency, void).init(allocator);
    defer frequencies.deinit();
    for (0..map.items.len) |i| {
        for (0..map.items[i].len) |j| {
            if (map.items[i][j] != '.') {
                const current = Frequency{ .i = i, .j = j, .type = map.items[i][j] };
                try checkForFrequencies(map.items, &frequencies, current);
            }
        }
    }
    try stdout.print("{d}\n", .{frequencies.count()});
}
