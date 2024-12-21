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

    var lineTokenizer = std.mem.tokenize(u8, content, "\n");
    while (lineTokenizer.next()) |line| {
        if (std.mem.indexOf(u8, line, ":")) |semiColonIndex| {
            var numbers = std.ArrayList(i32).init(allocator);
            defer numbers.deinit();

            var numberTokenizer = std.mem.tokenize(u8, line[semiColonIndex + 1 ..], " ");
            while (numberTokenizer.next()) |num| {
                const number = try std.fmt.parseInt(i32, num, 10);
                try numbers.append(number);
            }
            try stdout.print("{d}\n", .{numbers.items});
        }
    }
}
