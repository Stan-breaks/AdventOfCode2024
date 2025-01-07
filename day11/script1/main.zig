const std = @import("std");

fn blink(arr: []i32, allocator: std.mem.Allocator) std.ArrayList(i32) {
    var result = std.ArrayList(i32).init(allocator);
    defer result.deinit();
    for (arr) |item| {
        const str = std.fmt.allocPrint(allocator, "{d}", .{item}) catch return result;
        defer allocator.free(str);
        if (item == 0) {
            result.append(1) catch return result;
        } else if (str.len % 2 == 0) {
            const num1 = std.fmt.parseInt(i32, str[0 .. str.len / 2], 10) catch return result;
            const num2 = std.fmt.parseInt(i32, str[str.len / 2 ..], 10) catch return result;
            result.append(num1) catch return result;
            result.append(num2) catch return result;
        } else {
            result.append(item * 2024) catch return result;
        }
    }
    return result;
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

    var arr = std.ArrayList(i32).init(allocator);
    defer arr.deinit();

    var numberTokenizer = std.mem.tokenize(u8, content, "   ");
    while (numberTokenizer.next()) |val| {
        const num = try std.fmt.parseInt(i32, val, 10);
        try arr.append(num);
    }

    for (0..6) |_| {
        arr = blink(arr.items, allocator);
    }

    try stdout.print("{d}\n", .{arr.items.len});
}
