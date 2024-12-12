const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const file = try std.fs.cwd().openFile("test_input.txt", .{});
    defer file.close();

    const content = try file.readToEndAlloc(allocator, 1024 * 1024);
    defer allocator.free(content);

    const stdout = std.io.getStdOut().writer();

    var stringBuilder = std.ArrayList(u8).init(allocator);
    defer stringBuilder.deinit();

    var count: i32 = 0;
    var totalSum: i64 = 0;
    var firstNum: i64 = 0;
    var secondNum: i64 = 0;

    for (content) |char| {
        if (char == 'm') {
            stringBuilder.clearRetainingCapacity();
            count = 1;
            firstNum = 0;
            secondNum = 0;
        }
        if (count == 1) {
            try stringBuilder.append(char);
            if (char == ')') {
                if (stringBuilder.items.len <= 12 and stringBuilder.items.len >= 8 and std.mem.startsWith(u8, stringBuilder.items, "mul(")) {
                    if (std.mem.indexOf(u8, stringBuilder.items, ",")) |commaIndex| {
                        const first = stringBuilder.items[4..commaIndex];
                        const second = stringBuilder.items[commaIndex + 1 .. stringBuilder.items.len - 1];

                        firstNum = try std.fmt.parseInt(i64, first, 10);
                        secondNum = try std.fmt.parseInt(i64, second, 10);

                        totalSum += (firstNum * secondNum);
                    }
                    count = 0;
                    stringBuilder.clearRetainingCapacity();
                }
            }
        }
    }
    try stdout.print("Total sum: {}\n", .{totalSum});
}
