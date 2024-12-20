const std = @import("std");

const Direction = enum {
    up,
    right,
    down,
    left,
};

const Index = struct {
    i: usize,
    j: usize,
};

const State = struct {
    i: usize,
    j: usize,
    direction: Direction,
};

fn moveGuard(currentState: *State, map: [][]u8) void {
    var nextPos = getNextPosition(currentState.*);
    if (map[nextPos.i][nextPos.j] == '#') {
        var turnCount: u8 = 0;
        while (map[nextPos.i][nextPos.j] == '#' and turnCount < 4) : (turnCount += 1) {
            currentState.direction = getNextDirection(currentState.direction);
            nextPos = getNextPosition(currentState.*);
        }
        if (turnCount < 4) {
            currentState.i = nextPos.i;
            currentState.j = nextPos.j;
        }
    } else {
        currentState.i = nextPos.i;
        currentState.j = nextPos.j;
    }
}

fn getNextPosition(currentState: State) Index {
    return switch (currentState.direction) {
        .up => Index{ .i = currentState.i - 1, .j = currentState.j },
        .right => Index{ .i = currentState.i, .j = currentState.j + 1 },
        .down => Index{ .i = currentState.i + 1, .j = currentState.j },
        .left => Index{ .i = currentState.i, .j = currentState.j - 1 },
    };
}

fn getNextDirection(current: Direction) Direction {
    return switch (current) {
        .up => .right,
        .right => .down,
        .down => .left,
        .left => .up,
    };
}

fn isGuardStuck(currentState: State, map: [][]u8, allocator: std.mem.Allocator) bool {
    var startState: State = State{
        .i = currentState.i,
        .j = currentState.j,
        .direction = currentState.direction,
    };
    var visited = std.AutoHashMap(State, void).init(allocator);
    defer visited.deinit();

    while (startState.i > 0 and startState.i < map.len - 1 and
        startState.j > 0 and startState.j < map[0].len - 1)
    {
        if (visited.contains(startState)) {
            return true;
        }
        visited.put(startState, {}) catch {
            return false;
        };
        moveGuard(&startState, map);
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

    var map = std.ArrayList([]u8).init(allocator);
    defer {
        for (map.items) |line| {
            allocator.free(line);
        }
        map.deinit();
    }

    var lineTokenizer = std.mem.tokenize(u8, content, "\n");
    var currentState: State = State{ .i = undefined, .j = undefined, .direction = .up };
    var lineIndex: usize = 0;

    while (lineTokenizer.next()) |line| {
        const mutableLine = try allocator.alloc(u8, line.len);
        @memcpy(mutableLine, line);
        try map.append(mutableLine);
        if (std.mem.indexOf(u8, line, "^")) |j| {
            currentState.i = lineIndex;
            currentState.j = j;
        }
        lineIndex += 1;
    }

    var previousStates = std.ArrayList(State).init(allocator);
    defer previousStates.deinit();

    var seenPositions = std.AutoHashMap(Index, void).init(allocator);
    defer seenPositions.deinit();

    var possibleObstacles = std.AutoHashMap(Index, void).init(allocator);
    defer possibleObstacles.deinit();

    while (currentState.i > 0 and currentState.i < map.items.len - 1 and
        currentState.j > 0 and currentState.j < map.items[0].len - 1)
    {
        try previousStates.append(currentState);
        moveGuard(&currentState, map.items);
    }
    try previousStates.append(currentState);

    for (1..previousStates.items.len) |i| {
        const position = Index{
            .i = previousStates.items[i].i,
            .j = previousStates.items[i].j,
        };
        if (!seenPositions.contains(position)) {
            const testState = previousStates.items[i - 1];
            map.items[position.i][position.j] = '#';
            if (isGuardStuck(testState, map.items, allocator)) {
                if (!possibleObstacles.contains(position)) {
                    try possibleObstacles.put(position, {});
                }
            }
            map.items[position.i][position.j] = '.';
        }
        try seenPositions.put(position, {});
    }
    try stdout.print("{any}\n", .{possibleObstacles.count()});
}
