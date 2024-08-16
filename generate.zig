pub fn main() !void {
    mod.start();
    defer mod.end();

    // TODO: No Test
    const transfigured_darkcloud_necklace_ability_mult = -0.5;
    const transfigured_darkcloud_necklace_loot_mult = 1.5;
    item(.{
        .id = "it_transfigured_darkcloud_necklace",
        .name = .{
            .english = "Transfigured Darkcloud Necklace",
        },
        .description = .{
            .english = "Damage from abilities is reduced by [VAR0_PERCENT].#" ++
                "Damage from loot is increased by [VAR1_PERCENT.",
        },

        .type = .loot,
        .weaponType = .loot,

        .hbVar0 = @abs(transfigured_darkcloud_necklace_ability_mult),
        .primaryMult = transfigured_darkcloud_necklace_ability_mult,
        .secondaryMult = transfigured_darkcloud_necklace_ability_mult,
        .specialMult = transfigured_darkcloud_necklace_ability_mult,
        .defensiveMult = transfigured_darkcloud_necklace_ability_mult,

        .hbVar1 = transfigured_darkcloud_necklace_loot_mult,
        .lootMult = transfigured_darkcloud_necklace_loot_mult,
    });

    item(.{
        .id = "it_transfigured_leech_staff",
        .name = .{
            .english = "Transfigured Leech Staff",
        },
        .description = .{
            .english = "When you inflict a bleed, also inflict [SAP].",
        },

        .type = .loot,
        .weaponType = .loot,

        .hbsType = .sap,
        .hbsLength = 5 * std.time.ms_per_s,
        .hbsStrMult = 20,
    });
    trig(.hbsCreated, .{.hbs_selfcast});
    tset(.debug, .{"s_statusId"});
    cond(.eval, .{ "s_statusId", ">=", @intFromEnum(Hbs.bleed_0) });
    cond(.eval, .{ "s_statusId", "<=", @intFromEnum(Hbs.bleed_3) });
    qpat(.hb_flash_item, .{});
    ttrg(.player_afflicted_source, .{});
    tset(.hbs_def, .{});
    apat(.apply_hbs, .{});

    item(.{
        .id = "it_transfigured_tiny_hourglass",
        .name = .{
            .english = "Transfigured Tiny Hourglass",
        },
        .description = .{
            .english = "Every [CD], deal [STR] damage to all enemies.",
        },

        .type = .loot,
        .weaponType = .loot,

        .lootHbDispType = .cooldown,
        .cooldownType = .time,
        .cooldown = 60 * std.time.ms_per_s,
        .hbInput = .auto,

        .strMult = 2000,
    });
    trig(.autoStart, .{.hb_auto_pl});
    qpat(.hb_run_cooldown, .{});

    trig(.hotbarUsed, .{.hb_self});
    qpat(.hb_run_cooldown, .{});
    qpat(.hb_flash_item, .{});
    qpat(.hb_cdloot_proc, .{});
    ttrg(.players_opponent, .{});
    tset(.strength_def, .{});
    apat(.crown_of_storms, .{});

    const transfigured_kyou_no_omikuji_dmg_mult = 0.5;
    item(.{
        .id = "it_transfigured_kyou_no_omikuji",
        .name = .{
            .english = "Transfigured Kyou No Omikuji",
        },
        .description = .{
            .english = "All damage you deal increases by [VAR0_PERCENT]. You cannot use your " ++
                "Primary and Special.",
        },
        .type = .loot,
        .weaponType = .loot,

        .allMult = transfigured_kyou_no_omikuji_dmg_mult,
        .hbVar0 = transfigured_kyou_no_omikuji_dmg_mult,

        .hbShineFlag = 16 | // HBCROSS_PRIMARY   - Makes Primary unusable
            64, // HBCROSS_SPECIAL   - Makes Special unusable
    });

    item(.{
        .id = "it_transfigured_gemini_necklace",
        .name = .{
            .english = "Transfigured Gemini Necklace",
        },
        .description = .{
            .english = "Your Secondary have a [LUCK] chance of instantly resetting when used.",
        },
        .type = .loot,
        .weaponType = .loot,

        .procChance = 0.5,
    });
    trig(.hotbarUsedProc, .{.hb_secondary});
    cond(.random_def, .{});
    ttrg(.hotbarslots_self_weapontype, .{WeaponType.secondary});
    cond(.hb_check_resettable0, .{});
    qpat(.hb_reset_cooldown, .{});
    ttrg(.hotbarslot_self, .{});
    qpat(.hb_flash_item, .{});
    qpat(.hb_lucky_proc, .{});

    item(.{
        .id = "it_transfigured_abyss_artifact",
        .name = .{
            .english = "Transfigured Abyss Artifact",
        },
        .description = .{
            .english = "Every [CD], gaining [STILLNESS] will also grant you [SUPER] for [HBSL].",
        },

        .type = .loot,
        .weaponType = .loot,

        .lootHbDispType = .cooldown,
        .cooldownType = .time,
        .cooldown = 16 * std.time.ms_per_s,

        .hbsType = .super,
        .hbsLength = 4 * std.time.ms_per_s,
    });
    trig(.hbsCreated, .{.hbs_selfafl});
    cond(.hb_available, .{});
    cond(.eval, .{ "s_statusId", "==", @intFromEnum(Hbs.stillness) });
    qpat(.hb_run_cooldown, .{});
    qpat(.hb_flash_item, .{});
    ttrg(.player_afflicted_source, .{});
    tset(.hbs_def, .{});
    apat(.apply_hbs, .{});

    item(.{
        .id = "it_transfigured_golden_katana",
        .name = .{
            .english = "Transfigured Golden Katana",
        },
        .description = .{
            .english = "Every [CD] have a [LUCK] chance to slices the air around you dealing " ++
                "[STR] damage.",
        },

        .type = .loot,
        .weaponType = .loot,

        .lootHbDispType = .cooldown,
        .cooldownType = .time,
        .cooldown = 1 * std.time.ms_per_s,
        .hbInput = .auto,

        .procChance = 0.05,
        .radius = 400,
        .strMult = 500,
    });
    trig(.hotbarUsed, .{.hb_self});
    qpat(.hb_run_cooldown, .{});
    cond(.random_def, .{});
    qpat(.hb_flash_item, .{});
    qpat(.hb_cdloot_proc, .{});
    qpat(.hb_lucky_proc, .{});
    ttrg(.players_opponent, .{});
    tset(.strength_def, .{});
    apat(.darkmagic_blade, .{});

    // TODO: No Test
    const transfigured_nova_crown_cd = 99 * std.time.ms_per_s;
    item(.{
        .id = "it_transfigured_nova_crown",
        .name = .{
            .english = "Transfigured Nova Crown",
        },
        .description = .{
            .english = "Your cooldowns becomes [VAR0_SECONDS]. When you crit, reset all " ++
                "cooldowns.",
        },

        .type = .loot,
        .weaponType = .loot,

        .hbVar0 = transfigured_nova_crown_cd,
    });
    trig(.onDamageDone, .{});
    cond(.true, .{"s_isCrit"});
    ttrg(.hotbarslots_current_players, .{});
    cond(.hb_check_resettable0, .{});
    qpat(.hb_reset_cooldown, .{});
    ttrg(.hotbarslot_self, .{});
    qpat(.hb_flash_item, .{});

    trig(.cdCalc5, .{});
    ttrg(.hotbarslots_current_players, .{});
    ttrg(.hotbarslots_prune, .{ "ths#_cooldown", ">", 0 });
    qpat(.hb_set_cooldown_permanent, .{ "time", transfigured_nova_crown_cd });

    const transfigured_amethyst_bracelet_mult = 0.3;
    item(.{
        .id = "it_transfigured_amethyst_bracelet",
        .name = .{
            .english = "Transfigured Amethyst Bracelet",
        },
        .description = .{
            .english = "You deal [VAR0_PERCENT] more damage. You cannot inflict debuffs.",
        },

        .type = .loot,
        .weaponType = .loot,

        .allMult = transfigured_amethyst_bracelet_mult,
        .hbVar0 = transfigured_amethyst_bracelet_mult,
    });
    trig(.hbsCreated, .{.hbs_selfcast});
    cond(.false, .{"s_isBuff"});
    ttrg(.hbstatus_source, .{});
    qpat(.hbs_destroy, .{});

    const transfigured_redwhite_ribbon_mult = 0.3;
    item(.{
        .id = "it_transfigured_redwhite_ribbon",
        .name = .{
            .english = "Transfigured Redwhite Ribbon",
        },
        .description = .{
            .english = "You deal [VAR0_PERCENT] more damage. You cannot gain buffs.",
        },

        .type = .loot,
        .weaponType = .loot,

        .allMult = transfigured_redwhite_ribbon_mult,
        .hbVar0 = transfigured_redwhite_ribbon_mult,
    });
    trig(.hbsCreated, .{.hbs_selfafl});
    cond(.true, .{"s_isBuff"});
    ttrg(.hbstatus_source, .{});
    qpat(.hbs_destroy, .{});

    item(.{
        .id = "it_transfigured_shadow_bracelet",
        .name = .{
            .english = "Transfigured Shadow Bracelet",
        },
        .description = .{
            .english = "Abilities and loot that hit more than twice hits and additional time.",
        },

        .type = .loot,
        .weaponType = .loot,
    });
    trig(.strCalc2, .{});
    ttrg(.hotbarslots_current_players, .{});
    ttrg(.hotbarslots_prune, .{ "ths#_number", ">", 2 });
    qpat(.debug_targets, .{});
    qpat(.hb_add_hitbox_var, .{
        "varIndex", "hitbox.number",
        "amount",   1,
    });

    const transfigured_greysteel_shield_aoe = 1;
    item(.{
        .id = "it_transfigured_greysteel_shield",
        .name = .{
            .english = "Transfigured Greysteel Shield",
        },
        .description = .{
            .english = "Your Defensive has a [VAR0_PERCENT] larger radius.",
        },

        .type = .loot,
        .weaponType = .loot,

        .hbVar0 = transfigured_greysteel_shield_aoe,
    });
    trig(.strCalc2, .{});
    ttrg(.hotbarslots_self_weapontype, .{WeaponType.defensive});
    qpat(.hb_mult_hitbox_var, .{
        "varIndex", "hitbox.radius",
        "mult",     1 + transfigured_greysteel_shield_aoe,
    });

    item(.{
        .id = "it_transfigured_cursed_poisonfrog_charm",
        .name = .{
            .english = "Transfigured Poisonfrog Charm",
        },
        .description = .{
            .english = "When a % chance succeeds, apply [HEXP] to all enemies for [HBSL].",
        },

        .type = .loot,
        .weaponType = .loot,

        .hbsType = .hex_poison,
        .hbsLength = 2 * std.time.ms_per_s,
        .hbsStrMult = 40,
    });
    trig(.luckyProc, .{.pl_self});
    qpat(.hb_flash_item, .{});
    ttrg(.players_opponent, .{});
    tset(.hbs_def, .{});
    apat(.apply_hbs, .{});

    const transfigured_cursed_deathcap_tome_hbs_str_mult = 30;
    item(.{
        .id = "it_transfigured_cursed_deathcap_tome",
        .name = .{
            .english = "Transfigured Deathcap Tome",
        },
        .description = .{
            .english = "When you inflict a poison, also inflict [DECAY-0].",
        },

        .type = .loot,
        .weaponType = .loot,

        .hbsType = .decay_0,
        .hbsLength = 5 * std.time.ms_per_s,
        .hbsStrMult = transfigured_cursed_deathcap_tome_hbs_str_mult,
    });
    for ([_][2]Hbs{
        .{ .poison_0, .decay_0 },
        .{ .poison_1, .decay_1 },
        .{ .poison_2, .decay_2 },
        .{ .poison_3, .decay_3 },
        .{ .poison_4, .decay_4 },
        .{ .poison_5, .decay_5 },
        .{ .poison_6, .decay_6 },
    }) |hbs| {
        trig(.hbsCreated, .{.hbs_selfcast});
        cond(.eval, .{ "s_statusId", "==", @intFromEnum(hbs[0]) });
        qpat(.hb_flash_item, .{});
        ttrg(.player_afflicted_source, .{});
        tset(.hbskey, .{ hbs[1], "r_hbsLength" });
        tset(.hbsstr, .{transfigured_cursed_deathcap_tome_hbs_str_mult});
        apat(.apply_hbs, .{});
    }

    const transfigured_grasswoven_bracelet_hp = 1;
    const transfigured_grasswoven_bracelet_aoe_per_hp = 0.1;
    item(.{
        .id = "it_transfigured_grasswoven_bracelet",
        .name = .{
            .english = "Transfigured Grasswoven Bracelet",
        },
        .description = .{
            .english = "Your max HP is increased by [VAR0]. All abilities and loot's hitboxes " ++
                "are [VAR1_PERCENT] larger per HP. Slightly increases movement speed.",
        },

        .type = .loot,
        .weaponType = .loot,

        .charspeed = 1,
        .hp = transfigured_grasswoven_bracelet_hp,
        .hbVar0 = transfigured_grasswoven_bracelet_hp,
        .hbVar1 = transfigured_grasswoven_bracelet_aoe_per_hp,
    });
    trig(.strCalc2, .{});
    ttrg(.hotbarslots_current_players, .{});
    tset(.uservar, .{
        "u_aoeMult", "r_hp",
        "*",         transfigured_grasswoven_bracelet_aoe_per_hp,
    });
    tset(.uservar, .{
        "u_aoeMultFull", "u_aoeMult",
        "+",             1,
    });
    qpat(.hb_mult_hitbox_var, .{
        "varIndex", "hitbox.radius",
        "mult",     "u_aoeMultFull",
    });

    const transfigured_sunflower_crown_hp = 3;
    item(.{
        .id = "it_transfigured_sunflower_crown",
        .name = .{
            .english = "Transfigured Sunflower Crown",
        },
        .description = .{
            .english = "Your max HP is increased by [VAR0]. You are easier to hit. Slightly " ++
                "increases movement speed.",
        },

        .type = .loot,
        .weaponType = .loot,

        .charspeed = 1,
        .charradius = 20,
        .hp = transfigured_sunflower_crown_hp,
        .hbVar0 = transfigured_sunflower_crown_hp,
    });

    const transfigured_midsummer_dress_hp = 1;
    const transfigured_midsummer_dress_mult_per_hp = 0.05;
    item(.{
        .id = "it_transfigured_midsummer_dress",
        .name = .{
            .english = "Transfigured Midsummer Dress",
        },
        .description = .{
            .english = "Your max HP is increased by [VAR0]. You deal [VAR1_PERCENT] more " ++
                "damage per HP. Slightly increases movement speed.",
        },

        .type = .loot,
        .weaponType = .loot,

        .charspeed = 1,
        .hp = transfigured_midsummer_dress_hp,
        .hbVar0 = transfigured_midsummer_dress_hp,
        .hbVar1 = transfigured_midsummer_dress_mult_per_hp,
    });
    trig(.strCalc0, .{});
    tset(.uservar, .{
        "u_allMult", "r_hp",
        "*",         transfigured_midsummer_dress_mult_per_hp,
    });
    qpat(.hb_add_statchange_norefresh, .{
        "stat",   "stat.allMult",
        "amount", "u_allMult",
    });

    item(.{
        .id = "it_transfigured_staticshock_earrings",
        .name = .{
            .english = "Transfigured Staticshock Earrings",
        },
        .description = .{
            .english = "When you inflict spark, deal [STR] damage to all enemies.",
        },

        .type = .loot,
        .weaponType = .loot,

        .strMult = 150,
    });
    trig(.hbsCreated, .{.hbs_selfcast});
    cond(.eval, .{ "s_statusId", ">=", @intFromEnum(Hbs.spark_0) });
    cond(.eval, .{ "s_statusId", "<=", @intFromEnum(Hbs.spark_6) });
    qpat(.hb_flash_item, .{});
    ttrg(.players_opponent, .{});
    tset(.strength_def, .{});
    apat(.crown_of_storms, .{});

    item(.{
        .id = "it_transfigured_thunderclap_gloves",
        .name = .{
            .english = "Transfigured Thunderclap Gloves",
        },
        .description = .{
            .english = "Every [CD] have a [LUCK] chance of dealing [STR] damage to all enemies.",
        },

        .type = .loot,
        .weaponType = .loot,

        .lootHbDispType = .cooldown,
        .cooldownType = .time,
        .cooldown = 3 * std.time.ms_per_s,
        .hbInput = .auto,

        .procChance = 0.3,
        .strMult = 200,
    });
    trig(.hotbarUsed, .{.hb_self});
    qpat(.hb_run_cooldown, .{});
    cond(.random_def, .{});
    qpat(.hb_flash_item, .{});
    qpat(.hb_lucky_proc, .{});
    qpat(.hb_cdloot_proc, .{});
    ttrg(.players_opponent, .{});
    tset(.strength_def, .{});
    apat(.crown_of_storms, .{});

    for ([_]mod.Item{
        .{
            .id = "it_transfigured_sandpriestess_spear",
            .name = .{ .english = "Transfigured Sandpriestess Spear" },
            .description = .{ .english = "Every time you gain [FLASH-STR], gain [FLOW-STR]." },
            .hbsType = .flowstr,
        },
        .{
            .id = "it_transfigured_flamedancer_dagger",
            .name = .{ .english = "Transfigured Flamedancer Dagger" },
            .description = .{ .english = "Every time you gain [FLASH-DEX], gain [FLOW-DEX]." },
            .hbsType = .flowdex,
        },
        .{
            .id = "it_transfigured_whiteflame_staff",
            .name = .{ .english = "Transfigured Whiteflame Staff" },
            .description = .{ .english = "Every time you gain [FLASH-INT], gain [FLOW-INT]." },
            .hbsType = .flowint,
        },
    }) |_item| {
        var i = _item;
        i.type = .loot;
        i.weaponType = .loot;
        i.hbsLength = 5 * std.time.ms_per_s;

        const flash_hbs: Hbs = switch (_item.hbsType.?) {
            .flowstr => .flashstr,
            .flowdex => .flashdex,
            .flowint => .flashint,
            else => unreachable,
        };

        item(i);
        trig(.hbsCreated, .{.hbs_selfafl});
        cond(.eval, .{ "s_statusId", "==", @intFromEnum(flash_hbs) });
        qpat(.hb_flash_item, .{});
        ttrg(.player_afflicted_source, .{});
        tset(.hbs_def, .{});
        apat(.apply_hbs, .{});
    }

    const transfigured_cursed_candlestaff_hbs_str_mult = 250;
    item(.{
        .id = "it_transfigured_cursed_candlestaff",
        .name = .{
            .english = "Transfigured Cursed Candlestaff",
        },
        .description = .{
            .english = "When you inflict a burn, also inflict [GHOSTFLAME-0].",
        },

        .type = .loot,
        .weaponType = .loot,

        .hbsType = .ghostflame_0,
        .hbsLength = 5 * std.time.ms_per_s,
        .hbsStrMult = transfigured_cursed_candlestaff_hbs_str_mult,
    });
    for ([_][2]Hbs{
        .{ .burn_0, .ghostflame_0 },
        .{ .burn_1, .ghostflame_1 },
        .{ .burn_2, .ghostflame_2 },
        .{ .burn_3, .ghostflame_3 },
        .{ .burn_4, .ghostflame_4 },
        .{ .burn_5, .ghostflame_5 },
        .{ .burn_6, .ghostflame_0 },
    }) |hbs| {
        trig(.hbsCreated, .{.hbs_selfcast});
        cond(.hb_available, .{});
        cond(.eval, .{ "s_statusId", "==", @intFromEnum(hbs[0]) });
        qpat(.hb_flash_item, .{});
        ttrg(.player_afflicted_source, .{});
        tset(.hbskey, .{ hbs[1], "r_hbsLength" });
        tset(.hbsstr, .{transfigured_cursed_candlestaff_hbs_str_mult});
        apat(.apply_hbs, .{});
    }

    // TODO: No Test
    const transfigured_ballroom_gown_buff = 5.0;
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

        .allMult = transfigured_ballroom_gown_buff * 0.01,
        .haste = 1 - transfigured_ballroom_gown_buff * 0.01,
        .luck = transfigured_ballroom_gown_buff * 0.01,
        .invulnPlus = transfigured_ballroom_gown_buff * 100,
        .cdp = -transfigured_ballroom_gown_buff * 100,
        .charspeed = transfigured_ballroom_gown_buff * 0.1,
        .charradius = -transfigured_ballroom_gown_buff,
    });
    trig(.strCalc2, .{});
    ttrg(.hotbarslots_current_players, .{});
    qpat(.hb_mult_hitbox_var, .{
        "varIndex", "hitbox.radius",
        "mult",     1 + transfigured_ballroom_gown_buff * 0.01,
    });
    qpat(.hb_add_strength, .{
        "amount", transfigured_ballroom_gown_buff,
    });

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
    qpat(.hb_flash_item, .{});
    qpat(.hb_cdloot_proc, .{});
    qpat(.hb_run_cooldown, .{});
    ttrg(.hbstatus_source, .{});
    qpat(.hbs_destroy, .{});
    ttrg(.players_opponent, .{});
    tset(.strength_def, .{});
    apat(.darkmagic_blade, .{});

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
    cond(.eval, .{ "s_statusId", ">=", @intFromEnum(Hbs.curse_0) });
    cond(.eval, .{ "s_statusId", "<=", @intFromEnum(Hbs.curse_5) });
    qpat(.hb_flash_item, .{});
    qpat(.hb_cdloot_proc, .{});
    qpat(.hb_run_cooldown, .{});
    ttrg(.hbstatus_source, .{});
    qpat(.hbs_destroy, .{});
    ttrg(.players_opponent, .{});
    tset(.strength_def, .{});
    apat(.darkmagic_blade, .{});

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

        .hbsType = .hex_poison,
        .hbsLength = 5 * std.time.ms_per_s,
        .hbsStrMult = 40,
    });
    trig(.hbsCreated, .{.hbs_selfcast});
    cond(.hb_available, .{});
    cond(.eval, .{ "s_statusId", ">=", @intFromEnum(Hbs.curse_0) });
    cond(.eval, .{ "s_statusId", "<=", @intFromEnum(Hbs.curse_5) });
    qpat(.hb_flash_item, .{});
    qpat(.hb_cdloot_proc, .{});
    qpat(.hb_run_cooldown, .{});
    ttrg(.hbstatus_source, .{});
    qpat(.hbs_destroy, .{});
    ttrg(.player_afflicted_source, .{});
    tset(.hbs_def, .{});
    apat(.apply_hbs, .{});

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

        .hbsType = .hex_super,
        .hbsLength = 5 * std.time.ms_per_s,
    });
    trig(.hbsCreated, .{.hbs_selfcast});
    cond(.hb_available, .{});
    cond(.eval, .{ "s_statusId", ">=", @intFromEnum(Hbs.curse_0) });
    cond(.eval, .{ "s_statusId", "<=", @intFromEnum(Hbs.curse_5) });
    qpat(.hb_flash_item, .{});
    qpat(.hb_cdloot_proc, .{});
    qpat(.hb_run_cooldown, .{});
    ttrg(.hbstatus_source, .{});
    qpat(.hbs_destroy, .{});
    ttrg(.player_afflicted_source, .{});
    tset(.hbs_def, .{});
    apat(.apply_hbs, .{});

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
        tset(.hbskey, .{ debuff, "r_hbsLength" });
        tset(.hbsstr, .{transfigured_mimick_rabbitfoot_hbs_str_mult});
        apat(.poisonfrog_charm, .{});
        ttrg(.player_self, .{});
        tset(.hbskey, .{ Hbs.berserk, transfigured_mimick_rabbitfoot_cd });
        apat(.apply_hbs, .{});
    }

    trig(.hotbarUsed2, .{.hb_self});
    qpat(.hb_flash_item, .{});
    qpat(.hb_cdloot_proc, .{});
    qpat(.hb_run_cooldown, .{});
    qpat(.hb_square_add_var, .{ "varIndex", 0, "amount", 1 });

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
        .hbsType = .poison_0,
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
    ttrg(.hotbarslots_self_weapontype, .{WeaponType.secondary});
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
    ttrg(.hotbarslots_self_weapontype, .{WeaponType.special});
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
    qpat(.hb_flash_item, .{});
    qpat(.hb_cdloot_proc, .{});
    ttrg(.hotbarslots_self_weapontype, .{WeaponType.defensive});
    cond(.hb_check_chargeable0, .{});
    qpat(.hb_charge, .{3}); // TODO: Is 3 omegacharge?

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
        .hbsType = .lucky,
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
    ttrg(.hotbarslots_prune, .{ "ths#_weaponType", "!=", WeaponType.loot });
    ttrg(.hotbarslots_prune, .{ "ths#_weaponType", "!=", WeaponType.potion });
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
    ttrg(.hotbarslots_self_weapontype, .{WeaponType.special});
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

        .hbsType = .curse_0,
        .hbsLength = 5 * std.time.ms_per_s,

        .hbVar0 = transfigured_opal_necklace_num_curses,
        .hbVar1 = transfigured_opal_necklace_extra_cd,
    });
    trig(.cdCalc2a, .{});
    ttrg(.hotbarslots_self_weapontype, .{WeaponType.defensive});
    qpat(.hb_add_cooldown_permanent, .{ "amount", transfigured_opal_necklace_extra_cd });

    trig(.hotbarUsed, .{.hb_defensive});
    ttrg(.players_opponent, .{});

    const curses = [_]Hbs{
        .curse_0,
        .curse_1,
        .curse_2,
        .curse_3,
        .curse_4,
        .curse_5,
    };
    for (curses[0..transfigured_opal_necklace_num_curses]) |curse| {
        tset(.hbskey, .{ curse, "r_hbsLength" });
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
    qpat(.hb_flash_item, .{});
    qpat(.hb_cdloot_proc, .{});
    ttrg(.players_opponent, .{});
    tset(.strength_def, .{});
    apat(.sleeping_greatbow, .{});

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
    qpat(.hb_flash_item, .{});
    qpat(.hb_cdloot_proc, .{});
    ttrg(.players_ally, .{});
    tset(.hbskey, .{ "hbs_smite_0", "r_hbsLength" });
    apat(.apply_hbs, .{});

    trig(.hotbarUsed2, .{.hb_self});
    for (0..16) |i| {
        if (i % 5 != 0) cond(.hb_check_square_var_false, .{ 0, i });
    }
    qpat(.hb_flash_item, .{});
    qpat(.hb_cdloot_proc, .{});
    ttrg(.players_ally, .{});
    tset(.hbskey, .{ "hbs_elegy_0", "r_hbsLength" });
    apat(.apply_hbs, .{});

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
        .hbsType = .burn_3,
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
const Hbs = mod.Hbs;
const item = mod.item;
const qpat = mod.qpat;
const rgb = mod.rgb;
const trig = mod.trig;
const tset = mod.tset;
const ttrg = mod.ttrg;
const WeaponType = mod.WeaponType;

const mod = @import("mod.zig");
const std = @import("std");
