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

fn getPreviousMove(currentState: State) State {
    return switch (currentState.direction) {
        .up => State{ .i = currentState.i + 1, .j = currentState.j, .direction = currentState.direction },
        .right => State{ .i = currentState.i, .j = currentState.j - 1, .direction = currentState.direction },
        .down => State{ .i = currentState.i - 1, .j = currentState.j, .direction = currentState.direction },
        .left => State{ .i = currentState.i, .j = currentState.j + 1, .direction = currentState.direction },
    };
}
fn moveGuard(currentState: *State, map: [][]u8) void {
    const nextPos = switch (currentState.direction) {
        .up => Index{ .i = currentState.i - 1, .j = currentState.j },
        .right => Index{ .i = currentState.i, .j = currentState.j + 1 },
        .down => Index{ .i = currentState.i + 1, .j = currentState.j },
        .left => Index{ .i = currentState.i, .j = currentState.j - 1 },
    };
    if (map[nextPos.i][nextPos.j] == '#') {
        currentState.direction = getNextDirection(currentState.direction);
        switch (currentState.direction) {
            .up => currentState.i -= 1,
            .right => currentState.j += 1,
            .down => currentState.i += 1,
            .left => currentState.j -= 1,
        }
    } else {
        currentState.i = nextPos.i;
        currentState.j = nextPos.j;
    }
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
    var startState = getPreviousMove(currentState);
    var previousStates = std.ArrayList(State).init(allocator);
    defer previousStates.deinit();

    while (startState.i > 0 and startState.i < map.len - 1 and
        startState.j > 0 and startState.j < map[0].len - 1)
    {
        for (previousStates.items) |previousState| {
            if (previousState.i == startState.i and
                previousState.j == startState.j and
                previousState.direction == startState.direction)
            {
                return true;
            }
        }
        previousStates.append(startState) catch {
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

    var loops: i32 = 0;
    var possibleObstacles = std.ArrayList(Index).init(allocator);
    defer possibleObstacles.deinit();

    while (currentState.i > 0 and currentState.i < map.items.len - 1 and
        currentState.j > 0 and currentState.j < map.items[0].len - 1)
    {
        if (map.items[currentState.i][currentState.j] != '^') {
            map.items[currentState.i][currentState.j] = '#';
            if (isGuardStuck(currentState, map.items, allocator)) {
                loops += 1;
            }
            map.items[currentState.i][currentState.j] = '.';
        } else {
            map.items[currentState.i][currentState.j] = '.';
            currentState.i -= 1;
        }
        moveGuard(&currentState, map.items);
    }
    try stdout.print("{d}\n", .{loops});
}
