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

    var arr = std.ArrayList([]u8).init(allocator);
    defer {
        for (arr.items) |item| {
            allocator.free(item);
        }
        arr.deinit();
    }

    var id: i32 = 0;
    var maxId: i32 = 0;
    for (0..content.len - 1) |i| {
        if (i % 2 == 0) {
            const size: usize = @intCast(content[i] - '0');
            if (size > 0) {
                for (size) |_| {
                    const str = try std.fmt.allocPrint(allocator, "{}", .{id});
                    try arr.append(str);
                }
                maxId = id;
                id += 1;
            }
        } else {
            const space: usize = @intCast(content[i] - '0');
            if (space > 0) {
                for (space) |_| {
                    const dot = try std.fmt.allocPrint(allocator, ".", .{});
                    try arr.append(dot);
                }
            }
        }
    }

    var currentId = maxId;
    while (currentId >= 0) : (currentId -= 1) {
        const idStr = try std.fmt.allocPrint(allocator, "{}", .{currentId});
        defer allocator.free(idStr);
        var fileStart: ?usize = null;
        var fileLenght: usize = 0;
        var i: usize = 0;
        while (i < arr.items.len) : (i += 1) {
            if (std.mem.eql(u8, arr.items[i], idStr)) {
                if (fileStart == null) fileStart = i;
                fileLenght += 1;
            }
        }

        if (fileStart) |start| {
            var bestGapStart: ?usize = null;
            var currentGapStart: ?usize = null;
            var currentGapLenght: usize = 0;
            i = 0;
            while (i < arr.items.len) : (i += 1) {
                if (std.mem.eql(u8, arr.items[i], ".")) {
                    if (currentGapStart == null) currentGapStart = i;
                    if (currentGapLenght >= fileLenght) {
                        bestGapStart = currentGapStart;
                        break;
                    }
                    currentGapLenght += 1;
                } else {
                    currentGapStart = null;
                    currentGapLenght = 0;
                }
            }

            if (bestGapStart) |gapStart| {
                var j: usize = 0;
                while (j < fileLenght) : (j += 1) {
                    const temp = arr.items[start + j];
                    arr.items[start + j] = arr.items[gapStart + j];
                    arr.items[gapStart + j] = temp;
                }
            }
        }
    }

    var sum: i64 = 0;
    for (0..arr.items.len) |i| {
        if (!std.mem.eql(u8, arr.items[i], ".")) {
            const num = try std.fmt.parseInt(i64, arr.items[i], 10);
            sum += (@as(i64, @intCast(i)) * num);
        } else {
            break;
        }
    }
    try stdout.print("{d}\n", .{sum});
}
