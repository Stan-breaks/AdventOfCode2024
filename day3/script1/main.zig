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

    var stringbuilder = std.ArrayList(u8).init(allocator);
    defer stringbuilder.deinit();
    var count: i32 = 0;

    var total_sum: i64 = 0;
    var first_num: i64 = 0;
    var second_num: i64 = 0;

    for (content) |char| {
        if (char == 'm') {
            stringbuilder.clearRetainingCapacity();
            count = 1;
            first_num = 0;
            second_num = 0;
        }
        if (count == 1) {
            try stringbuilder.append(char);
            if (char == ')') {
                if (stringbuilder.items.len <= 12 and stringbuilder.items.len >= 8 and std.mem.startsWith(u8, stringbuilder.items, "mul(")) {
                    if (std.mem.indexOf(u8, stringbuilder.items, ",")) |comma_index| {
                        const first = stringbuilder.items[4..comma_index];
                        const second = stringbuilder.items[comma_index + 1 .. stringbuilder.items.len - 1];

                        first_num = try std.fmt.parseInt(i64, first, 10);
                        second_num = try std.fmt.parseInt(i64, second, 10);

                        total_sum += (first_num * second_num);
                    }
                    stringbuilder.clearRetainingCapacity();
                    count = 0;
                }
            }
        }
    }
    try stdout.print("Total sum: {}\n", .{total_sum});
}
