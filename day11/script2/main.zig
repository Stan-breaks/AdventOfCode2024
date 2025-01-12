const std = @import("std");

fn blink(numbers: *std.AutoHashMap(i64, i64), allocator: std.mem.Allocator) !std.AutoHashMap(i64, i64) {
    var newNumbers = std.AutoHashMap(i64, i64).init(allocator);
    var numberIterator = numbers.iterator();
    while (numberIterator.next()) |entry| {
        const key = entry.key_ptr.*;
        const val = entry.value_ptr.*;
        if (key == 0) {
            try newNumbers.put(1, val + (newNumbers.get(1) orelse 0));
        } else {
            const str = try std.fmt.allocPrint(allocator, "{d}", .{key});
            defer allocator.free(str);
            if (str.len % 2 == 0) {
                const num1 = try std.fmt.parseInt(i64, str[0 .. str.len / 2], 10);
                const num2 = try std.fmt.parseInt(i64, str[str.len / 2 ..], 10);

                try newNumbers.put(num1, val + (newNumbers.get(num1) orelse 0));
                try newNumbers.put(num2, val + (newNumbers.get(num2) orelse 0));
            } else {
                const newKey = key * 2024;
                try numbers.put(newKey, val + (newNumbers.get(newKey) orelse 0));
            }
        }
    }
    return newNumbers;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const file = try std.fs.cwd().openFile("test_input.txt", .{});
    defer file.close();

    const content = try file.readToEndAlloc(allocator, 1024 * 1024);
    defer allocator.free(content);

    const stdout = std.debug;

    var total: i64 = 0;

    var numbers = std.AutoHashMap(i64, i64).init(allocator);
    defer numbers.deinit();

    var numberTokenizer = std.mem.tokenize(u8, content, "    ");
    while (numberTokenizer.next()) |val| {
        const num = try std.fmt.parseInt(i64, std.mem.trim(u8, val, "\n"), 10);
        try numbers.put(num, 1 + (numbers.get(num) orelse 0));
    }
    for (0..25) |_| {
        const newNumbers = try blink(&numbers, allocator);
        numbers.deinit();
        numbers = newNumbers;
    }

    var numbersIterator = numbers.valueIterator();
    while (numbersIterator.next()) |val| {
        total += val.*;
    }
    stdout.print("{d}\n", .{total});
}
