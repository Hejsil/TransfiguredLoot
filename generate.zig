pub fn main() !void {
    mod.start();
    defer mod.end();

    const transfigured_snakefang_dagger_str = 10;
    item(.{
        .id = "it_transfigured_snakefang_dagger",
        .name = .{
            .english = "Transfigured Snakefang Dagger",
        },
        .description = .{
            .english = "Your Secondary deals [VAR0_PERCENT] less damage, and applies 4 [POISON-0].",
        },

        .type = .loot,

        .weaponType = .loot,
        .delay = 250,
        .hbsType = "hbs_poison_0",
        .hbsStrMult = transfigured_snakefang_dagger_str,
        .hbsLength = 5 * std.time.ms_per_s,

        .hbVar0 = 0.5,
        .secondaryMult = -0.5,

        .hbColor0 = rgb(0x0a, 0x51, 0x00),
        .hbColor1 = rgb(0x17, 0x7f, 0x00),
    });
    trigger(.onDamageDone, .{.tcond_dmg_self_secondary});
    target(.ttrg_player_damaged, .{});
    set(.tset_hbskey, .{ "hbs_poison_0", "r_hbsLength" });
    set(.tset_hbsstr, .{transfigured_snakefang_dagger_str});
    addPattern(.ipat_apply_hbs, .{});
    set(.tset_hbskey, .{ "hbs_poison_1", "r_hbsLength" });
    set(.tset_hbsstr, .{transfigured_snakefang_dagger_str});
    addPattern(.ipat_apply_hbs, .{});
    set(.tset_hbskey, .{ "hbs_poison_2", "r_hbsLength" });
    set(.tset_hbsstr, .{transfigured_snakefang_dagger_str});
    addPattern(.ipat_apply_hbs, .{});
    set(.tset_hbskey, .{ "hbs_poison_3", "r_hbsLength" });
    set(.tset_hbsstr, .{transfigured_snakefang_dagger_str});
    addPattern(.ipat_apply_hbs, .{});

    // Flash item when debuff was applied
    trigger(.hbsCreated, .{.tcond_hbs_thishbcast});
    quickPattern(.tpat_hb_flash_item, .{});

    // Set color of special to hbColor0/1
    trigger(.colorCalc, .{});
    target(.ttrg_hotbarslots_self_weapontype, .{2}); // 2 is secondary TODO: Have constant for that
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
            .english = "Every [CD], resets Special cooldowns for you and all allies.",
        },

        .type = .loot,
        .weaponType = .loot,
        .lootHbDispType = .cooldown,
        .hbInput = .auto,

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

    // TODO: Untested
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
        .lootHbDispType = .cooldown,
        .hbInput = .auto,

        .weaponType = .loot,
        .hbsType = "hbs_rabbit_luck", // TODO: What is the hbs for RABBITLUCK
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
            .english = "Every [CD] seconds, grant 3 random buffs to all allies for " ++
                "[HBSL]. Breaks if you take damage. Starts the battle on cooldown.",
        },

        .type = .loot,
        .weaponType = .loot,
        .lootHbDispType = .cooldown,
        .hbInput = .auto,

        .hbsLength = 4 * std.time.ms_per_s,

        .cooldownType = .time,
        .cooldown = 15 * std.time.ms_per_s,
    });
    // TODO: The "break the item" code hasn't been tested
    trigger(.onSquarePickup, .{.tcond_square_self});
    quickPattern(.tpat_hb_square_set_var, .{ "varIndex", 0, "amount", 1 });

    trigger(.onDamage, .{.tcond_pl_self});
    condition(.tcond_hb_check_square_var_false, .{ 0, 0 });
    quickPattern(.tpat_hb_square_add_var, .{ "varIndex", 0, "amount", -1 });
    quickPattern(.tpat_hb_reset_statchange, .{});
    quickPattern(.tpat_hb_flash_item, .{
        // "messageIndex", broke?
    });
    quickPattern(.tpat_hb_reset_cooldown, .{});

    trigger(.strCalc0, .{});
    condition(.tcond_hb_check_square_var_lte, .{ 0, 0 });
    quickPattern(.tpat_hb_set_cooldown_permanent, .{ "time", 0 });

    trigger(.hotbarUsed, .{.tcond_hb_self});
    quickPattern(.tpat_hb_run_cooldown, .{});
    quickPattern(.tpat_hb_flash_item, .{});
    target(.ttrg_players_ally, .{});
    set(.tset_hbs_randombuff, .{});
    addPattern(.ipat_apply_hbs, .{});
    set(.tset_hbs_randombuff, .{});
    addPattern(.ipat_apply_hbs, .{});
    set(.tset_hbs_randombuff, .{});
    addPattern(.ipat_apply_hbs, .{});

    trigger(.autoStart, .{.tcond_hb_auto_pl});
    quickPattern(.tpat_hb_run_cooldown, .{});

    // TODO: Untested
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

    // TODO: Not enough doc to implement
    item(.{
        .id = "it_transfigured_mountain_staff",
        .name = .{
            .english = "Transfigured Mountain Staff",
        },
        .description = .{
            .english = "Your Special hits two additional times. Its GCD is increased by " ++
                "1.4 seconds. Your movement speed is also moderately reduced.",
        },
        .type = .loot,
        .weaponType = .loot,
    });
    trigger(.cdCalc2a, .{});
    target(.ttrg_hotbarslots_self_weapontype, .{3}); // 3 is special TODO: Have constant for that
    quickPattern(.tpat_hb_add_gcd_permanent, .{ "amount", 1400 });

    const transfigured_witchs_cloak_hbs_mult = 1.5;
    const transfigured_witchs_cloak_ability_mult = -0.1;
    item(.{
        .id = "it_transfigured_witchs_cloak",
        .name = .{
            .english = "Transfigured Witch's Cloak",
        },
        .description = .{
            .english = "Your abilities deals [VAR0_PERCENT] less damage. Debuffs you place " ++
                "deal [VAR1_PERCENT] more damage. Slightly increases movement speed.",
        },
        .type = .loot,
        .weaponType = .loot,

        .hbVar0 = @abs(transfigured_witchs_cloak_ability_mult),
        .primaryMult = transfigured_witchs_cloak_ability_mult,
        .secondaryMult = transfigured_witchs_cloak_ability_mult,
        .specialMult = transfigured_witchs_cloak_ability_mult,
        .defensiveMult = transfigured_witchs_cloak_ability_mult,

        .hbVar1 = @abs(transfigured_witchs_cloak_hbs_mult),
        .hbsMult = transfigured_witchs_cloak_hbs_mult,

        .charspeed = 1,
    });
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
