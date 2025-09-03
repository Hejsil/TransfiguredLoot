pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const mod_exe = b.addExecutable(.{
        .name = "generate-mod",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/mod.zig"),
            .target = target,
        }),
    });
    b.installArtifact(mod_exe);

    const run_mod_exe_step = b.addRunArtifact(mod_exe);
    run_mod_exe_step.addArgs(b.args orelse &.{});
    run_mod_exe_step.stdio = .inherit;

    b.default_step.dependOn(&run_mod_exe_step.step);

    const changelog_exe = b.addExecutable(.{
        .name = "changelog",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/changelog.zig"),
            .target = target,
        }),
    });
    b.installArtifact(changelog_exe);

    const run_changelog_exe_step = b.addRunArtifact(changelog_exe);
    run_changelog_exe_step.addArgs(b.args orelse &.{});
    run_changelog_exe_step.stdio = .inherit;

    const run_changelog_step = b.step("changelog", "Generate changelog");
    run_changelog_step.dependOn(&run_changelog_exe_step.step);
}

const std = @import("std");
