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

    const transfigured_red_tanzaku_dmg = 7;
    item(.{
        .id = "it_transfigured_red_tanzaku",
        .name = .{
            .english = "Transfigured Red Tanzaku",
        },
        .description = .{
            .english = "Your abilities deal 7 damage. You have [LUCKY].",
        },

        .type = .loot,
        .lootHbDispType = .cooldown,
        .hbInput = .auto,

        .weaponType = .loot,
        .hbsType = "hbs_lucky",
        .hbsLength = std.time.ms_per_min,

        .cooldownType = .time,
        .cooldown = std.time.ms_per_min,

        .hbVar0 = transfigured_red_tanzaku_dmg,
    });
    trigger(.hotbarUsed, .{.tcond_hb_self});
    quickPattern(.tpat_hb_run_cooldown, .{});
    target(.ttrg_player_self, .{});
    set(.tset_hbs_def, .{});
    addPattern(.ipat_apply_hbs, .{});

    trigger(.strCalc1a, .{});
    target(.ttrg_hotbarslots_current_players, .{});
    target(.ttrg_hotbarslots_prune_base_has_str, .{});
    target(.ttrg_hotbarslots_prune, .{ "ths#_weaponType", "!=", "weaponType.loot" });
    target(.ttrg_hotbarslots_prune, .{ "ths#_weaponType", "!=", "weaponType.potion" });
    quickPattern(.tpat_hb_set_strength, .{ "amount", transfigured_red_tanzaku_dmg });

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

    // TODO: No test
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
    // quickPattern(.tpat_add_gold, .{});

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

    item(.{
        .id = "it_transfigured_glittering_trumpet",
        .name = .{
            .english = "Transfigured Glittering Trumpet",
        },
        .description = .{
            .english = "Your large hits counts as a % chance success.",
        },
        .type = .loot,
        .weaponType = .loot,
    });
    trigger(.onDamageDone, .{.tcond_dmg_islarge});
    quickPattern(.tpat_hb_flash_item, .{});
    quickPattern(.tpat_hb_lucky_proc, .{});

    // TODO: No tests
    item(.{
        .id = "it_transfigured_silver_coin",
        .name = .{
            .english = "Transfigured Silver Coin",
        },
        .description = .{
            .english = "When you level up, gain 1 gold.",
        },
        .type = .loot,
        .weaponType = .loot,
    });
    trigger(.onLevelup, .{});
    quickPattern(.tpat_hb_flash_item, .{});
    // quickPattern(.tpat_add_gold, .{1});

    const transfigured_timemage_cap_cd_set = 2 * std.time.ms_per_s;
    const transfigured_timemage_cap_cd_check = 4 * std.time.ms_per_s;
    item(.{
        .id = "it_transfigured_timemage_cap",
        .name = .{
            .english = "Transfigured Timemage Cap",
        },
        .description = .{
            .english = "Cooldowns less than or equal to [VAR0_SECONDS] become [VAR1_SECONDS].",
        },
        .type = .loot,
        .weaponType = .loot,

        .hbVar0 = transfigured_timemage_cap_cd_check,
        .hbVar1 = transfigured_timemage_cap_cd_set,
    });
    trigger(.cdCalc5, .{});
    target(.ttrg_hotbarslots_current_players, .{});
    target(.ttrg_hotbarslots_prune, .{ "ths#_cooldown", ">", 0 });
    target(.ttrg_hotbarslots_prune, .{ "ths#_cooldown", "<=", transfigured_timemage_cap_cd_check });
    quickPattern(.tpat_hb_set_cooldown_permanent, .{ "time", transfigured_timemage_cap_cd_set });

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

    const transfigured_opal_necklace_extra_cd = 15 * std.time.ms_per_s;
    item(.{
        .id = "it_transfigured_opal_necklace",
        .name = .{
            .english = "Transfigured Opal Necklace",
        },
        .description = .{
            .english = "Your Defensive applies 5 curses to all enemies, but its cooldown is " ++
                "increased by [VAR0_SECONDS].",
        },
        .type = .loot,
        .weaponType = .loot,

        .hbsType = "hbs_curse_0",
        .hbsLength = 5 * std.time.ms_per_s,

        .hbVar0 = transfigured_opal_necklace_extra_cd,
    });
    trigger(.cdCalc2a, .{});
    target(.ttrg_hotbarslots_self_weapontype, .{4}); // 4 is defensive TODO: Have constant for that
    quickPattern(.tpat_hb_add_cooldown_permanent, .{ "amount", transfigured_opal_necklace_extra_cd });

    trigger(.hotbarUsed, .{.tcond_hb_defensive});
    target(.ttrg_players_opponent, .{});
    set(.tset_hbskey, .{ "hbs_curse_0", "r_hbsLength" });
    addPattern(.ipat_apply_hbs, .{});
    set(.tset_hbskey, .{ "hbs_curse_1", "r_hbsLength" });
    addPattern(.ipat_apply_hbs, .{});
    set(.tset_hbskey, .{ "hbs_curse_2", "r_hbsLength" });
    addPattern(.ipat_apply_hbs, .{});
    set(.tset_hbskey, .{ "hbs_curse_3", "r_hbsLength" });
    addPattern(.ipat_apply_hbs, .{});
    set(.tset_hbskey, .{ "hbs_curse_4", "r_hbsLength" });
    addPattern(.ipat_apply_hbs, .{});

    const transfigured_sleeping_greatbow_cooldown = 12 * std.time.ms_per_s;
    const transfigured_sleeping_greatbow_dmg = 1000;
    item(.{
        .id = "transfigured_sleeping_greatbow",
        .name = .{
            .english = "Transfigured Sleeping Greatbow",
        },
        .description = .{
            .english = "Every [VAR0_SECONDS], fire a very slow-moving projectile at your " ++
                "targeted enemy that deals [VAR1] damage.",
        },
        .type = .loot,
        .weaponType = .loot,
        .hbInput = .auto,

        .delay = 10 * std.time.ms_per_s,
        .radius = 150,

        .hbVar0 = transfigured_sleeping_greatbow_cooldown,
        .cooldown = transfigured_sleeping_greatbow_cooldown,
        .lootHbDispType = .cooldown,
        .cooldownType = .time,

        .hbVar1 = transfigured_sleeping_greatbow_dmg,
        .strMult = transfigured_sleeping_greatbow_dmg,
    });
    trigger(.hotbarUsed, .{.tcond_hb_self});
    quickPattern(.tpat_hb_run_cooldown, .{});
    quickPattern(.tpat_hb_flash_item, .{});
    target(.ttrg_players_opponent, .{});
    set(.tset_strength_def, .{});
    addPattern(.ipat_sleeping_greatbow, .{});

    item(.{
        .id = "it_transfigured_ornamental_bell",
        .name = .{
            .english = "Transfigured Ornamental Bell",
        },
        .description = .{
            .english = "Every 3 seconds, grants [SMITE-0] to all allies for 1 seconds.#" ++
                "Every 5 seconds, grants [ELEGY-0] to all allies for 1 seconds.",
        },

        .type = .loot,
        .weaponType = .loot,
        .lootHbDispType = .cooldown,
        .hbInput = .auto,

        .cooldownType = .time,
        .cooldown = 1 * std.time.ms_per_s,

        .showSqVar = true,
        .hbsLength = 1 * std.time.ms_per_s,
    });
    trigger(.autoStart, .{.tcond_square_self});
    quickPattern(.tpat_hb_square_set_var, .{ "varIndex", 0, "amount", 0 });

    trigger(.hotbarUsed, .{.tcond_hb_self});
    quickPattern(.tpat_hb_run_cooldown, .{});
    quickPattern(.tpat_hb_square_add_var, .{ "varIndex", 0, "amount", 1 });

    trigger(.hotbarUsed2, .{.tcond_hb_self});
    condition(.tcond_hb_check_square_var_false, .{ 0, 1 });
    condition(.tcond_hb_check_square_var_false, .{ 0, 2 });
    condition(.tcond_hb_check_square_var_false, .{ 0, 4 });
    condition(.tcond_hb_check_square_var_false, .{ 0, 5 });
    condition(.tcond_hb_check_square_var_false, .{ 0, 7 });
    condition(.tcond_hb_check_square_var_false, .{ 0, 8 });
    condition(.tcond_hb_check_square_var_false, .{ 0, 10 });
    condition(.tcond_hb_check_square_var_false, .{ 0, 11 });
    condition(.tcond_hb_check_square_var_false, .{ 0, 13 });
    condition(.tcond_hb_check_square_var_false, .{ 0, 14 });
    quickPattern(.tpat_hb_flash_item, .{});
    target(.ttrg_players_ally, .{});
    set(.tset_hbskey, .{ "hbs_smite_0", "r_hbsLength" });
    addPattern(.ipat_apply_hbs, .{});

    trigger(.hotbarUsed2, .{.tcond_hb_self});
    condition(.tcond_hb_check_square_var_false, .{ 0, 1 });
    condition(.tcond_hb_check_square_var_false, .{ 0, 2 });
    condition(.tcond_hb_check_square_var_false, .{ 0, 3 });
    condition(.tcond_hb_check_square_var_false, .{ 0, 4 });
    condition(.tcond_hb_check_square_var_false, .{ 0, 6 });
    condition(.tcond_hb_check_square_var_false, .{ 0, 7 });
    condition(.tcond_hb_check_square_var_false, .{ 0, 8 });
    condition(.tcond_hb_check_square_var_false, .{ 0, 9 });
    condition(.tcond_hb_check_square_var_false, .{ 0, 11 });
    condition(.tcond_hb_check_square_var_false, .{ 0, 12 });
    condition(.tcond_hb_check_square_var_false, .{ 0, 13 });
    condition(.tcond_hb_check_square_var_false, .{ 0, 14 });
    quickPattern(.tpat_hb_flash_item, .{});
    target(.ttrg_players_ally, .{});
    set(.tset_hbskey, .{ "hbs_elegy_0", "r_hbsLength" });
    addPattern(.ipat_apply_hbs, .{});

    trigger(.hotbarUsed3, .{.tcond_hb_self});
    condition(.tcond_hb_check_square_var, .{ 0, 15 });
    quickPattern(.tpat_hb_square_set_var, .{ "varIndex", 0, "amount", 0 });

    const transfigured_meteor_staff_cd = 10 * std.time.ms_per_s;
    item(.{
        .id = "transfigured_meteor_staff",
        .name = .{
            .english = "Transfigured Meteor Staff",
        },
        .description = .{
            .english = "Every [VAR0_SECONDS], your next large hit inflict [BURN-3].",
        },
        .type = .loot,
        .weaponType = .loot,

        .cooldownType = .time,
        .cooldown = transfigured_meteor_staff_cd,
        .hbVar0 = transfigured_meteor_staff_cd,

        .delay = 250,
        .hbsType = "hbs_burn_3",
        .hbsLength = 5 * std.time.ms_per_s,
    });
    trigger(.onDamageDone, .{.tcond_dmg_islarge});
    condition(.tcond_hb_available, .{});
    quickPattern(.tpat_hb_run_cooldown, .{});
    target(.ttrg_player_damaged, .{});
    set(.tset_hbs_def, .{});
    set(.tset_hbs_burnhit, .{});
    addPattern(.ipat_apply_hbs, .{});

    trigger(.hbsCreated, .{.tcond_hbs_thishbcast});
    quickPattern(.tpat_hb_flash_item, .{});
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
