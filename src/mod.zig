pub fn main() !void {
    try transfiguredArcaneSet();
    try transfiguredNightSet();
    try transfiguredTimespaceSet();
    try transfiguredWindSet();
    try transfiguredBloodwolfSet();
    try transfiguredAssasinSet();
    try transfiguredRockdragonSet();
    try transfiguredFlameSet();
    try transfiguredGemSet();
    try transfiguredLightningSet();
    try transfiguredShrineSet();
    try transfiguredLuckySet();
    try transfiguredLifeSet();
    try transfiguredPoisonSet();
    try transfiguredDepthSet();
    try transfiguredDarkbiteSet();
    try transfiguredTimegemSet();
    try transfiguredYoukaiSet();
    try transfiguredHauntedSet();
    try transfiguredGladiatorSet();
    try transfiguredSparkbladeSet();
    try transfiguredSwiftflightSet();
    try transfiguredSacredflameSet();
    try transfiguredRuinsSet();
    try transfiguredLakeshrineSet();
}

fn transfiguredArcaneSet() !void {
    const color = rgb(0x53, 0x33, 0xe3);
    rns.start(.{
        .name = "Transfigured Arcane Set",
        .image_path = "images/arcane.png",
        .thumbnail_path = "images/arcane_thumbnail.png",
    });
    defer rns.end();

    item(.{
        .id = "it_transfigured_raven_grimoire",
        .name = .{
            .english = "Transfigured Raven Grimoire",
        },
        .description = .{
            .english = "Every [CD], your Special applies [HEXS].",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .purple,

        .lootHbDispType = .cooldown,
        .cooldownType = .time,
        .cooldown = 10 * std.time.ms_per_s,

        .hbsType = .hex_super,
        .hbsLength = 5 * std.time.ms_per_s,
    });
    trig.onDamageDone(&.{.dmg_self_special});
    cond.hb_available(.{});
    ttrg.player_damaged(.{});
    tset.hbs_def(.{});
    apat.apply_hbs(.{});

    trig.hbsCreated(&.{.hbs_thishbcast});
    qpat.hb_run_cooldown(.{});
    qpat.hb_cdloot_proc(.{});
    qpat.hb_flash_item(.{});

    const blackwing_staff_mult = 0.15;
    item(.{
        .id = "it_transfigured_blackwing_staff",
        .name = .{
            .english = "Transfigured Blackwing Staff",
        },
        .description = .{
            .english = "Your Primary deals [VAR0_PERCENT] more damage. If an enemy is cursed " ++
                "or hexed this value is tripled.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .purple,
        .lootHbDispType = .glowing,

        .glowSqVar0 = true,
        .autoOffSqVar0 = 0,

        .hbVar0 = blackwing_staff_mult,
    });

    for ([_][]const Hbs{ &Hbs.curses, &Hbs.hexes }) |hbs| {
        trig.hbsCreated(&.{});
        cond.eval(s.statusId, .@">=", @intFromEnum(hbs[0]));
        cond.eval(s.statusId, .@"<=", @intFromEnum(hbs[hbs.len - 1]));
        qpat.hb_square_add_var(.{ .varIndex = 0, .amount = 1 });
        qpat.hb_reset_statchange(.{});

        trig.hbsDestroyed(&.{});
        cond.eval(s.statusId, .@">=", @intFromEnum(hbs[0]));
        cond.eval(s.statusId, .@"<=", @intFromEnum(hbs[hbs.len - 1]));
        qpat.hb_square_add_var(.{ .varIndex = 0, .amount = -1 });
        qpat.hb_reset_statchange(.{});
    }

    trig.strCalc1c(&.{});
    cond.hb_check_square_var(.{ 0, 0 });
    ttrg.hotbarslots_self_weapontype(.{WeaponType.primary});
    qpat.hb_add_strcalcbuff(.{ .amount = blackwing_staff_mult });

    trig.strCalc1c(&.{});
    cond.hb_check_square_var_gte(.{ 0, 1 });
    ttrg.hotbarslots_self_weapontype(.{WeaponType.primary});
    qpat.hb_add_strcalcbuff(.{ .amount = blackwing_staff_mult * 3 });

    item(.{
        .id = "it_transfigured_curse_talon",
        .name = .{
            .english = "Transfigured Curse Talon",
        },
        .description = .{
            .english = "Every [CD], your Secondary applies [HEXP].",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .purple,

        .lootHbDispType = .cooldown,
        .cooldownType = .time,
        .cooldown = 10 * std.time.ms_per_s,

        .hbsType = .hex_poison,
        .hbsLength = 5 * std.time.ms_per_s,
        .hbsStrMult = 40,
    });
    trig.onDamageDone(&.{.dmg_self_secondary});
    cond.hb_available(.{});
    qpat.hb_flash_item(.{});
    qpat.hb_cdloot_proc(.{});
    qpat.hb_run_cooldown(.{});
    ttrg.player_damaged(.{});
    tset.hbs_def(.{});
    apat.apply_hbs(.{});

    item(.{
        .id = "it_transfigured_darkmagic_blade",
        .name = .{
            .english = "Transfigured Darkmagic Blade",
        },
        .description = .{
            .english = "Every [CD], slice the air around you dealing [STR] damage.#" ++
                "Cooldown resets every time you inflict a curse or hex.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .purple,

        .lootHbDispType = .cooldown,
        .cooldownType = .time,
        .cooldown = 10 * std.time.ms_per_s,
        .hbInput = .auto,

        .delay = 400,
        .radius = 400,
        .strMult = 300,
    });
    trig.autoStart(&.{.hb_auto_pl});
    qpat.hb_run_cooldown(.{});

    for ([_][]const Hbs{ &Hbs.curses, &Hbs.hexes }) |hbs| {
        trig.hbsCreated(&.{.hbs_selfcast});
        cond.eval(s.statusId, .@">=", @intFromEnum(hbs[0]));
        cond.eval(s.statusId, .@"<=", @intFromEnum(hbs[hbs.len - 1]));
        ttrg.hotbarslot_self(.{});
        qpat.hb_reset_cooldown(.{});
    }

    trig.hotbarUsed(&.{.hb_self});
    qpat.hb_flash_item(.{});
    qpat.hb_run_cooldown(.{});
    ttrg.players_opponent(.{});
    tset.strength_def(.{});
    apat.darkmagic_blade(.{});

    const witchs_cloak_hbs_mult = 1.5;
    const witchs_cloak_ability_mult = -0.1;
    item(.{
        .id = "it_transfigured_witchs_cloak",
        .name = .{
            .english = "Transfigured Witch's Cloak",
        },
        .description = .{
            .english = "Your abilities deals [VAR0_PERCENT] less damage. Debuffs you place " ++
                "deal [VAR1_PERCENT] more damage. Slightly increases movement speed.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .purple,

        .hbVar0 = @abs(witchs_cloak_ability_mult),
        .primaryMult = witchs_cloak_ability_mult,
        .secondaryMult = witchs_cloak_ability_mult,
        .specialMult = witchs_cloak_ability_mult,
        .defensiveMult = witchs_cloak_ability_mult,

        .hbVar1 = @abs(witchs_cloak_hbs_mult),
        .hbsMult = witchs_cloak_hbs_mult,

        .charspeed = charspeed.slightly,
    });

    item(.{
        .id = "it_transfigured_crowfeather_hairpin",
        .name = .{
            .english = "Transfigured Crowfeather Hairpin",
        },
        .description = .{
            .english = "When your Special hits a cursed or hexed enemy, deal an additional hit " ++
                "per curse or hex of [STR] damage.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .purple,

        .strMult = 35,
    });
    trig.onDamageDone(&.{.dmg_self_special});
    for ([_][]const Hbs{ &Hbs.curses, &Hbs.hexes }) |hbs| {
        ttrg.hbstatus_target(.{});
        ttrg.hbstatus_prune(thbss.statusId, .@">=", @intFromEnum(hbs[0]));
        ttrg.hbstatus_prune(thbss.statusId, .@"<=", @intFromEnum(hbs[hbs.len - 1]));
        tset.uservar_hbscount(.{"u_hbscount"});
        tset.uservar2("u_hbs_matching", "u_hbs_matching", .@"+", "u_hbscount");
    }
    cond.eval("u_hbs_matching", .@"!=", 0);
    ttrg.player_damaged(.{});
    tset.strength_def(.{});
    apat.melee_hit(.{ .numberStr = "u_hbs_matching" });

    const redblack_ribbon_dmg_mult = 0.05;
    const redblack_ribbon_mult_length_hbs = 1.0;
    item(.{
        .id = "it_transfigured_redblack_ribbon",
        .name = .{
            .english = "Transfigured Redblack Ribbon",
        },
        .description = .{
            .english = "You deal [VAR1_PERCENT] more damage. Debuffs you place last [VAR0_PERCENT] longer.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .purple,

        .allMult = redblack_ribbon_dmg_mult,
        .hbVar0 = redblack_ribbon_mult_length_hbs,
        .hbVar1 = redblack_ribbon_dmg_mult,
    });
    trig.cdCalc2b(&.{});
    ttrg.hotbarslots_current_players(.{});
    ttrg.hotbarslots_prune_bufftype(.{0});
    qpat.hb_mult_length_hbs(.{ .mult = redblack_ribbon_mult_length_hbs + 1 });

    const opal_necklace_extra_cd = 10 * std.time.ms_per_s;
    const opal_necklace_num_curses = 4;
    item(.{
        .id = "it_transfigured_opal_necklace",
        .name = .{
            .english = "Transfigured Opal Necklace",
        },
        .description = .{
            .english = "Your Defensive applies [VAR0] curses to all enemies, but its cooldown is " ++
                "increased by [VAR1_SECONDS].",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .purple,

        .hbsType = .curse_0,
        .hbsLength = 5 * std.time.ms_per_s,

        .hbVar0 = opal_necklace_num_curses,
        .hbVar1 = opal_necklace_extra_cd,

        .autoOffSqVar0 = 0,
    });
    trig.cdCalc2a(&.{});
    ttrg.hotbarslots_self_weapontype(.{WeaponType.defensive});
    qpat.hb_add_cooldown_permanent(.{ .amount = opal_necklace_extra_cd });

    trig.hotbarUsedProc(&.{.hb_defensive});
    ttrg.players_opponent(.{});
    qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 1 });

    for (Hbs.curses[0..opal_necklace_num_curses]) |curse| {
        tset.hbskey(.{ curse, r.hbsLength });
        apat.apply_hbs(.{});
    }

    // Flash item when debuff was applied
    trig.hbsCreated(&.{.hbs_thishbcast});
    // To avoid flashing for every debuff applied, instead keep track of if the defensive was used.
    // If so, flash once, and set the used flag to 0, so we don't flash again.
    cond.hb_check_square_var(.{ 0, 1 });
    qpat.hb_flash_item(.{});
    qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 0 });
}

fn transfiguredNightSet() !void {
    const color = rgb(0x8d, 0x57, 0xd6);
    rns.start(.{
        .name = "Transfigured Night Set",
        .image_path = "images/night.png",
        .thumbnail_path = "images/night_thumbnail.png",
    });
    defer rns.end();

    const sleeping_greatbow_cooldown = 12 * std.time.ms_per_s;
    item(.{
        .id = "it_transfigured_sleeping_greatbow",
        .name = .{
            .english = "Transfigured Sleeping Greatbow",
        },
        .description = .{
            .english = "Every [VAR0_SECONDS], fire a very slow-moving projectile at your " ++
                "targeted enemy that deals [STR] damage.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .purple,
        .hbInput = .auto,

        .delay = 10 * std.time.ms_per_s,
        .radius = 150,

        .hbVar0 = sleeping_greatbow_cooldown,
        .cooldown = sleeping_greatbow_cooldown,
        .lootHbDispType = .cooldown,
        .cooldownType = .time,

        .strMult = 1000,
    });
    trig.hotbarUsed(&.{.hb_self});
    qpat.hb_run_cooldown(.{});
    qpat.hb_flash_item(.{});
    ttrg.players_opponent(.{});
    tset.strength_def(.{});
    apat.sleeping_greatbow(.{});

    const transfigured_crescentmoon_dagger_hits = 2;
    item(.{
        .id = "it_transfigured_crescentmoon_dagger",
        .name = .{
            .english = "Transfigured Crescentmoon Dagger",
        },
        .description = .{
            .english = "Every [CD], your Primary will deal an additional [VAR0] hits of " ++
                "[STR] damage on hit.#" ++
                "These hits always crit.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .purple,
        .lootHbDispType = .cooldown,

        .cooldownType = .time,
        .cooldown = 10 * std.time.ms_per_s,

        .hbVar0 = transfigured_crescentmoon_dagger_hits,
        .hitNumber = transfigured_crescentmoon_dagger_hits,
        .strMult = 130,
    });
    trig.onDamageDone(&.{.dmg_self_primary});
    cond.hb_available(.{});
    qpat.hb_run_cooldown(.{});
    ttrg.player_damaged(.{});
    tset.strength_def(.{});
    tset.critratio(.{1});
    apat.black_wakizashi(.{});
    qpat.hb_flash_item(.{});
    qpat.hb_cdloot_proc(.{});

    item(.{
        .id = "it_transfigured_lullaby_harb",
        .name = .{
            .english = "Transfigured Lullaby Harp",
        },
        .description = .{
            .english = "Every [CD], resets Special cooldowns for you and all allies.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .purple,
        .lootHbDispType = .cooldown,
        .hbInput = .auto,

        .cooldownType = .time,
        .cooldown = 10 * std.time.ms_per_s,
    });
    trig.hotbarUsed(&.{.hb_self});
    qpat.hb_run_cooldown(.{});
    ttrg.players_ally(.{});
    ttrg.hotbarslots_self_weapontype(.{WeaponType.special});
    ttrg.hotbarslots_prune_noreset(.{});
    qpat.hb_reset_cooldown(.{});
    ttrg.hotbarslot_self(.{});
    qpat.hb_flash_item(.{});

    const nightstar_grimoire_radius = 200;
    item(.{
        .id = "it_transfigured_nightstar_grimoire",
        .name = .{
            .english = "Transfigured Nightstar Grimoire",
        },
        .description = .{
            .english = "Every [CD], hit a random area of the arena, dealing [STR] damage. If " ++
                "an enemy gets hit, the cooldown is reset.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .purple,
        .lootHbDispType = .cooldown,
        .hbInput = .auto,

        .cooldownType = .time,
        .cooldown = 25 * std.time.ms_per_s,

        .delay = 200,
        .radius = nightstar_grimoire_radius,
        .strMult = 900,
    });
    trig.hotbarUsed(&.{.hb_self});
    qpat.hb_flash_item(.{});
    qpat.hb_run_cooldown(.{});
    tset.strength_def(.{});
    ttrg.players_opponent(.{});
    tset.uservar_random_range(.{ "u_x", nightstar_grimoire_radius, 1800 - nightstar_grimoire_radius });
    tset.uservar_random_range(.{ "u_y", nightstar_grimoire_radius, 1000 - nightstar_grimoire_radius });
    apat.meteor_staff(.{ .fxStr = "u_x", .fyStr = "u_y" });

    trig.autoStart(&.{.hb_auto_pl});
    qpat.hb_run_cooldown(.{});

    trig.onDamageDone(&.{.dmg_self_thishb});
    qpat.hb_reset_cooldown(.{});

    const moon_pendant_radius = 200;
    item(.{
        .id = "it_transfigured_moon_pendant",
        .name = .{
            .english = "Transfigured Moon Pendant",
        },
        .description = .{
            .english = "Deals [STR] damage to a random area of the arena when you use your " ++
                "Special.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .purple,

        .delay = 200,
        .radius = moon_pendant_radius,
        .strMult = 300,
    });
    trig.hotbarUsedProc(&.{.hb_special});
    qpat.hb_flash_item(.{});
    tset.strength_def(.{});
    ttrg.players_opponent(.{});
    tset.uservar_random_range(.{ "u_x", moon_pendant_radius, 1800 - moon_pendant_radius });
    tset.uservar_random_range(.{ "u_y", moon_pendant_radius, 1000 - moon_pendant_radius });
    apat.meteor_staff(.{ .fxStr = "u_x", .fyStr = "u_y" });

    const pajama_hat_cd_reduction = 2 * std.time.ms_per_s;
    item(.{
        .id = "it_transfigured_pajama_hat",
        .name = .{
            .english = "Transfigured Pajama Hat",
        },
        .description = .{
            .english = "Using your Defensive decreases all other cooldowns by [VAR0_SECONDS].",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .purple,

        .hbVar0 = pajama_hat_cd_reduction,
    });
    trig.hotbarUsedProc(&.{.hb_defensive});
    ttrg.hotbarslots_current_players(.{});
    ttrg.hotbarslots_prune(thss.weaponType, .@"!=", WeaponType.defensive);
    ttrg.hotbarslots_prune(thss.cooldown, .@">", 0);
    ttrg.hotbarslots_prune(thss.resettable, .@"==", 1);
    qpat.hb_flash_item(.{});
    qpat.hb_add_cooldown(.{ .amount = -pajama_hat_cd_reduction });

    const stuffed_rabbit_activate_count = 10;
    const stuffed_rabbit_invul_dur = 3 * std.time.ms_per_s;
    item(.{
        .id = "it_transfigured_stuffed_rabbit",
        .name = .{
            .english = "Transfigured Stuffed Rabbit",
        },
        .description = .{
            .english = "Every [VAR0] times an ability or loot with a cooldown is activated, " ++
                "gain invulnerability for [VAR1_SECONDS].",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .purple,

        .showSqVar = true,

        .hbVar0 = stuffed_rabbit_activate_count,
        .hbVar1 = stuffed_rabbit_invul_dur,
    });
    trig.hotbarUsed(&.{.hb_selfcast});
    cond.eval(s.cooldown, .@">", 0);
    qpat.hb_square_add_var(.{ .varIndex = 0, .amount = 1 });
    cond.hb_check_square_var(.{ 0, stuffed_rabbit_activate_count });
    qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 0 });
    qpat.hb_flash_item(.{});
    ttrg.player_self(.{});
    apat.apply_invuln(.{ .duration = stuffed_rabbit_invul_dur });

    item(.{
        .id = "it_transfigured_nightingale_gown",
        .name = .{
            .english = "Transfigured Nightingale Gown",
        },
        .description = .{
            .english = "Every [CD] seconds, [OMEGACHARGE] your Secondary and Defensive.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .purple,
        .lootHbDispType = .cooldown,
        .hbInput = .auto,

        .cooldownType = .time,
        .cooldown = 15 * std.time.ms_per_s,

        .chargeType = .omegacharge,
    });
    trig.hotbarUsed(&.{.hb_self});
    qpat.hb_run_cooldown(.{});
    qpat.hb_flash_item(.{});

    for ([_]WeaponType{ .secondary, .defensive }) |weapon_type| {
        trig.hotbarUsed2(&.{.hb_self});
        ttrg.hotbarslots_self_weapontype(.{weapon_type});
        cond.hb_check_chargeable0(.{});
        cond.eval(ths0.strengthMult, .@">", 0);
        qpat.hb_charge(.{ .type = .omegacharge });
    }

    trig.autoStart(&.{.hb_auto_pl});
    qpat.hb_run_cooldown(.{});
}

fn transfiguredTimespaceSet() !void {
    const color = rgb(0x6e, 0x56, 0xe8);
    rns.start(.{
        .name = "Transfigured Timespace Set",
        .image_path = "images/timespace.png",
        .thumbnail_path = "images/timespace_thumbnail.png",
    });
    defer rns.end();

    item(.{
        .id = "it_transfigured_eternity_flute",
        .name = .{
            .english = "Transfigured Eternity Flute",
        },
        .description = .{
            .english = "Every [CD], grant [BERSERK] to all allies.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .purple,

        .lootHbDispType = .cooldown,
        .cooldownType = .time,
        .cooldown = 20 * std.time.ms_per_s,
        .hbInput = .auto,

        .hbsType = Hbs.berserk,
        .hbsLength = 5 * std.time.ms_per_s,
    });
    trig.autoStart(&.{.hb_auto_pl});
    qpat.hb_run_cooldown(.{});

    trig.hotbarUsed(&.{.hb_self});
    qpat.hb_run_cooldown(.{});
    ttrg.players_ally(.{});
    tset.hbs_def(.{});
    apat.apply_hbs(.{});

    const timewarp_wand_gcd_shorting = -0.1 * std.time.ms_per_s;
    item(.{
        .id = "it_transfigured_timewarp_wand",
        .name = .{
            .english = "Transfigured Timewarp Wand",
        },
        .description = .{
            .english = "Your GCDs are [VAR0_SECONDS] shorter.#" ++
                "When you have [HASTE-0] this value is doubled.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .purple,

        .showSqVar = true,
        .autoOffSqVar0 = 0,

        .hbVar0 = @abs(timewarp_wand_gcd_shorting),
    });
    trig.cdCalc5(&.{});
    for (WeaponType.abilities_with_gcd) |weapontype| {
        ttrg.hotbarslots_self_weapontype(.{weapontype});
        qpat.hb_add_gcd_permanent(.{ .amount = timewarp_wand_gcd_shorting });
    }
    ttrg.hbstatus_target(.{});
    ttrg.hbstatus_prune(thbss.statusId, .@">=", @intFromEnum(Hbs.haste_0));
    ttrg.hbstatus_prune(thbss.statusId, .@"<=", @intFromEnum(Hbs.haste_2));
    tset.uservar_hbscount(.{"u_hastes"});
    cond.unequal(.{ "u_hastes", 0 });
    for (WeaponType.abilities_with_gcd) |weapontype| {
        ttrg.hotbarslots_self_weapontype(.{weapontype});
        qpat.hb_add_gcd_permanent(.{ .amount = timewarp_wand_gcd_shorting });
    }

    item(.{
        .id = "it_transfigured_chrome_shield",
        .name = .{
            .english = "Transfigured Chrome Shield",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .purple,
    });

    item(.{
        .id = "it_transfigured_clockwork_tome",
        .name = .{
            .english = "Transfigured Clockwork Tome",
        },
        .description = .{
            .english = "Your abilities have a [LUCK] chance of giving a random haste buff.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .purple,

        .procChance = 0.1,

        .hbsLength = 5 * std.time.ms_per_s,
        .hbsType = .haste_0,
    });
    trig.autoStart(&.{.hb_auto_pl});
    qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 3 });

    for ([_]rns.Condition{ .hb_primary, .hb_secondary, .hb_special, .hb_defensive }) |c| {
        trig.hotbarUsed(&.{c});
        cond.random_def(.{});
        tset.uservar_random_range(.{ "u_haste", 0, 3 });
        // `uservar_random_range` generates a float, I just want an int between 0 and 2
        // TODO: Figure out a better way
        cond.eval("u_haste", .@"<=", 3);
        qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 2 });
        cond.eval("u_haste", .@"<=", 2);
        qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 1 });
        cond.eval("u_haste", .@"<=", 1);
        qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 0 });
    }

    for ([_]Hbs{ .haste_0, .haste_1, .haste_2 }, 0..) |hbs, i| {
        trig.hotbarUsed2(&.{.hb_selfcast});
        cond.hb_check_square_var(.{ 0, i });
        qpat.hb_flash_item(.{});
        qpat.hb_lucky_proc(.{});
        tset.hbskey(.{ hbs, r.hbsLength });
        apat.apply_hbs(.{});
    }

    trig.hotbarUsed3(&.{.hb_selfcast});
    qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 3 });

    const metronome_boots_hbs_len = 5 * std.time.ms_per_s;
    item(.{
        .id = "it_transfigured_metronome_boots",
        .name = .{
            .english = "Transfigured Metronome Boots",
        },
        .description = .{
            .english = "Every [CD], switch between having [HASTE-2] and [SMITE-3].",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .purple,

        .lootHbDispType = .cooldown,
        .cooldownType = .time,
        .cooldown = metronome_boots_hbs_len,
        .hbInput = .auto,

        // Vanilla Redwhite Ribbon doesn't work if an items `hbsType` is not a buff
        .hbFlags = .{ .hidehbs = true },
        .hbsType = .haste_2,
        .hbsLength = metronome_boots_hbs_len,
        .hbVar0 = metronome_boots_hbs_len,
    });
    trig.autoStart(&.{.hb_auto_pl});
    qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 0 });

    trig.hotbarUsed(&.{.hb_self});
    cond.hb_check_square_var(.{ 0, 0 });
    ttrg.player_self(.{});
    tset.hbskey(.{ Hbs.haste_2, r.hbsLength });
    apat.apply_hbs(.{});

    trig.hotbarUsed(&.{.hb_self});
    cond.hb_check_square_var(.{ 0, 1 });
    ttrg.player_self(.{});
    tset.hbskey(.{ Hbs.smite_3, r.hbsLength });
    apat.apply_hbs(.{});

    trig.hotbarUsed2(&.{.hb_self});
    qpat.hb_square_add_var(.{ .varIndex = 0, .amount = 1 });
    qpat.hb_run_cooldown(.{});
    qpat.hb_flash_item(.{});
    cond.hb_check_square_var(.{ 0, 2 });
    qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 0 });

    const timemage_cap_cd_set = 15 * std.time.ms_per_s;
    item(.{
        .id = "it_transfigured_timemage_cap",
        .name = .{
            .english = "Transfigured Timemage Cap",
        },
        .description = .{
            .english = "Cooldowns greater than [VAR0_SECONDS] become [VAR0_SECONDS].",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .purple,

        .hbVar0 = timemage_cap_cd_set,
    });
    trig.cdCalc5(&.{});
    ttrg.hotbarslots_current_players(.{});
    ttrg.hotbarslots_prune(thss.cooldown, .@">", timemage_cap_cd_set);
    qpat.hb_set_cooldown_permanent(.{ .time = timemage_cap_cd_set });

    const starry_cloak_cd_threshold = 15 * std.time.ms_per_s;
    item(.{
        .id = "it_transfigured_starry_cloak",
        .name = .{
            .english = "Transfigured Starry Cloak",
        },
        .description = .{
            .english = "When an ability or loot with a cooldown greater than or equal to " ++
                "[VAR0_SECONDS] is activated, gain [HASTE-2].",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .purple,

        .hbsLength = 5 * std.time.ms_per_s,
        .hbsType = .haste_2,

        .hbVar0 = starry_cloak_cd_threshold,
    });
    trig.hotbarUsed(&.{.hb_selfcast});
    cond.eval(s.cooldown, .@">=", starry_cloak_cd_threshold);
    ttrg.player_self(.{});
    tset.hbs_def(.{});
    apat.apply_hbs(.{});

    trig.hbsCreated(&.{.hbs_thishbcast});
    qpat.hb_flash_item(.{});

    item(.{
        .id = "it_transfigured_gemini_necklace",
        .name = .{
            .english = "Transfigured Gemini Necklace",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .purple,
    });
}

fn transfiguredWindSet() !void {
    const color = rgb(0x56, 0xe6, 0xd1);
    rns.start(.{
        .name = "Transfigured Wind Set",
        .image_path = "images/wind.png",
        .thumbnail_path = "images/wind_thumbnail.png",
    });
    defer rns.end();

    const hawkfeather_fan_cd_reduction = -1 * std.time.ms_per_s;
    item(.{
        .id = "it_transfigured_hawkfeather_fan",
        .name = .{
            .english = "Transfigured Hawkfeather Fan",
        },
        .description = .{
            .english = "All of your cooldowns are reduced by [VAR0_SECONDS].",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .blue,

        .hbVar0 = @abs(hawkfeather_fan_cd_reduction),
    });
    trig.cdCalc2b(&.{});
    ttrg.player_self(.{});
    ttrg.hotbarslots_current_players(.{});
    ttrg.hotbarslots_prune(thss.cooldown, .@">", 0);
    qpat.hb_add_cooldown_permanent(.{ .amount = hawkfeather_fan_cd_reduction });

    item(.{
        .id = "it_transfigured_windbite_dagger",
        .name = .{
            .english = "Transfigured Windbite Dagger",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .blue,
    });

    const pidgeon_bow_num_proj = 3;
    item(.{
        .id = "it_transfigured_pidgeon_bow",
        .name = .{
            .english = "Transfigured Pidgeon Bow",
        },
        .description = .{
            .english = "Every [CD], fires [VAR0] projectiles at your targeted enemy that deals " ++
                "[STR] damage.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .blue,

        .lootHbDispType = .cooldown,
        .cooldownType = .time,
        .cooldown = 3 * std.time.ms_per_s,
        .hbInput = .auto,

        .delay = 250,
        .radius = 1800,
        .strMult = 20,

        .hbVar0 = pidgeon_bow_num_proj,
        .hitNumber = pidgeon_bow_num_proj,
    });
    trig.autoStart(&.{.hb_auto_pl});
    qpat.hb_run_cooldown(.{});

    trig.hotbarUsed(&.{.hb_self});
    qpat.hb_run_cooldown(.{});
    qpat.hb_flash_item(.{});
    ttrg.players_opponent(.{});
    tset.strength_def(.{});
    apat.floral_bow(.{});

    item(.{
        .id = "it_transfigured_shinsoku_katana",
        .name = .{
            .english = "Transfigured Shinsoku Katana",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .blue,
    });

    const eaglewing_charm_extra_dmg = 5;
    item(.{
        .id = "it_transfigured_eaglewing_charm",
        .name = .{
            .english = "Transfigured Eaglewing Charm",
        },
        .description = .{
            .english = "All your abilities deal [VAR0] more damage for every defensive used " ++
                "this battle. Slightly increases movement speed.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .blue,

        .charspeed = charspeed.slightly,

        .showSqVar = true,
        .hbVar0 = eaglewing_charm_extra_dmg,
    });
    trig.battleStart0(&.{});
    qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 0 });

    trig.hotbarUsedProc(&.{.hb_defensive});
    qpat.hb_square_add_var(.{ .varIndex = 0, .amount = 1 });
    qpat.hb_reset_statchange(.{});

    trig.strCalc2(&.{});
    ttrg.hotbarslots_current_players(.{});
    ttrg.hotbarslots_prune_base_has_str(.{});
    ttrg.hotbarslots_prune(thss.weaponType, .@"!=", WeaponType.loot);
    ttrg.hotbarslots_prune(thss.weaponType, .@"!=", WeaponType.potion);
    tset.uservar2("u_str", r.sqVar0, .@"*", eaglewing_charm_extra_dmg);
    qpat.hb_add_strength(.{ .amountStr = "u_str" });

    const sparrow_feather_dmg = 5;
    const sparrow_feather_dmg_inc = 5;
    item(.{
        .id = "it_transfigured_sparrow_feather",
        .name = .{
            .english = "Transfigured Sparrow Feather",
        },
        .description = .{
            .english = "Deals [VAR0] damage to all enemies when you use your Primary.#" ++
                "When you use your Secondary, this damage is increased by [VAR1] until the end " ++
                "of the fight.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .blue,

        .showSqVar = true,

        .hbVar0 = sparrow_feather_dmg,
        .hbVar1 = sparrow_feather_dmg_inc,
        .strMult = sparrow_feather_dmg,
        .delay = 150,
    });
    trig.battleStart0(&.{});
    qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 0 });

    trig.hotbarUsedProc(&.{.hb_primary});
    tset.uservar2("u_str", r.sqVar0, .@"*", sparrow_feather_dmg_inc);
    tset.uservar2("u_str", "u_str", .@"+", sparrow_feather_dmg);
    qpat.hb_flash_item(.{});
    ttrg.players_opponent(.{});
    tset.strength_def(.{});
    tset.strength(.{"u_str"});
    apat.crown_of_storms(.{});

    trig.hotbarUsedProc(&.{.hb_secondary});
    qpat.hb_square_add_var(.{ .varIndex = 0, .amount = 1 });

    item(.{
        .id = "it_transfigured_winged_cap",
        .name = .{
            .english = "Transfigured Winged Cap",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .blue,
    });

    item(.{
        .id = "it_transfigured_thiefs_coat",
        .name = .{
            .english = "Transfigured Thief's Coat",
        },
        .description = .{
            .english = "Using your Defensive will grant you [VANISH].",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .blue,

        .hbsType = .vanish,
        .hbsLength = 3 * std.time.ms_per_s,
    });
    trig.hotbarUsedProc(&.{.hb_defensive});
    qpat.hb_flash_item(.{});
    tset.hbs_def(.{});
    apat.apply_hbs(.{});
}

fn transfiguredBloodwolfSet() !void {
    const color = rgb(0x25, 0x3d, 0xb0);
    rns.start(.{
        .name = "Transfigured Bloodwolf Set",
        .image_path = "images/bloodwolf.png",
        .thumbnail_path = "images/bloodwolf_thumbnail.png",
    });
    defer rns.end();

    item(.{
        .id = "it_transfigured_vampiric_dagger",
        .name = .{
            .english = "Transfigured Vampiric Dagger",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .blue,
    });

    item(.{
        .id = "it_transfigured_bloody_bandage",
        .name = .{
            .english = "Transfigured Bloody Bandage",
        },
        .description = .{
            .english = "When you used your Defensive, apply [BLEED-1] and [SAP] to enemies " ++
                "facing away from you.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .blue,

        .hbsStrMult = 20,
        .hbsType = .bleed_1,
        .hbsLength = 10 * std.time.ms_per_s,
    });
    trig.hotbarUsedProc(&.{.hb_defensive});
    qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 1 });
    ttrg.players_opponent_backstab(.{});
    tset.hbs_def(.{});
    tset.hbskey(.{ Hbs.bleed_1, r.hbsLength });
    apat.poisonfrog_charm(.{});
    tset.hbs_def(.{});
    tset.hbskey(.{ Hbs.sap, r.hbsLength });
    apat.poisonfrog_charm(.{});

    trig.hbsCreated(&.{.hbs_thishbcast});
    // To avoid flashing for every debuff applied, instead keep track of if the defensive has been
    // used. If so, flash once, and set the damage flag to 0, so we don't flash again.
    cond.hb_check_square_var(.{ 0, 1 });
    qpat.hb_flash_item(.{});
    qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 0 });

    item(.{
        .id = "it_transfigured_leech_staff",
        .name = .{
            .english = "Transfigured Leech Staff",
        },
        .description = .{
            .english = "When a % chance succeeds, inflict [BLEED-3] to a random enemy.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .blue,

        .hbsStrMult = 20,
        .hbsType = .bleed_3,
        .hbsLength = 5 * std.time.ms_per_s,
    });
    trig.luckyProc(&.{});
    qpat.hb_flash_item(.{});
    ttrg.players_opponent_random(.{});
    tset.hbs_def(.{});
    apat.poisonfrog_charm(.{});

    item(.{
        .id = "it_transfigured_bloodhound_greatsword",
        .name = .{
            .english = "Transfigured Bloodhound Greatsword",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .blue,
    });

    item(.{
        .id = "it_transfigured_reaper_cloak",
        .name = .{
            .english = "Transfigured Reaper Cloak",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .blue,
    });

    const bloodflower_brooch_hits = 3;
    item(.{
        .id = "it_transfigured_bloodflower_brooch",
        .name = .{
            .english = "Transfigured Bloodflower Brooch",
        },
        .description = .{
            .english = "Every [CD], apply [BLEED-1] to all enemies. Deal [STR] damage " ++
                "[VAR0_TIMES] to enemies you inflict with bleed.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .blue,

        .lootHbDispType = .cooldown,
        .cooldownType = .time,
        .cooldown = 15 * std.time.ms_per_s,
        .hbInput = .auto,

        .hbsStrMult = 20,
        .hbsType = .bleed_1,
        .hbsLength = 5 * std.time.ms_per_s,

        .hbVar0 = bloodflower_brooch_hits,
        .hitNumber = bloodflower_brooch_hits,
        .radius = 2000,
        .strMult = 40,
    });
    trig.autoStart(&.{.hb_auto_pl});
    qpat.hb_run_cooldown(.{});

    trig.hotbarUsed(&.{.hb_self});
    qpat.hb_run_cooldown(.{});
    qpat.hb_flash_item(.{});
    ttrg.players_opponent(.{});
    tset.hbs_def(.{});
    apat.poisonfrog_charm(.{});

    trig.hbsCreated(&.{.hbs_selfcast});
    cond.eval(s.statusId, .@">=", @intFromEnum(Hbs.bleed_0));
    cond.eval(s.statusId, .@"<=", @intFromEnum(Hbs.bleed_3));
    qpat.hb_flash_item(.{});
    ttrg.player_afflicted_source(.{});
    tset.strength_def(.{});
    apat.melee_hit(.{});

    item(.{
        .id = "it_transfigured_wolf_hood",
        .name = .{
            .english = "Transfigured Wolf Hood",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .blue,
    });

    item(.{
        .id = "it_transfigured_blood_vial",
        .name = .{
            .english = "Transfigured Blood Vial",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .blue,
    });
}

fn transfiguredAssasinSet() !void {
    const color = rgb(0x36, 0x50, 0xcf);
    rns.start(.{
        .name = "Transfigured Assasin Set",
        .image_path = "images/assasin.png",
        .thumbnail_path = "images/assasin_thumbnail.png",
    });
    defer rns.end();

    item(.{
        .id = "it_transfigured_black_wakizashi",
        .name = .{
            .english = "Transfigured Black Wakizashi",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .blue,
    });

    item(.{
        .id = "it_transfigured_throwing_dagger",
        .name = .{
            .english = "Transfigured Throwing Dagger",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .blue,
    });

    item(.{
        .id = "it_transfigured_assassins_knife",
        .name = .{
            .english = "Transfigured Assassin's Knife",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .blue,
    });

    const ninjutsu_scroll_max_hits = 9;
    const ninjutsu_scroll_proc_chance = 0.5;
    item(.{
        .id = "it_transfigured_ninjutsu_scroll",
        .name = .{
            .english = "Transfigured Ninjutsu Scroll",
        },
        .description = .{
            .english = "Your Special can deal up to [VAR0] additional blows, dealing [STR] " ++
                "damage each, in a radius around your target enemy.#" ++
                "Starting at [LUCK], each extra blow is [VAR1_PERCENT] less likely to happen " ++
                "as the previous.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .blue,

        .strMult = 130,
        .radius = 350,
        .delay = 125,
        .procChance = ninjutsu_scroll_proc_chance,
        .hbVar0 = ninjutsu_scroll_max_hits,
        .hbVar1 = 1.0 - ninjutsu_scroll_proc_chance,
    });
    trig.hotbarUsedProc(&.{.hb_special});
    qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 0 });

    for (0..ninjutsu_scroll_max_hits) |_| {
        cond.random_def(.{});
        qpat.hb_square_add_var(.{ .varIndex = 0, .amount = 1 });
    }

    trig.hotbarUsed2(&.{.hb_special});
    cond.hb_check_square_var_gte(.{ 0, 1 });
    qpat.hb_flash_item(.{});
    qpat.hb_lucky_proc(.{});
    ttrg.players_opponent(.{});
    tset.strength_def(.{});
    apat.black_wakizashi(.{ .numberR = .sqVar0 });

    item(.{
        .id = "it_transfigured_shadow_bracelet",
        .name = .{
            .english = "Transfigured Shadow Bracelet",
        },
        .description = .{
            .english = "Abilities and loot that hit more than twice hits and additional time.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .blue,
    });
    trig.strCalc2(&.{});
    ttrg.hotbarslots_current_players(.{});
    ttrg.hotbarslots_prune(thss.number, .@">", 2);
    qpat.hb_add_hitbox_var(.{
        .hitboxVar = .number,
        .amount = 1,
    });

    item(.{
        .id = "it_transfigured_ninja_robe",
        .name = .{
            .english = "Transfigured Ninja Robe",
        },
        .description = .{
            .english = "Your abilities have a [LUCK] chance of giving you [VANISH].",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .blue,

        .procChance = 0.2,

        .hbsType = .vanish,
        .hbsLength = 5 * std.time.ms_per_s,
    });
    for ([_]rns.Condition{ .hb_primary, .hb_secondary, .hb_special, .hb_defensive }) |c| {
        trig.hotbarUsed(&.{c});
        cond.random_def(.{});
        qpat.hb_flash_item(.{});
        qpat.hb_lucky_proc(.{});
        tset.hbs_def(.{});
        apat.apply_hbs(.{});
    }

    item(.{
        .id = "it_transfigured_kunoichi_hood",
        .name = .{
            .english = "Transfigured Kunoichi Hood",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .blue,
    });

    item(.{
        .id = "it_transfigured_shinobi_tabi",
        .name = .{
            .english = "Transfigured Shinobi Tabi",
        },
        .description = .{
            .english = "Standing still will cause you to [VANISH] for 2s. " ++
                "Available every [CD]. Slightly increases movement speed.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .blue,

        .lootHbDispType = .cooldown,
        .cooldownType = .time,
        .cooldown = 4 * std.time.ms_per_s,

        .hbsType = .vanish,
        .hbsLength = 2 * std.time.ms_per_s,

        .charspeed = charspeed.slightly,
    });
    trig.autoStart(&.{.hb_auto_pl});
    qpat.hb_run_cooldown(.{});

    trig.standingStill(&.{.pl_self});
    cond.hb_available(.{});
    qpat.hb_run_cooldown(.{});
    qpat.hb_flash_item(.{});
    qpat.hb_cdloot_proc(.{});
    tset.hbs_def(.{});
    apat.thiefs_coat(.{});
}

fn transfiguredRockdragonSet() !void {
    const color = rgb(0xb9, 0x3b, 0x4f);
    rns.start(.{
        .name = "Transfigured Rockdragon Set",
        .image_path = "images/rockdragon.png",
        .thumbnail_path = "images/rockdragon_thumbnail.png",
    });
    defer rns.end();

    item(.{
        .id = "it_transfigured_dragonhead_spear",
        .name = .{
            .english = "Transfigured Dragonhead Spear",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .red,
    });

    item(.{
        .id = "it_transfigured_granite_greatsword",
        .name = .{
            .english = "Transfigured Granite Greatsword",
        },
        .description = .{
            .english = "Every [CD], slices a HUGE radius around you dealing [STR] damage.#" ++
                "Moving a rabbitleap puts the item on cooldown.#" ++
                "Also slightly reduces movement speed.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .red,

        .lootHbDispType = .cooldown,
        .cooldownType = .time,
        .cooldown = 4 * std.time.ms_per_s,
        .hbInput = .auto,

        .strMult = 700,
        .radius = 600,
        .charspeed = -charspeed.slightly,
    });
    trig.autoStart(&.{.hb_auto_pl});
    qpat.hb_run_cooldown(.{});

    trig.distanceTick(&.{.pl_self});
    qpat.hb_run_cooldown(.{});

    trig.hotbarUsed(&.{.hb_self});
    qpat.hb_run_cooldown(.{});
    qpat.hb_flash_item(.{});
    ttrg.players_opponent(.{});
    tset.strength_def(.{});
    apat.darkmagic_blade(.{});

    const greysteel_shield_aoe = 1;
    const greysteel_shield_cd_reduction = -1 * std.time.ms_per_s;
    item(.{
        .id = "it_transfigured_greysteel_shield",
        .name = .{
            .english = "Transfigured Greysteel Shield",
        },
        .description = .{
            .english = "Your Defensive has a [VAR0_PERCENT] larger radius and a [VAR1_SECOND] " ++
                "shorter cooldown.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .red,

        .hbVar0 = greysteel_shield_aoe,
        .hbVar1 = @abs(greysteel_shield_cd_reduction),
    });
    trig.strCalc2(&.{});
    ttrg.hotbarslots_self_weapontype(.{WeaponType.defensive});
    qpat.hb_mult_hitbox_var(.{
        .hitboxVar = .radius,
        .mult = 1 + greysteel_shield_aoe,
    });

    trig.cdCalc2b(&.{});
    ttrg.hotbarslots_self_weapontype(.{WeaponType.defensive});
    qpat.hb_add_cooldown_permanent(.{ .amount = greysteel_shield_cd_reduction });

    item(.{
        .id = "it_transfigured_stonebreaker_staff",
        .name = .{
            .english = "Transfigured Stonebreaker Staff",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .red,
    });

    item(.{
        .id = "it_transfigured_tough_gauntlet",
        .name = .{
            .english = "Transfigured Tough Gauntlet",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .red,
    });

    const rockdragon_mail_every_nth_hit = 2;
    item(.{
        .id = "it_transfigured_rockdragon_mail",
        .name = .{
            .english = "Transfigured Rockdragon Mail",
        },
        .description = .{
            .english = "Shields you from every other hit.#" ++
                "Your movement speed is slightly reduced.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .red,

        .showSqVar = true,
        .charspeed = -charspeed.slightly,
        .hbsFlag = .{ .shield = true },
    });
    trig.onSquarePickup(&.{.square_self});
    qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 0 });

    trig.hbsShield0(&.{.pl_self});
    qpat.hb_square_add_var(.{ .varIndex = 0, .amount = 1 });
    cond.hb_check_square_var(.{ 0, rockdragon_mail_every_nth_hit });
    qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 0 });
    qpat.hb_flash_item(.{});
    qpat.player_shield(.{});
    ttrg.player_self(.{});
    apat.apply_invuln(.{});

    item(.{
        .id = "it_transfigured_obsidian_hairpin",
        .name = .{
            .english = "Transfigured Obsidian Hairpin",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .red,
    });

    item(.{
        .id = "it_transfigured_iron_greaves",
        .name = .{
            .english = "Transfigured Iron Greaves",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .red,
    });
}

fn transfiguredFlameSet() !void {
    const color = rgb(0xe2, 0x34, 0x34);
    rns.start(.{
        .name = "Transfigured Flame Set",
        .image_path = "images/flame.png",
        .thumbnail_path = "images/flame_thumbnail.png",
    });
    defer rns.end();

    item(.{
        .id = "it_transfigured_volcano_spear",
        .name = .{
            .english = "Transfigured Volcano Spear",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .red,
    });

    item(.{
        .id = "it_transfigured_reddragon_blade",
        .name = .{
            .english = "Transfigured Reddragon Blade",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .red,
    });

    item(.{
        .id = "it_transfigured_flame_bow",
        .name = .{
            .english = "Transfigured Flame Bow",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .red,
    });

    const meteor_staff_cd = 10 * std.time.ms_per_s;
    item(.{
        .id = "it_transfigured_meteor_staff",
        .name = .{
            .english = "Transfigured Meteor Staff",
        },
        .description = .{
            .english = "Every [VAR0_SECONDS], your next large hit inflict [BURN-3].",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .red,

        .cooldownType = .time,
        .cooldown = meteor_staff_cd,
        .hbVar0 = meteor_staff_cd,

        .delay = 250,
        .hbsType = .burn_3,
        .hbsLength = 5 * std.time.ms_per_s,
    });
    trig.onDamageDone(&.{.dmg_islarge});
    cond.hb_available(.{});
    qpat.hb_run_cooldown(.{});
    ttrg.player_damaged(.{});
    tset.hbs_def(.{});
    tset.hbs_burnhit(.{});
    apat.apply_hbs(.{});
    qpat.hb_cdloot_proc(.{});

    trig.hbsCreated(&.{.hbs_thishbcast});
    qpat.hb_flash_item(.{});

    const phoenix_charm_hp = 1;
    const phoenix_charm_chance = 0.5;
    item(.{
        .id = "it_transfigured_phoenix_charm",
        .name = .{
            .english = "Transfigured Phoenix Charm",
        },
        .description = .{
            .english = "Has a [LUCK] chance to shield you from damage when you are at [VAR0] HP.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .red,

        .hbsFlag = .{ .shield = true },

        .procChance = phoenix_charm_chance,
        .hbVar0 = phoenix_charm_hp,
    });
    trig.hbsShield5(&.{.pl_self});
    cond.eval(s.hp, .@"==", 1);
    cond.random_def(.{});
    ttrg.player_self(.{});
    apat.apply_invuln(.{});
    qpat.player_shield(.{});
    qpat.hb_flash_item(.{ .message = .shield });

    item(.{
        .id = "it_transfigured_firescale_corset",
        .name = .{
            .english = "Transfigured Firescale Corset",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .red,
    });

    item(.{
        .id = "it_transfigured_demon_horns",
        .name = .{
            .english = "Transfigured Demon Horns",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .red,
    });

    item(.{
        .id = "it_transfigured_flamewalker_boots",
        .name = .{
            .english = "Transfigured Flamewalker Boots",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .red,
    });
}

fn transfiguredGemSet() !void {
    const color = rgb(0xda, 0x57, 0x8a);
    rns.start(.{
        .name = "Transfigured Gem Set",
        .image_path = "images/gem.png",
        .thumbnail_path = "images/gem_thumbnail.png",
    });
    defer rns.end();

    item(.{
        .id = "it_transfigured_diamond_shield",
        .name = .{
            .english = "Transfigured Diamond Shield",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .red,
    });

    item(.{
        .id = "it_transfigured_peridot_rapier",
        .name = .{
            .english = "Transfigured Peridot Rapier",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .red,
    });

    const garnet_staff_dmg_per_erase = 0.05;
    item(.{
        .id = "it_transfigured_garnet_staff",
        .name = .{
            .english = "Transfigured Garnet Staff",
        },
        .description = .{
            .english = "When an ability or loot effect erases projectiles in a radius around " ++
                "you, you deal [VAR0_PERCENT] more damage. Resets at the start of each battle.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .red,

        .showSqVar = true,
        .autoOffSqVar0 = 0,

        .hbVar0 = garnet_staff_dmg_per_erase,
    });
    trig.onEraseDone(&.{.pl_self});
    qpat.hb_square_add_var(.{ .varIndex = 0, .amount = 1 });
    qpat.hb_reset_statchange(.{});

    trig.strCalc0(&.{});
    tset.uservar2("u_mult", r.sqVar0, .@"*", garnet_staff_dmg_per_erase);
    qpat.hb_reset_statchange_norefresh(.{});
    qpat.hb_add_statchange_norefresh(.{ .stat = .allMult, .amountStr = "u_mult" });

    const sapphire_violin_num_buffs = 3;
    item(.{
        .id = "it_transfigured_sapphire_violin",
        .name = .{
            .english = "Transfigured Sapphire Violin",
        },
        .description = .{
            .english = "Every [CD] seconds, grant [VAR0] random buffs to all allies for " ++
                "[HBSL]. Breaks if you take damage. Starts the battle on cooldown.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .red,
        .lootHbDispType = .cooldownVarAm,
        .hbInput = .auto,

        // Vanilla Redwhite Ribbon doesn't work if an items `hbsType` is not a buff
        .hbsType = .smite_0,
        .hbsLength = 5 * std.time.ms_per_s,

        .cooldownType = .time,
        .cooldown = 15 * std.time.ms_per_s,

        .hbVar0 = sapphire_violin_num_buffs,
        .greySqVar0 = true,
        .hbFlags = .{
            .var0req = true,
            .hidehbs = true,
        },
    });
    trig.onSquarePickup(&.{.square_self});
    qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 1 });

    trig.onDamage(&.{.pl_self});
    cond.hb_check_square_var_false(.{ 0, 0 });
    qpat.hb_square_add_var(.{ .varIndex = 0, .amount = -1 });
    qpat.hb_reset_statchange(.{});
    qpat.hb_flash_item(.{ .message = .broken });
    qpat.hb_reset_cooldown(.{});

    trig.hotbarUsed(&.{.hb_self});
    cond.hb_check_square_var_false(.{ 0, 0 });
    qpat.hb_run_cooldown(.{});
    qpat.hb_flash_item(.{});
    ttrg.players_ally(.{});
    for (0..sapphire_violin_num_buffs) |_| {
        tset.hbs_randombuff(.{});
        apat.ornamental_bell(.{});
    }

    trig.strCalc0(&.{});
    cond.hb_check_square_var_lte(.{ 0, 0 });
    qpat.hb_set_cooldown_permanent(.{ .time = 0 });

    trig.autoStart(&.{.hb_auto_pl});
    cond.hb_check_square_var_false(.{ 0, 0 });
    qpat.hb_run_cooldown(.{});

    item(.{
        .id = "it_transfigured_emerald_chestplate",
        .name = .{
            .english = "Transfigured Emerald Chestplate",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .red,
    });

    item(.{
        .id = "it_transfigured_amethyst_bracelet",
        .name = .{
            .english = "Transfigured Amethyst Bracelet",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .red,
    });

    item(.{
        .id = "it_transfigured_topaz_charm",
        .name = .{
            .english = "Transfigured Topaz Charm",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .red,
    });

    const ruby_circlet_start = 5;
    const ruby_circlet_stop = 0;
    const ruby_circlet_dmg_per_stock = 0.09;
    item(.{
        .id = "it_transfigured_ruby_circlet",
        .name = .{
            .english = "Transfigured Ruby Circlet",
        },
        .description = .{
            .english = "You deal [VAR0_PERCENT] more damage.#" ++
                "When you take damage, permanently reduce this value by [VAR1_PERCENT] " ++
                "(minimum [VAR2_PERCENT]).",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .red,

        .showSqVar = true,

        .hbVar0 = ruby_circlet_start * ruby_circlet_dmg_per_stock,
        .hbVar1 = ruby_circlet_dmg_per_stock,
        .hbVar2 = ruby_circlet_stop * ruby_circlet_dmg_per_stock,
    });
    trig.onSquarePickup(&.{.square_self});
    qpat.hb_square_set_var(.{ .varIndex = 0, .amount = ruby_circlet_start });

    trig.onDamage(&.{.pl_self});
    cond.hb_check_square_var_false(.{ 0, ruby_circlet_stop });
    qpat.hb_square_add_var(.{ .varIndex = 0, .amount = -1 });
    qpat.hb_reset_statchange(.{});
    qpat.hb_flash_item(.{ .message = .broken });

    trig.strCalc0(&.{});
    qpat.hb_reset_statchange_norefresh(.{});
    tset.uservar2("u_mult", r.sqVar0, .@"*", ruby_circlet_dmg_per_stock);
    qpat.hb_add_statchange_norefresh(.{
        .stat = .allMult,
        .amountStr = "u_mult",
    });
}

fn transfiguredLightningSet() !void {
    const color = rgb(0xe8, 0xe1, 0xa7);
    rns.start(.{
        .name = "Transfigured Lightning Set",
        .image_path = "images/lightning.png",
        .thumbnail_path = "images/lightning_thumbnail.png",
    });
    defer rns.end();

    const brightstorm_spear_proc_chance = 0.1;
    const brightstorm_spear_strength = 200;
    item(.{
        .id = "it_transfigured_brightstorm_spear",
        .name = .{
            .english = "Transfigured Brightstorm Spear",
        },
        .description = .{
            .english = "Has a [LUCK] chance of dealing [STR] damage to all enemies when your " ++
                "other loot does damage.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .yellow,

        .procChance = brightstorm_spear_proc_chance,
        .strMult = brightstorm_spear_strength,
    });
    trig.onDamageDone(&.{.pl_self});
    // 1,2,3,4 is the abilities. Negative ids are status effects
    cond.eval(s.originHbId, .@">", 4);
    cond.eval(s.originHbId, .@"!=", r.hbId);
    cond.random_def(.{});
    qpat.hb_lucky_proc(.{});
    qpat.hb_flash_item(.{});
    ttrg.players_opponent(.{});
    tset.strength_def(.{});
    apat.crown_of_storms(.{});

    item(.{
        .id = "it_transfigured_bolt_staff",
        .name = .{
            .english = "Transfigured Bolt Staff",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .yellow,
    });

    item(.{
        .id = "it_transfigured_lightning_bow",
        .name = .{
            .english = "Transfigured Lightning Bow",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .yellow,
    });

    item(.{
        .id = "it_transfigured_darkstorm_knife",
        .name = .{
            .english = "Transfigured Darkstorm Knife",
        },
        .description = .{
            .english = "Deals [STR] damage to all enemies when your abilities deal damage.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .yellow,

        .strMult = 15,
        .delay = 150,
    });
    for ([_]Condition{
        .dmg_self_primary,
        .dmg_self_secondary,
        .dmg_self_special,
        .dmg_self_defensive,
    }) |trigger| {
        trig.onDamageDone(&.{trigger});
        ttrg.players_opponent(.{});
        tset.strength_def(.{});
        apat.crown_of_storms(.{});
    }

    const darkcloud_necklace_ability_mult = -0.5;
    const darkcloud_necklace_loot_mult = 1.5;
    item(.{
        .id = "it_transfigured_darkcloud_necklace",
        .name = .{
            .english = "Transfigured Darkcloud Necklace",
        },
        .description = .{
            .english = "Damage from abilities is reduced by [VAR0_PERCENT].#" ++
                "Damage from loot is increased by [VAR1_PERCENT].",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .yellow,

        .hbVar0 = @abs(darkcloud_necklace_ability_mult),
        .primaryMult = darkcloud_necklace_ability_mult,
        .secondaryMult = darkcloud_necklace_ability_mult,
        .specialMult = darkcloud_necklace_ability_mult,
        .defensiveMult = darkcloud_necklace_ability_mult,

        .hbVar1 = darkcloud_necklace_loot_mult,
        .lootMult = darkcloud_necklace_loot_mult,
    });

    const crown_of_storms_mult = 0.25;
    item(.{
        .id = "it_transfigured_crown_of_storms",
        .name = .{
            .english = "Transfigured Crown of Storms",
        },
        .description = .{
            .english = "Your abilities and loot with a % chance deals [VAR0_PERCENT] more damage.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .yellow,

        .hbVar0 = crown_of_storms_mult,
    });
    trig.strCalc1c(&.{});
    ttrg.hotbarslots_current_players(.{});
    ttrg.hotbarslots_prune(thss.luck, .@">", 0);
    qpat.hb_add_strcalcbuff(.{ .amount = crown_of_storms_mult });

    item(.{
        .id = "it_transfigured_thunderclap_gloves",
        .name = .{
            .english = "Transfigured Thunderclap Gloves",
        },
        .description = .{
            .english = "Every [CD] have a [LUCK] chance of dealing [STR] damage to all enemies.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .yellow,

        .lootHbDispType = .cooldown,
        .cooldownType = .time,
        .cooldown = 3 * std.time.ms_per_s,
        .hbInput = .auto,

        .procChance = 0.3,
        .strMult = 300,
        .delay = 150,
    });
    trig.hotbarUsed(&.{.hb_self});
    qpat.hb_run_cooldown(.{});
    cond.random_def(.{});
    qpat.hb_flash_item(.{});
    qpat.hb_lucky_proc(.{});
    ttrg.players_opponent(.{});
    tset.strength_def(.{});
    apat.crown_of_storms(.{});

    item(.{
        .id = "it_transfigured_storm_petticoat",
        .name = .{
            .english = "Transfigured Storm Petticoat",
        },
        .description = .{
            .english = "Do [STR] damage to all enemies when you take damage.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .yellow,

        .strMult = 2000,
        .delay = 150,
    });
    trig.onDamage(&.{.pl_self});
    qpat.hb_flash_item(.{});
    ttrg.players_opponent(.{});
    tset.strength_def(.{});
    apat.crown_of_storms(.{});
}

fn transfiguredShrineSet() !void {
    const color = rgb(0xdb, 0x99, 0x85);
    rns.start(.{
        .name = "Transfigured Shrine Set",
        .image_path = "images/shrine.png",
        .thumbnail_path = "images/shrine_thumbnail.png",
    });
    defer rns.end();

    item(.{
        .id = "it_transfigured_holy_greatsword",
        .name = .{
            .english = "Transfigured Holy Greatsword",
        },
        .description = .{
            .english = "Every [CD], slice the air around you dealing [STR] damage.#" ++
                "Cooldown resets every time you gain a buff.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .yellow,

        .lootHbDispType = .cooldown,
        .cooldownType = .time,
        .cooldown = 10 * std.time.ms_per_s,
        .hbInput = .auto,

        .delay = 400,
        .radius = 400,
        .strMult = 300,
    });
    trig.autoStart(&.{.hb_auto_pl});
    qpat.hb_run_cooldown(.{});

    trig.hbsCreated(&.{.hbs_selfafl});
    cond.eval(s.isBuff, .@"==", 1);
    ttrg.hotbarslot_self(.{});
    qpat.hb_reset_cooldown(.{});

    trig.hotbarUsed(&.{.hb_self});
    qpat.hb_flash_item(.{});
    qpat.hb_run_cooldown(.{});
    ttrg.players_opponent(.{});
    tset.strength_def(.{});
    apat.darkmagic_blade(.{});

    const sacred_bow_mult_per_buff = 1;
    const sacred_bow_dmg = 250;
    item(.{
        .id = "it_transfigured_sacred_bow",
        .name = .{
            .english = "Transfigured Sacred Bow",
        },
        .description = .{
            .english = "Every [CD], fires a projectile at your targeted enemy that deals " ++
                "[STR] damage.#Deals [VAR0_PERCENT] more damage for each buff on you.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .yellow,

        .lootHbDispType = .cooldown,
        .cooldownType = .time,
        .cooldown = 10 * std.time.ms_per_s,
        .hbInput = .auto,

        .delay = 250,
        .radius = 1800,

        .strMult = sacred_bow_dmg,
        .hbVar0 = sacred_bow_mult_per_buff,
    });
    trig.autoStart(&.{.hb_auto_pl});
    qpat.hb_run_cooldown(.{});

    trig.hotbarUsed(&.{.hb_self});
    qpat.hb_run_cooldown(.{});
    qpat.hb_flash_item(.{});
    ttrg.player_self(.{});
    ttrg.hbstatus_target(.{});
    ttrg.hbstatus_prune(thbss.isBuff, .@"==", 1);
    tset.uservar_hbscount(.{"u_buffs"});
    tset.uservar2("u_allMult", "u_buffs", .@"*", sacred_bow_mult_per_buff);
    tset.uservar2("u_extraStr", "u_allMult", .@"*", sacred_bow_dmg);
    tset.uservar2("u_str", "u_extraStr", .@"+", sacred_bow_dmg);
    tset.strength_def(.{});
    tset.strength(.{"u_str"});
    ttrg.players_opponent(.{});
    apat.floral_bow(.{});

    item(.{
        .id = "it_transfigured_purification_rod",
        .name = .{
            .english = "Transfigured Purification Rod",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .yellow,
    });

    const ornamental_bell_fizz = 3;
    const ornamental_bell_buzz = 5;
    const ornamental_bell_fizzbuzz = 15;
    item(.{
        .id = "it_transfigured_ornamental_bell",
        .name = .{
            .english = "Transfigured Ornamental Bell",
        },
        .description = .{
            .english = "Every [VAR0_SECONDS], grants [SMITE-0] to all allies for [HBSL].#" ++
                "Every [VAR1_SECONDS], grants [ELEGY-0] to all allies for [HBSL].",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .yellow,
        .lootHbDispType = .cooldown,
        .hbInput = .auto,

        .cooldownType = .time,
        .cooldown = 1 * std.time.ms_per_s,

        .autoOffSqVar0 = 0,
        .showSqVar = true,

        // Vanilla Redwhite Ribbon doesn't work if an items `hbsType` is not a buff
        .hbFlags = .{ .hidehbs = true },
        .hbsType = .smite_0,
        .hbsLength = 2 * std.time.ms_per_s,

        .hbVar0 = ornamental_bell_fizz * std.time.ms_per_s,
        .hbVar1 = ornamental_bell_buzz * std.time.ms_per_s,
    });
    trig.hotbarUsed(&.{.hb_self});
    qpat.hb_square_add_var(.{ .varIndex = 0, .amount = 1 });
    qpat.hb_run_cooldown(.{});
    cond.hb_check_square_var(.{ 0, ornamental_bell_fizzbuzz });
    qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 0 });

    trig.hotbarUsed2(&.{.hb_self});
    for (0..ornamental_bell_fizzbuzz) |i| {
        if (i % ornamental_bell_fizz != 0)
            cond.hb_check_square_var_false(.{ 0, i });
    }
    qpat.hb_flash_item(.{});
    ttrg.players_ally(.{});
    tset.hbskey(.{ Hbs.smite_0, r.hbsLength });
    apat.ornamental_bell(.{});

    trig.hotbarUsed2(&.{.hb_self});
    for (0..ornamental_bell_fizzbuzz) |i| {
        if (i % ornamental_bell_buzz != 0)
            cond.hb_check_square_var_false(.{ 0, i });
    }
    qpat.hb_flash_item(.{});
    ttrg.players_ally(.{});
    tset.hbskey(.{ Hbs.elegy_0, r.hbsLength });
    apat.ornamental_bell(.{});

    const shrinemaidens_kosode_mult = 0.1;
    const shrinemaidens_kosode_mult_per_buff = 0.1;
    item(.{
        .id = "it_transfigured_shrinemaidens_kosode",
        .name = .{
            .english = "Transfigured Shrinemaiden's Kosode",
        },
        .description = .{
            .english = "You deal [VAR0_PERCENT] more damage.#" ++
                "You deal [VAR1_PERCENT] more damage for each buff on you.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .yellow,

        .allMult = shrinemaidens_kosode_mult,
        .hbVar0 = shrinemaidens_kosode_mult,
        .hbVar1 = shrinemaidens_kosode_mult_per_buff,
    });
    trig.strCalc0(&.{});
    ttrg.hbstatus_target(.{});
    ttrg.hbstatus_prune(thbss.isBuff, .@"==", 1);
    tset.uservar_hbscount(.{"u_buffs"});
    tset.uservar2("u_allMult", "u_buffs", .@"*", shrinemaidens_kosode_mult_per_buff);
    qpat.hb_reset_statchange_norefresh(.{});
    qpat.hb_add_statchange_norefresh(.{
        .stat = .allMult,
        .amountStr = "u_allMult",
    });

    item(.{
        .id = "it_transfigured_redwhite_ribbon",
        .name = .{
            .english = "Transfigured Redwhite Ribbon",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .yellow,
    });

    item(.{
        .id = "it_transfigured_divine_mirror",
        .name = .{
            .english = "Transfigured Divine Mirror",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .yellow,
    });

    item(.{
        .id = "it_transfigured_golden_chime",
        .name = .{
            .english = "Transfigured Golden Chime",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .yellow,
    });
}

fn transfiguredLuckySet() !void {
    const color = rgb(0xdb, 0x99, 0x85);
    rns.start(.{
        .name = "Transfigured Lucky Set",
        .image_path = "images/lucky.png",
        .thumbnail_path = "images/lucky_thumbnail.png",
    });
    defer rns.end();

    const book_of_cheats_dmg_mult = 1;
    const book_of_cheats_luck = 0.9;
    const book_of_cheats_charspeed = 5;
    const book_of_cheats_haste = -0.3;
    item(.{
        .id = "it_transfigured_book_of_cheats",
        .name = .{
            .english = "Transfigured Book of Cheats",
        },
        .description = .{
            .english = "At the start of each battle and until it ends, gain one of the " ++
                "following:#" ++
                " #" ++
                "1-4: One of your abilities deal [VAR0_PERCENT] more damage.#" ++
                "5: Your loot deals [VAR0_PERCENT] more damage.#" ++
                "6: Debuffs you place deals [VAR0_PERCENT] more damage.#" ++
                "7: You are extremely fast.#" ++
                "8: You are extremely lucky.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .yellow,

        .showSqVar = true,
        .glowSqVar0 = true,
        .hbVar0 = book_of_cheats_dmg_mult,
    });
    trig.onSquarePickup(&.{.square_self});
    qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 1 });

    trig.battleStart0(&.{});
    qpat.hb_flash_item(.{});
    tset.uservar_random_range(.{ "u_pick", 1, 9 });
    // `uservar_random_range` generates a float, I just want an int between 1 and 8
    // TODO: Figure out a better way
    cond.eval("u_pick", .@"<=", 9);
    qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 8 });
    cond.eval("u_pick", .@"<=", 8);
    qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 7 });
    cond.eval("u_pick", .@"<=", 7);
    qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 6 });
    cond.eval("u_pick", .@"<=", 6);
    qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 5 });
    cond.eval("u_pick", .@"<=", 5);
    qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 4 });
    cond.eval("u_pick", .@"<=", 4);
    qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 3 });
    cond.eval("u_pick", .@"<=", 3);
    qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 2 });
    cond.eval("u_pick", .@"<=", 2);
    qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 1 });

    for ([_]Stat{
        .primaryMult,
        .secondaryMult,
        .specialMult,
        .defensiveMult,
        .lootMult,
        .hbsMult,
    }, 1..) |stat, i| {
        trig.strCalc0(&.{});
        cond.hb_check_square_var(.{ 0, i });
        qpat.hb_reset_statchange_norefresh(.{});
        qpat.hb_add_statchange_norefresh(.{ .stat = stat, .amount = book_of_cheats_dmg_mult });
    }

    trig.strCalc0(&.{});
    cond.hb_check_square_var(.{ 0, 7 });
    qpat.hb_reset_statchange_norefresh(.{});
    qpat.hb_add_statchange_norefresh(.{
        .stat = .charspeed,
        .amount = book_of_cheats_charspeed,
    });
    qpat.hb_add_statchange_norefresh(.{
        .stat = .haste,
        .amount = book_of_cheats_haste,
    });

    trig.strCalc0(&.{});
    cond.hb_check_square_var(.{ 0, 8 });
    qpat.hb_reset_statchange_norefresh(.{});
    qpat.hb_add_statchange_norefresh(.{
        .stat = .luck,
        .amount = book_of_cheats_luck,
    });

    item(.{
        .id = "it_transfigured_golden_katana",
        .name = .{
            .english = "Transfigured Golden Katana",
        },
        .description = .{
            .english = "Every [CD] have a [LUCK] chance to slices the air around you dealing " ++
                "[STR] damage.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .yellow,

        .lootHbDispType = .cooldown,
        .cooldownType = .time,
        .cooldown = 1 * std.time.ms_per_s,
        .hbInput = .auto,

        .procChance = 0.05,
        .radius = 400,
        .strMult = 500,
    });
    trig.hotbarUsed(&.{.hb_self});
    qpat.hb_run_cooldown(.{});
    cond.random_def(.{});
    qpat.hb_flash_item(.{});
    qpat.hb_lucky_proc(.{});
    ttrg.players_opponent(.{});
    tset.strength_def(.{});
    apat.darkmagic_blade(.{});

    item(.{
        .id = "it_transfigured_glittering_trumpet",
        .name = .{
            .english = "Transfigured Glittering Trumpet",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .yellow,
    });

    const royal_staff_crit_dmg_buff = 0.03;
    const royal_staff_gold_per_crit_dmg = 2;
    const royal_staff_aoe_buff = 0.01;
    const royal_staff_gold_per_aoe = 2;
    item(.{
        .id = "it_transfigured_royal_staff",
        .name = .{
            .english = "Transfigured Royal Staff",
        },
        .description = .{
            .english = "Critical hits deal [VAR0_PERCENT] extra damage per [VAR1] Gold.#" ++
                "All abilities and loot's hitboxes are [VAR2_PERCENT] larger per [VAR3] Gold.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .yellow,

        .hbVar0 = royal_staff_crit_dmg_buff,
        .hbVar1 = royal_staff_gold_per_crit_dmg,
        .hbVar2 = royal_staff_aoe_buff,
        .hbVar3 = royal_staff_gold_per_aoe,
    });
    trig.onGoldChange(&.{.pl_self});
    qpat.hb_reset_statchange(.{});

    trig.strCalc0(&.{});
    tset.uservar_gold(.{"u_gold"});
    tset.uservar2("u_critDmg", "u_gold", .@"*", royal_staff_crit_dmg_buff);
    tset.uservar2("u_critDmg", "u_critDmg", .@"/", royal_staff_gold_per_crit_dmg);
    qpat.hb_reset_statchange_norefresh(.{});
    qpat.hb_add_statchange_norefresh(.{
        .stat = .critDamage,
        .amountStr = "u_critDmg",
    });

    trig.strCalc2(&.{});
    tset.uservar_gold(.{"u_gold"});
    ttrg.hotbarslots_current_players(.{});
    tset.uservar2("u_aoeMult", "u_gold", .@"*", royal_staff_aoe_buff);
    tset.uservar2("u_aoeMult", "u_aoeMult", .@"/", royal_staff_gold_per_aoe);
    tset.uservar2("u_aoeMultFull", "u_aoeMult", .@"+", 1);
    qpat.hb_mult_hitbox_var(.{
        .hitboxVar = .radius,
        .multStr = "u_aoeMultFull",
    });

    const ballroom_gown_buff = 5.0;
    item(.{
        .id = "it_transfigured_ballroom_gown",
        .name = .{
            .english = "Transfigured Ballroom Gown",
        },
        .description = .{
            .english = "Makes everything very slightly better.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .yellow,

        .allMult = ballroom_gown_buff * 0.01,
        .haste = 1 - ballroom_gown_buff * 0.01,
        .luck = ballroom_gown_buff * 0.01,
        .critDamage = ballroom_gown_buff * 0.01,
        .invulnPlus = ballroom_gown_buff * 100,
        .cdp = -ballroom_gown_buff * 100,
        .charspeed = ballroom_gown_buff * 0.1,
        .charradius = -ballroom_gown_buff,
    });
    trig.strCalc2(&.{});
    ttrg.hotbarslots_current_players(.{});
    qpat.hb_mult_hitbox_var(.{
        .hitboxVar = .radius,
        .mult = 1 + ballroom_gown_buff * 0.01,
    });
    qpat.hb_add_strength(.{ .amount = ballroom_gown_buff });

    const silver_coin_dmg_mult = 0.35;
    item(.{
        .id = "it_transfigured_silver_coin",
        .name = .{
            .english = "Transfigured Silver Coin",
        },
        .description = .{
            .english = "On pickup, flip the coin. 0 is heads, 1 is tails.#" ++
                " #" ++
                "On heads: Your Primary, Special and Debuffs deals [VAR0_PERCENT] more damage. " ++
                "Significantly increases movement speed.#" ++
                " #" ++
                "On tails: Your Secondary, Defensive and Loot deals [VAR0_PERCENT] more " ++
                "damage. Makes you significantly luckier.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .yellow,

        .showSqVar = true,
        .hbVar0 = silver_coin_dmg_mult,
    });
    trig.onSquarePickup(&.{.square_self});
    qpat.hb_reset_statchange(.{});
    qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 0 });
    tset.uservar_random_range(.{ "u_flip", 0, 1 });
    cond.eval("u_flip", .@"<", 0.5);
    qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 1 });

    trig.strCalc0(&.{});
    cond.hb_check_square_var(.{ 0, 0 });
    qpat.hb_reset_statchange_norefresh(.{});
    qpat.hb_add_statchange_norefresh(.{ .stat = .primaryMult, .amount = silver_coin_dmg_mult });
    qpat.hb_add_statchange_norefresh(.{ .stat = .specialMult, .amount = silver_coin_dmg_mult });
    qpat.hb_add_statchange_norefresh(.{ .stat = .hbsMult, .amount = silver_coin_dmg_mult });
    qpat.hb_add_statchange_norefresh(.{ .stat = .charspeed, .amount = charspeed.significantly });

    trig.strCalc0(&.{});
    cond.hb_check_square_var(.{ 0, 1 });
    qpat.hb_reset_statchange_norefresh(.{});
    qpat.hb_add_statchange_norefresh(.{ .stat = .secondaryMult, .amount = silver_coin_dmg_mult });
    qpat.hb_add_statchange_norefresh(.{ .stat = .defensiveMult, .amount = silver_coin_dmg_mult });
    qpat.hb_add_statchange_norefresh(.{ .stat = .lootMult, .amount = silver_coin_dmg_mult });
    qpat.hb_add_statchange_norefresh(.{ .stat = .luck, .amount = luck.significantly });

    item(.{
        .id = "it_transfigured_queens_crown",
        .name = .{
            .english = "Transfigured Queen's Crown",
        },
        .description = .{
            .english = "Your crits have a [LUCK] chance to deal an additional [STR] damage.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .yellow,

        .procChance = 0.2,
        .strMult = 200,
        .delay = 200,
    });
    trig.onDamageDone(&.{.pl_self});
    cond.true(.{s.isCrit});
    cond.random_def(.{});
    qpat.hb_flash_item(.{});
    qpat.hb_lucky_proc(.{});
    ttrg.player_damaged(.{});
    tset.strength_def(.{});
    apat.curse_talon(.{});

    item(.{
        .id = "it_transfigured_mimick_rabbitfoot",
        .name = .{
            .english = "Transfigured Mimick Rabbitfoot",
        },
        .description = .{
            .english = "Every [CD], proc as a % chance success.#" ++
                "Makes you slightly luckier. Also not a real rabbit's foot.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .yellow,

        .luck = luck.slightly,

        .lootHbDispType = .cooldown,
        .cooldownType = .time,
        .cooldown = 3 * std.time.ms_per_s,
        .hbInput = .auto,
    });
    trig.hotbarUsed(&.{.hb_self});
    qpat.hb_run_cooldown(.{});
    qpat.hb_flash_item(.{});
    qpat.hb_lucky_proc(.{});
}

fn transfiguredLifeSet() !void {
    const color = rgb(0x78, 0xf2, 0x66);
    rns.start(.{
        .name = "Transfigured Life Set",
        .image_path = "images/life.png",
        .thumbnail_path = "images/life_thumbnail.png",
    });
    defer rns.end();

    item(.{
        .id = "it_transfigured_butterfly_ocarina",
        .name = .{
            .english = "Transfigured Butterfly Ocarina",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .green,
    });

    item(.{
        .id = "it_transfigured_fairy_spear",
        .name = .{
            .english = "Transfigured Fairy Spear",
        },
        .description = .{
            .english = "Every [CD], using your Primary will summon an ethereal ally that " ++
                "fires at your target, dealing [STR] damage each time.#The number of of times " ++
                "each ally will fire is equal to you HP.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .green,
        .lootHbDispType = .cooldown,

        .cooldownType = .time,
        .cooldown = 10 * std.time.ms_per_s,

        .strMult = 100,
    });
    trig.onDamage(&.{.pl_self});
    qpat.hb_reset_statchange(.{});

    trig.hotbarUsedProc(&.{.hb_primary});
    cond.hb_available(.{});
    qpat.hb_run_cooldown(.{});
    qpat.hb_cdloot_proc(.{});
    ttrg.players_opponent(.{});
    tset.strength_def(.{});
    apat.druid_2(.{});

    trig.strCalc2(&.{});
    qpat.hb_add_hitbox_var(.{
        .hitboxVar = .number,
        .amountStr = r.hp.toCsvString(),
    });

    item(.{
        .id = "it_transfigured_moss_shield",
        .name = .{
            .english = "Transfigured Moss Shield",
        },
        .description = .{
            .english = "Every [CD], abilities with multiple uses gains a use.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .green,

        .lootHbDispType = .cooldown,
        .cooldownType = .time,
        .cooldown = 5 * std.time.ms_per_s,
        .hbInput = .auto,
    });
    trig.hotbarUsed(&.{.hb_self});
    qpat.hb_run_cooldown(.{});
    ttrg.hotbarslots_self_abilities(.{});
    ttrg.hotbarslots_prune(thss.maxStock, .@">", 1);
    qpat.hb_increase_stock(.{ .amount = 1 });

    item(.{
        .id = "it_transfigured_floral_bow",
        .name = .{
            .english = "Transfigured Floral Bow",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .green,
    });

    item(.{
        .id = "it_transfigured_blue_rose",
        .name = .{
            .english = "Transfigured Blue Rose",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .green,
    });

    const sunflower_crown_hp = 3;
    item(.{
        .id = "it_transfigured_sunflower_crown",
        .name = .{
            .english = "Transfigured Sunflower Crown",
        },
        .description = .{
            .english = "Your max HP is increased by [VAR0]. You are easier to hit. Slightly " ++
                "increases movement speed.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .green,

        .charspeed = charspeed.slightly,
        .charradius = 20,
        .hp = sunflower_crown_hp,
        .hbVar0 = sunflower_crown_hp,
    });
    trig.onSquarePickup(&.{.square_self});
    ttrg.player_self(.{});
    apat.heal_light(.{ .amount = sunflower_crown_hp });

    const midsummer_dress_hp = 1;
    const midsummer_dress_mult_per_hp = 0.05;
    item(.{
        .id = "it_transfigured_midsummer_dress",
        .name = .{
            .english = "Transfigured Midsummer Dress",
        },
        .description = .{
            .english = "Your max HP is increased by [VAR0]. You deal [VAR1_PERCENT] more " ++
                "damage per HP. Slightly increases movement speed.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .green,

        .charspeed = charspeed.slightly,
        .hp = midsummer_dress_hp,
        .hbVar0 = midsummer_dress_hp,
        .hbVar1 = midsummer_dress_mult_per_hp,
    });
    trig.onSquarePickup(&.{.square_self});
    ttrg.player_self(.{});
    apat.heal_light(.{ .amount = midsummer_dress_hp });

    trig.strCalc0(&.{});
    tset.uservar2("u_allMult", r.hp, .@"*", midsummer_dress_mult_per_hp);
    qpat.hb_reset_statchange_norefresh(.{});
    qpat.hb_add_statchange_norefresh(.{
        .stat = .allMult,
        .amountStr = "u_allMult",
    });

    const grasswoven_bracelet_hp = 1;
    const grasswoven_bracelet_aoe_per_hp = 0.1;
    item(.{
        .id = "it_transfigured_grasswoven_bracelet",
        .name = .{
            .english = "Transfigured Grasswoven Bracelet",
        },
        .description = .{
            .english = "Your max HP is increased by [VAR0]. All abilities and loot's hitboxes " ++
                "are [VAR1_PERCENT] larger per HP. Slightly increases movement speed.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .green,

        .charspeed = charspeed.slightly,
        .hp = grasswoven_bracelet_hp,
        .hbVar0 = grasswoven_bracelet_hp,
        .hbVar1 = grasswoven_bracelet_aoe_per_hp,
    });
    trig.onSquarePickup(&.{.square_self});
    ttrg.player_self(.{});
    apat.heal_light(.{ .amount = grasswoven_bracelet_hp });

    trig.strCalc2(&.{});
    ttrg.hotbarslots_current_players(.{});
    tset.uservar2("u_aoeMult", r.hp, .@"*", grasswoven_bracelet_aoe_per_hp);
    tset.uservar2("u_aoeMultFull", "u_aoeMult", .@"+", 1);
    qpat.hb_mult_hitbox_var(.{
        .hitboxVar = .radius,
        .multStr = "u_aoeMultFull",
    });
}

fn transfiguredPoisonSet() !void {
    const color = rgb(0x46, 0xd1, 0x72);
    rns.start(.{
        .name = "Transfigured Poison Set",
        .image_path = "images/poison.png",
        .thumbnail_path = "images/poison_thumbnail.png",
    });
    defer rns.end();

    const snakefang_dagger_secondary_mult = -0.25;
    const snakefang_dagger_str = 20;
    const snakefang_dagger_num_poisons = 3;
    item(.{
        .id = "it_transfigured_snakefang_dagger",
        .name = .{
            .english = "Transfigured Snakefang Dagger",
        },
        .description = .{
            .english = "Your Secondary deals [VAR0_PERCENT] less damage, and applies " ++
                "[VAR1] [POISON-0].",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .green,

        .delay = 250,
        .hbsType = .poison_0,
        .hbsStrMult = snakefang_dagger_str,
        .hbsLength = 5 * std.time.ms_per_s,

        .hbVar0 = @abs(snakefang_dagger_secondary_mult),
        .secondaryMult = snakefang_dagger_secondary_mult,

        .hbColor0 = rgb(0x0a, 0x51, 0x00),
        .hbColor1 = rgb(0x17, 0x7f, 0x00),

        .hbVar1 = snakefang_dagger_num_poisons,
        .autoOffSqVar0 = 0,
    });
    trig.onDamageDone(&.{.dmg_self_secondary});
    ttrg.player_damaged(.{});
    qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 1 });

    const poisons = [_]Hbs{
        .poison_0,
        .poison_1,
        .poison_2,
        .poison_3,
        .poison_4,
        .poison_5,
        .poison_6,
    };
    tset.hbs_def(.{});
    inline for (poisons[0..snakefang_dagger_num_poisons]) |hbs| {
        tset.hbskey(.{hbs});
        apat.apply_hbs(.{});
    }

    // Flash item when debuff was applied
    trig.hbsCreated(&.{.hbs_thishbcast});
    // To avoid flashing for every debuff applied, instead keep track of if the secondary has done
    // damage. If so, flash once, and set the damage flag to 0, so we don't flash again.
    cond.hb_check_square_var(.{ 0, 1 });
    qpat.hb_flash_item(.{});
    qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 0 });

    // Set color of special to hbColor0/1
    trig.colorCalc(&.{});
    ttrg.hotbarslots_self_weapontype(.{WeaponType.secondary});
    qpat.hb_set_color_def(.{});

    item(.{
        .id = "it_transfigured_ivy_staff",
        .name = .{
            .english = "Transfigured Ivy Staff",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .green,
    });

    item(.{
        .id = "it_transfigured_deathcap_tome",
        .name = .{
            .english = "Transfigured Deathcap Tome",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .green,
    });

    item(.{
        .id = "it_transfigured_spiderbite_bow",
        .name = .{
            .english = "Transfigured Spiderbite Bow",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .green,
    });

    item(.{
        .id = "it_transfigured_compound_gloves",
        .name = .{
            .english = "Transfigured Compound Gloves",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .green,
    });

    item(.{
        .id = "it_transfigured_cursed_poisonfrog_charm",
        .name = .{
            .english = "Transfigured Poisonfrog Charm",
        },
        .description = .{
            .english = "When a % chance succeeds, apply [HEXP] to all enemies for [HBSL].",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .green,

        .hbsType = .hex_poison,
        .hbsLength = 2 * std.time.ms_per_s,
        .hbsStrMult = 40,
    });
    trig.luckyProc(&.{.pl_self});
    qpat.hb_flash_item(.{});
    ttrg.players_opponent(.{});
    tset.hbs_def(.{});
    apat.apply_hbs(.{});

    item(.{
        .id = "it_transfigured_venom_hood",
        .name = .{
            .english = "Transfigured Venom Hood",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .green,
    });

    item(.{
        .id = "it_transfigured_chemists_coat",
        .name = .{
            .english = "Transfigured Chemist's Coat",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .green,
    });
}

fn transfiguredDepthSet() !void {
    const color = rgb(0x44, 0xc8, 0x84);
    rns.start(.{
        .name = "Transfigured Depth Set",
        .image_path = "images/depth.png",
        .thumbnail_path = "images/depth_thumbnail.png",
    });
    defer rns.end();

    item(.{
        .id = "it_transfigured_seashell_shield",
        .name = .{
            .english = "Transfigured Seashell Shield",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .green,
    });

    const necronomicon_stacks_consumed = 3;
    item(.{
        .id = "it_transfigured_necronomicon",
        .name = .{
            .english = "Transfigured Necronomicon",
        },
        .description = .{
            .english = "Every time you use your Secondary, gain a stack.#" ++
                "Activating an ability with a cooldown consumes [VAR0] stack" ++
                (if (necronomicon_stacks_consumed != 1) "s" else "") ++
                " to reset its cooldown instantly.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .green,

        .showSqVar = true,
        .autoOffSqVar0 = 0,
        .hbVar0 = necronomicon_stacks_consumed,
    });
    trig.hotbarUsedProc(&.{.hb_secondary});
    qpat.hb_square_add_var(.{ .varIndex = 0, .amount = 1 });

    const hb_conditions = [_]Condition{
        .hb_primary,
        .hb_secondary,
        .hb_special,
        .hb_defensive,
    };

    for (hb_conditions, WeaponType.abilities) |c, weapon| {
        trig.hotbarUsedProc(&.{c});
        cond.hb_check_square_var_gte(.{ 0, necronomicon_stacks_consumed });
        ttrg.hotbarslots_self_weapontype(.{weapon});
        cond.hb_check_resettable0(.{});
        qpat.hb_reset_cooldown(.{});
        ttrg.hotbarslot_self(.{});
        qpat.hb_square_add_var(.{ .varIndex = 0, .amount = -necronomicon_stacks_consumed });
        qpat.hb_flash_item(.{});
    }

    const tidal_greatsword_dmg_mult = 0.04;
    const tidal_greatsword_aoe_mult = 0.02;
    item(.{
        .id = "it_transfigured_tidal_greatsword",
        .name = .{
            .english = "Transfigured Tidal Greatsword",
        },
        .description = .{
            .english = "Every [CD] slices a large radius around you dealing [STR] damage.#" ++
                "For each enemy hit, your abilities and loot deal [VAR0_PERCENT] more damage " ++
                "and has a [VAR1_PERCENT] larger hitbox until the end of battle.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .green,

        .lootHbDispType = .cooldown,
        .hbInput = .auto,
        .cooldownType = .time,
        .cooldown = 10 * std.time.ms_per_s,

        .showSqVar = true,
        .autoOffSqVar0 = 0,

        .strMult = 200,
        .radius = 400,

        .hbVar0 = tidal_greatsword_dmg_mult,
        .hbVar1 = tidal_greatsword_aoe_mult,
    });
    trig.autoStart(&.{.hb_auto_pl});
    qpat.hb_run_cooldown(.{});

    trig.hotbarUsed(&.{.hb_self});
    qpat.hb_flash_item(.{});
    qpat.hb_run_cooldown(.{});
    ttrg.players_opponent(.{});
    tset.strength_def(.{});
    apat.darkmagic_blade(.{});

    trig.onDamageDone(&.{.dmg_self_thishb});
    qpat.hb_square_add_var(.{ .varIndex = 0, .amount = 1 });
    qpat.hb_reset_statchange(.{});

    trig.strCalc0(&.{});
    tset.uservar2("u_allMult", r.sqVar0, .@"*", tidal_greatsword_dmg_mult);
    qpat.hb_reset_statchange_norefresh(.{});
    qpat.hb_add_statchange_norefresh(.{
        .stat = .allMult,
        .amountStr = "u_allMult",
    });

    trig.strCalc2(&.{});
    ttrg.hotbarslots_current_players(.{});
    ttrg.hotbarslots_prune(thss.weaponType, .@"!=", WeaponType.potion);
    tset.uservar2("u_aoeMultBase", r.sqVar0, .@"*", tidal_greatsword_aoe_mult);
    tset.uservar2("u_aoeMult", "u_aoeMultBase", .@"+", 1);
    qpat.hb_mult_hitbox_var(.{
        .hitboxVar = .radius,
        .multStr = "u_aoeMult",
    });

    item(.{
        .id = "it_transfigured_occult_dagger",
        .name = .{
            .english = "Transfigured Occult Dagger",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .green,
    });

    item(.{
        .id = "it_transfigured_mermaid_scalemail",
        .name = .{
            .english = "Transfigured Mermaid Scalemail",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .green,
    });

    const hydrous_blob_secondary_stacks = 1;
    const hydrous_blob_special_stacks = 2;
    item(.{
        .id = "it_transfigured_hydrous_blob",
        .name = .{
            .english = "Transfigured Hydrous Blob",
        },
        .description = .{
            .english = "Every [CD], consume a stack to fire an eldritch beast towards your " ++
                "target, dealing [STR] damage.#" ++
                "Gains [VAR0] stack" ++ (if (hydrous_blob_secondary_stacks != 1) "s" else "") ++ " when you use your Secondary.#" ++
                "Gains [VAR1] stack" ++ (if (hydrous_blob_special_stacks != 1) "s" else "") ++ " when you use your Special.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .green,

        .lootHbDispType = .cooldown,
        .hbInput = .auto,
        .cooldownType = .time,
        .cooldown = 2 * std.time.ms_per_s,

        .strMult = 100,
        .delay = std.time.ms_per_s,
        .radius = 350,

        .showSqVar = true,
        .autoOffSqVar0 = 0,

        .hbVar0 = hydrous_blob_secondary_stacks,
        .hbVar1 = hydrous_blob_special_stacks,
    });
    trig.autoStart(&.{.hb_auto_pl});
    qpat.hb_run_cooldown(.{});

    trig.hotbarUsedProc(&.{.hb_secondary});
    qpat.hb_square_add_var(.{ .varIndex = 0, .amount = hydrous_blob_secondary_stacks });

    trig.hotbarUsedProc(&.{.hb_special});
    qpat.hb_square_add_var(.{ .varIndex = 0, .amount = hydrous_blob_special_stacks });

    trig.hotbarUsed(&.{.hb_self});
    cond.hb_check_square_var_false(.{ 0, 0 });
    qpat.hb_square_add_var(.{ .varIndex = 0, .amount = -1 });
    qpat.hb_run_cooldown(.{});
    qpat.hb_flash_item(.{});
    ttrg.players_opponent(.{});
    tset.strength_def(.{});
    apat.hydrous_blob(.{});

    item(.{
        .id = "it_transfigured_abyss_artifact",
        .name = .{
            .english = "Transfigured Abyss Artifact",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .green,
    });

    item(.{
        .id = "it_transfigured_lost_pendant",
        .name = .{
            .english = "Transfigured Lost Pendant",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .green,
    });
}

fn transfiguredDarkbiteSet() !void {
    const color = rgb(0x68, 0x4e, 0xf2);
    rns.start(.{
        .name = "Transfigured Darkbite Set",
        .image_path = "images/darkbite.png",
        .thumbnail_path = "images/darkbite_thumbnail.png",
    });
    defer rns.end();

    item(.{
        .id = "it_transfigured_sawtooth_cleaver",
        .name = .{
            .english = "Transfigured Sawtooth Cleaver",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .purpleblue,
    });

    item(.{
        .id = "it_transfigured_ravens_dagger",
        .name = .{
            .english = "Transfigured Raven's Dagger",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .purpleblue,
    });

    item(.{
        .id = "it_transfigured_killing_note",
        .name = .{
            .english = "Transfigured Killing Note",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .purpleblue,
    });

    item(.{
        .id = "it_transfigured_blacksteel_buckler",
        .name = .{
            .english = "Transfigured Blacksteel Buckler",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .purpleblue,
    });

    const nightguard_gloves_dmg_mult = 0.35;
    item(.{
        .id = "it_transfigured_nightguard_gloves",
        .name = .{
            .english = "Transfigured Nightguard Gloves",
        },
        .description = .{
            .english = "Whichever ability has the lowest base damage value deals " ++
                "[VAR0_PERCENT] more damage.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .purpleblue,

        .hbVar0 = nightguard_gloves_dmg_mult,
    });

    // There doesn't exist a hotbarslots_self_loweststrweapon, so the code below emulate this.
    // First, we need to ignore abilities with no base strength. To do this, we create 4 triggers,
    // one for each of the possible number of slots that has strength.
    for (1..5) |slot_count| {
        trig.strCalc1c(&.{});
        ttrg.hotbarslots_self_abilities(.{});
        ttrg.hotbarslots_prune_base_has_str(.{});
        tset.uservar_slotcount(.{"u_slots"});
        // Here is the check to exit triggers that does not match the slot count. The trigger for
        // 3 slots with base strength should not do any work if we have 4 abilities with strength.
        cond.equal(.{ "u_slots", slot_count });

        // Ok, we now know how many slots we need to perform checks for to isolate the ability with
        // the lowest stength. First, we save each abilities strength in a uservar. The strength
        // of all abilities will be gone once we start pruning.
        var buf1: [128]u8 = undefined;
        var buf2: [128]u8 = undefined;
        for (0..slot_count) |i| {
            tset.uservar1(
                try std.fmt.bufPrint(&buf1, "u_ths{}_strength", .{i}),
                // TODO: Refactor to use thsX
                try std.fmt.bufPrint(&buf2, "ths{}_strength", .{i}),
            );
        }

        // Next, for each uservar we created earlier, we prune the slots that have strength larger
        // than the user var.
        // For 3 slots that have strength, this turns into:
        // ttrg.hotbarslots_prune(thss.strength, .@"<=", "u_ths0_strength");
        // ttrg.hotbarslots_prune(thss.strength, .@"<=", "u_ths1_strength");
        // ttrg.hotbarslots_prune(thss.strength, .@"<=", "u_ths2_strength");
        for (0..slot_count) |i| {
            const u_strength = try std.fmt.bufPrint(&buf1, "u_ths{}_strength", .{i});
            ttrg.hotbarslots_prune(thss.strength, .@"<=", u_strength);
        }

        // With the above prune, only abilites with the lowest strength should be left (there can
        // be multiple).
        qpat.hb_add_strcalcbuff(.{ .amount = nightguard_gloves_dmg_mult });
    }

    item(.{
        .id = "it_transfigured_snipers_eyeglasses",
        .name = .{
            .english = "Transfigured Sniper's Eyeglasses",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .purpleblue,
    });

    item(.{
        .id = "it_transfigured_darkmage_charm",
        .name = .{
            .english = "Transfigured Darkmage Charm",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .purpleblue,
    });

    item(.{
        .id = "it_transfigured_firststrike_bracelet",
        .name = .{
            .english = "Transfigured Firststrike Bracelet",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .purpleblue,
    });
}

fn transfiguredTimegemSet() !void {
    const color = rgb(0x50, 0x3a, 0xe8);
    rns.start(.{
        .name = "Transfigured Timegem Set",
        .image_path = "images/timegem.png",
        .thumbnail_path = "images/timegem_thumbnail.png",
    });
    defer rns.end();

    const obsidian_rod_str = 80;
    item(.{
        .id = "it_transfigured_obsidian_rod",
        .name = .{
            .english = "Transfigured Obsidian Rod",
        },
        .description = .{
            .english = "Your Special's strength becomes the total GCD of all your abilities, " ++
                "in seconds, multiplied by [VAR0], divided by the times it hits your target.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .purplered,

        .hbVar0 = obsidian_rod_str,
    });
    trig.strCalc1b(&.{});
    for (WeaponType.abilities_with_gcd) |weapon_type| {
        ttrg.hotbarslots_self_weapontype(.{weapon_type});
        tset.uservar2("u_gcd", "u_gcd", .@"+", ths0.gcd);
    }

    ttrg.hotbarslots_self_weapontype(.{WeaponType.special});
    tset.uservar2("u_gcd", "u_gcd", .@"/", std.time.ms_per_s);
    tset.uservar2("u_str", "u_gcd", .@"*", obsidian_rod_str);
    qpat.hb_set_strength(.{ .amountStr = "u_str" });
    cond.eval(ths0.number, .@">", 1);
    tset.uservar2("u_str", "u_str", .@"/", ths0.number);
    qpat.hb_set_strength(.{ .amountStr = "u_str" });

    item(.{
        .id = "it_transfigured_darkglass_spear",
        .name = .{
            .english = "Transfigured Darkglass Spear",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .purplered,
    });

    item(.{
        .id = "it_transfigured_timespace_dagger",
        .name = .{
            .english = "Transfigured Timespace Dagger",
        },
        .description = .{
            .english = "Your Secondary's GCD becomes the GCD of your Primary.#" ++
                "Your Secondary's total strength becomes the total strength of your Special.#" ++
                "Your Secondary's cooldown becomes half the cooldown of your Defensive.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .purplered,
    });
    trig.strCalc1b(&.{});
    ttrg.hotbarslots_self_weapontype(.{WeaponType.special});
    tset.uservar2("u_str", ths0.strength, .@"*", ths0.number);

    // Some abilities that hit onces will have `number` as 0. To counteract this, we filter for
    // it and adds the strenght back as `u_str` will be one in that case
    ttrg.hotbarslots_prune(ths0.number, .@"==", 0);
    tset.uservar2("u_str", "u_str", .@"+", ths0.strength);

    ttrg.hotbarslots_self_weapontype(.{WeaponType.secondary});
    qpat.hb_set_strength(.{ .amountStr = "u_str" });

    // Same here. If `number` is 0, we exit early and don't do the divide
    cond.eval(ths0.number, .@">", 0);
    tset.uservar2("u_str", "u_str", .@"/", ths0.number);
    qpat.hb_set_strength(.{ .amountStr = "u_str" });

    trig.cdCalc5(&.{});
    ttrg.hotbarslots_self_weapontype(.{WeaponType.primary});
    tset.uservar1("u_gcd", ths0.gcd);
    ttrg.hotbarslots_self_weapontype(.{WeaponType.secondary});
    qpat.hb_set_gcd_permanent(.{ .amountStr = "u_gcd" });

    trig.cdCalc6(&.{});
    ttrg.hotbarslots_self_weapontype(.{WeaponType.defensive});
    tset.uservar2("u_cooldown", ths0.cooldown, .@"/", 2);
    ttrg.hotbarslots_self_weapontype(.{WeaponType.secondary});
    qpat.hb_set_cooldown_permanent(.{ .timeStr = "u_cooldown" });

    item(.{
        .id = "it_transfigured_quartz_shield",
        .name = .{
            .english = "Transfigured Quartz Shield",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .purplered,
    });

    item(.{
        .id = "it_transfigured_pocketwatch",
        .name = .{
            .english = "Transfigured Pocketwatch",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .purplered,
    });

    item(.{
        .id = "it_transfigured_nova_crown",
        .name = .{
            .english = "Transfigured Nova Crown",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .purplered,
    });

    item(.{
        .id = "it_transfigured_blackhole_charm",
        .name = .{
            .english = "Transfigured Blackhole Charm",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .purplered,
    });

    item(.{
        .id = "it_transfigured_twinstar_earrings",
        .name = .{
            .english = "Transfigured Twinstar Earrings",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .purplered,
    });
}

fn transfiguredYoukaiSet() !void {
    const color_dark = rgb(0x5e, 0x55, 0x5e);
    const color_light = rgb(0xf2, 0xed, 0xd6);
    rns.start(.{
        .name = "Transfigured Youkai Set",
        .image_path = "images/youkai.png",
        .thumbnail_path = "images/youkai_thumbnail.png",
    });
    defer rns.end();

    const kyou_no_omikuji_dmg_mult = 0.30;
    item(.{
        .id = "it_transfigured_kyou_no_omikuji",
        .name = .{
            .english = "Transfigured Kyou No Omikuji",
        },
        .description = .{
            .english = "All damage you deal increased by [VAR0_PERCENT]. You cannot gain " ++
                "buffs or inflict debuffs.",
        },
        .color = color_dark,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .purpleyellow,

        .allMult = kyou_no_omikuji_dmg_mult,
        .hbVar0 = kyou_no_omikuji_dmg_mult,
    });
    trig.hbsCreated(&.{.hbs_selfcast});
    cond.false(.{s.isBuff});
    ttrg.hbstatus_source(.{});
    qpat.hbs_destroy(.{});

    trig.hbsCreated(&.{.hbs_selfafl});
    cond.true(.{s.isBuff});
    ttrg.hbstatus_source(.{});
    qpat.hbs_destroy(.{});

    item(.{
        .id = "it_transfigured_youkai_bracelet",
        .name = .{
            .english = "Transfigured Youkai Bracelet",
        },
        .description = .{
            .english = "Your abilities base damage value becomes the average base damage " ++
                "value of all your abilities.",
        },
        .color = color_dark,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .purpleyellow,
    });
    trig.strCalc1c(&.{});
    ttrg.hotbarslots_self_abilities(.{});
    ttrg.hotbarslots_prune_base_has_str(.{});
    tset.uservar_slotcount(.{"u_slots"});

    tset.uservar2("u_sum0", ths0.strength, .@"+", ths1.strength);
    tset.uservar2("u_sum1", "u_sum0", .@"+", ths2.strength);
    tset.uservar2("u_sum", "u_sum1", .@"+", ths3.strength);
    tset.uservar2("u_avg", "u_sum", .@"/", "u_slots");

    qpat.hb_set_strength(.{ .amountStr = "u_avg" });

    const oni_staff_mult = 0.6;
    const oni_staff_cd = 15 * std.time.ms_per_s;
    item(.{
        .id = "it_transfigured_oni_staff",
        .name = .{
            .english = "Transfigured Oni Staff",
        },
        .description = .{
            .english = "Your Special deals [VAR0_PERCENT] more damage.#" ++
                "When you use your Special, abilities or loot with a cooldown goes on a " ++
                "[VAR1_SECONDS] cooldown.",
        },
        .color = color_dark,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .purpleyellow,

        .specialMult = oni_staff_mult,
        .hbVar0 = oni_staff_mult,
        .hbVar1 = oni_staff_cd,
    });
    trig.hotbarUsedProc(&.{.hb_special});
    ttrg.hotbarslots_current_players(.{});
    ttrg.hotbarslots_prune(thss.cooldown, .@">", 0);
    qpat.hb_run_cooldown_ext(.{ .length = oni_staff_cd });

    item(.{
        .id = "it_transfigured_kappa_shield",
        .name = .{
            .english = "Transfigured Kappa Shield",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color_dark,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .purpleyellow,
    });

    item(.{
        .id = "it_transfigured_usagi_kamen",
        .name = .{
            .english = "Transfigured Usagi Kamen",
        },
        .description = .{
            .english = "When a % chance succeeds, your Special resets.",
        },
        .color = color_light,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .purpleyellow,
    });
    trig.luckyProc(&.{.pl_self});
    ttrg.hotbarslots_self_weapontype(.{WeaponType.special});
    cond.hb_check_resettable0(.{});
    qpat.hb_reset_cooldown(.{});

    const red_tanzaku_dmg = 7;
    item(.{
        .id = "it_transfigured_red_tanzaku",
        .name = .{
            .english = "Transfigured Red Tanzaku",
        },
        .description = .{
            .english = "Your abilities deal 7 damage. You have [LUCKY].",
        },
        .color = color_light,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .purpleyellow,

        .lootHbDispType = .cooldown,
        .hbInput = .auto,

        .hbsType = .lucky,
        .hbsLength = std.time.ms_per_min,

        .cooldownType = .time,
        .cooldown = std.time.ms_per_min,

        .hbVar0 = red_tanzaku_dmg,
    });
    trig.hotbarUsed(&.{.hb_self});
    qpat.hb_run_cooldown(.{});
    ttrg.player_self(.{});
    tset.hbs_def(.{});
    apat.apply_hbs(.{});

    trig.strCalc1a(&.{});
    ttrg.hotbarslots_current_players(.{});
    ttrg.hotbarslots_prune_base_has_str(.{});
    ttrg.hotbarslots_prune(thss.weaponType, .@"!=", WeaponType.loot);
    ttrg.hotbarslots_prune(thss.weaponType, .@"!=", WeaponType.potion);
    qpat.hb_set_strength(.{ .amount = red_tanzaku_dmg });

    item(.{
        .id = "it_transfigured_vega_spear",
        .name = .{
            .english = "Transfigured Vega Spear",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color_light,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .purpleyellow,
    });

    item(.{
        .id = "it_transfigured_altair_dagger",
        .name = .{
            .english = "Transfigured Altair Dagger",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color_light,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .purpleyellow,
    });
}

fn transfiguredHauntedSet() !void {
    const color = rgb(0x7d, 0xe2, 0xc8);
    rns.start(.{
        .name = "Transfigured Haunted Set",
        .image_path = "images/haunted.png",
        .thumbnail_path = "images/haunted_thumbnail.png",
    });
    defer rns.end();

    item(.{
        .id = "it_transfigured_ghost_spear",
        .name = .{
            .english = "Transfigured Ghost Spear",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .purplegreen,
    });

    item(.{
        .id = "it_transfigured_phantom_dagger",
        .name = .{
            .english = "Transfigured Phantom Dagger",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .purplegreen,
    });

    item(.{
        .id = "it_transfigured_cursed_candlestaff",
        .name = .{
            .english = "Transfigured Cursed Candlestaff",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .purplegreen,
    });

    item(.{
        .id = "it_transfigured_smoke_shield",
        .name = .{
            .english = "Transfigured Smoke Shield",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .purplegreen,
    });

    item(.{
        .id = "it_transfigured_haunted_gloves",
        .name = .{
            .english = "Transfigured Haunted Gloves",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .purplegreen,
    });

    item(.{
        .id = "it_transfigured_old_bonnet",
        .name = .{
            .english = "Transfigured Old Bonnet",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .purplegreen,
    });

    item(.{
        .id = "it_transfigured_maid_outfit",
        .name = .{
            .english = "Transfigured Maid Outfit",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .purplegreen,
    });

    item(.{
        .id = "it_transfigured_calling_bell",
        .name = .{
            .english = "Transfigured Calling Bell",
        },
        .description = .{
            .english = "Afflicts all enemies with [GHOSTFLAME-4] when an ability or " ++
                "loot with a cooldown is activated.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .purplegreen,

        .hbsStrMult = 200,
        .hbsType = .ghostflame_4,
        .hbsLength = 5 * std.time.ms_per_s,
    });
    trig.hotbarUsed(&.{.hb_selfcast});
    cond.eval(s.cooldown, .@">", 0);
    qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 1 });
    ttrg.players_opponent(.{});
    tset.hbs_def(.{});
    apat.poisonfrog_charm(.{});

    trig.hbsCreated(&.{.hbs_thishbcast});
    // To avoid flashing for every debuff applied, instead keep track of if the loot has been
    // used. If so, flash once, and set the used flag to 0, so we don't flash again.
    cond.hb_check_square_var(.{ 0, 1 });
    qpat.hb_flash_item(.{});
    qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 0 });
}

fn transfiguredGladiatorSet() !void {
    const color = rgb(0x86, 0x7b, 0x7a);
    rns.start(.{
        .name = "Transfigured Gladiator Set",
        .image_path = "images/gladiator.png",
        .thumbnail_path = "images/gladiator_thumbnail.png",
    });
    defer rns.end();

    item(.{
        .id = "it_transfigured_grandmaster_spear",
        .name = .{
            .english = "Transfigured Grandmaster Spear",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .bluered,
    });

    const teacher_knife_per_sec_mult = 0.01;
    item(.{
        .id = "it_transfigured_teacher_knife",
        .name = .{
            .english = "Transfigured Teacher Knife",
        },
        .description = .{
            .english = "For each second of cooldown on your abilities your Secondary deals " ++
                "[VAR0_PERCENT] more damage.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .bluered,

        .hbVar0 = teacher_knife_per_sec_mult,
    });
    trig.strCalc1c(&.{});
    ttrg.hotbarslots_current_players(.{});
    ttrg.hotbarslots_prune(thss.weaponType, .@"!=", WeaponType.potion);
    ttrg.hotbarslots_prune(thss.weaponType, .@"!=", WeaponType.loot);
    ttrg.hotbarslots_prune(thss.cooldown, .@">", 0);

    inline for (.{ ths0, ths1, ths2, ths3 }) |ths| {
        tset.uservar2("u_mult_temp", ths.cooldown, .@"/", std.time.ms_per_s);
        tset.uservar2("u_mult_temp", "u_mult_temp", .@"*", teacher_knife_per_sec_mult);
        tset.uservar2("u_mult", "u_mult", .@"+", "u_mult_temp");
    }

    ttrg.hotbarslots_self_weapontype(.{WeaponType.secondary});
    qpat.hb_add_strcalcbuff(.{ .amountStr = "u_mult" });

    const tactician_rod_mult = -0.2;
    item(.{
        .id = "it_transfigured_tactician_rod",
        .name = .{
            .english = "Transfigured Tactician Rod",
        },
        .description = .{
            .english = "Your Special no longer has a cooldown, but deals [VAR0_PERCENT] less " ++
                "damage.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .bluered,

        .specialMult = tactician_rod_mult,
        .hbVar0 = @abs(tactician_rod_mult),
    });
    trig.cdCalc5(&.{});
    ttrg.hotbarslots_self_weapontype(.{WeaponType.special});
    qpat.hb_set_cooldown_permanent(.{ .time = 0 });

    item(.{
        .id = "it_transfigured_spiked_shield",
        .name = .{
            .english = "Transfigured Spiked Shield",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .bluered,
    });

    item(.{
        .id = "it_transfigured_battlemaiden_armor",
        .name = .{
            .english = "Transfigured Battlemaiden Armor",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .bluered,
    });

    const gladiator_helmet_dmg_mult = 0.2;
    item(.{
        .id = "it_transfigured_gladiator_helmet",
        .name = .{
            .english = "Transfigured Gladiator Helmet",
        },
        .description = .{
            .english = "Abilities and loot that doesn't have cooldowns deal [VAR0_PERCENT] " ++
                "more damage.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .bluered,

        .hbVar0 = gladiator_helmet_dmg_mult,
    });
    trig.strCalc1c(&.{});
    ttrg.hotbarslots_current_players(.{});
    ttrg.hotbarslots_prune(thss.weaponType, .@"!=", WeaponType.potion);
    ttrg.hotbarslots_prune(thss.cooldown, .@"==", 0);
    qpat.hb_add_strcalcbuff(.{ .amount = gladiator_helmet_dmg_mult });

    const lancer_gauntlets_mult = 0.35;
    item(.{
        .id = "it_transfigured_lancer_gauntlets",
        .name = .{
            .english = "Transfigured Lancer Gauntlets",
        },
        .description = .{
            .english = "Abilities different from the one you used last deal [VAR0_PERCENT] " ++
                "more damage.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .bluered,

        .showSqVar = true,
        .hbVar0 = lancer_gauntlets_mult,
    });

    const hb_conditions = [_]Condition{
        .hb_primary,
        .hb_secondary,
        .hb_special,
        .hb_defensive,
    };

    const hb_stats = [_]Stat{
        .primaryMult,
        .secondaryMult,
        .specialMult,
        .defensiveMult,
    };

    trig.onSquarePickup(&.{.square_self});
    qpat.hb_square_set_var(.{ .varIndex = 0, .amount = hb_stats.len });

    for (hb_conditions, hb_stats, 0..) |hotbar, exclude, i| {
        trig.hotbarUsedProc(&.{hotbar});
        cond.hb_check_square_var_false(.{ 0, i });
        qpat.hb_square_set_var(.{ .varIndex = 0, .amount = @floatFromInt(i) });
        qpat.hb_reset_statchange(.{});

        trig.strCalc0(&.{});
        cond.hb_check_square_var(.{ 0, i });
        qpat.hb_reset_statchange_norefresh(.{});
        for (hb_stats) |stat| {
            if (stat == exclude)
                continue;

            qpat.hb_add_statchange_norefresh(.{
                .stat = stat,
                .amount = lancer_gauntlets_mult,
            });
        }
    }

    item(.{
        .id = "it_transfigured_lion_charm",
        .name = .{
            .english = "Transfigured Lion Charm",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .bluered,
    });
}

fn transfiguredSparkbladeSet() !void {
    const color = rgb(0x37, 0x5b, 0xe8);
    rns.start(.{
        .name = "Transfigured Sparkblade Set",
        .image_path = "images/sparkblade.png",
        .thumbnail_path = "images/sparkblade_thumbnail.png",
    });
    defer rns.end();

    item(.{
        .id = "it_transfigured_bluebolt_staff",
        .name = .{
            .english = "Transfigured Bluebolt Staff",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .blueyellow,
    });

    item(.{
        .id = "it_transfigured_lapis_sword",
        .name = .{
            .english = "Transfigured Lapis Sword",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .blueyellow,
    });

    item(.{
        .id = "it_transfigured_shockwave_tome",
        .name = .{
            .english = "Transfigured Shockwave Tome",
        },
        .description = .{
            .english = "Every [CD], apply [SPARK-5] to all enemies.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .blueyellow,

        .lootHbDispType = .cooldown,
        .cooldownType = .time,
        .cooldown = 10 * std.time.ms_per_s,
        .hbInput = .auto,

        .hbsType = .spark_5,
        .hbsLength = 5 * std.time.ms_per_s,
        .hbsStrMult = 30,
    });
    trig.autoStart(&.{.hb_auto_pl});
    qpat.hb_run_cooldown(.{});

    trig.hotbarUsed(&.{.hb_self});
    qpat.hb_run_cooldown(.{});
    qpat.hb_flash_item(.{});
    ttrg.players_opponent(.{});
    tset.hbs_def(.{});
    apat.poisonfrog_charm(.{});

    const battery_shield_sparks = 10;
    const battery_shield_invul_dur = 5 * std.time.ms_per_s;
    item(.{
        .id = "it_transfigured_battery_shield",
        .name = .{
            .english = "Transfigured Battery Shield",
        },
        .description = .{
            .english = "When you use your Defensive, apply [SPARK-5] to all enemies.#" ++
                "Every [VAR0_TIMES] you inflict spark, deal [STR] damage to all enemies and " ++
                "gain invulnerability for [VAR1_SECONDS].",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .blueyellow,

        .hbsType = .spark_5,
        .hbsLength = 5 * std.time.ms_per_s,
        .hbsStrMult = 20,

        .hbVar0 = battery_shield_sparks,
        .hbVar1 = battery_shield_invul_dur,

        .showSqVar = true,
        .autoOffSqVar0 = 0,

        .strMult = 1200,
        .delay = 150,
    });
    trig.hotbarUsedProc(&.{.hb_defensive});
    qpat.hb_flash_item(.{});
    ttrg.players_opponent(.{});
    tset.hbs_def(.{});
    apat.poisonfrog_charm(.{});

    trig.hbsCreated(&.{.hbs_selfcast});
    cond.eval(s.statusId, .@">=", @intFromEnum(Hbs.spark_0));
    cond.eval(s.statusId, .@"<=", @intFromEnum(Hbs.spark_6));
    qpat.hb_square_add_var(.{ .varIndex = 0, .amount = 1 });
    cond.hb_check_square_var(.{ 0, battery_shield_sparks });
    qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 0 });
    qpat.hb_flash_item(.{});
    ttrg.player_self(.{});
    apat.apply_invuln(.{ .duration = battery_shield_invul_dur });
    ttrg.players_opponent(.{});
    tset.strength_def(.{});
    apat.crown_of_storms(.{});

    item(.{
        .id = "it_transfigured_raiju_crown",
        .name = .{
            .english = "Transfigured Raiju Crown",
        },
        .description = .{
            .english = "At the start of each fight, inflict all enemies with [SPARK-6]",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .blueyellow,

        .hbsType = .spark_6,
        .hbsStrMult = 15,
        .hbsLength = 60 * std.time.ms_per_s,
    });
    trig.battleStart3(&.{});
    qpat.hb_flash_item(.{});
    ttrg.players_opponent(.{});
    tset.hbs_def(.{});
    apat.poisonfrog_charm(.{});

    item(.{
        .id = "it_transfigured_staticshock_earrings",
        .name = .{
            .english = "Transfigured Staticshock Earrings",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .blueyellow,
    });

    const stormdance_gown_times_dmg_dealt = 40;
    item(.{
        .id = "it_transfigured_stormdance_gown",
        .name = .{
            .english = "Transfigured Stormdance Gown",
        },
        .description = .{
            .english = "Every [VAR0] times you or debuffs you apply deal damage to an enemy, " ++
                "gain a random buff for [HBSL].",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .blueyellow,

        .showSqVar = true,
        .autoOffSqVar0 = 0,

        // Vanilla Redwhite Ribbon doesn't work if an items `hbsType` is not a buff
        .hbFlags = .{ .hidehbs = true },
        .hbsType = .smite_0,
        .hbsLength = 5 * std.time.ms_per_s,

        .hbVar0 = stormdance_gown_times_dmg_dealt,
    });
    trig.onDamageDone(&.{});
    qpat.hb_square_add_var(.{ .varIndex = 0, .amount = 1 });
    cond.hb_check_square_var(.{ 0, stormdance_gown_times_dmg_dealt });
    qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 0 });
    qpat.hb_flash_item(.{});
    ttrg.player_self(.{});
    tset.hbs_randombuff(.{});
    apat.apply_hbs(.{});

    item(.{
        .id = "it_transfigured_blackbolt_ribbon",
        .name = .{
            .english = "Transfigured Blackbolt Ribbon",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .blueyellow,
    });
}

fn transfiguredSwiftflightSet() !void {
    const color = rgb(0x3d, 0xe6, 0xe8);
    rns.start(.{
        .name = "Transfigured Swiftflight Set",
        .image_path = "images/swiftflight.png",
        .thumbnail_path = "images/swiftflight_thumbnail.png",
    });
    defer rns.end();

    item(.{
        .id = "it_transfigured_crane_katana",
        .name = .{
            .english = "Transfigured Crane Katana",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .bluegreen,
    });

    item(.{
        .id = "it_transfigured_falconfeather_dagger",
        .name = .{
            .english = "Transfigured Falconfeather Dagger",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .bluegreen,
    });

    const tornado_staff_dist = 15;
    item(.{
        .id = "it_transfigured_tornado_staff",
        .name = .{
            .english = "Transfigured Tornado Staff",
        },
        .description = .{
            .english = "Gain a random buff every time you move [VAR0] rabbitleaps.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .bluegreen,

        .showSqVar = true,
        .autoOffSqVar0 = 0,

        .hbVar0 = tornado_staff_dist,

        // Vanilla Redwhite Ribbon doesn't work if an items `hbsType` is not a buff
        .hbFlags = .{ .hidehbs = true },
        .hbsType = .smite_0,
        .hbsLength = 5 * std.time.ms_per_s,
    });
    trig.distanceTickBattle(&.{.pl_self});
    qpat.hb_square_add_var(.{ .varIndex = 0, .amount = 1 });
    cond.hb_check_square_var(.{ 0, tornado_staff_dist });
    qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 0 });
    qpat.hb_flash_item(.{});
    tset.hbs_randombuff(.{});
    ttrg.player_self(.{});
    apat.apply_hbs(.{});

    item(.{
        .id = "it_transfigured_cloud_guard",
        .name = .{
            .english = "Transfigured Cloud Guard",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .bluegreen,
    });

    const hermes_bow_dmg_per_leap = 25;
    item(.{
        .id = "it_transfigured_hermes_bow",
        .name = .{
            .english = "Transfigured Hermes Bow",
        },
        .description = .{
            .english = "Every [CD], fires a projectile at your targeted enemy that deals " ++
                "[VAR0] damage per rabbitleap moved since last fired.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .bluegreen,

        .showSqVar = true,
        .hbVar0 = hermes_bow_dmg_per_leap,

        .lootHbDispType = .cooldown,
        .cooldownType = .time,
        .cooldown = 10 * std.time.ms_per_s,
        .hbInput = .auto,

        .delay = 250,
        .radius = 1800,
        .hitNumber = 1,
        .strMult = hermes_bow_dmg_per_leap,
    });
    trig.autoStart(&.{.hb_auto_pl});
    qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 0 });
    qpat.hb_run_cooldown(.{});

    trig.distanceTickBattle(&.{.pl_self});
    qpat.hb_square_add_var(.{ .varIndex = 0, .amount = 1 });

    trig.hotbarUsed(&.{.hb_self});
    qpat.hb_run_cooldown(.{});
    qpat.hb_flash_item(.{});
    ttrg.players_opponent(.{});
    tset.uservar2("u_str", r.sqVar0, .@"*", hermes_bow_dmg_per_leap);
    tset.strength_def(.{});
    tset.strength(.{"u_str"});
    apat.floral_bow(.{});
    qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 0 });

    const talon_charm_reduction = -(1 * std.time.ms_per_s);
    const talon_charm_distance = 10;
    item(.{
        .id = "it_transfigured_talon_charm",
        .name = .{
            .english = "Transfigured Talon Charm",
        },
        .description = .{
            .english = "Decreases all cooldowns by [VAR0_SECONDS] every time you move [VAR1] " ++
                "rabbitleaps.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .bluegreen,

        .showSqVar = true,
        .hbVar0 = @abs(talon_charm_reduction),
        .hbVar1 = talon_charm_distance,
    });
    trig.battleStart0(&.{});
    qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 0 });

    trig.distanceTickBattle(&.{.pl_self});
    qpat.hb_square_add_var(.{ .varIndex = 0, .amount = 1 });
    cond.hb_check_square_var(.{ 0, talon_charm_distance });
    qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 0 });
    qpat.hb_flash_item(.{});
    ttrg.hotbarslots_current_players(.{});
    ttrg.hotbarslots_prune(thss.cooldown, .@">", 0);
    qpat.hb_add_cooldown(.{ .amount = talon_charm_reduction });

    const tiny_wings_leaps = 10.0;
    const tiny_wings_dmg_per_leaps = 0.01;
    item(.{
        .id = "it_transfigured_tiny_wings",
        .name = .{
            .english = "Transfigured Tiny Wings",
        },
        .description = .{
            .english = "You deal [VAR0_PERCENT] more damage per [VAR1] rabbitleaps moved since " ++
                "the start of each battle.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .bluegreen,

        .showSqVar = true,
        .hbVar0 = tiny_wings_dmg_per_leaps,
        .hbVar1 = tiny_wings_leaps,
    });
    trig.autoStart(&.{.hb_auto_pl});
    qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 0 });
    qpat.hb_square_set_var(.{ .varIndex = 1, .amount = 0 });
    qpat.hb_run_cooldown(.{});

    trig.distanceTickBattle(&.{.pl_self});
    qpat.hb_square_add_var(.{ .varIndex = 1, .amount = 1 });
    cond.hb_check_square_var(.{ 1, tiny_wings_leaps });
    qpat.hb_square_add_var(.{ .varIndex = 0, .amount = 1 });
    qpat.hb_square_set_var(.{ .varIndex = 1, .amount = 0 });
    qpat.hb_reset_statchange(.{});

    trig.strCalc0(&.{});
    tset.uservar2("u_mult", r.sqVar0, .@"*", tiny_wings_dmg_per_leaps);
    qpat.hb_reset_statchange_norefresh(.{});
    qpat.hb_add_statchange_norefresh(.{ .stat = .allMult, .amountStr = "u_mult" });

    const feathered_overcoat_mult = 0.25;
    item(.{
        .id = "it_transfigured_feathered_overcoat",
        .name = .{
            .english = "Transfigured Feathered Overcoat",
        },
        .description = .{
            .english = "You deal [VAR0_PERCENT] more damage while moving.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .bluegreen,
        .lootHbDispType = .glowing,

        .showSqVar = true,
        .hbVar0 = feathered_overcoat_mult,
    });
    trig.onSquarePickup(&.{.square_self});
    qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 0 });
    qpat.hb_reset_statchange(.{});

    trig.standingStill(&.{});
    cond.hb_check_square_var(.{ 0, 1 });
    qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 0 });
    qpat.hb_reset_statchange(.{});

    trig.distanceTick(&.{});
    cond.hb_check_square_var(.{ 0, 0 });
    qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 1 });
    qpat.hb_reset_statchange(.{});

    trig.strCalc0(&.{});
    qpat.hb_reset_statchange_norefresh(.{});
    cond.hb_check_square_var(.{ 0, 1 });
    qpat.hb_add_statchange_norefresh(.{
        .stat = .allMult,
        .amount = feathered_overcoat_mult,
    });
}

fn transfiguredSacredflameSet() !void {
    const color = rgb(0xe8, 0x8a, 0x72);
    rns.start(.{
        .name = "Transfigured Sacredflame Set",
        .image_path = "images/sacredflame.png",
        .thumbnail_path = "images/sacredflame_thumbnail.png",
    });
    defer rns.end();

    const flame_to_flow_mult = 0.1;
    for ([_]rns.Item{
        .{
            .id = "it_transfigured_sandpriestess_spear",
            .name = .{
                .english = "Transfigured Sandpriestess Spear",
            },
            .description = .{
                .english = "You deal [VAR0_PERCENT] more damage.#" ++
                    "Every time you gain [FLASH-STR], gain [FLOW-STR].",
            },
            .hbsType = .flowstr,
        },
        .{
            .id = "it_transfigured_flamedancer_dagger",
            .name = .{
                .english = "Transfigured Flamedancer Dagger",
            },
            .description = .{
                .english = "You deal [VAR0_PERCENT] more damage.#" ++
                    "Every time you gain [FLASH-DEX], gain [FLOW-DEX].",
            },
            .hbsType = .flowdex,
        },
        .{
            .id = "it_transfigured_whiteflame_staff",
            .name = .{
                .english = "Transfigured Whiteflame Staff",
            },
            .description = .{
                .english = "You deal [VAR0_PERCENT] more damage.#" ++
                    "Every time you gain [FLASH-INT], gain [FLOW-INT].",
            },
            .hbsType = .flowint,
        },
    }) |_item| {
        var i = _item;
        i.color = color;
        i.type = .loot;
        i.weaponType = .loot;
        i.treasureType = .redyellow;
        i.hbsLength = 5 * std.time.ms_per_s;
        i.allMult = flame_to_flow_mult;
        i.hbVar0 = flame_to_flow_mult;

        const flash_hbs: Hbs = switch (_item.hbsType.?) {
            .flowstr => .flashstr,
            .flowdex => .flashdex,
            .flowint => .flashint,
            else => unreachable,
        };

        item(i);
        trig.hbsCreated(&.{.hbs_selfafl});
        cond.eval(s.statusId, .@"==", @intFromEnum(flash_hbs));
        qpat.hb_flash_item(.{});
        ttrg.player_afflicted_source(.{});
        tset.hbs_def(.{});
        apat.apply_hbs(.{});
    }

    item(.{
        .id = "it_transfigured_sacred_shield",
        .name = .{
            .english = "Transfigured Sacred Shield",
        },
        .description = .{
            .english = "Whenever you gain invulnerability, gain [FLASH-INT].",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .redyellow,

        .hbsLength = 5 * std.time.ms_per_s,
        .hbsType = .flashint,
    });
    trig.onInvuln(&.{.pl_self});
    qpat.hb_flash_item(.{});
    ttrg.player_self(.{});
    tset.hbs_def(.{});
    apat.apply_hbs(.{});

    item(.{
        .id = "it_transfigured_marble_clasp",
        .name = .{
            .english = "Transfigured Marble Clasp",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .redyellow,
    });

    const sun_pendant_times = 10;
    item(.{
        .id = "it_transfigured_sun_pendant",
        .name = .{
            .english = "Transfigured Sun Pendant",
        },
        .description = .{
            .english = "Every [VAR0_TIMES] you use an ability, gain [FLASH-STR], [FLASH-DEX] " ++
                "and [FLASH-INT].",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .redyellow,

        .showSqVar = true,
        .autoOffSqVar0 = 0,
        .hbVar0 = sun_pendant_times,

        // Vanilla Redwhite Ribbon doesn't work if an items `hbsType` is not a buff
        .hbFlags = .{ .hidehbs = true },
        .hbsType = .flashstr,
        .hbsLength = 5 * std.time.ms_per_s,
    });
    for ([_]rns.Condition{ .hb_primary, .hb_secondary, .hb_special, .hb_defensive }) |c| {
        trig.hotbarUsedProc(&.{c});
        qpat.hb_square_add_var(.{ .varIndex = 0, .amount = 1 });
    }
    trig.hotbarUsed2(&.{});
    cond.hb_check_square_var(.{ 0, sun_pendant_times });
    qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 0 });
    qpat.hb_flash_item(.{});
    ttrg.player_self(.{});
    for ([_]Hbs{ .flashdex, .flashint, .flashstr }) |hbs| {
        tset.hbskey(.{ hbs, r.hbsLength });
        apat.apply_hbs(.{});
    }

    item(.{
        .id = "it_transfigured_tiny_hourglass",
        .name = .{
            .english = "Transfigured Tiny Hourglass",
        },
        .description = .{
            .english = "Every [CD], deal [STR] damage to all enemies.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .redyellow,

        .lootHbDispType = .cooldown,
        .cooldownType = .time,
        .cooldown = 60 * std.time.ms_per_s,
        .hbInput = .auto,

        .strMult = 2000,
        .delay = 150,
    });
    trig.autoStart(&.{.hb_auto_pl});
    qpat.hb_run_cooldown(.{});

    trig.hotbarUsed(&.{.hb_self});
    qpat.hb_run_cooldown(.{});
    qpat.hb_flash_item(.{});
    ttrg.players_opponent(.{});
    tset.strength_def(.{});
    apat.crown_of_storms(.{});

    item(.{
        .id = "it_transfigured_desert_earrings",
        .name = .{
            .english = "Transfigured Desert Earrings",
        },
        .description = .{
            .english = "Every time your allies gain a buff, you gain a buff of the same type " ++
                "for [HBSL].",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .redyellow,

        // Vanilla Redwhite Ribbon doesn't work if an items `hbsType` is not a buff
        .hbFlags = .{ .hidehbs = true },
        .hbsType = .smite_0,
        .hbsLength = 5 * std.time.ms_per_s,
    });
    for (Hbs.buffs) |buff| {
        trig.hbsCreated(&.{});
        cond.eval(s.statusId, .@"==", @intFromEnum(buff));
        cond.eval(s.playerId, .@"!=", r.playerId);
        cond.eval(s.teamId, .@"==", r.teamId);
        tset.hbskey(.{ buff, r.hbsLength });
        ttrg.player_self(.{});
        apat.apply_hbs(.{});
    }
}

fn transfiguredRuinsSet() !void {
    const color = rgb(0x65, 0xe8, 0xa2);
    rns.start(.{
        .name = "Transfigured Ruins Set",
        .image_path = "images/ruins.png",
        .thumbnail_path = "images/ruins_thumbnail.png",
    });
    defer rns.end();

    item(.{
        .id = "it_transfigured_giant_stone_club",
        .name = .{
            .english = "Transfigured Giant Stone Club",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .redgreen,
    });

    item(.{
        .id = "it_transfigured_ruins_sword",
        .name = .{
            .english = "Transfigured Ruins Sword",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .redgreen,
    });

    item(.{
        .id = "it_transfigured_mountain_staff",
        .name = .{
            .english = "Transfigured Mountain Staff",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .redgreen,
    });

    item(.{
        .id = "it_transfigured_boulder_shield",
        .name = .{
            .english = "Transfigured Boulder Shield",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .redgreen,
    });

    item(.{
        .id = "it_transfigured_golems_claymore",
        .name = .{
            .english = "Transfigured Golem's Claymore",
        },
        .description = .{
            .english = "Every [CD], using your Secondary grants you [STONESKIN] for [HBSL].#" ++
                "When [STONESKIN] or [GRANITESKIN] shields you from damage slice the air " ++
                "around you, dealing [STR] damage to nearby enemies.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .redgreen,

        .lootHbDispType = .cooldown,
        .cooldownType = .time,
        .cooldown = 5 * std.time.ms_per_s,

        .hbsType = .stoneskin,
        .hbsLength = 0.5 * std.time.ms_per_s,

        .delay = 150,
        .radius = 400,
        .strMult = 500,
    });
    trig.hotbarUsedProc(&.{.hb_secondary});
    cond.hb_available(.{});
    ttrg.player_self(.{});
    qpat.hb_run_cooldown(.{});
    qpat.hb_flash_item(.{});
    qpat.hb_cdloot_proc(.{});
    tset.hbs_def(.{});
    apat.apply_hbs(.{});

    trig.hbsShield2(&.{.pl_self});
    ttrg.player_self(.{});
    ttrg.hbstatus_target(.{});
    ttrg.hbstatus_prune(thbss.statusId, .@"==", @intFromEnum(Hbs.stoneskin));
    tset.uservar_hbscount(.{"u_stoneskins"});
    tset.uservar1("u_count", "u_stoneskins");
    ttrg.player_self(.{});
    ttrg.hbstatus_target(.{});
    ttrg.hbstatus_prune(thbss.statusId, .@"==", @intFromEnum(Hbs.graniteskin));
    tset.uservar_hbscount(.{"u_graniteskins"});
    tset.uservar2("u_count", "u_count", .@"+", "u_graniteskins");
    cond.eval("u_count", .@">", 0);
    qpat.hb_flash_item(.{});
    ttrg.players_opponent(.{});
    tset.strength_def(.{});
    apat.darkmagic_blade(.{});

    const stoneplate_armor_dmg_mult = 0.04;
    item(.{
        .id = "it_transfigured_stoneplate_armor",
        .name = .{
            .english = "Transfigured Stoneplate Armor",
        },
        .description = .{
            .english = "Every [CD], grants you [STONESKIN]. Starts battle off cooldown.#" ++
                "When [STONESKIN] or [GRANITESKIN] shields you from damage you permanently " ++
                "deal [VAR0_PERCENT] more damage.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .redgreen,

        .lootHbDispType = .cooldown,
        .cooldownType = .time,
        .cooldown = 60 * std.time.ms_per_s,
        .hbInput = .auto,

        .hbsType = .stoneskin,
        .hbsLength = 3 * std.time.ms_per_s,

        .showSqVar = true,
        .hbVar0 = stoneplate_armor_dmg_mult,
    });
    trig.onSquarePickup(&.{.square_self});
    qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 0 });

    trig.autoStart(&.{.hb_auto_pl});
    qpat.hb_run_cooldown(.{});

    trig.hotbarUsed(&.{.hb_self});
    ttrg.player_self(.{});
    qpat.hb_run_cooldown(.{});
    qpat.hb_flash_item(.{});
    tset.hbs_def(.{});
    apat.apply_hbs(.{});

    trig.hbsShield2(&.{.pl_self});
    ttrg.player_self(.{});
    ttrg.hbstatus_target(.{});
    ttrg.hbstatus_prune(thbss.statusId, .@"==", @intFromEnum(Hbs.stoneskin));
    tset.uservar_hbscount(.{"u_stoneskins"});
    tset.uservar1("u_count", "u_stoneskins");
    ttrg.player_self(.{});
    ttrg.hbstatus_target(.{});
    ttrg.hbstatus_prune(thbss.statusId, .@"==", @intFromEnum(Hbs.graniteskin));
    tset.uservar_hbscount(.{"u_graniteskins"});
    tset.uservar2("u_count", "u_count", .@"+", "u_graniteskins");
    cond.eval("u_count", .@">", 0);
    qpat.hb_flash_item(.{});
    qpat.hb_square_add_var(.{ .varIndex = 0, .amount = 1 });
    qpat.hb_reset_statchange(.{});

    trig.strCalc0(&.{});
    tset.uservar2("u_mult", r.sqVar0, .@"*", stoneplate_armor_dmg_mult);
    qpat.hb_reset_statchange_norefresh(.{});
    qpat.hb_add_statchange_norefresh(.{ .stat = .allMult, .amountStr = "u_mult" });

    item(.{
        .id = "it_transfigured_sacredstone_charm",
        .name = .{
            .english = "Transfigured Sacredstone Charm",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .redgreen,
    });

    item(.{
        .id = "it_transfigured_clay_rabbit",
        .name = .{
            .english = "Transfigured Clay Rabbit",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .redgreen,
    });
}

fn transfiguredLakeshrineSet() !void {
    const color = rgb(0x45, 0xcd, 0x9c);
    rns.start(.{
        .name = "Transfigured Lakeshrine Set",
        .image_path = "images/lakeshrine.png",
        .thumbnail_path = "images/lakeshrine_thumbnail.png",
    });
    defer rns.end();

    item(.{
        .id = "it_transfigured_waterfall_polearm",
        .name = .{
            .english = "Transfigured Waterfall Polearm",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .yellowgreen,
    });

    item(.{
        .id = "it_transfigured_vorpal_dao",
        .name = .{
            .english = "Transfigured Vorpal Dao",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .yellowgreen,
    });

    item(.{
        .id = "it_transfigured_jade_staff",
        .name = .{
            .english = "Transfigured Jade Staff",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .yellowgreen,
    });

    item(.{
        .id = "it_transfigured_reflection_shield",
        .name = .{
            .english = "Transfigured Reflection Shield",
        },
        .description = .{
            .english = "Every time you gain a buff, allies gain a buff of the same type for " ++
                "[HBSL].",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .yellowgreen,

        // Vanilla Redwhite Ribbon doesn't work if an items `hbsType` is not a buff
        .hbFlags = .{ .hidehbs = true },
        .hbsType = .smite_0,
        .hbsLength = 5 * std.time.ms_per_s,
    });
    for (Hbs.buffs) |buff| {
        trig.hbsCreated(&.{.hbs_selfafl});
        cond.eval(s.statusId, .@"==", @intFromEnum(buff));
        tset.hbskey(.{ buff, r.hbsLength });
        ttrg.players_ally(.{});
        ttrg.players_prune_self(.{});
        apat.apply_hbs(.{});
    }

    item(.{
        .id = "it_transfigured_butterfly_hairpin",
        .name = .{
            .english = "Transfigured Butterfly Hairpin",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .yellowgreen,
    });

    item(.{
        .id = "it_transfigured_watermage_pendant",
        .name = .{
            .english = "Transfigured Watermage Pendant",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .yellowgreen,
    });

    item(.{
        .id = "it_transfigured_raindrop_earrings",
        .name = .{
            .english = "Transfigured Raindrop Earrings",
        },
        .description = .{
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .yellowgreen,
    });

    item(.{
        .id = "it_transfigured_aquamarine_bracelet",
        .name = .{
            .english = "Transfigured Aquamarine Bracelet",
        },
        .description = .{
            .english = "At the start of each fight, gain 2 random buffs for [VAR0_SECONDS] " ++
                "seconds.",
        },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .yellowgreen,

        // Vanilla Redwhite Ribbon doesn't work if an items `hbsType` is not a buff
        .hbFlags = .{ .hidehbs = true },
        .hbsType = .smite_0,
        .hbsLength = std.time.ms_per_min,

        .hbVar0 = std.time.ms_per_min,
    });
    trig.battleStart3(&.{});
    qpat.hb_flash_item(.{});
    ttrg.player_self(.{});
    tset.hbs_randombuff(.{});
    apat.apply_hbs(.{});
    tset.hbs_randombuff(.{});
    apat.apply_hbs(.{});
}

const charspeed = rns.charspeed;
const item = rns.item;
const luck = rns.luck;
const rgb = rns.rgb;

const apat = rns.apat;
const cond = rns.cond;
const qpat = rns.qpat;
const trig = rns.trig;
const tset = rns.tset;
const ttrg = rns.ttrg;

const Condition = rns.Condition;
const Hbs = rns.Hbs;
const Stat = rns.Stat;
const Trigger = rns.Trigger;
const WeaponType = rns.WeaponType;

const s = rns.s;
const r = rns.r;
const tps = rns.tps;
const tp0 = rns.tp0;
const tp1 = rns.tp1;
const tp2 = rns.tp2;
const tp3 = rns.tp3;
const thss = rns.thss;
const ths0 = rns.ths0;
const ths1 = rns.ths1;
const ths2 = rns.ths2;
const ths3 = rns.ths3;
const thbss = rns.thbss;
const thbs0 = rns.thbs0;
const thbs1 = rns.thbs1;
const thbs2 = rns.thbs2;
const thbs3 = rns.thbs3;

const rns = @import("rns.zig");
const std = @import("std");
