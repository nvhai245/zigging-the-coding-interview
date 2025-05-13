const std = @import("std");

// This is a simple example of a function that takes a list of items and returns
// true if all items in the list are unique. Since the string is Unicode, we
// need to use Utf8View to iterate over the string and check each codepoint.
// This function uses a hash map to keep track of which items have been seen, therefore
// requires a custom allocator.
pub fn isUniqueUnicode(list: []const u8, allocator: std.mem.Allocator) !bool {
    var utf8 = try std.unicode.Utf8View.init(list);
    var iterator = utf8.iterator();
    var seen = std.AutoHashMap(u21, void).init(allocator);
    defer seen.deinit();
    while (iterator.nextCodepoint()) |codepoint| {
        if (seen.contains(codepoint)) {
            return false;
        }
        seen.put(codepoint, void{}) catch unreachable;
    }
    return true;
}

// This is a simple example of a function that takes a list of items and returns
// true if all items in the list are unique. Instead of using a hash map, we
// use a fixed size array to keep track of which items have been seen. Since the string
// is ASCII, we can use a smaller size array.
pub fn isUniqueASCII(list: []const u8) bool {
    var seen: [128]bool = [_]bool{false} ** 128;
    for (list) |item| {
        if (seen[item]) {
            return false;
        }
        seen[item] = true;
    }
    return true;
}

test "ASCII" {
    try std.testing.expect(isUniqueASCII("numbers"));
    try std.testing.expect(!isUniqueASCII("hello world"));
}

test "Chinese" {
    try std.testing.expect(try isUniqueUnicode("你好，世界！", std.testing.allocator));
    try std.testing.expect(!try isUniqueUnicode("你好，世界！你好，世界！", std.testing.allocator));
}

test "Japanese" {
    try std.testing.expect(try isUniqueUnicode("こんにちは", std.testing.allocator));
    try std.testing.expect(!try isUniqueUnicode("こんにちはこんにちは", std.testing.allocator));
}

test "Invalid UTF-8" {
    try std.testing.expectError(error.InvalidUtf8, isUniqueUnicode("\xed\xa0\x80", std.testing.allocator));
}
