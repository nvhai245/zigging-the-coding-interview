const std = @import("std");

/// This function receives 2 input strings and check if the 2nd string is the result
/// of 1 operation(insert, delete, replace) a character from the 1st string. We use
/// 2 array hasp maps to store the number of occurences of each character from both strings.
/// If the occurences differ on more than 1 character, return false.
/// Overall time complexity is O(n).
/// Overall space complexity is O(n).
pub fn oneAway(str1: []const u8, str2: []const u8, allocator: std.mem.Allocator) !bool {
    var occur1 = std.AutoArrayHashMap(u8, usize).init(allocator);
    defer occur1.deinit();
    var occur2 = std.AutoArrayHashMap(u8, usize).init(allocator);
    defer occur2.deinit();
    for (str1) |char| {
        if (occur1.contains(char)) {
            try occur1.put(char, occur1.get(char).? + 1);
        } else {
            try occur1.put(char, 1);
        }
    }
    for (str2) |char| {
        if (occur2.contains(char)) {
            try occur2.put(char, occur2.get(char).? + 1);
        } else {
            try occur2.put(char, 1);
        }
    }

    var iterator = occur1.iterator();
    var diff: usize = 0;
    while (iterator.next()) |v| {
        if (occur2.contains(v.key_ptr.*)) {
            if (v.value_ptr.* != occur2.get(v.key_ptr.*).?) {
                if (diff >= 1) {
                    return false;
                }
            }
        } else {
            diff += 1;
        }
    }

    if (diff == 1) {
        if (occur2.count() > occur1.count()) {
            return false;
        }
    }

    return 0 < diff and diff <= 1;
}

test "true" {
    try std.testing.expect(try oneAway("pale", "ple", std.testing.allocator));
    try std.testing.expect(try oneAway("pales", "pale", std.testing.allocator));
    try std.testing.expect(try oneAway("pale", "bale", std.testing.allocator));
}

test "false" {
    try std.testing.expect(!try oneAway("pale", "bake", std.testing.allocator));
}
