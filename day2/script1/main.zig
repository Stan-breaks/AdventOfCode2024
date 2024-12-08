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
    var safe: i32 = 0;
    var line_tokenizer = std.mem.tokenize(u8, content, "\n");
    while (line_tokenizer.next()) |line| {
        var number_tokenizer = std.mem.tokenize(u8, line, " ");
        var numbers = std.ArrayList(i32).init(allocator);
        defer numbers.deinit();
        while (number_tokenizer.next()) |number_token| {
            if (std.fmt.parseInt(i32, number_token, 10)) |num| {
                try numbers.append(num);
            } else |_| {}
        }
        var is_ascending = true;
        var is_descending = true;
        for (0..numbers.items.len - 2) |i| {
            if (@abs(numbers.items[i] - numbers.items[i + 1]) > 3 or numbers.items[i] >= numbers.items[i + 1]) {
                is_descending = false;
                break;
            }
        }
        for (0..numbers.items.len - 2) |i| {
            if (@abs(numbers.items[i + 1] - numbers.items[i]) > 3 or numbers.items[i] <= numbers.items[i + 1]) {
                is_ascending = false;
                break;
            }
        }
        if (is_ascending == true or is_descending == true) {
            safe += 1;
        }
    }
    try stdout.print("{any}\n", .{safe});
}
