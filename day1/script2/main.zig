const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    const content = try file.readToEndAlloc(allocator, 1024 * 1024);
    defer allocator.free(content);

    var arr = std.ArrayList(i32).init(allocator);
    defer arr.deinit();
    var map = std.AutoHashMap(i32, i32).init(allocator);
    defer map.deinit();
    var sum: i32 = 0;

    const stdout = std.io.getStdOut().writer();
    var line_tokenizer = std.mem.tokenize(u8, content, "\n");
    while (line_tokenizer.next()) |line| {
        var number_tokenizer = std.mem.tokenize(u8, line, "   ");
        if (number_tokenizer.next()) |first| {
            if (std.fmt.parseInt(i32, first, 10)) |num1| {
                try arr.append(num1);
            } else |_| {}
        }
        if (number_tokenizer.next()) |second| {
            if (std.fmt.parseInt(i32, second, 10)) |num2| {
                const count = map.get(num2) orelse 0;
                try map.put(num2, count + 1);
            } else |_| {}
        }
    }
    for (arr.items) |num| {
        const count = map.get(num) orelse 0;
        sum += (num * count);
    }
    try stdout.print("{any}\n", .{sum});
}
