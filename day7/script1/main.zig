const std = @import("std");

fn tryAllResults(numbers: []i64, results: *std.ArrayList(i64), allocator: std.mem.Allocator) !void {
    if (numbers.len == 1) {
        try results.append(numbers[0]);
    }
    var i: usize = 0;
    while (i < numbers.len) : (i += 1) {
        const left = numbers[0..i];
        const right = numbers[i + 1 ..];
        var left_result = std.ArrayList(i64).init(allocator);
        defer left_result.deinit();
        var right_result = std.ArrayList(i64).init(allocator);
        defer right_result.deinit();

        try tryAllResults(left, &left_result, allocator);
        try tryAllResults(right, &right_result, allocator);
        for (left_result.items) |left_val| {
            for (right_result.items) |right_val| {
                try std.io.getStdOut().writer().print("num {d},num {d}\n", .{ left_val, right_val });
                try results.append(left_val + right_val);
                try results.append(left_val * right_val);
            }
        }

        try std.io.getStdOut().writer().print("{d}\n", .{results.items});
    }
}

fn tryAllcombination(numbers: []i64, target: i64, allocator: std.mem.Allocator) bool {
    if (numbers.len == 1) {
        return numbers[0] == target;
    }
    var i: usize = 0;
    while (i < numbers.len) : (i += 1) {
        const left = numbers[0..i];
        const right = numbers[i + 1 ..];
        var left_results = std.ArrayList(i64).init(allocator);
        defer left_results.deinit();
        var right_results = std.ArrayList(i64).init(allocator);
        defer right_results.deinit();
        tryAllResults(left, &left_results, allocator) catch {
            return false;
        };
        tryAllResults(right, &right_results, allocator) catch {
            return false;
        };
        for (left_results.items) |left_val| {
            for (right_results.items) |right_val| {
                if (left_val * right_val == target) {
                    return true;
                }
                if (left_val + right_val == target) {
                    return true;
                }
            }
        }
    }
    return false;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const file = try std.fs.cwd().openFile("test_input.txt", .{});
    defer file.close();

    const content = try file.readToEndAlloc(allocator, 1024 * 1024);
    defer allocator.free(content);

    const stdout = std.io.getStdOut().writer();

    var sum: i64 = 0;
    var lineTokenizer = std.mem.tokenize(u8, content, "\n");
    while (lineTokenizer.next()) |line| {
        if (std.mem.indexOf(u8, line, ":")) |semiColonIndex| {
            const target = try std.fmt.parseInt(i64, line[0..semiColonIndex], 10);
            var numbers = std.ArrayList(i64).init(allocator);
            defer numbers.deinit();

            var numberTokenizer = std.mem.tokenize(u8, line[semiColonIndex + 1 ..], " ");
            while (numberTokenizer.next()) |num| {
                const number = try std.fmt.parseInt(i32, num, 10);
                try numbers.append(number);
            }
            if (tryAllcombination(numbers.items, target, allocator)) {
                sum += target;
            }
        }
    }
    try stdout.print("{d}\n", .{sum});
}
