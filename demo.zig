const std = @import("std");

pub fn main() !void {
    // create a general purpose allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    //open a file
    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    //Read the file contents into memory
    const content = try file.readToEndAlloc(allocator, 1024 * 1024); //1MB max
    defer allocator.free(content);

    //split the contents into lines
    var line = std.mem.tokenize(u8, content, "/n");

    //Example of parsing strategies
    while (line.next()) |l| {
        const stdout = std.io.getStdOut().writer();
        try stdout.print("{s}\n", .{l});
    }
}
