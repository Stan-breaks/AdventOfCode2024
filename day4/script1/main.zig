const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const file = try std.fs.cwd().openFile("test_input.txt", .{});
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
            if (arr.items[i][j] == 'S' or arr.items[i][j] == 'X') {
                if (std.mem.startsWith(u8, arr.items[i][j..], "SAMX") or std.mem.startsWith(u8, arr.items[i][j..], "XMAS")) {
                    count += 1;
                }
                if (i + 4 <= arr.items.len) {
                    var verticalStr = std.ArrayList(u8).init(allocator);
                    defer verticalStr.deinit();
                    for (0..4) |k| {
                        try verticalStr.append(arr.items[i + k][j]);
                    }
                    if (std.mem.startsWith(u8, verticalStr.items, "SAMX") or std.mem.startsWith(u8, verticalStr.items, "XMAS")) {
                        count += 1;
                    }
                }
                if (i + 4 <= arr.items.len and j + 4 <= arr.items[i].len) {
                    var forwardDiagonal = std.ArrayList(u8).init(allocator);
                    defer forwardDiagonal.deinit();
                    var r = i;
                    var c = j;
                    while (r < i + 4 and c < j + 4) {
                        try forwardDiagonal.append(arr.items[r][c]);
                        r += 1;
                        c += 1;
                    }
                    if (std.mem.startsWith(u8, forwardDiagonal.items, "SAMX") or std.mem.startsWith(u8, forwardDiagonal.items, "XMAS")) {
                        count += 1;
                    }
                }
                const signedI: i64 = @intCast(i);
                if (signedI - 4 >= 0 and j + 4 <= arr.items[i].len) {
                    var backwardDiagonal = std.ArrayList(u8).init(allocator);
                    defer backwardDiagonal.deinit();
                    var r = i;
                    var c = j;
                    while (r > i - 4 and c < j + 4) {
                        try backwardDiagonal.append(arr.items[r][c]);
                        r -= 1;
                        c += 1;
                    }
                    if (std.mem.startsWith(u8, backwardDiagonal.items, "SAMX") or std.mem.startsWith(u8, backwardDiagonal.items, "XMAS")) {
                        count += 1;
                    }
                }
            }
        }
    }

    try stdout.print("Number of instances is {}\n", .{count});
}
