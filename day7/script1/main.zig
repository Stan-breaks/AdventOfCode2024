const std = @import("std");

fn tryAllcombination(numbers: []i64, target: i64) bool {
    if (numbers.len == 1) {
        return target == numbers[0];
    }
    if (numbers.len == 0) {
        return false;
    }
    const length: usize = numbers.len - 1;
    const total = @as(usize, 1) << @intCast(length);

    var i: usize = 0;
    while (i < total) : (i += 1) {
        var totalVal: i64 = numbers[0];
        var j: u6 = 0;
        while (j < length) : (j += 1) {
            const bit: usize = ((i >> @intCast(length -% 1 -% j))) & 1;

            if (bit == 0) {
                totalVal += (numbers[j + 1]);
            } else {
                totalVal *= (numbers[j + 1]);
            }
        }
        if (totalVal == target) {
            return true;
        }
    }
    return false;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const file = try std.fs.cwd().openFile("advent_input.txt", .{});
    defer file.close();

    const content = try file.readToEndAlloc(allocator, 1024 * 1024);
    defer allocator.free(content);

    const stdout = std.io.getStdOut().writer();

    var sum: i64 = 0;
    var lineTokenizer = std.mem.tokenize(u8, content, "\n");
    while (lineTokenizer.next()) |line| {
        if (std.mem.indexOf(u8, line, ":")) |colonIndex| {
            const target = try std.fmt.parseInt(i64, line[0..colonIndex], 10);
            var numbers = std.ArrayList(i64).init(allocator);
            defer numbers.deinit();

            var numbersTokenizer = std.mem.tokenize(u8, line[colonIndex + 1 ..], " ");
            while (numbersTokenizer.next()) |val| {
                const num = try std.fmt.parseInt(i64, val, 10);
                try numbers.append(num);
            }
            if (tryAllcombination(numbers.items, target)) {
                sum += target;
            }
        }
    }
    try stdout.print("{d}\n", .{sum});
}
