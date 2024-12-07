const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    const content = try file.readToEndAlloc(allocator, 1024 * 1024);
    defer allocator.free(content);

    const stdout = std.io.getStdOut().writer();
    var line_tokenizer = std.mem.tokenize(u8, content, "\n");
    while (line_tokenizer.next()) |line| {
        var number_tokenizer = std.mem.tokenize(u8, line, " ");
        while (number_tokenizer.next()) |number_token| {
            if (std.fmt.parseInt(i32, number_token, 10)) |num| {
                try stdout.print("{any}\n", .{num});
            } else |_| {}
        }
        try stdout.print("end of line.\n", .{});
    }
}
