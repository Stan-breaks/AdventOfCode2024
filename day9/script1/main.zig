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

    var arr = std.ArrayList(u8).init(allocator);
    defer arr.deinit();

    var id: usize = 0;
    for (0..content.len - 1) |i| {
        if (i % 2 == 0) {
            const str: u8 = @intCast(id + 48);
            const size: usize = @intCast(content[i] - 48);
            if (size > 0) {
                for (size) |_| {
                    try arr.append(str);
                }
                id += 1;
            }
        } else {
            const space: usize = @intCast(content[i] - 48);
            if (space > 0) {
                for (space) |_| {
                    try arr.append('.');
                }
            }
        }
    }
    try stdout.print("{s}\n", .{arr.items});
}
