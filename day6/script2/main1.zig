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

fn isGuardStuck(pointerState: []u8, pointerIndex: Index, map: [][]u8, allocator: std.mem.Allocator) bool {
    var pointerStateCopy = std.ArrayList(u8).init(allocator);
    defer pointerStateCopy.deinit();
    pointerStateCopy.appendSlice(pointerState) catch {
        return false;
    };
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
    var pointerIndexCopy: Index = undefined;
    pointerIndexCopy.i = pointerIndex.i;
    pointerIndexCopy.j = pointerIndex.j;

    mapCopy.items[pointerIndexCopy.i][pointerIndexCopy.j] = '#';

    var previousMoves = std.ArrayList(State).init(allocator);
    defer previousMoves.deinit();

    while (pointerIndexCopy.i > 0 and pointerIndexCopy.i < mapCopy.items.len - 1 and pointerIndexCopy.j > 0 and pointerIndexCopy.j < mapCopy.items[0].len - 1) {
        const move: State = State{
            .i = pointerIndexCopy.i,
            .j = pointerIndexCopy.j,
            .direction = pointerStateCopy.items,
        };
        for (previousMoves.items) |previousMove| {
            if (previousMove.i == move.i and previousMove.j == move.j and std.mem.eql(u8, previousMove.direction, move.direction)) {
                return true;
            }
        }
        previousMoves.append(move) catch {
            return false;
        };
        if (std.mem.eql(u8, pointerStateCopy.items, "up")) {
            if (mapCopy.items[pointerIndexCopy.i - 1][pointerIndexCopy.j] == '#') {
                pointerStateCopy.clearRetainingCapacity();
                pointerStateCopy.appendSlice("right") catch {
                    return false;
                };
                pointerIndexCopy.j += 1;
            } else {
                pointerIndexCopy.i -= 1;
            }
        } else if (std.mem.eql(u8, pointerStateCopy.items, "right")) {
            if (mapCopy.items[pointerIndexCopy.i][pointerIndexCopy.j + 1] == '#') {
                pointerStateCopy.clearRetainingCapacity();
                pointerStateCopy.appendSlice("down") catch {
                    return false;
                };
                pointerIndexCopy.i += 1;
            } else {
                pointerIndexCopy.j += 1;
            }
        } else if (std.mem.eql(u8, pointerStateCopy.items, "down")) {
            if (mapCopy.items[pointerIndexCopy.i + 1][pointerIndexCopy.j] == '#') {
                pointerStateCopy.clearRetainingCapacity();
                pointerStateCopy.appendSlice("left") catch {
                    return false;
                };
                pointerIndexCopy.j -= 1;
            } else {
                pointerIndexCopy.i += 1;
            }
        } else if (std.mem.eql(u8, pointerStateCopy.items, "left")) {
            if (mapCopy.items[pointerIndexCopy.i][pointerIndexCopy.j - 1] == '#') {
                pointerStateCopy.clearRetainingCapacity();
                pointerStateCopy.appendSlice("up") catch {
                    return false;
                };
                pointerIndexCopy.i -= 1;
            } else {
                pointerIndexCopy.j -= 1;
            }
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
    var possibleObstacles = std.ArrayList(Index).init(allocator);
    defer possibleObstacles.deinit();

    while (pointerIndex.i > 0 and pointerIndex.i < map.items.len - 1 and pointerIndex.j > 0 and pointerIndex.j < map.items[0].len - 1) {
        map.items[pointerIndex.i][pointerIndex.j] = '.';
        if (map.items[pointerIndex.i][pointerIndex.j] != '^') {
            const indexI = pointerIndex.i;
            const indexJ = pointerIndex.j;
            if (isGuardStuck(pointerState.items, Index{ .i = indexI, .j = indexJ }, map.items, allocator)) {
                try possibleObstacles.append(Index{ .i = indexI, .j = indexJ });
            }
        }
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
        map.items[pointerIndex.i][pointerIndex.j] = '^';
    }
    try stdout.print("{d}\n", .{possibleObstacles.items.len});
}
