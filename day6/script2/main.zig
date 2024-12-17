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

fn getNextDirection(current: Direction) Direction {
    return switch (current) {
        .up => .right,
        .right => .down,
        .down => .left,
        .left => .up,
    };
}

fn isGuardStuck(initialDirection: Direction, pointerIndex: Index, map: [][]u8, allocator: std.mem.Allocator) bool {
    var mapCopy = std.ArrayList([]u8).init(allocator);
    defer {
        for (mapCopy.items) |item| {
            allocator.free(item);
        }
        mapCopy.deinit();
    }

    for (map) |item| {
        const mutableItem = allocator.alloc(u8, item.len) catch {
            return false;
        };
        @memcpy(mutableItem, item);
        mapCopy.append(mutableItem) catch {
            return false;
        };
    }

    var currentState = State{
        .i = pointerIndex.i,
        .j = pointerIndex.j,
        .direction = initialDirection,
    };
    mapCopy.items[currentState.i][currentState.j] = '#';

    var previousStates = std.ArrayList(State).init(allocator);
    defer previousStates.deinit();

    while (currentState.i > 0 and currentState.i < mapCopy.items.len - 1 and
        currentState.j > 0 and currentState.j < mapCopy.items[0].len - 1)
    {
        for (previousStates.items) |previousState| {
            if (previousState.i == currentState.i and
                previousState.j == currentState.j and
                previousState.direction == currentState.direction)
            {
                return true;
            }
        }
        previousStates.append(currentState) catch {
            return false;
        };
        const nextPos = switch (currentState.direction) {
            .up => Index{ .i = currentState.i - 1, .j = currentState.j },
            .right => Index{ .i = currentState.i, .j = currentState.j + 1 },
            .down => Index{ .i = currentState.i + 1, .j = currentState.j },
            .left => Index{ .i = currentState.i, .j = currentState.j - 1 },
        };
        if (mapCopy.items[nextPos.i][nextPos.j] == '#') {
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
    return false;
}

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
    var pointerDirection: Direction = .up;
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

    var possibleObstacles = std.ArrayList(Index).init(allocator);
    defer possibleObstacles.deinit();

    var count: i32 = 0;
    while (pointerIndex.i > 0 and pointerIndex.i < map.items.len - 1 and
        pointerIndex.j > 0 and pointerIndex.j < map.items[0].len - 1)
    {
        if (isGuardStuck(pointerDirection, pointerIndex, map.items, allocator)) {
            count += 1;
        }
        const nextPos = switch (pointerDirection) {
            .up => Index{ .i = pointerIndex.i - 1, .j = pointerIndex.j },
            .right => Index{ .i = pointerIndex.i, .j = pointerIndex.j + 1 },
            .down => Index{ .i = pointerIndex.i + 1, .j = pointerIndex.j },
            .left => Index{ .i = pointerIndex.i, .j = pointerIndex.j - 1 },
        };
        if (map.items[nextPos.i][nextPos.j] == '#') {
            pointerDirection = getNextDirection(pointerDirection);
            switch (pointerDirection) {
                .up => pointerIndex.i -= 1,
                .right => pointerIndex.j += 1,
                .down => pointerIndex.i += 1,
                .left => pointerIndex.j -= 1,
            }
        } else {
            pointerIndex.i = nextPos.i;
            pointerIndex.j = nextPos.j;
        }
        count += 1;
    }

    if (possibleObstacles.items) |item| {
        map.items[item[0].i][item[0].j] = 'O';
    }

    for (map.items) |item| {
        try stdout.print("{s}\n", .{item});
    }

    try stdout.print("{d}\n", .{count});
}
