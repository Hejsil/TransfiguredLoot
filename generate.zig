pub fn main() !void {
    mod.start(6);
    defer mod.end();

    item(.{
        .id = "it_steel_rabbit",
        .name = .{ .english = "Steel Rabbit" },
        .description = .{ .english = "Raises all damage by [VAR0_PERCENT]." },

        .type = .loot,
        .treasureType = .all,
        .weaponType = .loot,

        .hbVar0 = 0.1,
        .allMult = 0.1,
    });

    item(.{
        .id = "it_opal_rabbit",
        .name = .{ .english = "Opal Rabbit" },
        .description = .{ .english = "Raises Special damage by [VAR0_PERCENT]." },

        .type = .loot,
        .treasureType = .purple,
        .weaponType = .loot,

        .hbVar0 = 0.2,
        .specialMult = 0.2,
    });

    item(.{
        .id = "it_sapphire_rabbit",
        .name = .{ .english = "Sapphire Rabbit" },
        .description = .{ .english = "Raises Secondary damage by [VAR0_PERCENT]." },

        .type = .loot,
        .treasureType = .blue,
        .weaponType = .loot,

        .hbVar0 = 0.2,
        .secondaryMult = 0.2,
    });

    item(.{
        .id = "it_ruby_rabbit",
        .name = .{ .english = "Ruby Rabbit" },
        .description = .{ .english = "Raises Primary damage by [VAR0_PERCENT]." },

        .type = .loot,
        .treasureType = .red,
        .weaponType = .loot,

        .hbVar0 = 0.2,
        .primaryMult = 0.2,
    });

    item(.{
        .id = "it_garnet_rabbit",
        .name = .{ .english = "Garnet Rabbit" },
        .description = .{ .english = "Every [CD], become invulnerable for [VAR0_SECONDS]." },

        .type = .loot,
        .treasureType = .yellow,
        .weaponType = .loot,
        .lootHbDispType = .cooldown,
        .hbInput = .auto,

        .showSqVar = true,
        .greySqVar0 = true,

        .cooldownType = .time,
        .cooldown = 12 * std.time.ms_per_s,

        .hbVar0 = 2000,
    });

    trigger(.hotbarUsed, .{.tcond_hb_self});
    quickPattern(.tpat_hb_run_cooldown, .{});
    addPattern(.ipat_apply_invuln, .{ "duration", 2 * std.time.ms_per_s });
    quickPattern(.tpat_hb_flash_item, .{});

    trigger(.autoStart, .{.tcond_hb_auto_pl});
    quickPattern(.tpat_hb_run_cooldown, .{});

    item(.{
        .id = "it_emerald_rabbit",
        .name = .{ .english = "Emerald Rabbit" },
        .description = .{ .english = "Heals [VAR0] HP after each fight, up to [VAR1] times." },

        .type = .loot,
        .treasureType = .green,
        .weaponType = .loot,

        .hbVar0 = 1,
        .hbVar1 = 5,
    });

    trigger(.onSquarePickup, .{.tcond_square_self});
    quickPattern(.tpat_hb_square_set_var, .{ "varIndex", 0, "amount", 5 });

    trigger(.battleEnd2, .{});
    condition(.tcond_hb_check_square_var_gte, .{ 0, 1 });
    condition(.tcond_missing_health, .{1});
    addPattern(.ipat_heal_light, .{ "amount", 1 });
    quickPattern(.tpat_hb_square_add_var, .{ "varIndex", 0, "amount", -1 });
    quickPattern(.tpat_hb_flash_item, .{});
}

const addPattern = mod.addPattern;
const condition = mod.condition;
const item = mod.item;
const quickPattern = mod.quickPattern;
const trigger = mod.trigger;

const mod = @import("mod.zig");
const std = @import("std");
