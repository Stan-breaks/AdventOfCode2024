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
        if (is_sequence_safe(numbers.items)) {
            safe += 1;
            continue;
        }

        var is_removable_safe = false;
        for (0..numbers.items.len) |remove_index| {
            var test_numbers = try numbers.clone();
            defer test_numbers.deinit();
            _ = test_numbers.orderedRemove(remove_index);
            if (is_sequence_safe(test_numbers.items)) {
                is_removable_safe = true;
                break;
            }
        }
        if (is_removable_safe) {
            safe += 1;
        }
    }
    try stdout.print("{any}\n", .{safe});
}

fn is_sequence_safe(numbers: []const i32) bool {
    var is_descending = true;
    for (0..(numbers.len - 1)) |i| {
        if (@abs(numbers[i] - numbers[i + 1]) > 3 or numbers[i] <= numbers[i + 1]) {
            is_descending = false;
            break;
        }
    }
    var is_ascending = true;
    for (0..(numbers.len - 1)) |i| {
        if (@abs(numbers[i + 1] - numbers[i]) > 3 or numbers[i] >= numbers[i + 1]) {
            is_ascending = false;
            break;
        }
    }

    if (is_ascending or is_descending) {
        return true;
    } else {
        return false;
    }
}
