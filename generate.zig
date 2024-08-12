pub fn main() !void {
    mod.start();
    defer mod.end();

    for ([_]mod.Item{
        .{
            .id = "it_transfigured_sandpriestess_spear",
            .name = .{ .english = "Transfigured Sandpriestess Spear" },
            .description = .{ .english = "Every time you gain [FLASH-STR], gain [FLOW-STR]." },
            .hbsType = .hbs_flowstr,
        },
        .{
            .id = "it_transfigured_flamedancer_dagger",
            .name = .{ .english = "Transfigured Flamedancer Dagger" },
            .description = .{ .english = "Every time you gain [FLASH-DEX], gain [FLOW-DEX]." },
            .hbsType = .hbs_flowdex,
        },
        .{
            .id = "it_transfigured_whiteflame_staff",
            .name = .{ .english = "Transfigured Whiteflame Staff" },
            .description = .{ .english = "Every time you gain [FLASH-INT], gain [FLOW-INT]." },
            .hbsType = .hbs_flowint,
        },
    }) |_item| {
        var i = _item;
        i.type = .loot;
        i.weaponType = .loot;
        i.hbsLength = 5 * std.time.ms_per_s;

        const flash_hbs: Hbs = switch (_item.hbsType.?) {
            .hbs_flowstr => .hbs_flashstr,
            .hbs_flowdex => .hbs_flashdex,
            .hbs_flowint => .hbs_flashint,
            else => unreachable,
        };

        // TODO: No test
        item(i);
        trig(.hbsCreated, .{.hbs_selfafl});
        cond(.eval, .{ "s_statusId", "==", @intFromEnum(flash_hbs) });
        ttrg(.player_afflicted_source, .{});
        tset(.hbs_def, .{});
        apat(.apply_hbs, .{});
        qpat(.hb_flash_item, .{});
    }

    // TODO: No test
    const transfigured_cursed_candlestafff_hbs_str_mult = 250;
    item(.{
        .id = "it_transfigured_cursed_candlestafff",
        .name = .{
            .english = "Transfigured Cursed Candlestaff",
        },
        .description = .{
            .english = "When you inflict a burn, also inflict [GHOSTFLAME-0].",
        },

        .type = .loot,
        .weaponType = .loot,

        .hbsType = .hbs_ghostflame_0,
        .hbsLength = 5 * std.time.ms_per_s,
        .hbsStrMult = transfigured_cursed_candlestafff_hbs_str_mult,
    });
    for ([_][2]Hbs{
        .{ .hbs_burn_0, .hbs_ghostflame_0 },
        .{ .hbs_burn_1, .hbs_ghostflame_1 },
        .{ .hbs_burn_2, .hbs_ghostflame_2 },
        .{ .hbs_burn_3, .hbs_ghostflame_3 },
        .{ .hbs_burn_4, .hbs_ghostflame_4 },
        .{ .hbs_burn_5, .hbs_ghostflame_5 },
        .{ .hbs_burn_6, .hbs_ghostflame_0 },
    }) |hbs| {
        trig(.hbsCreated, .{.hbs_selfcast});
        cond(.hb_available, .{});
        cond(.eval, .{ "s_statusId", "==", @intFromEnum(hbs[0]) });
        ttrg(.player_afflicted_source, .{});
        tset(.hbskey, .{ @tagName(hbs[1]), "r_hbsLength" });
        tset(.hbsstr, .{transfigured_cursed_candlestafff_hbs_str_mult});
        apat(.apply_hbs, .{});
        qpat(.hb_flash_item, .{});
    }

    // TODO: No test
    item(.{
        .id = "it_transfigured_ballroom_gown",
        .name = .{
            .english = "Transfigured Ballroom Gown",
        },
        .description = .{
            .english = "Makes everything very slightly better.",
        },

        .type = .loot,
        .weaponType = .loot,

        .hp = 1,
        .allMult = 0.05,
        .cdp = -500,
        .haste = -0.05,
        .luck = 0.05,
        .charspeed = 0.5,
        .charradius = -5,
        .invulnPlus = 500,
    });

    // TODO: No test
    item(.{
        .id = "it_transfigured_holy_greatsword",
        .name = .{
            .english = "Transfigured Holy Greatsword",
        },
        .description = .{
            .english = "Every [CD], consume a buff you gain to slices the air around you " ++
                "dealing [STR] damage.",
        },

        .type = .loot,
        .weaponType = .loot,

        .lootHbDispType = .cooldown,
        .cooldownType = .time,
        .cooldown = 4 * std.time.ms_per_s,

        .delay = 400,
        .radius = 400,
        .strMult = 400,
    });
    trig(.hbsCreated, .{.hbs_selfafl});
    cond(.hb_available, .{});
    cond(.true, .{"s_isBuff"});
    qpat(.hb_run_cooldown, .{});
    ttrg(.hbstatus_source, .{});
    qpat(.hbs_destroy, .{});
    ttrg(.players_opponent, .{});
    tset(.strength_def, .{});
    apat(.darkmagic_blade, .{});
    qpat(.hb_flash_item, .{});
    qpat(.hb_cdloot_proc, .{});

    const transfigured_shrinemaidens_kosode_mult_per_buff = 0.1;
    item(.{
        .id = "it_transfigured_shrinemaidens_kosode",
        .name = .{
            .english = "Transfigured Shrinemaiden's Kosode",
        },
        .description = .{
            .english = "Deal [VAR0_PERCENT] more damage for each buff on you.",
        },

        .type = .loot,
        .weaponType = .loot,

        .showSqVar = true,
        .hbVar0 = transfigured_shrinemaidens_kosode_mult_per_buff,
    });
    trig(.battleStart0, .{});
    qpat(.hb_square_set_var, .{ "varIndex", 0, "amount", 0 });
    qpat(.hb_reset_statchange, .{});

    trig(.hbsCreated, .{.hbs_selfafl});
    qpat(.hb_square_add_var, .{ "varIndex", 0, "amount", 1 });
    qpat(.hb_reset_statchange, .{});

    trig(.hbsRefreshed, .{.hbs_selfafl});
    qpat(.hb_square_add_var, .{ "varIndex", 0, "amount", -1 });
    qpat(.hb_reset_statchange, .{});

    trig(.hbsDestroyed, .{.hbs_selfafl});
    qpat(.hb_square_add_var, .{ "varIndex", 0, "amount", -1 });
    qpat(.hb_reset_statchange, .{});

    trig(.strCalc0, .{});
    tset(.uservar, .{
        "u_allMult", "r_sqVar0",
        "*",         transfigured_shrinemaidens_kosode_mult_per_buff,
    });
    qpat(.hb_add_statchange_norefresh, .{
        "stat",   "stat.allMult",
        "amount", "u_allMult",
    });

    item(.{
        .id = "it_transfigured_darkmagic_blade",
        .name = .{
            .english = "Transfigured Darkmagic Blade",
        },
        .description = .{
            .english = "Every [CD], consume a curse you apply to slice the air around you " ++
                "dealing [STR] damage.",
        },

        .type = .loot,
        .weaponType = .loot,

        .lootHbDispType = .cooldown,
        .cooldownType = .time,
        .cooldown = 4 * std.time.ms_per_s,

        .delay = 400,
        .radius = 400,
        .strMult = 400,
    });
    trig(.hbsCreated, .{.hbs_selfcast});
    cond(.hb_available, .{});
    cond(.eval, .{ "s_statusId", ">=", @intFromEnum(Hbs.hbs_curse_0) });
    cond(.eval, .{ "s_statusId", "<=", @intFromEnum(Hbs.hbs_curse_5) });
    qpat(.hb_run_cooldown, .{});
    ttrg(.hbstatus_source, .{});
    qpat(.hbs_destroy, .{});
    ttrg(.players_opponent, .{});
    tset(.strength_def, .{});
    apat(.darkmagic_blade, .{});
    qpat(.hb_flash_item, .{});
    qpat(.hb_cdloot_proc, .{});

    item(.{
        .id = "it_transfigured_curse_talon",
        .name = .{
            .english = "Transfigured Curse Talon",
        },
        .description = .{
            .english = "Every [CD], replace a curse you apply with [HEXP].",
        },

        .type = .loot,
        .weaponType = .loot,

        .lootHbDispType = .cooldown,
        .cooldownType = .time,
        .cooldown = 10 * std.time.ms_per_s,

        .hbsType = .hbs_hex_poison,
        .hbsLength = 5 * std.time.ms_per_s,
        .hbsStrMult = 40,
    });
    trig(.hbsCreated, .{.hbs_selfcast});
    cond(.hb_available, .{});
    cond(.eval, .{ "s_statusId", ">=", @intFromEnum(Hbs.hbs_curse_0) });
    cond(.eval, .{ "s_statusId", "<=", @intFromEnum(Hbs.hbs_curse_5) });
    qpat(.hb_run_cooldown, .{});
    ttrg(.hbstatus_source, .{});
    qpat(.hbs_destroy, .{});
    ttrg(.player_afflicted_source, .{});
    tset(.hbs_def, .{});
    apat(.apply_hbs, .{});
    qpat(.hb_flash_item, .{});
    qpat(.hb_cdloot_proc, .{});

    item(.{
        .id = "it_transfigured_raven_grimoire",
        .name = .{
            .english = "Transfigured Raven Grimoire",
        },
        .description = .{
            .english = "Every [CD], replace a curse you apply with [HEXS].",
        },

        .type = .loot,
        .weaponType = .loot,

        .lootHbDispType = .cooldown,
        .cooldownType = .time,
        .cooldown = 10 * std.time.ms_per_s,

        .hbsType = .hbs_hex_super,
        .hbsLength = 5 * std.time.ms_per_s,
    });
    trig(.hbsCreated, .{.hbs_selfcast});
    cond(.hb_available, .{});
    cond(.eval, .{ "s_statusId", ">=", @intFromEnum(Hbs.hbs_curse_0) });
    cond(.eval, .{ "s_statusId", "<=", @intFromEnum(Hbs.hbs_curse_5) });
    qpat(.hb_run_cooldown, .{});
    ttrg(.hbstatus_source, .{});
    qpat(.hbs_destroy, .{});
    ttrg(.player_afflicted_source, .{});
    tset(.hbs_def, .{});
    apat(.apply_hbs, .{});
    qpat(.hb_flash_item, .{});
    qpat(.hb_cdloot_proc, .{});

    const transfigured_mimick_rabbitfoot_all_mult = -0.13;
    const transfigured_mimick_rabbitfoot_hbs_str_mult = 30;
    const transfigured_mimick_rabbitfoot_cd = 4 * std.time.ms_per_s;
    item(.{
        .id = "it_transfigured_mimick_rabbitfoot",
        .name = .{
            .english = "Transfigured Mimick Rabbitfoot",
        },
        .description = .{
            .english = "It's a real rabbit foot.#" ++
                "Negative emotions consume you.#" ++
                " #" ++
                "You are unlucky.#" ++
                // "You go into massive debt. (You lose all you're money.)#" ++
                "You deal [VAR0_PERCENT] less damage.#" ++
                "Every [CD], inflict a [HBSL] debuff to all enemies.",
        },

        .type = .loot,
        .weaponType = .loot,

        .hbsStrMult = transfigured_mimick_rabbitfoot_hbs_str_mult,
        .hbsLength = 13 * std.time.ms_per_s,

        .hbVar0 = @abs(transfigured_mimick_rabbitfoot_all_mult),
        .allMult = transfigured_mimick_rabbitfoot_all_mult,
        .luck = -13,

        .lootHbDispType = .cooldown,
        .cooldownType = .time,
        .cooldown = transfigured_mimick_rabbitfoot_cd,
        .hbInput = .auto,
    });
    var random_state = std.Random.DefaultPrng.init(1);
    const random = random_state.random();
    var debuffs = mod.Hbs.debuffs;
    random.shuffle(Hbs, &debuffs);

    for (debuffs, 0..) |debuff, i| {
        trig(.hotbarUsed, .{.hb_self});
        cond(.hb_check_square_var, .{ 0, i });
        ttrg(.players_opponent, .{});
        tset(.hbskey, .{ @tagName(debuff), "r_hbsLength" });
        tset(.hbsstr, .{transfigured_mimick_rabbitfoot_hbs_str_mult});
        apat(.poisonfrog_charm, .{});
        ttrg(.player_self, .{});
        tset(.hbskey, .{ @tagName(Hbs.hbs_berserk), transfigured_mimick_rabbitfoot_cd });
        apat(.apply_hbs, .{});
    }

    trig(.hotbarUsed2, .{.hb_self});
    qpat(.hb_run_cooldown, .{});
    qpat(.hb_square_add_var, .{ "varIndex", 0, "amount", 1 });
    qpat(.hb_flash_item, .{});
    qpat(.hb_cdloot_proc, .{});

    trig(.hotbarUsed3, .{.hb_self});
    cond(.hb_check_square_var, .{ 0, debuffs.len });
    qpat(.hb_square_set_var, .{ "varIndex", 0, "amount", 0 });

    const transfigured_snakefang_dagger_str = 10;
    const transfigured_snakefang_dagger_num_poisons = 4;
    item(.{
        .id = "it_transfigured_snakefang_dagger",
        .name = .{
            .english = "Transfigured Snakefang Dagger",
        },
        .description = .{
            .english = "Your Secondary deals [VAR0_PERCENT] less damage, and applies " ++
                "[VAR1] [POISON-0].",
        },

        .type = .loot,

        .weaponType = .loot,
        .delay = 250,
        .hbsType = .hbs_poison_0,
        .hbsStrMult = transfigured_snakefang_dagger_str,
        .hbsLength = 5 * std.time.ms_per_s,

        .hbVar0 = 0.5,
        .secondaryMult = -0.5,

        .hbColor0 = rgb(0x0a, 0x51, 0x00),
        .hbColor1 = rgb(0x17, 0x7f, 0x00),

        .hbVar1 = transfigured_snakefang_dagger_num_poisons,
    });
    trig(.onDamageDone, .{.dmg_self_secondary});
    ttrg(.player_damaged, .{});
    inline for (0..transfigured_snakefang_dagger_num_poisons) |i| {
        tset(.hbskey, .{ std.fmt.comptimePrint("hbs_poison_{}", .{i}), "r_hbsLength" });
        tset(.hbsstr, .{transfigured_snakefang_dagger_str});
        apat(.apply_hbs, .{});
    }

    // Flash item when debuff was applied
    trig(.hbsCreated, .{.hbs_thishbcast});
    qpat(.hb_flash_item, .{});

    // Set color of special to hbColor0/1
    trig(.colorCalc, .{});
    ttrg(.hotbarslots_self_weapontype, .{2}); // 2 is secondary TODO: Have constant for that
    qpat(.hb_set_color_def, .{});

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
    trig(.battleStart3, .{});
    ttrg(.player_self, .{});
    tset(.hbs_randombuff, .{});
    apat(.apply_hbs, .{});
    tset(.hbs_randombuff, .{});
    apat(.apply_hbs, .{});

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
    trig(.hotbarUsed, .{.hb_self});
    qpat(.hb_run_cooldown, .{});
    ttrg(.players_ally, .{});
    ttrg(.hotbarslots_self_weapontype, .{3}); // 3 is special TODO: Have constant for that
    cond(.hb_check_resettable0, .{});
    qpat(.hb_reset_cooldown, .{});
    ttrg(.hotbarslot_self, .{});
    qpat(.hb_flash_item, .{});
    qpat(.hb_cdloot_proc, .{});

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
    trig(.hotbarUsed, .{.hb_self});
    qpat(.hb_run_cooldown, .{});
    ttrg(.hotbarslots_self_weapontype, .{4}); // 4 is defensive TODO: Have constant for that
    cond(.hb_check_chargeable0, .{});
    qpat(.hb_charge, .{3}); // TODO: Is 3 omegacharge?
    qpat(.hb_flash_item, .{});
    qpat(.hb_cdloot_proc, .{});

    trig(.autoStart, .{.hb_auto_pl});
    qpat(.hb_run_cooldown, .{});

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
        .hbsType = .hbs_lucky,
        .hbsLength = std.time.ms_per_min,

        .cooldownType = .time,
        .cooldown = std.time.ms_per_min,

        .hbVar0 = transfigured_red_tanzaku_dmg,
    });
    trig(.hotbarUsed, .{.hb_self});
    qpat(.hb_run_cooldown, .{});
    ttrg(.player_self, .{});
    tset(.hbs_def, .{});
    apat(.apply_hbs, .{});

    trig(.strCalc1a, .{});
    ttrg(.hotbarslots_current_players, .{});
    ttrg(.hotbarslots_prune_base_has_str, .{});
    ttrg(.hotbarslots_prune, .{ "ths#_weaponType", "!=", "weaponType.loot" });
    ttrg(.hotbarslots_prune, .{ "ths#_weaponType", "!=", "weaponType.potion" });
    qpat(.hb_set_strength, .{ "amount", transfigured_red_tanzaku_dmg });

    const transfigured_sapphire_violin_num_buffs = 3;
    item(.{
        .id = "it_transfigured_sapphire_violin",
        .name = .{
            .english = "Transfigured Sapphire Violin",
        },
        .description = .{
            .english = "Every [CD] seconds, grant [VAR0] random buffs to all allies for " ++
                "[HBSL]. Breaks if you take damage. Starts the battle on cooldown.",
        },

        .type = .loot,
        .weaponType = .loot,
        .lootHbDispType = .cooldown,
        .hbInput = .auto,

        .hbsLength = 4 * std.time.ms_per_s,

        .cooldownType = .time,
        .cooldown = 15 * std.time.ms_per_s,

        .hbVar0 = transfigured_sapphire_violin_num_buffs,
    });
    // TODO: The "break the item" code hasn't been tested
    trig(.onSquarePickup, .{.square_self});
    qpat(.hb_square_set_var, .{ "varIndex", 0, "amount", 1 });

    trig(.onDamage, .{.pl_self});
    cond(.hb_check_square_var_false, .{ 0, 0 });
    qpat(.hb_square_add_var, .{ "varIndex", 0, "amount", -1 });
    qpat(.hb_reset_statchange, .{});
    qpat(.hb_flash_item, .{
        // "messageIndex", broke?
    });
    qpat(.hb_reset_cooldown, .{});

    trig(.strCalc0, .{});
    cond(.hb_check_square_var_lte, .{ 0, 0 });
    qpat(.hb_set_cooldown_permanent, .{ "time", 0 });

    trig(.hotbarUsed, .{.hb_self});
    qpat(.hb_run_cooldown, .{});
    qpat(.hb_flash_item, .{});
    ttrg(.players_ally, .{});
    for (0..transfigured_sapphire_violin_num_buffs) |_| {
        tset(.hbs_randombuff, .{});
        apat(.apply_hbs, .{});
    }

    trig(.autoStart, .{.hb_auto_pl});
    qpat(.hb_run_cooldown, .{});

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
    trig(.onDamage, .{.hb_self});
    // quickPattern(.add_gold, .{});

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
    trig(.cdCalc2a, .{});
    ttrg(.hotbarslots_self_weapontype, .{3}); // 3 is special TODO: Have constant for that
    qpat(.hb_add_gcd_permanent, .{ "amount", 1400 });

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
    trig(.onDamageDone, .{.dmg_islarge});
    qpat(.hb_flash_item, .{});
    qpat(.hb_lucky_proc, .{});

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
    trig(.onLevelup, .{});
    qpat(.hb_flash_item, .{});
    // quickPattern(.add_gold, .{1});

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
    trig(.cdCalc5, .{});
    ttrg(.hotbarslots_current_players, .{});
    ttrg(.hotbarslots_prune, .{ "ths#_cooldown", ">", 0 });
    ttrg(.hotbarslots_prune, .{ "ths#_cooldown", "<=", transfigured_timemage_cap_cd_check });
    qpat(.hb_set_cooldown_permanent, .{ "time", transfigured_timemage_cap_cd_set });

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
    const transfigured_opal_necklace_num_curses = 5;
    item(.{
        .id = "it_transfigured_opal_necklace",
        .name = .{
            .english = "Transfigured Opal Necklace",
        },
        .description = .{
            .english = "Your Defensive applies [VAR0] curses to all enemies, but its cooldown is " ++
                "increased by [VAR1_SECONDS].",
        },
        .type = .loot,
        .weaponType = .loot,

        .hbsType = .hbs_curse_0,
        .hbsLength = 5 * std.time.ms_per_s,

        .hbVar0 = transfigured_opal_necklace_num_curses,
        .hbVar1 = transfigured_opal_necklace_extra_cd,
    });
    trig(.cdCalc2a, .{});
    ttrg(.hotbarslots_self_weapontype, .{4}); // 4 is defensive TODO: Have constant for that
    qpat(.hb_add_cooldown_permanent, .{ "amount", transfigured_opal_necklace_extra_cd });

    trig(.hotbarUsed, .{.hb_defensive});
    ttrg(.players_opponent, .{});
    inline for (0..transfigured_opal_necklace_num_curses) |i| {
        tset(.hbskey, .{ std.fmt.comptimePrint("hbs_curse_{}", .{i}), "r_hbsLength" });
        apat(.apply_hbs, .{});
    }

    const transfigured_sleeping_greatbow_cooldown = 12 * std.time.ms_per_s;
    item(.{
        .id = "transfigured_sleeping_greatbow",
        .name = .{
            .english = "Transfigured Sleeping Greatbow",
        },
        .description = .{
            .english = "Every [VAR0_SECONDS], fire a very slow-moving projectile at your " ++
                "ttrged enemy that deals [STR] damage.",
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

        .strMult = 1000,
    });
    trig(.hotbarUsed, .{.hb_self});
    qpat(.hb_run_cooldown, .{});
    ttrg(.players_opponent, .{});
    tset(.strength_def, .{});
    apat(.sleeping_greatbow, .{});
    qpat(.hb_flash_item, .{});
    qpat(.hb_cdloot_proc, .{});

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
    trig(.autoStart, .{.square_self});
    qpat(.hb_square_set_var, .{ "varIndex", 0, "amount", 0 });

    trig(.hotbarUsed, .{.hb_self});
    qpat(.hb_run_cooldown, .{});
    qpat(.hb_square_add_var, .{ "varIndex", 0, "amount", 1 });

    trig(.hotbarUsed2, .{.hb_self});
    for (0..16) |i| {
        if (i % 3 != 0) cond(.hb_check_square_var_false, .{ 0, i });
    }
    ttrg(.players_ally, .{});
    tset(.hbskey, .{ "hbs_smite_0", "r_hbsLength" });
    apat(.apply_hbs, .{});
    qpat(.hb_flash_item, .{});
    qpat(.hb_cdloot_proc, .{});

    trig(.hotbarUsed2, .{.hb_self});
    for (0..16) |i| {
        if (i % 5 != 0) cond(.hb_check_square_var_false, .{ 0, i });
    }
    ttrg(.players_ally, .{});
    tset(.hbskey, .{ "hbs_elegy_0", "r_hbsLength" });
    apat(.apply_hbs, .{});
    qpat(.hb_flash_item, .{});
    qpat(.hb_cdloot_proc, .{});

    trig(.hotbarUsed3, .{.hb_self});
    cond(.hb_check_square_var, .{ 0, 15 });
    qpat(.hb_square_set_var, .{ "varIndex", 0, "amount", 0 });

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
        .hbsType = .hbs_burn_3,
        .hbsLength = 5 * std.time.ms_per_s,
    });
    trig(.onDamageDone, .{.dmg_islarge});
    cond(.hb_available, .{});
    qpat(.hb_run_cooldown, .{});
    ttrg(.player_damaged, .{});
    tset(.hbs_def, .{});
    tset(.hbs_burnhit, .{});
    apat(.apply_hbs, .{});
    qpat(.hb_cdloot_proc, .{});

    trig(.hbsCreated, .{.hbs_thishbcast});
    qpat(.hb_flash_item, .{});
}

const apat = mod.apat;
const cond = mod.cond;
const item = mod.item;
const qpat = mod.qpat;
const rgb = mod.rgb;
const tset = mod.tset;
const ttrg = mod.ttrg;
const trig = mod.trig;
const Hbs = mod.Hbs;

const mod = @import("mod.zig");
const std = @import("std");
