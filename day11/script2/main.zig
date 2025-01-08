const std = @import("std");

fn getDigitLength(num: i64) u8 {
    if (num == 0) return 1;

    var n = if (num < 0) -num else num;
    var len: u8 = 0;
    while (n > 0) : (n = @divTrunc(n, 10)) {
        len += 1;
    }
    return len;
}

fn splitNumber(num: i64, len: u8) struct { i64, i64 } {
    var pow: i64 = 1;
    var l = len / 2;
    while (l > 0) : (l -= 1) {
        pow *= 10;
    }
    return .{ @divTrunc(num, pow), @mod(num, pow) };
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var stones = std.AutoHashMap(i64, i64).init(allocator);
    defer stones.deinit();

    const file = try std.fs.cwd().openFile("test_input.txt", .{});
    defer file.close();

    var buf: [64 * 1024]u8 = undefined;
    const bytes_read = try file.readAll(&buf);

    var it = std.mem.tokenizeScalar(u8, buf[0..bytes_read], ' ');
    while (it.next()) |val| {
        const num = try std.fmt.parseInt(i64, std.mem.trim(u8, val, "\n"), 10);
        const count = stones.get(num) orelse 0;
        try stones.put(num, count + 1);
    }

    for (0..25) |_| {
        var new_stones = std.AutoHashMap(i64, i64).init(allocator);

        var iterator = stones.iterator();
        while (iterator.next()) |entry| {
            const stone = entry.key_ptr.*;
            const count = entry.value_ptr.*;

            if (stone == 0) {
                const existing = new_stones.get(1) orelse 0;
                try new_stones.put(1, existing + count);
                continue;
            }

            const len = getDigitLength(stone);
            if (len % 2 == 0) {
                const nums = splitNumber(if (stone < 0) -stone else stone, len);
                const sign: i64 = if (stone < 0) -1 else 1;

                const n1 = nums[0] * sign;
                const n2 = nums[1] * sign;

                const count1 = new_stones.get(n1) orelse 0;
                const count2 = new_stones.get(n2) orelse 0;

                try new_stones.put(n1, count1 + count);
                try new_stones.put(n2, count2 + count);
            } else {
                const new_stone = stone * 2024;
                const existing = new_stones.get(new_stone) orelse 0;
                try new_stones.put(new_stone, existing + count);
            }
        }

        stones.deinit();
        stones = new_stones;
    }

    var total: i64 = 0;
    var iterator = stones.valueIterator();
    while (iterator.next()) |count| {
        total += count.*;
    }

    try std.io.getStdOut().writer().print("{d}\n", .{total});
}
