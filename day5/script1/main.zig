const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const file = try std.fs.cwd().openFile("advent_input.txt", .{});
    defer file.close();

    const content = try file.readToEndAlloc(allocator, 1024 * 1024);
    defer allocator.free(content);

    const stdout = std.io.getStdOut().writer();

    var firstSection: []const u8 = undefined;
    var secondSection: []const u8 = undefined;

    for (0..content.len - 1) |i| {
        if (content[i] == '\n' and content[i + 1] == '\n') {
            firstSection = content[0..i];
            secondSection = content[i + 2 ..];
            break;
        }
    }

    var firstLineTokenizer = std.mem.tokenize(u8, firstSection, "\n");
    var rules = std.ArrayList(struct { first: i32, second: i32 }).init(allocator);
    defer rules.deinit();
    while (firstLineTokenizer.next()) |line| {
        if (std.mem.indexOf(u8, line, "|")) |separatorIndex| {
            const firstRule = try std.fmt.parseInt(i32, line[0..separatorIndex], 10);
            const secondRule = try std.fmt.parseInt(i32, line[separatorIndex + 1 ..], 10);
            try rules.append(.{ .first = firstRule, .second = secondRule });
        }
    }

    var secondLineTokenizer = std.mem.tokenize(u8, secondSection, "\n");
    var numbersList = std.ArrayList([]i32).init(allocator);
    defer {
        for (numbersList.items) |line| {
            allocator.free(line);
        }
        numbersList.deinit();
    }
    while (secondLineTokenizer.next()) |line| {
        var numbersInLine = std.ArrayList(i32).init(allocator);
        defer numbersInLine.deinit();

        var numbersTokenizer = std.mem.tokenize(u8, line, ",");
        while (numbersTokenizer.next()) |number| {
            const value = try std.fmt.parseInt(i32, number, 10);
            try numbersInLine.append(value);
        }
        const mutableLine = try allocator.alloc(i32, numbersInLine.items.len);
        @memcpy(mutableLine, numbersInLine.items);
        try numbersList.append(mutableLine);
    }

    var sum: i32 = 0;
    for (numbersList.items) |list| {
        var isCorrect = true;
        for (0..list.len - 1) |i| {
            const firstNum = list[i];
            const secondNum = list[i + 1];
            for (rules.items) |rule| {
                if (firstNum == rule.second and secondNum == rule.first) {
                    isCorrect = false;
                }
            }
        }
        if (isCorrect == true) {
            sum += (list[(list.len / 2)]);
        }
    }

    try stdout.print("{d}\n", .{sum});
}
