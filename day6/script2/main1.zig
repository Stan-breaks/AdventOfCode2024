const std = @import("std");

const Index = struct {
    i: usize,
    j: usize,
};

const State = struct {
    i: usize,
    j: usize,
    direction: []u8,
};

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

    var pointerIndex: Index = undefined;

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

    var previousStates = std.ArrayList(State).init(allocator);
    defer previousStates.deinit();

    var path = std.ArrayList(Index).init(allocator);
    defer path.deinit();

    // Collect the guard's path until it starts repeating
    while (pointerIndex.i > 0 and pointerIndex.i < map.items.len - 1 and
        pointerIndex.j > 0 and pointerIndex.j < map.items[0].len - 1)
    {
        const currentState = State{
            .i = pointerIndex.i,
            .j = pointerIndex.j,
            .direction = pointerState.items,
        };

        // Check if we've seen this state before
        var foundRepeat = false;
        for (previousStates.items) |prev| {
            if (prev.i == currentState.i and
                prev.j == currentState.j and
                std.mem.eql(u8, prev.direction, currentState.direction))
            {
                foundRepeat = true;
                break;
            }
        }
        if (foundRepeat) break;

        try previousStates.append(currentState);
        try path.append(Index{ .i = pointerIndex.i, .j = pointerIndex.j });

        if (std.mem.eql(u8, pointerState.items, "up")) {
            if (map.items[pointerIndex.i - 1][pointerIndex.j] == '#') {
                pointerState.clearRetainingCapacity();
                try pointerState.appendSlice("right");
                pointerIndex.j += 1;
            } else {
                pointerIndex.i -= 1;
            }
        } else if (std.mem.eql(u8, pointerState.items, "right")) {
            if (map.items[pointerIndex.i][pointerIndex.j + 1] == '#') {
                pointerState.clearRetainingCapacity();
                try pointerState.appendSlice("down");
                pointerIndex.i += 1;
            } else {
                pointerIndex.j += 1;
            }
        } else if (std.mem.eql(u8, pointerState.items, "down")) {
            if (map.items[pointerIndex.i + 1][pointerIndex.j] == '#') {
                pointerState.clearRetainingCapacity();
                try pointerState.appendSlice("left");
                pointerIndex.j -= 1;
            } else {
                pointerIndex.i += 1;
            }
        } else if (std.mem.eql(u8, pointerState.items, "left")) {
            if (map.items[pointerIndex.i][pointerIndex.j - 1] == '#') {
                pointerState.clearRetainingCapacity();
                try pointerState.appendSlice("up");
                pointerIndex.i -= 1;
            } else {
                pointerIndex.j -= 1;
            }
        }
    }

    var loopPositions = std.AutoHashMap(Index, void).init(allocator);
    defer loopPositions.deinit();

    // Find positions that would create loops
    for (path.items) |pos| {
        const adjacents = [_]Index{
            Index{ .i = pos.i - 1, .j = pos.j }, // up
            Index{ .i = pos.i + 1, .j = pos.j }, // down
            Index{ .i = pos.i, .j = pos.j - 1 }, // left
            Index{ .i = pos.i, .j = pos.j + 1 }, // right
        };

        for (adjacents) |adj| {
            // Skip if out of bounds or already a wall
            if (adj.i == 0 or adj.i >= map.items.len - 1 or
                adj.j == 0 or adj.j >= map.items[0].len - 1 or
                map.items[adj.i][adj.j] == '#')
            {
                continue;
            }

            // Skip the guard's starting position
            if (map.items[adj.i][adj.j] == '^') {
                continue;
            }

            // Count adjacent path positions
            var adjacentPathCount: u32 = 0;
            for (path.items) |pathPos| {
                if (isAdjacent(adj, pathPos)) {
                    adjacentPathCount += 1;
                }
            }

            if (adjacentPathCount >= 2) {
                try loopPositions.put(adj, {});
            }
        }
    }

    try stdout.print("Number of possible positions for obstruction: {d}\n", .{loopPositions.count()});
}

fn isAdjacent(a: Index, b: Index) bool {
    const di = if (a.i > b.i) a.i - b.i else b.i - a.i;
    const dj = if (a.j > b.j) a.j - b.j else b.j - a.j;
    return (di == 1 and dj == 0) or (di == 0 and dj == 1);
}
