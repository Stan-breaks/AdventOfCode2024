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
    var left: usize = 0;
    var right: usize = arr.items.len - 1;
    while (left < right) {
        if (arr.items[left] == '.') {
            arr.items[left] = arr.items[right];
            arr.items[right] = '.';
            right -= 1;
        } else {
            left += 1;
        }
    }

    var sum: i32 = 0;
    for (0..arr.items.len) |i| {
        if (arr.items[i] != '.') {
            const num: usize = @intCast(arr.items[i]);
            sum += @intCast(i * (num - 48));
        } else {
            break;
        }
    }
    try stdout.print("{d}\n", .{sum});
}
