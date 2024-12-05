const std = @import("std");

pub fn main() !void {
    // creating a general purpose allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    //open a file
    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    // read the file into memory
    const content = try file.readToEndAlloc(allocator, 1024 * 1024);
    defer allocator.free(content);

    // Prepare dynamic arrays for storage
    var array1 = std.ArrayList(i32).init(allocator);
    defer array1.deinit();
    var array2 = std.ArrayList(i32).init(allocator);
    defer array2.deinit();

    var sum: i32 = 0;

    var line_tokenizer = std.mem.tokenize(u8, content, "\n");
    const stdout = std.io.getStdOut().writer();
    while (line_tokenizer.next()) |line| {
        var number_tokenizer = std.mem.tokenize(u8, line, "   ");
        if (number_tokenizer.next()) |first| {
            if (std.fmt.parseInt(i32, first, 10)) |num1| {
                try array1.append(num1);
            } else |_| {}
        }
        if (number_tokenizer.next()) |second| {
            if (std.fmt.parseInt(i32, second, 10)) |num2| {
                try array2.append(num2);
            } else |_| {}
        }
    }

    std.mem.sort(i32, array1.items, {}, comptime std.sort.asc(i32));
    std.mem.sort(i32, array2.items, {}, comptime std.sort.asc(i32));

    for (array1.items, array2.items) |val1, val2| {
        sum += (if (val1 > val2) val1 - val2 else val2 - val1);
    }
    try stdout.print("{any}\n", .{sum});
}
