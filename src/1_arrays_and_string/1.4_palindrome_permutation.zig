const std = @import("std");

/// This function receives an input string and checks whether it is a
/// permutation of a palindrome. For better iteration performace, we use
/// an array hash map to store the number of occurences of each character,
/// then check if there are any odd occurence larger than 1.
/// Overall time complexity is O(n).
/// Overall space complexity is O(n).
pub fn palindromePermutation(str: []const u8, allocator: std.mem.Allocator) !bool {
    var occur = std.AutoArrayHashMap(u8, usize).init(allocator);
    defer occur.deinit();
    for (str) |char| {
        if (!std.ascii.isAlphabetic(char)) {
            continue;
        }
        const lower_char = std.ascii.toLower(char);
        if (occur.contains(lower_char)) {
            try occur.put(lower_char, occur.get(lower_char).? + 1);
        } else {
            try occur.put(lower_char, 1);
        }
    }

    var iterator = occur.iterator();
    var odd_occurence_count: usize = 0;
    while (iterator.next()) |v| {
        if (v.value_ptr.* % 2 != 0) {
            if (odd_occurence_count >= 1) {
                return false;
            }
            odd_occurence_count += 1;
        }
    }
    return true;
}

test "is palindrome permutation" {
    try std.testing.expect(try palindromePermutation("Tact Coa", std.testing.allocator));
}
