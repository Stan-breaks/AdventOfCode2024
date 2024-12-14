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
            if (std.mem.startsWith(u8, arr.items[i][j..], "SAMX") or std.mem.startsWith(u8, arr.items[i][j..], "XMAS")) {
                count += 1;
            }
            if (std.mem.startsWith(u8, arr.items[j][i..], "SAMX") or std.mem.startsWith(u8, arr.items[j][i..], "XMAS")) {
                count += 1;
            }
        }
    }

    try stdout.print("Number of instances is {}\n", .{count});
}
