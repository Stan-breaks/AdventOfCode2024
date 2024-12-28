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
        for (arr.items) |item| {
            allocator.free(item);
        }
        arr.deinit();
    }

    var id: i32 = 0;
    for (0..content.len - 1) |i| {
        if (i % 2 == 0) {
            const size: usize = @intCast(content[i] - '0');
            if (size > 0) {
                for (size) |_| {
                    const str = try std.fmt.allocPrint(allocator, "{}", .{id});
                    try arr.append(str);
                }
                id += 1;
            }
        } else {
            const space: usize = @intCast(content[i] - '0');
            if (space > 0) {
                for (space) |_| {
                    const dot = try std.fmt.allocPrint(allocator, ".", .{});
                    try arr.append(dot);
                }
            }
        }
    }
    var left: usize = 0;
    var right: usize = arr.items.len - 1;
    while (left < right) {
        if (std.mem.eql(u8, arr.items[left], ".")) {
            const dot = arr.items[left];
            const num = arr.items[right];
            arr.items[left] = num;
            arr.items[right] = dot;
            right -= 1;
        } else {
            left += 1;
        }
    }

    var sum: i64 = 0;
    for (0..arr.items.len) |i| {
        if (!std.mem.eql(u8, arr.items[i], ".")) {
            const num = try std.fmt.parseInt(i64, arr.items[i], 10);
            sum += (@as(i64, @intCast(i)) * num);
        } else {
            break;
        }
    }
    try stdout.print("{d}\n", .{sum});
}
