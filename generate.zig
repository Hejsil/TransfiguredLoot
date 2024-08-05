pub fn main() !void {
    mod.start();
    defer mod.end();

    item(.{
        .id = "it_transfigured_raven_grimoire",
        .name = .{
            .english = "Transfigured Raven Grimoire",
        },
        .description = .{
            .english = "Your Special applies all curses but deals [VAR0_PERCENT] less damage.",
        },

        .type = .loot,

        .weaponType = .loot,
        .delay = 250, // Delay after hit?
        .hbsType = "hbs_curse_0",
        .hbsLength = 5 * std.time.ms_per_s,

        .hbColor0 = rgb(66, 46, 105),
        .hbColor1 = rgb(225, 92, 239),

        .hbVar0 = 0.99,
        .specialMult = -0.99,
    });
    trigger(.onDamageDone, .{.tcond_dmg_self_special});
    target(.ttrg_player_damaged, .{});
    set(.tset_hbs_def, .{});
    addPattern(.ipat_apply_hbs, .{});

    // Flash item when debuff was applied
    trigger(.hbsCreated, .{.tcond_hbs_thishbcast});
    quickPattern(.tpat_hb_flash_item, .{});

    // Set color of special to hbColor0/1
    trigger(.colorCalc, .{});
    target(.ttrg_hotbarslots_self_weapontype, .{3}); // 3 is special TODO: Have constant for that
    quickPattern(.tpat_hb_set_color_def, .{});

    item(.{
        .id = "it_transfigured_aquamarine_bracelet",
        .name = .{
            .english = "Transfigured Aquamarine Bracelet",
        },
        .description = .{
            .english = "At the start of each fight, gain 2 random buffs for [VAR0_SECONDS] " ++
                "seconds.",
        },

        .type = .loot,
        .weaponType = .loot,

        .hbVar0 = std.time.ms_per_min,
        .hbsLength = std.time.ms_per_min,
    });
    trigger(.battleStart3, .{});
    target(.ttrg_player_self, .{});
    set(.tset_hbs_randombuff, .{});
    addPattern(.ipat_apply_hbs, .{});
    set(.tset_hbs_randombuff, .{});
    addPattern(.ipat_apply_hbs, .{});

    item(.{
        .id = "it_transfigured_lullaby_harb",
        .name = .{
            .english = "Transfigured Lullaby Harp",
        },
        .description = .{
            .english = "Every [CD] seconds, resets Special cooldowns for you and all allies.",
        },

        .type = .loot,
        .weaponType = .loot,
        .lootHbDispType = .cooldown,
        .hbInput = .auto,

        .showSqVar = true,
        .greySqVar0 = true,

        .cooldownType = .time,
        .cooldown = 10 * std.time.ms_per_s,
    });
    trigger(.hotbarUsed, .{.tcond_hb_self});
    quickPattern(.tpat_hb_run_cooldown, .{});
    target(.ttrg_players_ally, .{});
    target(.ttrg_hotbarslots_self_weapontype, .{3}); // 3 is special TODO: Have constant for that
    condition(.tcond_hb_check_resettable0, .{});
    quickPattern(.tpat_hb_reset_cooldown, .{});
    target(.ttrg_hotbarslot_self, .{});
    quickPattern(.tpat_hb_flash_item, .{});

    trigger(.autoStart, .{.tcond_hb_auto_pl});
    quickPattern(.tpat_hb_run_cooldown, .{});

    item(.{
        .id = "it_transfigured_nightingale_gown",
        .name = .{
            .english = "Transfigured Nightingale Gown",
        },
        .description = .{
            .english = "Every [CD] seconds, OMEGACHARGE your Defensive.",
        },
        .chargeType = .omegacharge,

        .type = .loot,
        .weaponType = .loot,
        .lootHbDispType = .cooldown,
        .hbInput = .auto,

        .showSqVar = true,
        .greySqVar0 = true,

        .cooldownType = .time,
        .cooldown = 15 * std.time.ms_per_s,
    });
    trigger(.hotbarUsed, .{.tcond_hb_self});
    quickPattern(.tpat_hb_run_cooldown, .{});
    target(.ttrg_hotbarslots_self_weapontype, .{4}); // 4 is defensive TODO: Have constant for that
    condition(.tcond_hb_check_chargeable0, .{});
    quickPattern(.tpat_hb_charge, .{3}); // TODO: Is 3 omegacharge?

    trigger(.autoStart, .{.tcond_hb_auto_pl});
    quickPattern(.tpat_hb_run_cooldown, .{});

    item(.{
        .id = "it_transfigured_red_tanzaku",
        .name = .{
            .english = "Transfigured Red Tanzaku",
        },
        .description = .{
            .english = "You have RABBITLUCK, but your abilities deal [VAR0_PERCENT] less damage.",
        },

        .type = .loot,

        .weaponType = .loot,
        .hbsType = "hbs_rabbitluck",
        .hbsLength = std.time.ms_per_min,

        .cooldownType = .time,
        .cooldown = std.time.ms_per_min,

        .hbVar0 = 0.99,
        .primaryMult = -0.99,
        .secondaryMult = -0.99,
        .specialMult = -0.99,
        .defensiveMult = -0.99,
    });
    trigger(.hotbarUsed, .{.tcond_hb_self});
    quickPattern(.tpat_hb_run_cooldown, .{});
    target(.ttrg_player_self, .{});
    set(.tset_hbs_def, .{});
    addPattern(.ipat_apply_hbs, .{});

    item(.{
        .id = "it_transfigured_sapphire_violin",
        .name = .{
            .english = "Transfigured Sapphire Violin",
        },
        .description = .{
            .english = "Every [CD] seconds, grant 3 random bufffs to all allies for 4 seconds. " ++
                "Breaks if you take damage once. Starts the battle on cooldown.",
        },

        .type = .loot,
        .weaponType = .loot,
        .lootHbDispType = .cooldown,
        .hbInput = .auto,

        .hbsLength = 4 * std.time.ms_per_s,

        .cooldownType = .time,
        .cooldown = 15 * std.time.ms_per_s,
    });
    trigger(.hotbarUsed, .{.tcond_hb_self});
    target(.ttrg_players_ally, .{});
    set(.tset_hbs_randombuff, .{});
    addPattern(.ipat_apply_hbs, .{});
    set(.tset_hbs_randombuff, .{});
    addPattern(.ipat_apply_hbs, .{});
    set(.tset_hbs_randombuff, .{});
    addPattern(.ipat_apply_hbs, .{});

    trigger(.autoStart, .{.tcond_hb_auto_pl});
    quickPattern(.tpat_hb_run_cooldown, .{});

    item(.{
        .id = "it_transfigured_topaz_charm",
        .name = .{
            .english = "Transfigured Topaz Charm",
        },
        .description = .{
            .english = "Gain 12 extra Gold when you take damage.",
        },

        .type = .loot,
        .weaponType = .loot,
    });
    trigger(.onDamage, .{.tcond_hb_self});
    quickPattern(.tpat_add_gold, .{});
}

const addPattern = mod.addPattern;
const condition = mod.condition;
const item = mod.item;
const quickPattern = mod.quickPattern;
const rgb = mod.rgb;
const set = mod.set;
const target = mod.target;
const trigger = mod.trigger;

const mod = @import("mod.zig");
const std = @import("std");
