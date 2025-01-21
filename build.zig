pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "TransfiguredLoot",
        .root_source_file = b.path("src/mod.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(exe);

    const run_exe_step = b.addRunArtifact(exe);
    run_exe_step.addArgs(b.args orelse &.{});
    b.default_step.dependOn(&run_exe_step.step);
}

const std = @import("std");
