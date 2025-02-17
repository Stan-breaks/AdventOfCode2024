const std = @import("std");
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const file = try std.fs.cwd().openFile("advent_input.txt", .{});
    defer file.close();

    const content = try file.readToEndAlloc(allocator, 1024 * 1024);
    defer allocator.free(content);

    const stdout = std.io.getStdOut().writer();

    var arr = std.ArrayList([]u8).init(allocator);
    defer {
        for (arr.items) |line| {
            allocator.free(line);
        }
        arr.deinit();
    }

    var lineTokenizer = std.mem.tokenize(u8, content, "\n");
    while (lineTokenizer.next()) |line| {
        const mutableLine = try allocator.alloc(u8, line.len);
        @memcpy(mutableLine, line);
        try arr.append(mutableLine);
    }

    var count: i64 = 0;

    for (0..arr.items.len) |i| {
        for (0..arr.items[i].len) |j| {
            const signedI: i64 = @intCast(i);
            const signedJ: i64 = @intCast(j);
            if (arr.items[i][j] == 'A' and signedI - 1 >= 0 and signedJ - 1 >= 0 and i + 1 < arr.items.len and j + 1 < arr.items[i].len) {
                var forwardDiagonal = std.ArrayList(u8).init(allocator);
                defer forwardDiagonal.deinit();

                for (0..3) |k| {
                    try forwardDiagonal.append(arr.items[i + k - 1][j + k - 1]);
                }

                var backDiagonal = std.ArrayList(u8).init(allocator);
                defer backDiagonal.deinit();

                for (0..3) |k| {
                    try backDiagonal.append(arr.items[i + k - 1][j + 1 - k]);
                }

                if ((std.mem.startsWith(u8, forwardDiagonal.items, "SAM") or std.mem.startsWith(u8, forwardDiagonal.items, "MAS")) and (std.mem.startsWith(u8, backDiagonal.items, "SAM") or std.mem.startsWith(u8, backDiagonal.items, "MAS"))) {
                    count += 1;
                }
            }
        }
    }

    try stdout.print("{d}\n", .{count});
}
