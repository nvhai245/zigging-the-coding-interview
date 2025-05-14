const std = @import("std");

/// This function converts a string to a url-friendly string.
/// Since the swaps are performed in place, the original string is modified.
/// Overall complexity is O(n).
/// Overall space complexity is O(1).
pub fn urlify(str: []u8) ![]u8 {
    if (str.len == 0) {
        return str;
    }
    var i = str.len - 1;
    var j = str.len - 1;
    var t: u8 = undefined;

    while (i > 0) {
        if (str[i] == ' ') {
            i -= 1;
            continue;
        } else break;
    }

    while (i >= 0) {
        if (str[i] != ' ' and i != 0) {
            t = str[j];
            str[j] = str[i];
            str[i] = t;
            i -= 1;
            j -= 1;
            continue;
        }
        if (j == 0) {
            break;
        }
        str[j] = '0';
        str[j - 1] = '2';
        str[j - 2] = '%';
        if (i == 0) {
            break;
        }
        i -= 1;
        j -= 3;
    }

    return str;
}

test "hello world" {
    var str = "Hello World  ".*;
    try std.testing.expectEqualStrings("Hello%20World", try urlify(&str));
}

test "whitespace at the beginning" {
    var str = " Hello World    ".*;
    try std.testing.expectEqualStrings("%20Hello%20World", try urlify(&str));
}

test "no whitespace" {
    var str = "HelloWorld".*;
    try std.testing.expectEqualStrings("HelloWorld", try urlify(&str));
}
