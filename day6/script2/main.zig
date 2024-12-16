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

    var map = std.ArrayList([]u8).init(allocator);
    defer {
        for (map.items) |line| {
            allocator.free(line);
        }
        map.deinit();
    }

    var lineTokenizer = std.mem.tokenize(u8, content, "\n");

    var pointerIndex: struct { i: usize, j: usize } = undefined;

    var pointerState = std.ArrayList(u8).init(allocator);
    defer pointerState.deinit();
    try pointerState.append('u');
    try pointerState.append('p');

    var lineIndex: usize = 0;
    while (lineTokenizer.next()) |line| {
        const mutableLine = try allocator.alloc(u8, line.len);
        @memcpy(mutableLine, line);
        try map.append(mutableLine);
        if (std.mem.indexOf(u8, line, "^")) |j| {
            pointerIndex.i = lineIndex;
            pointerIndex.j = j;
        }
        lineIndex += 1;
    }
    var count: i32 = 0;
    while (pointerIndex.i > 0 and pointerIndex.i < map.items.len - 1 and pointerIndex.j > 0 and pointerIndex.j < map.items[0].len - 1) {
        if (std.mem.eql(u8, pointerState.items, "up")) {
            if (map.items[pointerIndex.i - 1][pointerIndex.j] == '#') {
                pointerState.clearRetainingCapacity();
                try pointerState.append('r');
                try pointerState.append('i');
                try pointerState.append('g');
                try pointerState.append('h');
                try pointerState.append('t');
                pointerIndex.j += 1;
            } else {
                pointerIndex.i -= 1;
                var row = std.ArrayList(u8).init(allocator);
                defer row.deinit();
                for (pointerIndex.j..map.items[pointerIndex.i].len) |j| {
                    try row.append(map.items[pointerIndex.i][j]);
                }
                var topRight: struct { i: usize, j: usize } = undefined;
                if (std.mem.indexOf(u8, row, "#")) |obIndex| {
                    topRight.i = pointerIndex.i;
                    topRight.j = obIndex;
                }
                var col = std.ArrayList(u8).init(allocator);
                defer col.deinit();
                for (pointerIndex.i..map.items.len) |i| {
                    try col.append(map.items[i][pointerIndex.j]);
                }
                var bottomLeft: struct { i: usize, j: usize } = undefined;
                if (std.mem.indexOf(u8, col, "#")) |obIndex| {
                    bottomLeft.i = obIndex;
                    bottomLeft.j = pointerIndex.j;
                }
                if (topRight == undefined or bottomLeft == undefined) {
                    continue;
                }
                if (map.items[bottomLeft.i][topRight.j]) {
                    count += 1;
                }
            }
        } else if (std.mem.eql(u8, pointerState.items, "right")) {
            if (map.items[pointerIndex.i][pointerIndex.j + 1] == '#') {
                pointerState.clearRetainingCapacity();
                try pointerState.append('d');
                try pointerState.append('o');
                try pointerState.append('w');
                try pointerState.append('n');
                pointerIndex.i += 1;
            } else {
                pointerIndex.j += 1;
            }
        } else if (std.mem.eql(u8, pointerState.items, "down")) {
            if (map.items[pointerIndex.i + 1][pointerIndex.j] == '#') {
                pointerState.clearRetainingCapacity();
                try pointerState.append('l');
                try pointerState.append('e');
                try pointerState.append('f');
                try pointerState.append('t');
                pointerIndex.j -= 1;
            } else {
                pointerIndex.i += 1;
            }
        } else if (std.mem.eql(u8, pointerState.items, "left")) {
            if (map.items[pointerIndex.i][pointerIndex.j - 1] == '#') {
                pointerState.clearRetainingCapacity();
                try pointerState.append('u');
                try pointerState.append('p');
                pointerIndex.i -= 1;
            } else {
                pointerIndex.j -= 1;
            }
        }
    }
    try stdout.print("{d}\n", .{count + 1});
}
