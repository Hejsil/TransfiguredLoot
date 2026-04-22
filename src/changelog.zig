pub fn main(init: std.process.Init) !void {
    const arena = init.arena.allocator();
    const args = try init.minimal.args.toSlice(arena);
    return generateChangelog(init.io, arena, args[1], args[2]);
}

fn generateChangelog(
    io: std.Io,
    arena: std.mem.Allocator,
    old_path: []const u8,
    new_path: []const u8,
) !void {
    const cwd = std.Io.Dir.cwd();
    var changelog = std.Io.Writer.Allocating.init(arena);
    const old_dir = try cwd.openDir(io, old_path, .{ .iterate = true });
    const new_dir = try cwd.openDir(io, new_path, .{});

    var mod_folders = old_dir.iterate();
    while (try mod_folders.next(io)) |entry| {
        std.debug.assert(entry.kind == .directory);
        const old_mod_dir = try old_dir.openDir(io, entry.name, .{});
        const new_mod_dir = try new_dir.openDir(io, entry.name, .{});
        try generateChangelogModEntry(
            io,
            arena,
            &changelog.writer,
            entry.name,
            old_mod_dir,
            new_mod_dir,
        );
    }

    try cwd.writeFile(io, .{
        .sub_path = "zig-out/changelog.md",
        .data = changelog.written(),
    });
}

fn generateChangelogModEntry(
    io: std.Io,
    arena: std.mem.Allocator,
    writer: *std.Io.Writer,
    transfigured_mod_name: []const u8,
    old_dir: std.Io.Dir,
    new_dir: std.Io.Dir,
) !void {
    const transfigured_prefix = "Transfigured ";
    if (!std.mem.startsWith(u8, transfigured_mod_name, transfigured_prefix)) {
        std.log.warn("Skipping mod {s}", .{transfigured_mod_name});
        return;
    }

    const mod_name = transfigured_mod_name[transfigured_prefix.len..];
    const old_items_csv = try old_dir.readFileAlloc(io, "Items.csv", arena, .unlimited);
    const new_items_csv = try new_dir.readFileAlloc(io, "Items.csv", arena, .unlimited);
    const old_items_ini = try old_dir.readFileAlloc(io, "Items.ini", arena, .unlimited);
    const new_items_ini = try new_dir.readFileAlloc(io, "Items.ini", arena, .unlimited);

    const old_items_str = try old_dir.readFileAlloc(io, "Items_Full.json", arena, .unlimited);
    const new_items_str = try new_dir.readFileAlloc(io, "Items_Full.json", arena, .unlimited);

    var old_items_json = try std.json.parseFromSliceLeaky(std.json.Value, arena, old_items_str, .{});
    var new_items_json = try std.json.parseFromSliceLeaky(std.json.Value, arena, new_items_str, .{});

    const old_item_values = old_items_json.object.values();
    const new_item_values = new_items_json.object.values();

    var print_mod_name: bool = true;
    for (old_item_values, new_item_values) |old_item_json, new_item_json| {
        const old_item = try std.json.parseFromValueLeaky(rns.Item, arena, old_item_json, .{});
        const new_item = try std.json.parseFromValueLeaky(rns.Item, arena, new_item_json, .{});

        const transfigured_item_name = old_item.name.english;
        const item_name = transfigured_item_name[transfigured_prefix.len..];

        std.debug.assert(std.mem.eql(u8, old_item.id, new_item.id));
        std.debug.assert(std.mem.startsWith(u8, transfigured_item_name, transfigured_prefix));

        const old_desc = old_item.description.english_expanded.?;
        const new_desc = new_item.description.english_expanded.?;

        if (!std.mem.eql(u8, old_desc, new_desc)) {
            if (print_mod_name) {
                try writer.print("\n# {s}\n\n", .{mod_name});
                print_mod_name = false;
            }
            try writer.print("- {s}\n", .{item_name});
            if (std.mem.startsWith(u8, new_desc, "Not Implemented")) {
                try writer.writeAll("  - Has been removed\n");
            } else {
                if (std.mem.startsWith(u8, old_desc, "Not Implemented")) {
                    try writer.writeAll("  - Has been added\n");
                } else {
                    try writer.writeAll("  - old: ");
                    try writeDescription(writer, old_desc);
                    try writer.writeAll("\n");
                }
                try writer.writeAll("  - new: ");
                try writeDescription(writer, new_desc);
                try writer.writeAll("\n");
            }
            continue;
        }

        const id_prefix = "it_";
        const item_id = blk: {
            const lower = try std.ascii.allocLowerString(arena, transfigured_item_name);
            const underscore = try std.mem.replaceOwned(u8, arena, lower, " ", "_");
            const no_tick = try std.mem.replaceOwned(u8, arena, underscore, "'", "");
            break :blk try std.fmt.allocPrint(arena, "{s}{s}", .{ id_prefix, no_tick });
        };

        const old_item_csv_start = std.mem.indexOf(u8, old_items_csv, item_id).? + item_id.len;
        const new_item_csv_start = std.mem.indexOf(u8, new_items_csv, item_id).? + item_id.len;
        const old_item_csv_end = std.mem.indexOfPos(u8, old_items_csv, old_item_csv_start, id_prefix) orelse old_items_csv.len;
        const new_item_csv_end = std.mem.indexOfPos(u8, new_items_csv, new_item_csv_start, id_prefix) orelse new_items_csv.len;

        const old_item_csv = old_items_csv[old_item_csv_start..old_item_csv_end];
        const new_item_csv = new_items_csv[new_item_csv_start..new_item_csv_end];
        if (std.mem.indexOfDiff(u8, old_item_csv, new_item_csv)) |diff_idx| {
            if (print_mod_name) {
                try writer.print("\n# {s}\n\n", .{mod_name});
                print_mod_name = false;
            }
            try writer.print("- {s}\n", .{item_name});
            try writer.print("  - old: {s}\n", .{getLineContainingIndex(old_item_csv, diff_idx)});
            try writer.print("  - new: {s}\n", .{getLineContainingIndex(new_item_csv, diff_idx)});
            continue;
        }

        const old_item_ini_start = std.mem.indexOf(u8, old_items_ini, item_id).? + item_id.len;
        const new_item_ini_start = std.mem.indexOf(u8, new_items_ini, item_id).? + item_id.len;
        const old_item_ini_end = std.mem.indexOfPos(u8, old_items_ini, old_item_ini_start, id_prefix) orelse old_items_ini.len;
        const new_item_ini_end = std.mem.indexOfPos(u8, new_items_ini, new_item_ini_start, id_prefix) orelse new_items_ini.len;

        const old_item_ini = old_items_ini[old_item_ini_start..old_item_ini_end];
        const new_item_ini = new_items_ini[new_item_ini_start..new_item_ini_end];
        if (std.mem.indexOfDiff(u8, old_item_ini, new_item_ini)) |diff_idx| {
            if (print_mod_name) {
                try writer.print("\n# {s}\n\n", .{mod_name});
                print_mod_name = false;
            }
            try writer.print("- {s}\n", .{item_name});
            try writer.print("  - old: {s}\n", .{getLineContainingIndex(old_item_ini, diff_idx)});
            try writer.print("  - new: {s}\n", .{getLineContainingIndex(new_item_ini, diff_idx)});
            continue;
        }
    }
}

fn getLineContainingIndex(str: []const u8, idx: usize) []const u8 {
    var start: usize = 0;
    for (str[0..idx], 0..) |c, i| {
        if (c == '\n') start = i + 1;
    }

    const end = std.mem.indexOfScalarPos(u8, str, idx, '\n') orelse str.len;
    return str[start..end];
}

fn writeDescription(writer: *std.Io.Writer, desc: []const u8) !void {
    var pos: usize = 0;
    while (std.mem.indexOfScalarPos(u8, desc, pos, '#')) |i| {
        try writer.writeAll(desc[pos..i]);
        try writer.writeAll(" ");
        pos = i + 1;
    }
    try writer.writeAll(desc[pos..]);
}

const rns = @import("rns.zig");
const std = @import("std");
