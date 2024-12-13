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
    var bigArr = std.ArrayList([]u8).init(allocator);
    defer bigArr.deinit();

    var lineTokenizer = std.mem.tokenize(u8, content, "\n");

    while (lineTokenizer.next()) |line| {
        var smallArr = std.ArrayList(u8).init(allocator);
        defer smallArr.deinit();
        for (line) |char| {
            try smallArr.append(char);
        }
        try bigArr.append(smallArr.items);
    }

    try stdout.print("{any}\n", .{bigArr.items});
}
