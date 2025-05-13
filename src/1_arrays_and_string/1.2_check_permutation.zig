const std = @import("std");

pub fn checkPermutationASCII(str1: []const u8, str2: []const u8, allocator: std.mem.Allocator) !bool {
    if (str1.len != str2.len) {
        return false;
    }

    var count1 = std.AutoHashMap(u8, usize).init(allocator);
    defer count1.deinit();

    var count2 = std.AutoHashMap(u8, usize).init(allocator);
    defer count2.deinit();

    for (str1) |item| {
        if (count1.contains(item)) {
            try count1.put(item, count1.get(item).? + 1);
        } else {
            try count1.put(item, 1);
        }
    }

    for (str2) |item| {
        if (count2.contains(item)) {
            try count2.put(item, count2.get(item).? + 1);
        } else {
            try count2.put(item, 1);
        }
    }

    for (str1) |item| {
        if (!count1.contains(item) or
            !count2.contains(item) or
            count1.get(item).? != count2.get(item).?)
        {
            return false;
        }
    }

    return true;
}

test "ASCII" {
    try std.testing.expect(try checkPermutationASCII("hello", "olleh", std.testing.allocator));
    try std.testing.expect(!try checkPermutationASCII("hello", "ollea", std.testing.allocator));
    try std.testing.expect(!try checkPermutationASCII("hello", "ollehhh", std.testing.allocator));
}

test "Out of memory" {
    var buffer: [1]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    try std.testing.expectError(error.OutOfMemory, checkPermutationASCII("hello", "olleh", fba.allocator()));
}
