const std = @import("std");
fn tryAllcombination(numbers: []i64, target: i64) bool {
    if (numbers.len == 1) return target == numbers[0];
    if (numbers.len == 0) return false;

    const length: usize = numbers.len - 1;
    const combinations = std.math.pow(usize, 3, length);
    var i: usize = 0;
    var buffer: [32]u8 = undefined;
    while (i < combinations) : (i += 1) {
        var total: i64 = numbers[0];
        var j: usize = 0;
        var tempI = i;
        while (j < length) : (j += 1) {
            const op = tempI % 3;
            tempI /= 3;
            switch (op) {
                0 => total += numbers[j + 1],
                1 => total *= numbers[j + 1],
                2 => {
                    const str = std.fmt.bufPrint(&buffer, "{d}{d}", .{ total, numbers[j + 1] }) catch {
                        return false;
                    };
                    total = std.fmt.parseInt(i64, str, 10) catch {
                        return false;
                    };
                },
                else => continue,
            }
        }
        if (total == target) {
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
            var numberTokenizer = std.mem.tokenize(u8, line[colonIndex + 1 ..], " ");
            while (numberTokenizer.next()) |val| {
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
