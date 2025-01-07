const std = @import("std");

fn blink(arr: []i64, allocator: std.mem.Allocator) std.ArrayList(i64) {
    var result = std.ArrayList(i64).init(allocator);

    for (arr) |item| {
        const str = std.fmt.allocPrint(allocator, "{d}", .{item}) catch return result;
        defer allocator.free(str);
        if (item == 0) {
            result.append(1) catch return result;
            continue;
        }
        var len: u8 = 1;
        var temp = item;
        while (temp >= 10) : (temp = @divFloor(temp, 10)) {
            len += 1;
        }
        if (len % 2 == 0) {
            const divisor: i64 = std.math.pow(i64, 10, len / 2);
            const num1 = @divFloor(item, divisor);
            const num2 = @mod(item, divisor);
            result.appendSlice(&[_]i64{ num1, num2 }) catch return result;
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

    var result = std.ArrayList(i64).init(allocator);
    defer result.deinit();

    var numberTokenizer = std.mem.tokenize(u8, content, "    ");
    while (numberTokenizer.next()) |val| {
        const num = try std.fmt.parseInt(i64, std.mem.trim(u8, val, "\n"), 10);
        try result.append(num);
    }

    for (0..75) |_| {
        const newresult = blink(result.items, allocator);
        result.deinit();
        result = newresult;
    }

    try stdout.print("{d}", .{result.items.len});
}
