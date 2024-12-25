const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    for (0..27) |i| {
        var tempI = i;
        for (0..3) |_| {
            const op = tempI % 3;
            tempI /= 3;
            try stdout.print("{d}", .{op});
        }

        try stdout.print("\n", .{});
    }
}
