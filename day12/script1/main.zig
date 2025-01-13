const std = @import("std");

const Position = struct {
    i: usize,
    j: usize,
};

const direction = enum {
    up,
    right,
    down,
    left,
};

const State = struct {
    i: usize,
    j: usize,
    direction: direction,
};

fn move(currentState: State, map: [][]u8, val: u8) State {
    var nexPos = getNextPosition(currentState);
    const newDirection = getNextDirection(currentState.direction);
    if (map[nexPos.i][nexPos.j] == val) {
        return State{ .i = nexPos.i, .j = nexPos.j, .direction = currentState.direction };
    } else {
        const newState = State{ .i = currentState.i, .j = currentState.j, .direction = newDirection };
        nexPos = getNextPosition(newState);
        return State{ .i = nexPos.i, .j = nexPos.j, .direction = newState.direction };
    }
}

fn getNextDirection(currentDirection: direction) direction {
    return switch (currentDirection) {
        .up => direction.right,
        .right => direction.down,
        .down => direction.left,
        .left => direction.up,
    };
}

fn getNextPosition(currentState: State) Position {
    return switch (currentState.direction) {
        .up => Position{ .i = currentState.i - 1, .j = currentState.j },
        .right => Position{ .i = currentState.i, .j = currentState.j + 1 },
        .down => Position{ .i = currentState.i + 1, .j = currentState.j },
        .left => Position{ .i = currentState.i, .j = currentState.j - 1 },
    };
}

fn findValues(currentPosition: Position, map: [][]u8, visited: *std.AutoHashMap(Position, void)) !struct { pos: Position, end: usize } {
    const val = map[currentPosition.i][currentPosition.j];
    var newState = State{ .i = currentPosition.i, .j = currentPosition.j, .direction = direction.right };
    while (newState.i < map.len and newState.i >= 0 and newState.j < map[newState.i].len and newState.j >= 0) {
        const position = Position{ .i = newState.i, .j = newState.j };
        if (visited.contains(position)) {
            break;
        } else {
            try visited.put(position, {});
        }
        newState = move(newState, map, val);
    }
    return .{ currentPosition, 0 };
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const file = try std.fs.cwd().openFile("advent_input.txt", .{});
    defer file.close();

    const content = try file.readToEndAlloc(allocator, 1024 * 1024);
    defer allocator.free(content);

    const stdout = std.debug;

    var map = std.ArrayList([]u8).init(allocator);
    defer {
        for (map.items) |item| {
            allocator.free(item);
        }
        map.deinit();
    }

    var lineTokenizer = std.mem.tokenize(u8, content, "\n");
    while (lineTokenizer.next()) |line| {
        const mutableLine = try allocator.alloc(u8, line.len);
        @memcpy(mutableLine, line);
        try map.append(mutableLine);
    }
    var visited = std.AutoHashMap(Position, void).init(allocator);
    defer visited.deinit();

    for (0..map.items.len) |i| {
        for (0..map.items[i].len) |j| {
            const currentPosition = Position{ .i = i, .j = j };
            try visited.put(currentPosition, {});
        }
    }

    stdout.print("{d}\n", .{visited.count()});
}
