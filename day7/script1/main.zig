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

    var sum: i64 = 0;

    var lineTokenizer = std.mem.tokenize(u8, content, "\n");
    while (lineTokenizer.next()) |line| {
        if (std.mem.indexOf(u8, line, ":")) |semiColonIndex| {
            const result = try std.fmt.parseInt(i64, line[0..semiColonIndex], 10);
            var allSum: i64 = 0;
            var allMul: i64 = 1;
            var evenSum: i64 = 1;
            var evenMul: i64 = 0;
            var numberTokenizer = std.mem.tokenize(u8, line[semiColonIndex + 1 ..], " ");
            var i: usize = 0;
            while (numberTokenizer.next()) |num| : (i += 1) {
                const number = try std.fmt.parseInt(i64, num, 10);
                allSum += number;
                allMul *= number;
                if (i % 2 == 0) {
                    evenSum *= number;
                    evenMul += number;
                } else {
                    evenSum += number;
                    evenMul *= number;
                }
            }
            if (allMul == result or allSum == result or evenMul == result or evenSum == result) {
                sum += result;
            }
        }
    }
    try stdout.print("{d}\n", .{sum});
}
