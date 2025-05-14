const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) !void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    // // This creates a "module", which represents a collection of source files alongside
    // // some compilation options, such as optimization mode and linked system libraries.
    // // Every executable or library we compile will be based on one or more modules.
    // const lib_mod = b.createModule(.{
    //     // `root_source_file` is the Zig "entry point" of the module. If a module
    //     // only contains e.g. external object files, you can make this `null`.
    //     // In this case the main source file is merely a path, however, in more
    //     // complicated build scripts, this could be a generated file.
    //     .root_source_file = b.path("src/root.zig"),
    //     .target = target,
    //     .optimize = optimize,
    // });
    const test_step = b.step("test", "run unit tests");

    // iterate over the source files in the directory

    const cwd = std.fs.cwd();
    const dir = try cwd.openDir("src/", .{ .iterate = true });
    var it = dir.iterate();
    while (try it.next()) |entry| {
        if (entry.kind == .directory) {
            const sub_dir = try cwd.openDir(std.mem.concat(b.allocator, u8, &.{ "src/", entry.name }) catch unreachable, .{ .iterate = true });
            var sub_it = sub_dir.iterate();
            while (try sub_it.next()) |sub_entry| {
                if (sub_entry.kind == .file and std.mem.endsWith(u8, sub_entry.name, ".zig")) {
                    const moduleName = std.mem.trimRight(u8, sub_entry.name, ".zig");
                    const module = b.createModule(.{
                        .root_source_file = b.path(std.mem.concat(b.allocator, u8, &.{ "src/", entry.name, "/", sub_entry.name }) catch unreachable),
                        .target = target,
                        .optimize = optimize,
                    });

                    const file_unit_tests = b.addTest(.{
                        .name = std.mem.concat(b.allocator, u8, &.{ moduleName, "_unit_tests" }) catch unreachable,
                        .root_module = module,
                    });

                    b.installArtifact(file_unit_tests);

                    const run_file_unit_tests = b.addRunArtifact(file_unit_tests);

                    var splitIterator = std.mem.splitScalar(u8, sub_entry.name, '_');
                    const questionNum = splitIterator.first();
                    const lib_test_step = b.step(std.mem.concat(b.allocator, u8, &.{ "test_", questionNum }) catch unreachable, std.mem.concat(b.allocator, u8, &.{ "Run unit tests for ", questionNum }) catch unreachable);
                    lib_test_step.dependOn(&run_file_unit_tests.step);
                    test_step.dependOn(&run_file_unit_tests.step);
                }
            }
        }
    }
}
