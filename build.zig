pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const mod_module = b.createModule(.{
        .root_source_file = b.path("src/mod.zig"),
        .target = target,
    });

    const mod_exe = b.addExecutable(.{
        .name = "generate-mod",
        .root_module = mod_module,
    });

    const run_mod_exe_step = b.addRunArtifact(mod_exe);
    run_mod_exe_step.addArgs(b.args orelse &.{});
    run_mod_exe_step.stdio = .inherit;
    b.default_step.dependOn(&run_mod_exe_step.step);

    const install_mod_exe = b.addInstallArtifact(mod_exe, .{});
    run_mod_exe_step.step.dependOn(&install_mod_exe.step);

    const mod_test = b.addTest(.{ .root_module = mod_module });
    const run_mod_test = b.addRunArtifact(mod_test);
    b.default_step.dependOn(&run_mod_test.step);

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

    const check = b.step("check", "Check if tests compile");
    check.dependOn(&changelog_exe.step);
    check.dependOn(&mod_test.step);
}

const std = @import("std");
