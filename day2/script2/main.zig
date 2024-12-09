const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    const content = try file.readToEndAlloc(allocator, 1024 * 1024);
    defer allocator.free(content);

    var line_tokenizer = std.mem.tokenize(u8, content, "\n");
    const stdout = std.io.getStdOut().writer();
    var safe: i32 = 0;

    while (line_tokenizer.next()) |line| {
        var number_tokenizer = std.mem.tokenize(u8, line, " ");
        var numbers = std.ArrayList(i32).init(allocator);
        defer numbers.deinit();
        while (number_tokenizer.next()) |val| {
            if (std.fmt.parseInt(i32, val, 10)) |num| {
                try numbers.append(num);
            } else |_| {}
        }
        var is_asceding = true;
        var ascend_count: i32 = 0;
        var i: usize = 0;
        while (i < numbers.items.len - 1) {
            if (@abs(numbers.items[i + 1] - numbers.items[i]) > 3 or numbers.items[i] >= numbers.items[i + 1]) {
                if (ascend_count == 0) {
                    ascend_count = 1;
                    _ = numbers.orderedRemove(i);
                    if (i > 0) {
                        i -= 1;
                    }
                } else {
                    is_asceding = false;
                    break;
                }
            }
            i += 1;
        }
        var is_desceding = true;
        var descend_count: i32 = 0;
        var j: usize = 0;
        while (j < numbers.items.len - 1) {
            if (@abs(numbers.items[j] - numbers.items[j + 1]) > 3 or numbers.items[j + 1] >= numbers.items[j]) {
                if (descend_count == 0) {
                    descend_count = 1;
                    _ = numbers.orderedRemove(j);
                    if (j > 0) {
                        j -= 1;
                    }
                } else {
                    is_desceding = false;
                    break;
                }
            }
            j += 1;
        }
        if (is_asceding or is_desceding) {
            safe += 1;
        }
    }
    try stdout.print("{any}\n", .{safe});
}
