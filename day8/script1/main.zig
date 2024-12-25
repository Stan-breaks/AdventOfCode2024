const std = @import("std");

const Frequency = struct {
    i: usize,
    j: usize,
    type: u8,
};

fn checkForFrequencies(map: [][]u8, current: Frequency, frequencies: *std.AutoHashMap(Frequency, void)) !void {
    var i = current.i + 1;
    while (i < map.len) : (i += 1) {
        var j: usize = 0;
        while (j < map[i].len) : (j += 1) {
            if (map[i][j] == current.type) {
                const diffI: i64 = @as(i64, @intCast(current.i)) - @as(i64, @intCast(i));
                const curr_j: i64 = @as(i64, @intCast(current.j));
                const pos_j: i64 = @as(i64, @intCast(j));

                if (j < current.j) {
                    const mirror_dist = curr_j - pos_j;
                    if (curr_j + mirror_dist >= 0 and curr_j + mirror_dist < @as(i64, @intCast(map[i].len)) and
                        current.i >= @as(usize, @intCast(@abs(diffI))))
                    {
                        const antinode = Frequency{
                            .j = @as(usize, @intCast(curr_j + mirror_dist)),
                            .i = current.i - @as(usize, @intCast(@abs(diffI))),
                            .type = '#',
                        };
                        try frequencies.put(antinode, {});
                    }
                    if (pos_j >= mirror_dist and i + @as(usize, @intCast(@abs(diffI))) < map.len) {
                        const antinode = Frequency{
                            .j = @as(usize, @intCast(pos_j - mirror_dist)),
                            .i = i + @as(usize, @intCast(@abs(diffI))),
                            .type = '#',
                        };
                        try frequencies.put(antinode, {});
                    }
                } else {
                    const mirror_dist = pos_j - curr_j;
                    if (curr_j >= mirror_dist and current.i >= @as(usize, @intCast(@abs(diffI)))) {
                        const antinode = Frequency{
                            .j = @as(usize, @intCast(curr_j - mirror_dist)),
                            .i = current.i - @as(usize, @intCast(@abs(diffI))),
                            .type = '#',
                        };
                        try frequencies.put(antinode, {});
                    }
                    if (pos_j + mirror_dist < @as(i64, @intCast(map[i].len)) and
                        i + @as(usize, @intCast(@abs(diffI))) < map.len)
                    {
                        const antinode = Frequency{
                            .j = @as(usize, @intCast(pos_j + mirror_dist)),
                            .i = i + @as(usize, @intCast(@abs(diffI))),
                            .type = '#',
                        };
                        try frequencies.put(antinode, {});
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
                const current = Frequency{
                    .i = i,
                    .j = j,
                    .type = map.items[i][j],
                };
                try checkForFrequencies(map.items, current, &frequencies);
            }
        }
    }
    try stdout.print("{d}\n", .{frequencies.count()});
}
