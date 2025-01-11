const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const file = try std.fs.cwd().openFile("test_input.txt", .{});
    defer file.close();

    const content = try file.readToEndAlloc(allocator, 1024 * 1024);
    defer allocator.free(content);

    const stdout = std.debug;

    const result: i32 = 0;

    var numbers = std.ArrayList(i64).init(allocator);
    defer numbers.deinit();

    var numberTokenizer = std.mem.tokenize(u8, content, "    ");
    while (numberTokenizer.next()) |val| {
        const num = try std.fmt.parseInt(i64, std.mem.trim(u8, val, "\n"), 10);
        try numbers.append(num);
    }

    stdout.print("{d}\n", .{result});

    stdout.print("{any}\n", .{numbers.items});
}
