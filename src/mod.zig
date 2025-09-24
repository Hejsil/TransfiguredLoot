const steam_description_header =
    \\Part of the Transfigured Loot collection https://steamcommunity.com/sharedfiles/filedetails/?id=3354085327
    \\
    \\Comparison between original loot and their Transfigured version:
    \\
;

pub fn main() !void {
    try transfiguredArcaneSet();
    try transfiguredNightSet();
    try transfiguredTimespaceSet();
    try transfiguredWindSet();
    try transfiguredBloodwolfSet();
    try transfiguredAssassinSet();
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
        .steam_description_header = steam_description_header,
    });
    defer rns.end();

    item(.{
        .id = "it_transfigured_raven_grimoire",
        .name = .{
            .original = "Raven Grimoire",
            .english = "Transfigured Raven Grimoire",
        },
        .description = .{
            .original = "Your Special applies CURSE.",
            .english = "Every [CD], your Special applies [HEXS].",
        },
        // .itemFlags = .{ .starting_item = true },
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
    cond.hb_available();
    ttrg.player_damaged();
    tset.hbs_def();
    apat.apply_hbs(.{});

    trig.hbsCreated(&.{.hbs_thishbcast});
    qpat.hb_run_cooldown();
    qpat.hb_cdloot_proc();
    qpat.hb_flash_item(.{});

    const blackwing_staff_mult = 0.15;
    item(.{
        .id = "it_transfigured_blackwing_staff",
        .name = .{
            .original = "Blackwing Staff",
            .english = "Transfigured Blackwing Staff",
        },
        .description = .{
            .original = "Your Primary applies CURSE.",
            .english = "Your Primary deals [VAR0_PERCENT] more damage. If an enemy is debuffed " ++
                "this value is tripled.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .purple,
        .lootHbDispType = .glowing,

        .glowSqVar0 = true,
        .autoOffSqVar0 = 0,

        .hbVar0 = blackwing_staff_mult,
    });
    trig.hbsCreated(&.{});
    cond.false(.{s.isBuff});
    qpat.hb_square_add_var(.{ .varIndex = 0, .amount = 1 });
    qpat.hb_reset_statchange();

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
            .original = "Curse Talon",
            .english = "Transfigured Curse Talon",
        },
        .description = .{
            .original = "Your Secondary applies CURSE.",
            .english = "Every [CD], your Secondary applies [HEXP].",
        },
        // .itemFlags = .{ .starting_item = true },
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
    cond.hb_available();
    qpat.hb_flash_item(.{});
    qpat.hb_cdloot_proc();
    qpat.hb_run_cooldown();
    ttrg.player_damaged();
    tset.hbs_def();
    apat.apply_hbs(.{});

    item(.{
        .id = "it_transfigured_darkmagic_blade",
        .name = .{
            .original = "Darkmagic Blade",
            .english = "Transfigured Darkmagic Blade",
        },
        .description = .{
            .original = "Every 10s, slices the air around you dealing 300 damage and applying " ++
                "CURSE to nearby enemies.",
            .english = "Every [CD], slice the air around you dealing [STR] damage.#" ++
                "Cooldown resets every time you inflict a debuff.",
        },
        // .itemFlags = .{ .starting_item = true },
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
    qpat.hb_run_cooldown();

    trig.hbsCreated(&.{.hbs_selfcast});
    cond.false(.{s.isBuff});
    ttrg.hotbarslot_self();
    qpat.hb_reset_cooldown();

    trig.hotbarUsed(&.{.hb_self});
    qpat.hb_flash_item(.{});
    qpat.hb_run_cooldown();
    ttrg.players_opponent();
    tset.strength_def();
    apat.darkmagic_blade(.{});

    const witchs_cloak_hbs_mult = 1.5;
    const witchs_cloak_ability_mult = -0.1;
    item(.{
        .id = "it_transfigured_witchs_cloak",
        .name = .{
            .original = "Witch's Cloak",
            .english = "Transfigured Witch's Cloak",
        },
        .description = .{
            .original = "Your Secondary deals 10% more damage. Debuffs you place deal 70% " ++
                "more damage. Slightly increases movement speed.",
            .english = "Your abilities deals [VAR0_PERCENT] less damage. Debuffs you place " ++
                "deal [VAR1_PERCENT] more damage. Slightly increases movement speed.",
        },
        // .itemFlags = .{ .starting_item = true },
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
            .original = "Crowfeather Hairpin",
            .english = "Transfigured Crowfeather Hairpin",
        },
        .description = .{
            .original = "Increases Special damage by 20%. When you place a debuff on an " ++
                "opponent, your Special has a 50% chance of resetting.",
            .english = "When your Special hits a debuffed enemy, deal an additional hit per " ++
                "debuff of [STR] damage.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .purple,

        .strMult = 35,
    });
    trig.onDamageDone(&.{.dmg_self_special});
    ttrg.hbstatus_target();
    ttrg.hbstatus_prune(thbss.isBuff, .@"==", 0);
    tset.uservar_hbscount(.{"u_debuff_count"});
    cond.eval("u_debuff_count", .@"!=", 0);
    ttrg.player_damaged();
    tset.strength_def();
    apat.melee_hit(.{ .numberStr = "u_debuff_count" });

    const redblack_ribbon_dmg_mult = 0.05;
    const redblack_ribbon_mult_length_hbs = 1.0;
    item(.{
        .id = "it_transfigured_redblack_ribbon",
        .name = .{
            .original = "Redblack Ribbon",
            .english = "Transfigured Redblack Ribbon",
        },
        .description = .{
            .original = "You deal 5% more damage. When you place a debuff on an opponent, " ++
                "your Defensive has a 50% chance of resetting.",
            .english = "You deal [VAR1_PERCENT] more damage. Debuffs you place last " ++
                "[VAR0_PERCENT] longer.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .purple,

        .allMult = redblack_ribbon_dmg_mult,
        .hbVar0 = redblack_ribbon_mult_length_hbs,
        .hbVar1 = redblack_ribbon_dmg_mult,
    });
    trig.cdCalc2b(&.{});
    ttrg.hotbarslots_current_players();
    ttrg.hotbarslots_prune_bufftype(.{0});
    qpat.hb_mult_length_hbs(.{ .mult = redblack_ribbon_mult_length_hbs + 1 });

    const opal_necklace_dmg_per_debuff = 0.20;
    item(.{
        .id = "it_transfigured_opal_necklace",
        .name = .{
            .original = "Opal Necklace",
            .english = "Transfigured Opal Necklace",
        },
        .description = .{
            .original = "When you use your Defensive, apply CURSE to all enemies.",
            .english = "For every debuff on enemies, you deal [VAR0_PERCENT] more damage.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .purple,
        .lootHbDispType = .glowing,

        .showSqVar = true,
        .glowSqVar0 = true,
        .autoOffSqVar0 = 0,

        .hbVar0 = opal_necklace_dmg_per_debuff,
    });
    trig.hbsCreated(&.{});
    cond.false(.{s.isBuff});
    qpat.hb_square_add_var(.{ .varIndex = 0, .amount = 1 });
    qpat.hb_reset_statchange();

    trig.hbsDestroyed(&.{});
    cond.false(.{s.isBuff});
    qpat.hb_square_add_var(.{ .varIndex = 0, .amount = -1 });
    qpat.hb_reset_statchange();

    trig.strCalc1c(&.{});
    tset.uservar2("u_hpMiss", r.sqVar0, .@"*", opal_necklace_dmg_per_debuff);
    qpat.hb_reset_statchange_norefresh();
    qpat.hb_add_statchange_norefresh(.{
        .stat = .allMult,
        .amountStr = "u_allMult",
    });
}

fn transfiguredNightSet() !void {
    const color = rgb(0x8d, 0x57, 0xd6);
    rns.start(.{
        .name = "Transfigured Night Set",
        .image_path = "images/night.png",
        .thumbnail_path = "images/night_thumbnail.png",
        .steam_description_header = steam_description_header,
    });
    defer rns.end();

    const sleeping_greatbow_cooldown = 12 * std.time.ms_per_s;
    item(.{
        .id = "it_transfigured_sleeping_greatbow",
        .name = .{
            .original = "Sleeping Greatbow",
            .english = "Transfigured Sleeping Greatbow",
        },
        .description = .{
            .original = "Every 6s, fires a slow-moving projectile at your targeted enemy that " ++
                "deals 200 damage.",
            .english = "Every [VAR0_SECONDS], fire a very slow-moving projectile at your " ++
                "targeted enemy that deals [STR] damage.",
        },
        // .itemFlags = .{ .starting_item = true },
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
    qpat.hb_run_cooldown();
    qpat.hb_flash_item(.{});
    ttrg.players_opponent();
    tset.strength_def();
    apat.sleeping_greatbow(.{});

    const transfigured_crescentmoon_dagger_hits = 2;
    item(.{
        .id = "it_transfigured_crescentmoon_dagger",
        .name = .{
            .original = "Crescentmoon Dagger",
            .english = "Transfigured Crescentmoon Dagger",
        },
        .description = .{
            .original = "Every 10s, your Secondary will deal an additional 400 damage on hit.",
            .english = "Every [CD], your Primary will deal an additional [VAR0] hits of " ++
                "[STR] damage on hit.#" ++
                "These hits always crit.",
        },
        // .itemFlags = .{ .starting_item = true },
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
    cond.hb_available();
    qpat.hb_run_cooldown();
    ttrg.player_damaged();
    tset.strength_def();
    tset.critratio(.{1});
    apat.black_wakizashi(.{});
    qpat.hb_flash_item(.{});
    qpat.hb_cdloot_proc();

    item(.{
        .id = "it_transfigured_lullaby_harp",
        .name = .{
            .original = "Lullaby Harp",
            .english = "Transfigured Lullaby Harp",
        },
        .description = .{
            .original = "Every 10s, resets Defensive cooldowns for you and all allies.",
            .english = "Every [CD], resets Special cooldowns for you and all allies.",
        },
        // .itemFlags = .{ .starting_item = true },
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
    qpat.hb_run_cooldown();
    ttrg.hotbarslots_ally();
    ttrg.hotbarslots_prune(thss.weaponType, .@"==", WeaponType.special);
    ttrg.hotbarslots_prune_noreset();
    qpat.hb_reset_cooldown();
    ttrg.hotbarslot_self();
    qpat.hb_flash_item(.{});

    const nightstar_grimoire_radius = 200;
    item(.{
        .id = "it_transfigured_nightstar_grimoire",
        .name = .{
            .original = "Nightstar Grimoire",
            .english = "Transfigured Nightstar Grimoire",
        },
        .description = .{
            .original = "Every 25s, deal 900 damage to all enemies.",
            .english = "Every [CD], hit a random area of the arena, dealing [STR] damage. If " ++
                "an enemy gets hit, the cooldown is reset.",
        },
        // .itemFlags = .{ .starting_item = true },
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
    qpat.hb_run_cooldown();
    tset.strength_def();
    ttrg.players_opponent();
    tset.uservar_random_range(.{ "u_x", nightstar_grimoire_radius, 1800 - nightstar_grimoire_radius });
    tset.uservar_random_range(.{ "u_y", nightstar_grimoire_radius, 1000 - nightstar_grimoire_radius });
    apat.meteor_staff(.{ .fxStr = "u_x", .fyStr = "u_y" });

    trig.autoStart(&.{.hb_auto_pl});
    qpat.hb_run_cooldown();

    trig.onDamageDone(&.{.dmg_self_thishb});
    qpat.hb_reset_cooldown();

    const moon_pendant_radius = 200;
    item(.{
        .id = "it_transfigured_moon_pendant",
        .name = .{
            .original = "Moon Pendant",
            .english = "Transfigured Moon Pendant",
        },
        .description = .{
            .original = "Every 12s, using your Special will deal 400 damage to enemies in a " ++
                "moderate radius around you.",
            .english = "Deals [STR] damage to a random area of the arena when you use your " ++
                "Special.",
        },
        // .itemFlags = .{ .starting_item = true },
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
    tset.strength_def();
    ttrg.players_opponent();
    tset.uservar_random_range(.{ "u_x", moon_pendant_radius, 1800 - moon_pendant_radius });
    tset.uservar_random_range(.{ "u_y", moon_pendant_radius, 1000 - moon_pendant_radius });
    apat.meteor_staff(.{ .fxStr = "u_x", .fyStr = "u_y" });

    const pajama_hat_cd_reduction = 2 * std.time.ms_per_s;
    item(.{
        .id = "it_transfigured_pajama_hat",
        .name = .{
            .original = "Pajama Hat",
            .english = "Transfigured Pajama Hat",
        },
        .description = .{
            .original = "Defensive and loot cooldowns are shortened by 2s.",
            .english = "Using your Defensive decreases all other cooldowns by [VAR0_SECONDS].",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .purple,

        .hbVar0 = pajama_hat_cd_reduction,
    });
    trig.hotbarUsedProc(&.{.hb_defensive});
    ttrg.hotbarslots_current_players();
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
            .original = "Stuffed Rabbit",
            .english = "Transfigured Stuffed Rabbit",
        },
        .description = .{
            .original = "Increases Special damage by 20%. Every 12s, using your Special will " ++
                "grant you invulnerability for 3s. Starts battle on cooldown.",
            .english = "Every [VAR0] times an ability or loot with a cooldown is activated, " ++
                "gain invulnerability for [VAR1_SECONDS].",
        },
        // .itemFlags = .{ .starting_item = true },
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
    ttrg.player_self();
    apat.apply_invuln(.{ .duration = stuffed_rabbit_invul_dur });

    item(.{
        .id = "it_transfigured_nightingale_gown",
        .name = .{
            .original = "Nightingale Gown",
            .english = "Transfigured Nightingale Gown",
        },
        .description = .{
            .original = "Every 15s, OMEGACHARGE your Special.",
            .english = "Every [CD] seconds, [OMEGACHARGE] your Secondary and Defensive.",
        },
        // .itemFlags = .{ .starting_item = true },
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
    qpat.hb_run_cooldown();
    qpat.hb_flash_item(.{});

    for ([_]WeaponType{ .secondary, .defensive }) |weapon_type| {
        trig.hotbarUsed2(&.{.hb_self});
        ttrg.hotbarslots_self_weapontype(.{weapon_type});
        cond.hb_check_chargeable0(.{});
        cond.eval(ths0.strengthMult, .@">", 0);
        qpat.hb_charge(.{ .type = .omegacharge });
    }

    trig.autoStart(&.{.hb_auto_pl});
    qpat.hb_run_cooldown();
}

fn transfiguredTimespaceSet() !void {
    const color = rgb(0x6e, 0x56, 0xe8);
    rns.start(.{
        .name = "Transfigured Timespace Set",
        .image_path = "images/timespace.png",
        .thumbnail_path = "images/timespace_thumbnail.png",
        .steam_description_header = steam_description_header,
    });
    defer rns.end();

    item(.{
        .id = "it_transfigured_eternity_flute",
        .name = .{
            .original = "Eternity Flute",
            .english = "Transfigured Eternity Flute",
        },
        .description = .{
            .original = "Every 12s, grants HASTE to all allies.",
            .english = "Every [CD], grant [BERSERK] to all allies.",
        },
        // .itemFlags = .{ .starting_item = true },
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
    qpat.hb_run_cooldown();

    trig.hotbarUsed(&.{.hb_self});
    qpat.hb_run_cooldown();
    ttrg.players_ally();
    tset.hbs_def();
    apat.apply_hbs(.{});

    const timewarp_wand_gcd_shorting = -0.1 * std.time.ms_per_s;
    item(.{
        .id = "it_transfigured_timewarp_wand",
        .name = .{
            .original = "Timewarp Wand",
            .english = "Transfigured Timewarp Wand",
        },
        .description = .{
            .original = "Your Secondary has a 40% chance of giving you HASTE.",
            .english = "Your GCDs are [VAR0_SECONDS] shorter.#" ++
                "When you have [HASTE-0] this value is doubled.",
        },
        // .itemFlags = .{ .starting_item = true },
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
    ttrg.hbstatus_target();
    ttrg.hbstatus_prune(thbss.statusId, .@">=", @intFromEnum(Hbs.hastes[0]));
    ttrg.hbstatus_prune(thbss.statusId, .@"<=", @intFromEnum(Hbs.hastes[Hbs.hastes.len - 1]));
    tset.uservar_hbscount(.{"u_hastes"});
    cond.unequal(.{ "u_hastes", 0 });
    for (WeaponType.abilities_with_gcd) |weapontype| {
        ttrg.hotbarslots_self_weapontype(.{weapontype});
        qpat.hb_add_gcd_permanent(.{ .amount = timewarp_wand_gcd_shorting });
    }

    item(.{
        .id = "it_transfigured_chrome_shield",
        .name = .{
            .original = "Chrome Shield",
            .english = "Transfigured Chrome Shield",
        },
        .description = .{
            .original = "Using your Defensive will grant you HASTE.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .purple,
    });

    item(.{
        .id = "it_transfigured_clockwork_tome",
        .name = .{
            .original = "Clockwork Tome",
            .english = "Transfigured Clockwork Tome",
        },
        .description = .{
            .original = "Your Special has a 50% chance of giving you HASTE.",
            .english = "Your abilities have a [LUCK] chance of giving a random haste buff.",
        },
        // .itemFlags = .{ .starting_item = true },
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
        qpat.hb_lucky_proc();
        tset.hbskey(.{ hbs, r.hbsLength });
        apat.apply_hbs(.{});
    }

    trig.hotbarUsed3(&.{.hb_selfcast});
    qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 3 });

    const metronome_boots_hbs_len = 5 * std.time.ms_per_s;
    item(.{
        .id = "it_transfigured_metronome_boots",
        .name = .{
            .original = "Metronome Boots",
            .english = "Transfigured Metronome Boots",
        },
        .description = .{
            .original = "Your GCDs become 1.1s. Also moderately increases movement speed.",
            .english = "Every [CD], switch between having [HASTE-2] and [SMITE-3].",
        },
        // .itemFlags = .{ .starting_item = true },
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
    ttrg.player_self();
    tset.hbskey(.{ Hbs.haste_2, r.hbsLength });
    apat.apply_hbs(.{});

    trig.hotbarUsed(&.{.hb_self});
    cond.hb_check_square_var(.{ 0, 1 });
    ttrg.player_self();
    tset.hbskey(.{ Hbs.smite_3, r.hbsLength });
    apat.apply_hbs(.{});

    trig.hotbarUsed2(&.{.hb_self});
    qpat.hb_square_add_var(.{ .varIndex = 0, .amount = 1 });
    qpat.hb_run_cooldown();
    qpat.hb_flash_item(.{});
    cond.hb_check_square_var(.{ 0, 2 });
    qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 0 });

    const timemage_cap_cd_set = 15 * std.time.ms_per_s;
    item(.{
        .id = "it_transfigured_timemage_cap",
        .name = .{
            .original = "Timemage Cap",
            .english = "Transfigured Timemage Cap",
        },
        .description = .{
            .original = "Cooldowns less than or equal to 10s become 5s.",
            .english = "Cooldowns greater than [VAR0_SECONDS] become [VAR0_SECONDS].",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .purple,

        .hbVar0 = timemage_cap_cd_set,
    });
    trig.cdCalc5(&.{});
    ttrg.hotbarslots_current_players();
    ttrg.hotbarslots_prune(thss.cooldown, .@">", timemage_cap_cd_set);
    qpat.hb_set_cooldown_permanent(.{ .time = timemage_cap_cd_set });

    const starry_cloak_cd_threshold = 15 * std.time.ms_per_s;
    item(.{
        .id = "it_transfigured_starry_cloak",
        .name = .{
            .original = "Starry Cloak",
            .english = "Transfigured Starry Cloak",
        },
        .description = .{
            .original = "Your Defensive's cooldown becomes 10s. Slightly increases movement speed.",
            .english = "When an ability or loot with a cooldown greater than or equal to " ++
                "[VAR0_SECONDS] is activated, gain [HASTE-2].",
        },
        // .itemFlags = .{ .starting_item = true },
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
    ttrg.player_self();
    tset.hbs_def();
    apat.apply_hbs(.{});

    trig.hbsCreated(&.{.hbs_thishbcast});
    qpat.hb_flash_item(.{});

    const gemini_necklace_proc_chance = 0.25;
    item(.{
        .id = "it_transfigured_gemini_necklace",
        .name = .{
            .original = "Gemini Necklace",
            .english = "Transfigured Gemini Necklace",
        },
        .description = .{
            .original = "Your Special and Defensive have a 30% chance of instantly resetting " ++
                "when used.",
            .english = "Your loot have a [LUCK] chance of instantly resetting when used.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .purple,

        .procChance = gemini_necklace_proc_chance,
    });
    trig.hotbarUsedProc(&.{.hb_loot});
    cond.random_def(.{});
    ttrg.hotbarslots_current_players();
    ttrg.hotbarslots_prune(thss.hbId, .@"==", s.hbId);
    cond.hb_check_resettable0(.{});
    qpat.hb_reset_cooldown();
    ttrg.hotbarslot_self();
    qpat.hb_flash_item(.{});
    qpat.hb_lucky_proc();
}

fn transfiguredWindSet() !void {
    const color = rgb(0x56, 0xe6, 0xd1);
    rns.start(.{
        .name = "Transfigured Wind Set",
        .image_path = "images/wind.png",
        .thumbnail_path = "images/wind_thumbnail.png",
        .steam_description_header = steam_description_header,
    });
    defer rns.end();

    const hawkfeather_fan_cd_reduction = -1 * std.time.ms_per_s;
    item(.{
        .id = "it_transfigured_hawkfeather_fan",
        .name = .{
            .original = "Hawkfeather Fan",
            .english = "Transfigured Hawkfeather Fan",
        },
        .description = .{
            .original = "Reduces your Special's cooldown by 2s.",
            .english = "All of your cooldowns are reduced by [VAR0_SECONDS].",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .blue,

        .hbVar0 = @abs(hawkfeather_fan_cd_reduction),
    });
    trig.cdCalc2b(&.{});
    ttrg.player_self();
    ttrg.hotbarslots_current_players();
    ttrg.hotbarslots_prune(thss.cooldown, .@">", 0);
    qpat.hb_add_cooldown_permanent(.{ .amount = hawkfeather_fan_cd_reduction });

    item(.{
        .id = "it_transfigured_windbite_dagger",
        .name = .{
            .original = "Windbite Dagger",
            .english = "Transfigured Windbite Dagger",
        },
        .description = .{
            .original = "Your Secondary's GCD becomes 0.5s, but its damage is reduced by 60%.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .blue,
    });

    const pidgeon_bow_num_proj = 3;
    item(.{
        .id = "it_transfigured_pidgeon_bow",
        .name = .{
            .original = "Pidgeon Bow",
            .english = "Transfigured Pidgeon Bow",
        },
        .description = .{
            .original = "Every 3s, fires a projectile at your targeted enemy that deals 70 damage.",
            .english = "Every [CD], fires [VAR0] projectiles at your targeted enemy that deals " ++
                "[STR] damage.",
        },
        // .itemFlags = .{ .starting_item = true },
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
    qpat.hb_run_cooldown();

    trig.hotbarUsed(&.{.hb_self});
    qpat.hb_run_cooldown();
    qpat.hb_flash_item(.{});
    ttrg.players_opponent();
    tset.strength_def();
    apat.floral_bow(.{});

    item(.{
        .id = "it_transfigured_shinsoku_katana",
        .name = .{
            .original = "Shinsoku Katana",
            .english = "Transfigured Shinsoku Katana",
        },
        .description = .{
            .original = "Your Primary's GCD has a 50% chance to be 0.8s instead of its " ++
                "normal amount.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .blue,
    });

    const eaglewing_charm_extra_dmg = 5;
    item(.{
        .id = "it_transfigured_eaglewing_charm",
        .name = .{
            .original = "Eaglewing Charm",
            .english = "Transfigured Eaglewing Charm",
        },
        .description = .{
            .original = "All your abilities deal 20 more damage. Significantly increases " ++
                "movement speed.",
            .english = "All your abilities deal [VAR0] more damage for every defensive used " ++
                "this battle. Slightly increases movement speed.",
        },
        // .itemFlags = .{ .starting_item = true },
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
    qpat.hb_reset_statchange();

    trig.strCalc2(&.{});
    ttrg.hotbarslots_current_players();
    ttrg.hotbarslots_prune_base_has_str();
    ttrg.hotbarslots_prune(thss.weaponType, .@"!=", WeaponType.loot);
    ttrg.hotbarslots_prune(thss.weaponType, .@"!=", WeaponType.potion);
    tset.uservar2("u_str", r.sqVar0, .@"*", eaglewing_charm_extra_dmg);
    qpat.hb_add_strength(.{ .amountStr = "u_str" });

    const sparrow_feather_dmg = 5;
    const sparrow_feather_dmg_inc = 5;
    item(.{
        .id = "it_transfigured_sparrow_feather",
        .name = .{
            .original = "Sparrow Feather",
            .english = "Transfigured Sparrow Feather",
        },
        .description = .{
            .original = "Deals 50 damage to all enemies when your Primary or Secondary is used.",
            .english = "Deals [VAR0] damage to all enemies when you use your Primary.#" ++
                "When you use your Secondary, this damage is increased by [VAR1] until the end " ++
                "of the fight.",
        },
        // .itemFlags = .{ .starting_item = true },
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
    ttrg.players_opponent();
    tset.strength_def();
    tset.strength(.{"u_str"});
    apat.crown_of_storms(.{});

    trig.hotbarUsedProc(&.{.hb_secondary});
    qpat.hb_square_add_var(.{ .varIndex = 0, .amount = 1 });

    item(.{
        .id = "it_transfigured_winged_cap",
        .name = .{
            .original = "Winged Cap",
            .english = "Transfigured Winged Cap",
        },
        .description = .{
            .original = "Grants a brief speed boost when your Secondary is used. Moderately " ++
                "increases movement speed.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .blue,
    });

    item(.{
        .id = "it_transfigured_thiefs_coat",
        .name = .{
            .original = "Thief's Coat",
            .english = "Transfigured Thief's Coat",
        },
        .description = .{
            .original = "Every 10s, Gain VANISH and gain a brief speed boost when you use " ++
                "your Special. Moderately increases movement speed.",
            .english = "Using your Defensive will grant you [VANISH].",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .blue,

        .hbsType = .vanish,
        .hbsLength = 3 * std.time.ms_per_s,
    });
    trig.hotbarUsedProc(&.{.hb_defensive});
    qpat.hb_flash_item(.{});
    tset.hbs_def();
    apat.apply_hbs(.{});
}

fn transfiguredBloodwolfSet() !void {
    const color = rgb(0x25, 0x3d, 0xb0);
    rns.start(.{
        .name = "Transfigured Bloodwolf Set",
        .image_path = "images/bloodwolf.png",
        .thumbnail_path = "images/bloodwolf_thumbnail.png",
        .steam_description_header = steam_description_header,
    });
    defer rns.end();

    item(.{
        .id = "it_transfigured_vampiric_dagger",
        .name = .{
            .original = "Vampiric Dagger",
            .english = "Transfigured Vampiric Dagger",
        },
        .description = .{
            .original = "Your Secondary inflicts Bleed.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .blue,
    });

    item(.{
        .id = "it_transfigured_bloody_bandage",
        .name = .{
            .original = "Bloody Bandage",
            .english = "Transfigured Bloody Bandage",
        },
        .description = .{
            .original = "When you use your Defensive, apply BLEED to all enemies.",
            .english = "When you used your Defensive, apply [BLEED-1] and [SAP] to enemies " ++
                "facing away from you.",
        },
        // .itemFlags = .{ .starting_item = true },
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
    ttrg.players_opponent_backstab();
    tset.hbs_def();
    tset.hbskey(.{ Hbs.bleed_1, r.hbsLength });
    apat.poisonfrog_charm(.{});
    tset.hbs_def();
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
            .original = "Leech Staff",
            .english = "Transfigured Leech Staff",
        },
        .description = .{
            .original = "Your Primary inflicts BLEED.",
            .english = "When a % chance succeeds, inflict [BLEED-3] to a random enemy.",
        },
        // .itemFlags = .{ .starting_item = true },
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
    tset.hbs_def();
    apat.poisonfrog_charm(.{});

    item(.{
        .id = "it_transfigured_bloodhound_greatsword",
        .name = .{
            .original = "Bloodhound Greatsword",
            .english = "Transfigured Bloodhound Greatsword",
        },
        .description = .{
            .original = "Every 12s, slices the air around you dealing 380 damage and applying " ++
                "BLEED to nearby enemies.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .blue,
    });

    item(.{
        .id = "it_transfigured_reaper_cloak",
        .name = .{
            .original = "Reaper Cloak",
            .english = "Transfigured Reaper Cloak",
        },
        .description = .{
            .original = "Your Defensive additionally deals 100 damage 3 times to enemies " ++
                "facing away from you. Slightly increases movement speed.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .blue,
    });

    const bloodflower_brooch_hits = 3;
    item(.{
        .id = "it_transfigured_bloodflower_brooch",
        .name = .{
            .original = "Bloodflower Brooch",
            .english = "Transfigured Bloodflower Brooch",
        },
        .description = .{
            .original = "All abilities deal 40 damage 2 times to enemies facing away from you.",
            .english = "Every [CD], apply [BLEED-1] to all enemies. Deal [STR] damage " ++
                "[VAR0_TIMES] to enemies you inflict with bleed.",
        },
        // .itemFlags = .{ .starting_item = true },
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
    qpat.hb_run_cooldown();

    trig.hotbarUsed(&.{.hb_self});
    qpat.hb_run_cooldown();
    qpat.hb_flash_item(.{});
    ttrg.players_opponent();
    tset.hbs_def();
    apat.poisonfrog_charm(.{});

    trig.hbsCreated(&.{.hbs_selfcast});
    cond.eval(s.statusId, .@">=", @intFromEnum(Hbs.bleeds[0]));
    cond.eval(s.statusId, .@"<=", @intFromEnum(Hbs.bleeds[Hbs.bleeds.len - 1]));
    qpat.hb_flash_item(.{});
    ttrg.player_afflicted_source();
    tset.strength_def();
    apat.melee_hit(.{});

    item(.{
        .id = "it_transfigured_wolf_hood",
        .name = .{
            .original = "Wolf Hood",
            .english = "Transfigured Wolf Hood",
        },
        .description = .{
            .original = "Every 6 seconds when you use your Primary, deal 250 damage to " ++
                "enemies facing away from you. Slightly increases movement speed.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .blue,
    });

    item(.{
        .id = "it_transfigured_blood_vial",
        .name = .{
            .original = "Blood Vial",
            .english = "Transfigured Blood Vial",
        },
        .description = .{
            .original = "At the start of each fight, inflict all enemies with SAP.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .blue,
    });
}

fn transfiguredAssassinSet() !void {
    const color = rgb(0x36, 0x50, 0xcf);
    rns.start(.{
        .name = "Transfigured Assassin Set",
        .image_path = "images/assassin.png",
        .thumbnail_path = "images/assassin_thumbnail.png",
        .steam_description_header = steam_description_header,
    });
    defer rns.end();

    item(.{
        .id = "it_transfigured_black_wakizashi",
        .name = .{
            .original = "Black Wakizashi",
            .english = "Transfigured Black Wakizashi",
        },
        .description = .{
            .original = "Your Primary has a 30% chance of dealing an additional 3 blows, " ++
                "dealing 50 damage each, in a radius around your target enemy.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .blue,
    });

    item(.{
        .id = "it_transfigured_throwing_dagger",
        .name = .{
            .original = "Throwing Dagger",
            .english = "Transfigured Throwing Dagger",
        },
        .description = .{
            .original = "Every 5s, fires a projectile at your targeted enemy that deals 120 " ++
                "damage. Cooldown resets every time you use your Special.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .blue,
    });

    item(.{
        .id = "it_transfigured_assassins_knife",
        .name = .{
            .original = "Assassin's Knife",
            .english = "Transfigured Assassin's Knife",
        },
        .description = .{
            .original = "Your Secondary has a 30% chance of dealing an additional 2 blows, " ++
                "dealing 50 damage each, in a radius around your target enemy.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
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
            .original = "Ninjutsu Scroll",
            .english = "Transfigured Ninjutsu Scroll",
        },
        .description = .{
            .original = "Your Special has a 30% chance of dealing an additional 3 blows, " ++
                "dealing 150 damage each, in a radius around your target enemy.",
            .english = "Your Special can deal up to [VAR0] additional blows, dealing [STR] " ++
                "damage each, in a radius around your target enemy.#" ++
                "Starting at [LUCK], each extra blow is [VAR1_PERCENT] less likely to happen " ++
                "as the previous.",
        },
        // .itemFlags = .{ .starting_item = true },
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
    qpat.hb_lucky_proc();
    ttrg.players_opponent();
    tset.strength_def();
    apat.black_wakizashi(.{ .numberStr = r.sqVar0 });

    item(.{
        .id = "it_transfigured_shadow_bracelet",
        .name = .{
            .original = "Shadow Bracelet",
            .english = "Transfigured Shadow Bracelet",
        },
        .description = .{
            .original = "Abilities and loot that hit more than once deal 30 more damage.",
            .english = "Abilities and loot that hit more than twice hits and additional time.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .blue,
    });
    trig.strCalc2(&.{});
    ttrg.hotbarslots_current_players();
    ttrg.hotbarslots_prune(thss.number, .@">", 2);
    qpat.hb_add_hitbox_var(.{
        .hitboxVar = .number,
        .amount = 1,
    });

    item(.{
        .id = "it_transfigured_ninja_robe",
        .name = .{
            .original = "Ninja Robe",
            .english = "Transfigured Ninja Robe",
        },
        .description = .{
            .original = "When a % chance succeeds, erase projectiles around you and VANISH. " ++
                "Slightly increases movement speed.",
            .english = "Your abilities have a [LUCK] chance of giving you [VANISH].",
        },
        // .itemFlags = .{ .starting_item = true },
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
        qpat.hb_lucky_proc();
        tset.hbs_def();
        apat.apply_hbs(.{});
    }

    const kunoichi_hood_str = 15;
    const kunoichi_hood_str_per_potions = 10;
    const kunoichi_hood_potion_str_mult = 2;
    item(.{
        .id = "it_transfigured_kunoichi_hood",
        .name = .{
            .original = "Kunoichi Hood",
            .english = "Transfigured Kunoichi Hood",
        },
        .description = .{
            .original = "Your abilities do 15 more damage. Your loot does 50 more damage. " ++
                "Slightly increases movement speed.",
            .english = "Your abilities do [VAR2] more damage and [VAR0] more " ++
                "damage per potion you have.#" ++
                "Your potions deal [VAR1_PERCENT] more damage.#" ++
                "Slightly increases movement speed.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .blue,

        .charspeed = charspeed.slightly,

        .hbVar0 = kunoichi_hood_str_per_potions,
        .hbVar1 = kunoichi_hood_potion_str_mult,
        .hbVar2 = kunoichi_hood_str,
    });
    trig.strCalc2(&.{});
    ttrg.hotbarslots_current_players();
    ttrg.hotbarslots_prune(thss.weaponType, .@"==", WeaponType.potion);
    tset.uservar_slotcount(.{"u_count"});
    tset.uservar2("u_str", "u_count", .@"*", kunoichi_hood_str_per_potions);
    tset.uservar2("u_str", "u_str", .@"+", kunoichi_hood_str);
    ttrg.hotbarslots_self_abilities();
    ttrg.hotbarslots_prune_base_has_str();
    qpat.hb_add_strength(.{ .amountStr = "u_str" });

    trig.strCalc1c(&.{});
    ttrg.hotbarslots_current_players();
    ttrg.hotbarslots_prune(thss.weaponType, .@"==", WeaponType.potion);
    qpat.hb_add_strcalcbuff(.{ .amount = kunoichi_hood_potion_str_mult });

    item(.{
        .id = "it_transfigured_shinobi_tabi",
        .name = .{
            .original = "Shinobi Tabi",
            .english = "Transfigured Shinobi Tabi",
        },
        .description = .{
            .original = "Standing still will cause you to VANISH and resets your Special. " ++
                "Available every 8s. Starts battle on cooldown. Slightly increases movement speed.",
            .english = "Standing still will cause you to [VANISH] for 2s. " ++
                "Available every [CD]. Slightly increases movement speed.",
        },
        // .itemFlags = .{ .starting_item = true },
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
    qpat.hb_run_cooldown();

    trig.standingStill(&.{.pl_self});
    cond.hb_available();
    qpat.hb_run_cooldown();
    qpat.hb_flash_item(.{});
    qpat.hb_cdloot_proc();
    tset.hbs_def();
    apat.thiefs_coat(.{});
}

fn transfiguredRockdragonSet() !void {
    const color = rgb(0xb9, 0x3b, 0x4f);
    rns.start(.{
        .name = "Transfigured Rockdragon Set",
        .image_path = "images/rockdragon.png",
        .thumbnail_path = "images/rockdragon_thumbnail.png",
        .steam_description_header = steam_description_header,
    });
    defer rns.end();

    item(.{
        .id = "it_transfigured_dragonhead_spear",
        .name = .{
            .original = "Dragonhead Spear",
            .english = "Transfigured Dragonhead Spear",
        },
        .description = .{
            .original = "Your Primary is 40% more powerful, but gains a cooldown of 3s. Also " ++
                "slightly reduces movement speed.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .red,
    });

    item(.{
        .id = "it_transfigured_granite_greatsword",
        .name = .{
            .original = "Granite Greatsword",
            .english = "Transfigured Granite Greatsword",
        },
        .description = .{
            .original = "Every 16s, slices a large radius around you dealing 700 damage.",
            .english = "Every [CD], slices a HUGE radius around you dealing [STR] damage.#" ++
                "Moving a rabbitleap puts the item on cooldown.#" ++
                "Also slightly reduces movement speed.",
        },
        // .itemFlags = .{ .starting_item = true },
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
    qpat.hb_run_cooldown();

    trig.distanceTick(&.{.pl_self});
    qpat.hb_run_cooldown();

    trig.hotbarUsed(&.{.hb_self});
    qpat.hb_run_cooldown();
    qpat.hb_flash_item(.{});
    ttrg.players_opponent();
    tset.strength_def();
    apat.darkmagic_blade(.{});

    const greysteel_shield_aoe = 1;
    const greysteel_shield_cd_reduction = -1 * std.time.ms_per_s;
    item(.{
        .id = "it_transfigured_greysteel_shield",
        .name = .{
            .original = "Greysteel Shield",
            .english = "Transfigured Greysteel Shield",
        },
        .description = .{
            .original = "Your Defensive has a 30% larger radius. Invulnerability effects " ++
                "last 1s longer.",
            .english = "Your Defensive has a [VAR0_PERCENT] larger radius and a [VAR1_SECOND] " ++
                "shorter cooldown.",
        },
        // .itemFlags = .{ .starting_item = true },
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
            .original = "Stonebreaker Staff",
            .english = "Transfigured Stonebreaker Staff",
        },
        .description = .{
            .original = "Your Special's cooldown is increased by 2s, but deals 40% more damage.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .red,

    });

    const tough_gauntlet_dmg = 80;
    item(.{
        .id = "it_transfigured_tough_gauntlet",
        .name = .{
            .original = "Tough Gauntlet",
            .english = "Transfigured Tough Gauntlet",
        },
        .description = .{
            .original = "Your abilities and loot all deal 30% more damage, but all GCDs are " ++
                "0.2s longer.",
            .english = "Abilities and loot that hit once deal [VAR0] more damage.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .red,

        .hbVar0 = tough_gauntlet_dmg,
    });
    trig.strCalc2(&.{});
    ttrg.hotbarslots_current_players();
    ttrg.hotbarslots_prune(thss.weaponType, .@"!=", WeaponType.potion);
    ttrg.hotbarslots_prune(thss.number, .@"<=", 1);
    ttrg.hotbarslots_prune(thss.strength, .@"!=", 0);
    qpat.hb_add_strength(.{ .amount = tough_gauntlet_dmg });

    const rockdragon_mail_every_nth_hit = 2;
    item(.{
        .id = "it_transfigured_rockdragon_mail",
        .name = .{
            .original = "Rockdragon Mail",
            .english = "Transfigured Rockdragon Mail",
        },
        .description = .{
            .original = "Your movement speed is significantly reduced.#" ++
                "Will shield you from damage for 2 seconds every 45 seconds.#" ++
                "Starts battle on a 5 second cooldown.",
            .english = "Shields you from every other hit.#" ++
                "Your movement speed is slightly reduced.",
        },
        // .itemFlags = .{ .starting_item = true },
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
    qpat.player_shield();
    ttrg.player_self();
    apat.apply_invuln(.{});

    item(.{
        .id = "it_transfigured_obsidian_hairpin",
        .name = .{
            .original = "Obsidian Hairpin",
            .english = "Transfigured Obsidian Hairpin",
        },
        .description = .{
            .original = "Increases Special damage by 20%. Whenever you gain invulnerability, " ++
                "your Special has a 50% chance of resetting.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .red,
    });

    item(.{
        .id = "it_transfigured_iron_greaves",
        .name = .{
            .original = "Iron Greaves",
            .english = "Transfigured Iron Greaves",
        },
        .description = .{
            .original = "Every 12s, standing still will grant brief invulnerability and reset " ++
                "your Defensive. Movement speed is slightly reduced. Starts battle on cooldown.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
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
        .steam_description_header = steam_description_header,
    });
    defer rns.end();

    item(.{
        .id = "it_transfigured_volcano_spear",
        .name = .{
            .original = "Volcano Spear",
            .english = "Transfigured Volcano Spear",
        },
        .description = .{
            .original = "Your Primary inflicts BURN.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .red,
    });

    item(.{
        .id = "it_transfigured_reddragon_blade",
        .name = .{
            .original = "Reddragon Blade",
            .english = "Transfigured Reddragon Blade",
        },
        .description = .{
            .original = "Your Secondary inflicts BURN.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .red,
    });

    item(.{
        .id = "it_transfigured_flame_bow",
        .name = .{
            .original = "Flame Bow",
            .english = "Transfigured Flame Bow",
        },
        .description = .{
            .original = "Every 10s, fires a projectile at your targeted enemy that deals 180 " ++
                "damage and applies BURN.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .red,
    });

    const meteor_staff_cd = 10 * std.time.ms_per_s;
    item(.{
        .id = "it_transfigured_meteor_staff",
        .name = .{
            .original = "Meteor Staff",
            .english = "Transfigured Meteor Staff",
        },
        .description = .{
            .original = "Your Special inflicts BURN.",
            .english = "Every [VAR0_SECONDS], your next large hit inflict [BURN-3].",
        },
        // .itemFlags = .{ .starting_item = true },
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
    cond.hb_available();
    qpat.hb_run_cooldown();
    ttrg.player_damaged();
    tset.hbs_def();
    tset.hbs_burnhit();
    apat.apply_hbs(.{});
    qpat.hb_cdloot_proc();

    trig.hbsCreated(&.{.hbs_thishbcast});
    qpat.hb_flash_item(.{});

    const phoenix_charm_hp = 1;
    const phoenix_charm_chance = 0.5;
    const phoenix_charm_dmg_per_missing_hp = 0.05;
    item(.{
        .id = "it_transfigured_phoenix_charm",
        .name = .{
            .original = "Phoenix Charm",
            .english = "Transfigured Phoenix Charm",
        },
        .description = .{
            .original = "If you perish in battle, restore to full HP instead. Only works once.",
            .english = "Has a [LUCK] chance to shield you from damage when you are at [VAR0] HP.#" ++
                "You deal [VAR1_PERCENT] more damage per missing HP.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .red,

        .hbsFlag = .{ .shield = true },

        .procChance = phoenix_charm_chance,
        .hbVar0 = phoenix_charm_hp,
        .hbVar1 = phoenix_charm_dmg_per_missing_hp,
    });
    trig.hbsShield5(&.{.pl_self});
    cond.eval(s.hp, .@"==", 1);
    cond.random_def(.{});
    ttrg.player_self();
    apat.apply_invuln(.{});
    qpat.player_shield();
    qpat.hb_flash_item(.{ .message = .shield });

    trig.onDamage(&.{.pl_self});
    qpat.hb_reset_statchange();

    trig.strCalc0(&.{});
    tset.uservar2("u_hpMiss", r.hpMax, .@"-", r.hp);
    tset.uservar2("u_allMult", "u_hpMiss", .@"*", phoenix_charm_dmg_per_missing_hp);
    qpat.hb_reset_statchange_norefresh();
    qpat.hb_add_statchange_norefresh(.{
        .stat = .allMult,
        .amountStr = "u_allMult",
    });

    item(.{
        .id = "it_transfigured_firescale_corset",
        .name = .{
            .original = "Firescale Corset",
            .english = "Transfigured Firescale Corset",
        },
        .description = .{
            .original = "All of your cooldowns are reduced by 3s. If you use your Defensive, " ++
                "this effect ends until the end of battle.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .red,
    });

    item(.{
        .id = "it_transfigured_demon_horns",
        .name = .{
            .original = "Demon Horns",
            .english = "Transfigured Demon Horns",
        },
        .description = .{
            .original = "All your abilities and loot deal 30% more damage. If you use your " ++
                "Defensive, this effect ends until the end of battle.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .red,
    });

    item(.{
        .id = "it_transfigured_flamewalker_boots",
        .name = .{
            .original = "Flamewalker Boots",
            .english = "Transfigured Flamewalker Boots",
        },
        .description = .{
            .original = "All GCDs are shortened by 15% and your movement speed is increased " ++
                "significantly. If you use your Defensive, this effect ends until the end of battle.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
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
        .steam_description_header = steam_description_header,
    });
    defer rns.end();

    item(.{
        .id = "it_transfigured_diamond_shield",
        .name = .{
            .original = "Diamond Shield",
            .english = "Transfigured Diamond Shield",
        },
        .description = .{
            .original = "Every 25s, using your Defensive will place down a small field for 3 " ++
                "seconds that erases projectiles. While standing in the field, allies don't " ++
                "take damage. Starts battle on 5 second cooldown.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .red,
    });

    item(.{
        .id = "it_transfigured_peridot_rapier",
        .name = .{
            .original = "Peridot Rapier",
            .english = "Transfigured Peridot Rapier",
        },
        .description = .{
            .original = "Increases Secondary damage by 20%. Every 8s, using your Secondary " ++
                "will grant you brief invulnerability and erase projectiles in a large radius " ++
                "around you.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .red,
    });

    const garnet_staff_dmg_per_erase = 0.05;
    item(.{
        .id = "it_transfigured_garnet_staff",
        .name = .{
            .original = "Garnet Staff",
            .english = "Transfigured Garnet Staff",
        },
        .description = .{
            .original = "Increases Special damage by 20%. Your Special will erase projectiles " ++
                "in a radius around you and grant brief invulnerability.",
            .english = "When an ability or loot effect erases projectiles in a radius around " ++
                "you, you deal [VAR0_PERCENT] more damage. Resets at the start of each battle.",
        },
        // .itemFlags = .{ .starting_item = true },
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
    qpat.hb_reset_statchange();

    trig.strCalc0(&.{});
    tset.uservar2("u_mult", r.sqVar0, .@"*", garnet_staff_dmg_per_erase);
    qpat.hb_reset_statchange_norefresh();
    qpat.hb_add_statchange_norefresh(.{ .stat = .allMult, .amountStr = "u_mult" });

    const sapphire_violin_num_buffs = 3;
    item(.{
        .id = "it_transfigured_sapphire_violin",
        .name = .{
            .original = "Sapphire Violin",
            .english = "Transfigured Sapphire Violin",
        },
        .description = .{
            .original = "Every 18s, grants ELEGY to all allies. Breaks if you take damage " ++
                "2 times. Starts battle on cooldown.",
            .english = "Every [CD] seconds, grant [VAR0] random buffs to all allies for " ++
                "[HBSL]. Breaks if you take damage. Starts the battle on cooldown.",
        },
        // .itemFlags = .{ .starting_item = true },
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
    qpat.hb_reset_statchange();
    qpat.hb_flash_item(.{ .message = .broken });
    qpat.hb_reset_cooldown();

    trig.hotbarUsed(&.{.hb_self});
    cond.hb_check_square_var_false(.{ 0, 0 });
    qpat.hb_run_cooldown();
    qpat.hb_flash_item(.{});
    ttrg.players_ally();
    for (0..sapphire_violin_num_buffs) |_| {
        tset.hbs_randombuff();
        apat.ornamental_bell(.{});
    }

    trig.strCalc0(&.{});
    cond.hb_check_square_var_lte(.{ 0, 0 });
    qpat.hb_set_cooldown_permanent(.{ .time = 0 });

    trig.autoStart(&.{.hb_auto_pl});
    cond.hb_check_square_var_false(.{ 0, 0 });
    qpat.hb_run_cooldown();

    item(.{
        .id = "it_transfigured_emerald_chestplate",
        .name = .{
            .original = "Emerald Chestplate",
            .english = "Transfigured Emerald Chestplate",
        },
        .description = .{
            .original = "The counter on this item will decrease instead of you taking damage. " ++
                "The counter starts at 3 on pickup.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .red,
    });

    item(.{
        .id = "it_transfigured_amethyst_bracelet",
        .name = .{
            .original = "Amethyst Bracelet",
            .english = "Transfigured Amethyst Bracelet",
        },
        .description = .{
            .original = "Deal 30% more damage. Breaks if you take damage 3 times.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .red,
    });

    const topaz_charm_haste_per_gold = -0.01;
    const topaz_charm_gold_per_haste = 4;
    item(.{
        .id = "it_transfigured_topaz_charm",
        .name = .{
            .original = "Topaz Charm",
            .english = "Transfigured Topaz Charm",
        },
        .description = .{
            .original = "Gain 8 extra Gold at the end of each fight. Breaks if you take " ++
                "damage 3 times.",
            .english = "Hastens GCD actions by [VAR0_PERCENT] for every [VAR1] gold you have. " ++
                "If you take damage, this effect is lost until the end of battle.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .red,

        .greySqVar0 = true,

        .hbVar0 = @abs(topaz_charm_haste_per_gold),
        .hbVar1 = topaz_charm_gold_per_haste,
    });
    trig.onSquarePickup(&.{.square_self});
    qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 1 });
    qpat.hb_reset_statchange();

    trig.battleStart0(&.{});
    qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 1 });
    qpat.hb_reset_statchange();

    trig.onDamage(&.{.pl_self});
    cond.hb_check_square_var(.{ 0, 1 });
    qpat.hb_flash_item(.{ .message = .broken });
    qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 0 });
    qpat.hb_reset_statchange();

    trig.strCalc0(&.{});
    qpat.hb_reset_statchange_norefresh();
    cond.hb_check_square_var(.{ 0, 1 });
    tset.uservar_gold(.{"u_gold"});
    tset.uservar2("u_haste", "u_gold", .@"*", topaz_charm_haste_per_gold);
    tset.uservar2("u_haste", "u_haste", .@"/", topaz_charm_gold_per_haste);
    qpat.hb_add_statchange_norefresh(.{
        .stat = .haste,
        .amountStr = "u_haste",
    });

    const ruby_circlet_start = 5;
    const ruby_circlet_stop = 0;
    const ruby_circlet_dmg_per_stock = 0.09;
    item(.{
        .id = "it_transfigured_ruby_circlet",
        .name = .{
            .original = "Ruby Circlet",
            .english = "Transfigured Ruby Circlet",
        },
        .description = .{
            .original = "Your Special deals 80% more damage. Breaks if you take damage once.",
            .english = "You deal [VAR0_PERCENT] more damage.#" ++
                "When you take damage, permanently reduce this value by [VAR1_PERCENT] " ++
                "(minimum [VAR2_PERCENT]).",
        },
        // .itemFlags = .{ .starting_item = true },
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
    qpat.hb_reset_statchange();
    qpat.hb_flash_item(.{ .message = .broken });

    trig.strCalc0(&.{});
    qpat.hb_reset_statchange_norefresh();
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
        .steam_description_header = steam_description_header,
    });
    defer rns.end();

    const brightstorm_spear_proc_chance = 0.1;
    const brightstorm_spear_strength = 200;
    item(.{
        .id = "it_transfigured_brightstorm_spear",
        .name = .{
            .original = "Brightstorm Spear",
            .english = "Transfigured Brightstorm Spear",
        },
        .description = .{
            .original = "Has a 30% chance of dealing 100 damage to all enemies when your " ++
                "Primary does damage.",
            .english = "Has a [LUCK] chance of dealing [STR] damage to all enemies when your " ++
                "other loot does damage.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .yellow,

        .procChance = brightstorm_spear_proc_chance,
        .strMult = brightstorm_spear_strength,
    });
    trig.onDamageDone(&.{.pl_self});
    ttrg.hotbarslots_current_players();
    ttrg.hotbarslots_prune(thss.hbId, .@"==", s.originHbId);
    ttrg.hotbarslots_prune(thss.hbId, .@"!=", r.hbId);
    ttrg.hotbarslots_prune(thss.weaponType, .@"==", WeaponType.loot);
    tset.uservar_slotcount(.{"u_count"});
    cond.eval("u_count", .@">", 0);
    cond.random_def(.{});
    qpat.hb_lucky_proc();
    qpat.hb_flash_item(.{});
    ttrg.players_opponent();
    tset.strength_def();
    apat.crown_of_storms(.{});

    item(.{
        .id = "it_transfigured_bolt_staff",
        .name = .{
            .original = "Bolt Staff",
            .english = "Transfigured Bolt Staff",
        },
        .description = .{
            .original = "Deals 150 damage to all enemies when you use your Special.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .yellow,
    });

    item(.{
        .id = "it_transfigured_lightning_bow",
        .name = .{
            .original = "Lightning Bow",
            .english = "Transfigured Lightning Bow",
        },
        .description = .{
            .original = "Every 12s, fires a projectile at your targeted enemy that deals " ++
                "300 damage. Cooldown instantly resets when a % chance succeeds.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .yellow,
    });

    item(.{
        .id = "it_transfigured_darkstorm_knife",
        .name = .{
            .original = "Darkstorm Knife",
            .english = "Transfigured Darkstorm Knife",
        },
        .description = .{
            .original = "Has a 30% chance of dealing 100 damage to all enemies when your " ++
                "Secondary does damage.",
            .english = "Deals [STR] damage to all enemies when your abilities deal damage.",
        },
        // .itemFlags = .{ .starting_item = true },
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
        ttrg.players_opponent();
        tset.strength_def();
        apat.crown_of_storms(.{});
    }

    const darkcloud_necklace_cooldown_reduction = 1 * std.time.ms_per_s;
    item(.{
        .id = "it_transfigured_darkcloud_necklace",
        .name = .{
            .original = "Darkcloud Necklace",
            .english = "Transfigured Darkcloud Necklace",
        },
        .description = .{
            .original = "Damage from loot is increased 50%.",
            .english = "When you use an ability, reduce the cooldown left on your loot " ++
                "by [VAR0_SECONDS].",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .yellow,

        .hbVar0 = darkcloud_necklace_cooldown_reduction,
    });

    for ([_]Condition{ .hb_primary, .hb_secondary, .hb_special, .hb_defensive }) |hb| {
        trig.hotbarUsedProc(&.{hb});
        for ([_]TriggerVariables{ ths0, ths1, ths2, ths3, ths4 }, 0..) |target_hotbar, i| {
            ttrg.hotbarslots_current_players();
            ttrg.hotbarslots_prune(thss.cooldown, .@">", 0);
            ttrg.hotbarslots_prune(thss.weaponType, .@"==", WeaponType.loot);

            tset.uservar_slotcount(.{"u_slots"});
            cond.eval("u_slots", .@">", i);

            ttrg.hotbarslots_prune(thss.hbId, .@"==", target_hotbar.hbId);
            tset.uservar2("u_new_cd", ths0.cdSecLeft, .@"-", darkcloud_necklace_cooldown_reduction);
            qpat.hb_run_cooldown_ext(.{ .lengthStr = "u_new_cd" });
        }
    }

    const crown_of_storms_mult = 0.25;
    item(.{
        .id = "it_transfigured_crown_of_storms",
        .name = .{
            .original = "Crown of Storms",
            .english = "Transfigured Crown of Storms",
        },
        .description = .{
            .original = "When a % chance succeeds, deal 200 damage to all enemies.",
            .english = "Your abilities and loot with a % chance deals [VAR0_PERCENT] more damage.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .yellow,

        .hbVar0 = crown_of_storms_mult,
    });
    trig.strCalc1c(&.{});
    ttrg.hotbarslots_current_players();
    ttrg.hotbarslots_prune(thss.luck, .@">", 0);
    qpat.hb_add_strcalcbuff(.{ .amount = crown_of_storms_mult });

    item(.{
        .id = "it_transfigured_thunderclap_gloves",
        .name = .{
            .original = "Thunderclap Gloves",
            .english = "Transfigured Thunderclap Gloves",
        },
        .description = .{
            .original = "All abilities have a 20% chance of dealing 200 damage to all enemies " ++
                "when used.",
            .english = "Every [CD] have a [LUCK] chance of dealing [STR] damage to all enemies.",
        },
        // .itemFlags = .{ .starting_item = true },
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
    qpat.hb_run_cooldown();
    cond.random_def(.{});
    qpat.hb_flash_item(.{});
    qpat.hb_lucky_proc();
    ttrg.players_opponent();
    tset.strength_def();
    apat.crown_of_storms(.{});

    item(.{
        .id = "it_transfigured_storm_petticoat",
        .name = .{
            .original = "Storm Petticoat",
            .english = "Transfigured Storm Petticoat",
        },
        .description = .{
            .original = "Do 250 damage to all enemies when you gain invulnerability.",
            .english = "Do [STR] damage to all enemies when you take damage.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .yellow,

        .strMult = 3000,
        .delay = 150,
    });
    trig.onDamage(&.{.pl_self});
    qpat.hb_flash_item(.{});
    ttrg.players_opponent();
    tset.strength_def();
    apat.crown_of_storms(.{});
}

fn transfiguredShrineSet() !void {
    const color = rgb(0xdb, 0x99, 0x85);
    rns.start(.{
        .name = "Transfigured Shrine Set",
        .image_path = "images/shrine.png",
        .thumbnail_path = "images/shrine_thumbnail.png",
        .steam_description_header = steam_description_header,
    });
    defer rns.end();

    item(.{
        .id = "it_transfigured_holy_greatsword",
        .name = .{
            .original = "Holy Greatsword",
            .english = "Transfigured Holy Greatsword",
        },
        .description = .{
            .original = "Every 10s, grants you SMITE and then slices the air around you, " ++
                "dealing 200 damage to nearby enemies.",
            .english = "Every [CD], slice the air around you dealing [STR] damage.#" ++
                "Cooldown resets every time you gain a buff.",
        },
        // .itemFlags = .{ .starting_item = true },
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
    qpat.hb_run_cooldown();

    trig.hbsCreated(&.{.hbs_selfafl});
    cond.eval(s.isBuff, .@"==", 1);
    ttrg.hotbarslot_self();
    qpat.hb_reset_cooldown();

    trig.hotbarUsed(&.{.hb_self});
    qpat.hb_flash_item(.{});
    qpat.hb_run_cooldown();
    ttrg.players_opponent();
    tset.strength_def();
    apat.darkmagic_blade(.{});

    const sacred_bow_mult_per_buff = 1;
    const sacred_bow_dmg = 250;
    item(.{
        .id = "it_transfigured_sacred_bow",
        .name = .{
            .original = "Sacred Bow",
            .english = "Transfigured Sacred Bow",
        },
        .description = .{
            .original = "Every 10s, fires a projectile at your targeted enemy that deals " ++
                "250 damage. Cooldown instantly resets when you gain a buff.",
            .english = "Every [CD], fires a projectile at your targeted enemy that deals " ++
                "[STR] damage.#Deals [VAR0_PERCENT] more damage for each buff on you.",
        },
        // .itemFlags = .{ .starting_item = true },
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
    qpat.hb_run_cooldown();

    trig.hotbarUsed(&.{.hb_self});
    qpat.hb_run_cooldown();
    qpat.hb_flash_item(.{});
    ttrg.player_self();
    ttrg.hbstatus_target();
    ttrg.hbstatus_prune(thbss.isBuff, .@"==", 1);
    tset.uservar_hbscount(.{"u_buffs"});
    tset.uservar2("u_allMult", "u_buffs", .@"*", sacred_bow_mult_per_buff);
    tset.uservar2("u_extraStr", "u_allMult", .@"*", sacred_bow_dmg);
    tset.uservar2("u_str", "u_extraStr", .@"+", sacred_bow_dmg);
    tset.strength_def();
    tset.strength(.{"u_str"});
    ttrg.players_opponent();
    apat.floral_bow(.{});

    item(.{
        .id = "it_transfigured_purification_rod",
        .name = .{
            .original = "Purification Rod",
            .english = "Transfigured Purification Rod",
        },
        .description = .{
            .original = "Every 18s, using your Primary will give you ELEGY.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .yellow,
    });

    item(.{
        .id = "it_transfigured_ornamental_bell",
        .name = .{
            .original = "Ornamental Bell",
            .english = "Transfigured Ornamental Bell",
        },
        .description = .{
            .original = "Every 15s, grants SMITE to all allies.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .yellow,
    });

    const shrinemaidens_kosode_mult = 0.1;
    const shrinemaidens_kosode_mult_per_buff = 0.1;
    item(.{
        .id = "it_transfigured_shrinemaidens_kosode",
        .name = .{
            .original = "Shrinemaiden's Kosode",
            .english = "Transfigured Shrinemaiden's Kosode",
        },
        .description = .{
            .original = "When you have a buff, your movement speed increases significantly " ++
                "and you deal 25% more damage.",
            .english = "You deal [VAR0_PERCENT] more damage.#" ++
                "You deal [VAR1_PERCENT] more damage for each buff on you.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .yellow,

        .allMult = shrinemaidens_kosode_mult,
        .hbVar0 = shrinemaidens_kosode_mult,
        .hbVar1 = shrinemaidens_kosode_mult_per_buff,
    });
    trig.strCalc0(&.{});
    ttrg.hbstatus_target();
    ttrg.hbstatus_prune(thbss.isBuff, .@"==", 1);
    tset.uservar_hbscount(.{"u_buffs"});
    tset.uservar2("u_allMult", "u_buffs", .@"*", shrinemaidens_kosode_mult_per_buff);
    qpat.hb_reset_statchange_norefresh();
    qpat.hb_add_statchange_norefresh(.{
        .stat = .allMult,
        .amountStr = "u_allMult",
    });

    item(.{
        .id = "it_transfigured_redwhite_ribbon",
        .name = .{
            .original = "Redwhite Ribbon",
            .english = "Transfigured Redwhite Ribbon",
        },
        .description = .{
            .original = "You deal 5% more damage. Buffs you place last 50% longer.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .yellow,
    });

    item(.{
        .id = "it_transfigured_divine_mirror",
        .name = .{
            .original = "Divine Mirror",
            .english = "Transfigured Divine Mirror",
        },
        .description = .{
            .original = "Every 10 times you use an ability, deal 500 damage to all enemies.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .yellow,
    });

    item(.{
        .id = "it_transfigured_golden_chime",
        .name = .{
            .original = "Golden Chime",
            .english = "Transfigured Golden Chime",
        },
        .description = .{
            .original = "Every 2 times you use your Defensive, gain ELEGY.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
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
        .steam_description_header = steam_description_header,
    });
    defer rns.end();

    const book_of_cheats_dmg_mult = 1;
    const book_of_cheats_luck = 0.9;
    const book_of_cheats_charspeed = 5;
    const book_of_cheats_haste = -0.3;
    item(.{
        .id = "it_transfigured_book_of_cheats",
        .name = .{
            .original = "Book of Cheats",
            .english = "Transfigured Book of Cheats",
        },
        .description = .{
            .original = "Your Special will have random, chaotic effects.",
            .english = "At the start of each battle and until it ends, gain one of the " ++
                "following:#" ++
                " #" ++
                "1-4: One of your abilities deal [VAR0_PERCENT] more damage.#" ++
                "5: Your loot deals [VAR0_PERCENT] more damage.#" ++
                "6: Debuffs you place deals [VAR0_PERCENT] more damage.#" ++
                "7: You are extremely fast.#" ++
                "8: You are extremely lucky.",
        },
        // .itemFlags = .{ .starting_item = true },
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
        qpat.hb_reset_statchange_norefresh();
        qpat.hb_add_statchange_norefresh(.{ .stat = stat, .amount = book_of_cheats_dmg_mult });
    }

    trig.strCalc0(&.{});
    cond.hb_check_square_var(.{ 0, 7 });
    qpat.hb_reset_statchange_norefresh();
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
    qpat.hb_reset_statchange_norefresh();
    qpat.hb_add_statchange_norefresh(.{
        .stat = .luck,
        .amount = book_of_cheats_luck,
    });

    item(.{
        .id = "it_transfigured_golden_katana",
        .name = .{
            .original = "Golden Katana",
            .english = "Transfigured Golden Katana",
        },
        .description = .{
            .original = "Your Primary and Secondary have a 5% chance to deal 100 damage 5 " ++
                "times to a large radius around your targeted enemy when used.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .yellow,
    });

    item(.{
        .id = "it_transfigured_glittering_trumpet",
        .name = .{
            .original = "Glittering Trumpet",
            .english = "Transfigured Glittering Trumpet",
        },
        .description = .{
            .original = "Every 20s, grant RABBITLUCK to all allies. Cooldown cannot be reset " ++
                "by ability or loot effects.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
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
            .original = "Royal Staff",
            .english = "Transfigured Royal Staff",
        },
        .description = .{
            .original = "Your Special deals extra damage based on how much gold you have " ++
                "(1% for every 1 gold).",
            .english = "Critical hits deal [VAR0_PERCENT] extra damage per [VAR1] Gold.#" ++
                "All abilities and loot's hitboxes are [VAR2_PERCENT] larger per [VAR3] Gold.",
        },
        // .itemFlags = .{ .starting_item = true },
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
    qpat.hb_reset_statchange();

    trig.strCalc0(&.{});
    tset.uservar_gold(.{"u_gold"});
    tset.uservar2("u_critDmg", "u_gold", .@"*", royal_staff_crit_dmg_buff);
    tset.uservar2("u_critDmg", "u_critDmg", .@"/", royal_staff_gold_per_crit_dmg);
    qpat.hb_reset_statchange_norefresh();
    qpat.hb_add_statchange_norefresh(.{
        .stat = .critDamage,
        .amountStr = "u_critDmg",
    });

    trig.strCalc2(&.{});
    tset.uservar_gold(.{"u_gold"});
    ttrg.hotbarslots_current_players();
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
            .original = "Ballroom Gown",
            .english = "Transfigured Ballroom Gown",
        },
        .description = .{
            .original = "Makes you slightly luckier and slightly increases your movement speed.",
            .english = "Makes everything very slightly better.",
        },
        // .itemFlags = .{ .starting_item = true },
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
    ttrg.hotbarslots_current_players();
    qpat.hb_mult_hitbox_var(.{
        .hitboxVar = .radius,
        .mult = 1 + ballroom_gown_buff * 0.01,
    });
    qpat.hb_add_strength(.{ .amount = ballroom_gown_buff });

    const silver_coin_dmg_mult = 0.35;
    item(.{
        .id = "it_transfigured_silver_coin",
        .name = .{
            .original = "Silver Coin",
            .english = "Transfigured Silver Coin",
        },
        .description = .{
            .original = "On pickup, gain 30 gold.",
            .english = "On pickup, flip the coin. 0 is heads, 1 is tails.#" ++
                " #" ++
                "On heads: Your Primary, Special and Debuffs deals [VAR0_PERCENT] more damage. " ++
                "Significantly increases movement speed.#" ++
                " #" ++
                "On tails: Your Secondary, Defensive and Loot deals [VAR0_PERCENT] more " ++
                "damage. Makes you significantly luckier.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .yellow,

        .showSqVar = true,
        .hbVar0 = silver_coin_dmg_mult,
    });
    trig.onSquarePickup(&.{.square_self});
    qpat.hb_reset_statchange();
    qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 0 });
    tset.uservar_random_range(.{ "u_flip", 0, 1 });
    cond.eval("u_flip", .@"<", 0.5);
    qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 1 });

    trig.strCalc0(&.{});
    cond.hb_check_square_var(.{ 0, 0 });
    qpat.hb_reset_statchange_norefresh();
    qpat.hb_add_statchange_norefresh(.{ .stat = .primaryMult, .amount = silver_coin_dmg_mult });
    qpat.hb_add_statchange_norefresh(.{ .stat = .specialMult, .amount = silver_coin_dmg_mult });
    qpat.hb_add_statchange_norefresh(.{ .stat = .hbsMult, .amount = silver_coin_dmg_mult });
    qpat.hb_add_statchange_norefresh(.{ .stat = .charspeed, .amount = charspeed.significantly });

    trig.strCalc0(&.{});
    cond.hb_check_square_var(.{ 0, 1 });
    qpat.hb_reset_statchange_norefresh();
    qpat.hb_add_statchange_norefresh(.{ .stat = .secondaryMult, .amount = silver_coin_dmg_mult });
    qpat.hb_add_statchange_norefresh(.{ .stat = .defensiveMult, .amount = silver_coin_dmg_mult });
    qpat.hb_add_statchange_norefresh(.{ .stat = .lootMult, .amount = silver_coin_dmg_mult });
    qpat.hb_add_statchange_norefresh(.{ .stat = .luck, .amount = luck.significantly });

    item(.{
        .id = "it_transfigured_queens_crown",
        .name = .{
            .original = "Queen's Crown",
            .english = "Transfigured Queen's Crown",
        },
        .description = .{
            .original = "Critical hits now deal 175% extra damage, instead of their normal " ++
                "75% extra damage.",
            .english = "Your crits have a [LUCK] chance to deal an additional [STR] damage.",
        },
        // .itemFlags = .{ .starting_item = true },
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
    qpat.hb_lucky_proc();
    ttrg.player_damaged();
    tset.strength_def();
    apat.curse_talon(.{});

    item(.{
        .id = "it_transfigured_mimick_rabbitfoot",
        .name = .{
            .original = "Mimick Rabbitfoot",
            .english = "Transfigured Mimick Rabbitfoot",
        },
        .description = .{
            .original = "Makes you significantly luckier. Not a real rabbit's foot.",
            .english = "Every [CD], proc as a % chance success.#" ++
                "Makes you slightly luckier. Also not a real rabbit's foot.",
        },
        // .itemFlags = .{ .starting_item = true },
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
    qpat.hb_run_cooldown();
    qpat.hb_flash_item(.{});
    qpat.hb_lucky_proc();
}

fn transfiguredLifeSet() !void {
    const color = rgb(0x78, 0xf2, 0x66);
    rns.start(.{
        .name = "Transfigured Life Set",
        .image_path = "images/life.png",
        .thumbnail_path = "images/life_thumbnail.png",
        .steam_description_header = steam_description_header,
    });
    defer rns.end();

    item(.{
        .id = "it_transfigured_butterfly_ocarina",
        .name = .{
            .original = "Butterfly Ocarina",
            .english = "Transfigured Butterfly Ocarina",
        },
        .description = .{
            .original = "On pickup, heal all allies for 1. Heals all allies for 1 HP " ++
                "every 2 fights.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .green,
    });

    item(.{
        .id = "it_transfigured_fairy_spear",
        .name = .{
            .original = "Fairy Spear",
            .english = "Transfigured Fairy Spear",
        },
        .description = .{
            .original = "Your Primary has a 30% larger radius and deals 40% more damage, but " ++
                "stops movement when used.",
            .english = "Every [CD], using your Primary will summon an ethereal ally that " ++
                "fires at your target, dealing [STR] damage each time.#The number of of times " ++
                "each ally will fire is equal to you HP.",
        },
        // .itemFlags = .{ .starting_item = true },
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
    qpat.hb_reset_statchange();

    trig.hotbarUsedProc(&.{.hb_primary});
    cond.hb_available();
    qpat.hb_run_cooldown();
    qpat.hb_cdloot_proc();
    ttrg.players_opponent();
    tset.strength_def();
    apat.druid_2(.{});

    trig.strCalc2(&.{});
    qpat.hb_add_hitbox_var(.{
        .hitboxVar = .number,
        .amountStr = r.hp,
    });

    item(.{
        .id = "it_transfigured_moss_shield",
        .name = .{
            .original = "Moss Shield",
            .english = "Transfigured Moss Shield",
        },
        .description = .{
            .original = "Every 12s, using your Defensive will reset its cooldown instantly.",
            .english = "Every [CD], abilities with multiple uses gains a use.",
        },
        // .itemFlags = .{ .starting_item = true },
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
    qpat.hb_run_cooldown();
    ttrg.hotbarslots_self_abilities();
    ttrg.hotbarslots_prune(thss.maxStock, .@">", 1);
    qpat.hb_increase_stock(.{ .amount = 1 });

    item(.{
        .id = "it_transfigured_floral_bow",
        .name = .{
            .original = "Floral Bow",
            .english = "Transfigured Floral Bow",
        },
        .description = .{
            .original = "Every 6s, fires a projectile at your targeted enemy that deals 250 " ++
                "damage. Only activates while standing still.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .green,
    });

    item(.{
        .id = "it_transfigured_blue_rose",
        .name = .{
            .original = "Blue Rose",
            .english = "Transfigured Blue Rose",
        },
        .description = .{
            .original = "Your max HP is increased by 1. Has a 50% chance of healing you for 1 " ++
                "and granting you 100 XP at the end of each fight.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .green,
    });

    const sunflower_crown_hp = 3;
    item(.{
        .id = "it_transfigured_sunflower_crown",
        .name = .{
            .original = "Sunflower Crown",
            .english = "Transfigured Sunflower Crown",
        },
        .description = .{
            .original = "Your max HP is increased by 1. You become able to graze slightly " ++
                "into a projectile without taking damage. Slightly increases movement speed.",
            .english = "Your max HP is increased by [VAR0]. You are easier to hit. Slightly " ++
                "increases movement speed.",
        },
        // .itemFlags = .{ .starting_item = true },
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
    ttrg.player_self();
    apat.heal_light(.{ .amount = sunflower_crown_hp });

    const midsummer_dress_hp = 1;
    const midsummer_dress_mult_per_hp = 0.04;
    item(.{
        .id = "it_transfigured_midsummer_dress",
        .name = .{
            .original = "Midsummer Dress",
            .english = "Transfigured Midsummer Dress",
        },
        .description = .{
            .original = "Your max HP is increased by 1. Ability or loot effects that " ++
                "temporarily slow your movement no longer affect you. Slightly increases " ++
                "movement speed.",
            .english = "Your max HP is increased by [VAR0]. You deal [VAR1_PERCENT] more " ++
                "damage per max HP. Slightly increases movement speed.",
        },
        // .itemFlags = .{ .starting_item = true },
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
    ttrg.player_self();
    apat.heal_light(.{ .amount = midsummer_dress_hp });

    trig.strCalc0(&.{});
    tset.uservar2("u_allMult", r.hpMax, .@"*", midsummer_dress_mult_per_hp);
    qpat.hb_reset_statchange_norefresh();
    qpat.hb_add_statchange_norefresh(.{
        .stat = .allMult,
        .amountStr = "u_allMult",
    });

    const grasswoven_bracelet_hp = 1;
    const grasswoven_bracelet_aoe_per_hp = 0.08;
    item(.{
        .id = "it_transfigured_grasswoven_bracelet",
        .name = .{
            .original = "Grasswoven Bracelet",
            .english = "Transfigured Grasswoven Bracelet",
        },
        .description = .{
            .original = "Your max HP is increased by 1. All abilities and loot's hitboxes are " ++
                "30% larger. Slightly increases movement speed.",
            .english = "Your max HP is increased by [VAR0]. All abilities and loot's hitboxes " ++
                "are [VAR1_PERCENT] larger per max HP. Slightly increases movement speed.",
        },
        // .itemFlags = .{ .starting_item = true },
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
    ttrg.player_self();
    apat.heal_light(.{ .amount = grasswoven_bracelet_hp });

    trig.strCalc2(&.{});
    ttrg.hotbarslots_current_players();
    tset.uservar2("u_aoeMult", r.hpMax, .@"*", grasswoven_bracelet_aoe_per_hp);
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
        .steam_description_header = steam_description_header,
    });
    defer rns.end();

    item(.{
        .id = "it_transfigured_snakefang_dagger",
        .name = .{
            .original = "Snakefang Dagger",
            .english = "Transfigured Snakefang Dagger",
        },
        .description = .{
            .original = "Your Secondary applies POISON.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .green,

    });

    item(.{
        .id = "it_transfigured_ivy_staff",
        .name = .{
            .original = "Ivy Staff",
            .english = "Transfigured Ivy Staff",
        },
        .description = .{
            .original = "Your Primary applies POISON.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .green,
    });

    item(.{
        .id = "it_transfigured_deathcap_tome",
        .name = .{
            .original = "Deathcap Tome",
            .english = "Transfigured Deathcap Tome",
        },
        .description = .{
            .original = "Your Special applies POISON.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .green,
    });

    item(.{
        .id = "it_transfigured_spiderbite_bow",
        .name = .{
            .original = "Spiderbite Bow",
            .english = "Transfigured Spiderbite Bow",
        },
        .description = .{
            .original = "Every 10s fires a projectile at your targeted enemy that deals 50 " ++
                "damage and applies Poison.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .green,
    });

    item(.{
        .id = "it_transfigured_compound_gloves",
        .name = .{
            .original = "Compound Gloves",
            .english = "Transfigured Compound Gloves",
        },
        .description = .{
            .original = "When you deal damage, has a 10% chance to apply DECAY.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .green,
    });

    item(.{
        .id = "it_transfigured_poisonfrog_charm",
        .name = .{
            .original = "Poisonfrog Charm",
            .english = "Transfigured Poisonfrog Charm",
        },
        .description = .{
            .original = "When a % chance succeeds, apply POISON to all enemies.",
            .english = "When a % chance succeeds, apply [HEXP] to all enemies for [HBSL].",
        },
        // .itemFlags = .{ .starting_item = true },
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
    ttrg.players_opponent();
    tset.hbs_def();
    apat.apply_hbs(.{});

    item(.{
        .id = "it_transfigured_venom_hood",
        .name = .{
            .original = "Venom Hood",
            .english = "Transfigured Venom Hood",
        },
        .description = .{
            .original = "Your abilities do 15 more damage. Debuffs you place deal 50 more damage.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .green,
    });

    item(.{
        .id = "it_transfigured_chemists_coat",
        .name = .{
            .original = "Chemist's Coat",
            .english = "Transfigured Chemist's Coat",
        },
        .description = .{
            .original = "Your Defensive applies Poison to nearby enemies. Slightly increases " ++
                "movement speed.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
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
        .steam_description_header = steam_description_header,
    });
    defer rns.end();

    item(.{
        .id = "it_transfigured_seashell_shield",
        .name = .{
            .original = "Seashell Shield",
            .english = "Transfigured Seashell Shield",
        },
        .description = .{
            .original = "Your Defensive has a random cooldown between 1s and 15s every time " ++
                "you use it.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .green,
    });

    const necronomicon_stacks_consumed = 3;
    item(.{
        .id = "it_transfigured_necronomicon",
        .name = .{
            .original = "Necronomicon",
            .english = "Transfigured Necronomicon",
        },
        .description = .{
            .original = "Every 8s, using your Special will reset its cooldown instantly and " ++
                "gains CHARGE.",
            .english = "When you use your Secondary, gain a stack.#" ++
                "Activating an ability with a cooldown consumes [VAR0] stack" ++
                (if (necronomicon_stacks_consumed != 1) "s" else "") ++
                " to reset its cooldown instantly.",
        },
        // .itemFlags = .{ .starting_item = true },
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
        qpat.hb_reset_cooldown();
        ttrg.hotbarslot_self();
        qpat.hb_square_add_var(.{ .varIndex = 0, .amount = -necronomicon_stacks_consumed });
        qpat.hb_flash_item(.{});
    }

    const tidal_greatsword_dmg_mult = 0.04;
    const tidal_greatsword_aoe_mult = 0.02;
    item(.{
        .id = "it_transfigured_tidal_greatsword",
        .name = .{
            .original = "Tidal Greatsword",
            .english = "Transfigured Tidal Greatsword",
        },
        .description = .{
            .original = "Every 12s slices a large radius around you dealing 200 damage. Slowly " ++
                "gets larger and deals more damage as a fight drags on.",
            .english = "Every [CD] slices a large radius around you dealing [STR] damage.#" ++
                "For each enemy hit, your abilities and loot deal [VAR0_PERCENT] more damage " ++
                "and has a [VAR1_PERCENT] larger hitbox until the end of battle.",
        },
        // .itemFlags = .{ .starting_item = true },
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
    qpat.hb_run_cooldown();

    trig.hotbarUsed(&.{.hb_self});
    qpat.hb_flash_item(.{});
    qpat.hb_run_cooldown();
    ttrg.players_opponent();
    tset.strength_def();
    apat.darkmagic_blade(.{});

    trig.onDamageDone(&.{.dmg_self_thishb});
    qpat.hb_square_add_var(.{ .varIndex = 0, .amount = 1 });
    qpat.hb_reset_statchange();

    trig.strCalc0(&.{});
    tset.uservar2("u_allMult", r.sqVar0, .@"*", tidal_greatsword_dmg_mult);
    qpat.hb_reset_statchange_norefresh();
    qpat.hb_add_statchange_norefresh(.{
        .stat = .allMult,
        .amountStr = "u_allMult",
    });

    trig.strCalc2(&.{});
    ttrg.hotbarslots_current_players();
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
            .original = "Occult Dagger",
            .english = "Transfigured Occult Dagger",
        },
        .description = .{
            .original = "Your Secondary is 80% more powerful. 5s of cooldown is added to your " ++
                "Secondary.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .green,
    });

    item(.{
        .id = "it_transfigured_mermaid_scalemail",
        .name = .{
            .original = "Mermaid Scalemail",
            .english = "Transfigured Mermaid Scalemail",
        },
        .description = .{
            .original = "All cooldowns are reduced by 2s. All loot and abilities with " ++
                "cooldowns start battles on a 8s cooldown.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
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
            .original = "Hydrous Blob",
            .english = "Transfigured Hydrous Blob",
        },
        .description = .{
            .original = "Every 8s, using your Secondary will fire an eldritch beast towards " ++
                "your target, dealing 300 damage. Starts battles on cooldown.",
            .english = "Every [CD], consume a stack to fire an eldritch beast towards your " ++
                "target, dealing [STR] damage.#" ++
                "Gains [VAR0] stack" ++ (if (hydrous_blob_secondary_stacks != 1) "s" else "") ++ " when you use your Secondary.#" ++
                "Gains [VAR1] stack" ++ (if (hydrous_blob_special_stacks != 1) "s" else "") ++ " when you use your Special.",
        },
        // .itemFlags = .{ .starting_item = true },
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
    qpat.hb_run_cooldown();

    trig.hotbarUsedProc(&.{.hb_secondary});
    qpat.hb_square_add_var(.{ .varIndex = 0, .amount = hydrous_blob_secondary_stacks });

    trig.hotbarUsedProc(&.{.hb_special});
    qpat.hb_square_add_var(.{ .varIndex = 0, .amount = hydrous_blob_special_stacks });

    trig.hotbarUsed(&.{.hb_self});
    cond.hb_check_square_var_false(.{ 0, 0 });
    qpat.hb_square_add_var(.{ .varIndex = 0, .amount = -1 });
    qpat.hb_run_cooldown();
    qpat.hb_flash_item(.{});
    ttrg.players_opponent();
    tset.strength_def();
    apat.hydrous_blob(.{});

    item(.{
        .id = "it_transfigured_abyss_artifact",
        .name = .{
            .original = "Abyss Artifact",
            .english = "Transfigured Abyss Artifact",
        },
        .description = .{
            .original = "Every 30s, using your Defensive will grant you SUPER. Starts on a 15s " ++
                "cooldown.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .green,
    });

    item(.{
        .id = "it_transfigured_lost_pendant",
        .name = .{
            .original = "Lost Pendant",
            .english = "Transfigured Lost Pendant",
        },
        .description = .{
            .original = "At the start of each fight, inflict all enemies with DECAY.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
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
        .steam_description_header = steam_description_header,
    });
    defer rns.end();

    item(.{
        .id = "it_transfigured_sawtooth_cleaver",
        .name = .{
            .original = "Sawtooth Cleaver",
            .english = "Transfigured Sawtooth Cleaver",
        },
        .description = .{
            .original = "Increases your Primary's damage by 30%, but decreases its radius by 20%.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .purpleblue,
    });

    item(.{
        .id = "it_transfigured_ravens_dagger",
        .name = .{
            .original = "Raven's Dagger",
            .english = "Transfigured Raven's Dagger",
        },
        .description = .{
            .original = "Increases your Secondary's damage by 50%, but decreases its radius by 40%.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .purpleblue,
    });

    item(.{
        .id = "it_transfigured_killing_note",
        .name = .{
            .original = "Killing Note",
            .english = "Transfigured Killing Note",
        },
        .description = .{
            .original = "Increases your Special's damage by 30%, but decreases its radius by 20%.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .purpleblue,
    });

    item(.{
        .id = "it_transfigured_blacksteel_buckler",
        .name = .{
            .original = "Blacksteel Buckler",
            .english = "Transfigured Blacksteel Buckler",
        },
        .description = .{
            .original = "Your Defensive's range decreases by 30%, but now has a 2s shorter " ++
                "cooldown and grants COUNTER.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .purpleblue,
    });

    const nightguard_gloves_dmg_mult = 0.35;
    item(.{
        .id = "it_transfigured_nightguard_gloves",
        .name = .{
            .original = "Nightguard Gloves",
            .english = "Transfigured Nightguard Gloves",
        },
        .description = .{
            .original = "Whichever ability has the highest base damage value deals 20% more damage.",
            .english = "Whichever ability has the lowest base damage value deals " ++
                "[VAR0_PERCENT] more damage.",
        },
        // .itemFlags = .{ .starting_item = true },
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
        ttrg.hotbarslots_self_abilities();
        ttrg.hotbarslots_prune_base_has_str();
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
            .original = "Sniper's Eyeglasses",
            .english = "Transfigured Sniper's Eyeglasses",
        },
        .description = .{
            .original = "You deal 30% more damage when you are separated from your target by " ++
                "at least 3 rabbitleaps.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .purpleblue,
    });

    item(.{
        .id = "it_transfigured_darkmage_charm",
        .name = .{
            .original = "Darkmage Charm",
            .english = "Transfigured Darkmage Charm",
        },
        .description = .{
            .original = "When you've been standing still for 1s, your Special deals 40% more damage.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .purpleblue,
    });

    const firststrike_bracelet_mult = 6;
    item(.{
        .id = "it_transfigured_firststrike_bracelet",
        .name = .{
            .original = "Firststrike Bracelet",
            .english = "Transfigured Firststrike Bracelet",
        },
        .description = .{
            .original = "Every 15s, gain BLACKSTRIKE when you use your Secondary.",
            .english = "The first ability you use in each battle deals [VAR0_PERCENT] more " ++
                "damage.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .purpleblue,

        .lootHbDispType = .glowing,
        .glowSqVar0 = true,
        .greySqVar0 = true,

        .hbVar0 = firststrike_bracelet_mult,
    });
    trig.onSquarePickup(&.{.square_self});
    qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 1 });
    qpat.hb_reset_statchange();

    trig.battleStart0(&.{});
    qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 1 });
    qpat.hb_flash_item(.{});
    qpat.hb_reset_statchange();

    const hb_conditions = [_]Condition{
        .hb_primary,
        .hb_secondary,
        .hb_special,
        .hb_defensive,
    };

    for (hb_conditions) |hotbar| {
        trig.hotbarUsedProc(&.{hotbar});
        cond.hb_check_square_var(.{ 0, 1 });
        qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 0 });
        qpat.hb_reset_statchange();
    }

    trig.strCalc0(&.{});
    tset.uservar2("u_mult", r.sqVar0, .@"*", firststrike_bracelet_mult);
    qpat.hb_reset_statchange_norefresh();
    qpat.hb_add_statchange_norefresh(.{ .stat = .primaryMult, .amountStr = "u_mult" });
    qpat.hb_add_statchange_norefresh(.{ .stat = .secondaryMult, .amountStr = "u_mult" });
    qpat.hb_add_statchange_norefresh(.{ .stat = .specialMult, .amountStr = "u_mult" });
    qpat.hb_add_statchange_norefresh(.{ .stat = .defensiveMult, .amountStr = "u_mult" });
}

fn transfiguredTimegemSet() !void {
    const color = rgb(0x50, 0x3a, 0xe8);
    rns.start(.{
        .name = "Transfigured Timegem Set",
        .image_path = "images/timegem.png",
        .thumbnail_path = "images/timegem_thumbnail.png",
        .steam_description_header = steam_description_header,
    });
    defer rns.end();

    const obsidian_rod_str = 80;
    item(.{
        .id = "it_transfigured_obsidian_rod",
        .name = .{
            .original = "Obsidian Rod",
            .english = "Transfigured Obsidian Rod",
        },
        .description = .{
            .original = "Your Special's strength becomes the total cooldown time of all your " ++
                "abilities and loot, in seconds, multiplied by 10, divided by the times it hits " ++
                "your target (Maximum of 1000 total).",
            .english = "Your Special's strength becomes the total GCD of all your abilities, " ++
                "in seconds, multiplied by [VAR0], divided by the times it hits your target.",
        },
        // .itemFlags = .{ .starting_item = true },
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
            .original = "Darkglass Spear",
            .english = "Transfigured Darkglass Spear",
        },
        .description = .{
            .original = "Your Primary's strength becomes your Special's cooldown, multiplied " ++
                "by 30, minus your Secondary's strength, divided by the times your Primary " ++
                "hits your target (Maximum of 500 total).",
            .english = "Your Secondary's strength becomes the same as the loot item " ++
                "with the highest strength, divided by the times it hits your target",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .purplered,

        .strMult = 200,
    });
    trig.strCalc1b(&.{});
    ttrg.hotbarslots_current_players();
    ttrg.hotbarslots_prune(thss.weaponType, .@"==", WeaponType.loot);
    for ([_]TriggerVariables{ ths5, ths4, ths3, ths2, ths1, ths0 }) |ths|
        ttrg.hotbarslots_prune(thss.strengthMult, .@">=", ths.strengthMult);

    tset.uservar1("u_str", ths0.strengthMult);

    ttrg.hotbarslots_self_weapontype(.{WeaponType.secondary});
    qpat.hb_set_strength(.{ .amountStr = "u_str" });
    cond.eval(ths0.number, .@">", 1);
    tset.uservar2("u_str", "u_str", .@"/", ths0.number);
    qpat.hb_set_strength(.{ .amountStr = "u_str" });

    item(.{
        .id = "it_transfigured_timespace_dagger",
        .name = .{
            .original = "Timespace Dagger",
            .english = "Transfigured Timespace Dagger",
        },
        .description = .{
            .original = "Your Secondary's strength becomes your Special and Defensive's " ++
                "cooldown added together, multiplied by 10, divided by the times your " ++
                "Secondary hits your target. (Maximum of 500 total).",
            .english = "Your Secondary's GCD becomes the GCD of your Primary.#" ++
                "Your Secondary's total strength becomes the total strength of your Special.#" ++
                "Your Secondary's cooldown becomes half the cooldown of your Defensive.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .purplered,
    });
    trig.strCalc1b(&.{});
    ttrg.hotbarslots_self_weapontype(.{WeaponType.special});
    tset.uservar2("u_str", ths0.strengthMult, .@"*", ths0.number);

    // Some abilities that hit onces will have `number` as 0. To counteract this, we filter for
    // it and adds the strenght back as `u_str` will be one in that case
    ttrg.hotbarslots_prune(ths0.number, .@"==", 0);
    tset.uservar2("u_str", "u_str", .@"+", ths0.strengthMult);

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
            .original = "Quartz Shield",
            .english = "Transfigured Quartz Shield",
        },
        .description = .{
            .original = "Your Defensive's cooldown becomes 30. When a loot item with a " ++
                "cooldown activates, the remaining timer on your Defensive is reduced by that amount.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .purplered,
    });

    item(.{
        .id = "it_transfigured_pocketwatch",
        .name = .{
            .original = "Pocketwatch",
            .english = "Transfigured Pocketwatch",
        },
        .description = .{
            .original = "Abilities with a GCD less than or equal to 1.1s deal 30% more damage.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .purplered,
    });

    item(.{
        .id = "it_transfigured_nova_crown",
        .name = .{
            .original = "Nova Crown",
            .english = "Transfigured Nova Crown",
        },
        .description = .{
            .original = "Your Special's cooldown becomes 30s. Every 8s, this loot item " ++
                "reduces your Special's cooldown timer to 1s and CHARGEs it.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .purplered,
    });

    item(.{
        .id = "it_transfigured_blackhole_charm",
        .name = .{
            .original = "Blackhole Charm",
            .english = "Transfigured Blackhole Charm",
        },
        .description = .{
            .original = "Deal 200 damage to all enemies when you use an ability or loot " ++
                "item with a cooldown of 10s or more. Hits one extra time for every 10s longer " ++
                "the cooldown is than that, up to 5 times.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .purplered,
    });

    item(.{
        .id = "it_transfigured_twinstar_earrings",
        .name = .{
            .original = "Twinstar Earrings",
            .english = "Transfigured Twinstar Earrings",
        },
        .description = .{
            .original = "Your Primary and Secondary now have a 2s GCD, and deal 70% more damage.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
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
        .steam_description_header = steam_description_header,
    });
    defer rns.end();

    const kyou_no_omikuji_dmg_mult = 0.30;
    item(.{
        .id = "it_transfigured_kyou_no_omikuji",
        .name = .{
            .original = "Kyou No Omikuji",
            .english = "Transfigured Kyou No Omikuji",
        },
        .description = .{
            .original = "All damage you deal increases by 50%. % chance triggers no longer " ++
                "happen, and you no longer hit for critical damage.",
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
    ttrg.hbstatus_source();
    qpat.hbs_destroy();

    trig.hbsCreated(&.{.hbs_selfafl});
    cond.true(.{s.isBuff});
    ttrg.hbstatus_source();
    qpat.hbs_destroy();

    item(.{
        .id = "it_transfigured_youkai_bracelet",
        .name = .{
            .original = "Youkai Bracelet",
            .english = "Transfigured Youkai Bracelet",
        },
        .description = .{
            .original = "All damage you deal increases by 40%. Your attacks will no longer " ++
                "have randomized damage, or hit for critical damage.",
            .english = "Your abilities base damage value becomes the average base damage " ++
                "value of all your abilities.",
        },
        .color = color_dark,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .purpleyellow,
    });
    trig.strCalc1c(&.{});
    ttrg.hotbarslots_self_abilities();
    ttrg.hotbarslots_prune_base_has_str();
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
            .original = "Oni Staff",
            .english = "Transfigured Oni Staff",
        },
        .description = .{
            .original = "Your Special deals 30% more damage. When a % chance succeeds, your " ++
                "Special goes on an 8s cooldown.",
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
    ttrg.hotbarslots_current_players();
    ttrg.hotbarslots_prune(thss.cooldown, .@">", 0);
    qpat.hb_run_cooldown_ext(.{ .length = oni_staff_cd });

    item(.{
        .id = "it_transfigured_kappa_shield",
        .name = .{
            .original = "Kappa Shield",
            .english = "Transfigured Kappa Shield",
        },
        .description = .{
            .original = "Your Defensive has a 3s shorter cooldown, but can no longer be reset " ++
                "by ability or loot effects.",
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
            .original = "Usagi Kamen",
            .english = "Transfigured Usagi Kamen",
        },
        .description = .{
            .original = "When a % chance succeeds, gain a random buff for 5s.",
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
    qpat.hb_reset_cooldown();

    item(.{
        .id = "it_transfigured_red_tanzaku",
        .name = .{
            .original = "Red Tanzaku",
            .english = "Transfigured Red Tanzaku",
        },
        .description = .{
            .original = "Miracles occasionally happen.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        .color = color_light,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .purpleyellow,
    });

    item(.{
        .id = "it_transfigured_vega_spear",
        .name = .{
            .original = "Vega Spear",
            .english = "Transfigured Vega Spear",
        },
        .description = .{
            .original = "Your Primary deals 70% more damage, but gains a 7s cooldown. When a % " ++
                "chance succeeds, its cooldown resets.",
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
            .original = "Altair Dagger",
            .english = "Transfigured Altair Dagger",
        },
        .description = .{
            .original = "Your Secondary deals 30% more damage, but its GCD becomes 3s. When " ++
                "you use your Secondary, it has a 90% chance to have a GCD of 1s instead.",
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
        .steam_description_header = steam_description_header,
    });
    defer rns.end();

    item(.{
        .id = "it_transfigured_ghost_spear",
        .name = .{
            .original = "Ghost Spear",
            .english = "Transfigured Ghost Spear",
        },
        .description = .{
            .original = "Your Primary now only deals 10 damage, and applies GHOSTFLAME.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .purplegreen,
    });

    item(.{
        .id = "it_transfigured_phantom_dagger",
        .name = .{
            .original = "Phantom Dagger",
            .english = "Transfigured Phantom Dagger",
        },
        .description = .{
            .original = "Your Secondary now only deals 10 damage, and applies GHOSTFLAME.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .purplegreen,
    });

    item(.{
        .id = "it_transfigured_cursed_candlestaff",
        .name = .{
            .original = "Cursed Candlestaff",
            .english = "Transfigured Cursed Candlestaff",
        },
        .description = .{
            .original = "Your Special now only deals 10 damage, and applies GHOSTFLAME.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .purplegreen,
    });

    item(.{
        .id = "it_transfigured_smoke_shield",
        .name = .{
            .original = "Smoke Shield",
            .english = "Transfigured Smoke Shield",
        },
        .description = .{
            .original = "Every 24s, your Defensive now grants GHOST. Your Secondary no longer " ++
                "breaks VANISH or GHOST.#" ++
                "Starts battle on a 5 second cooldown.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .purplegreen,
    });

    item(.{
        .id = "it_transfigured_haunted_gloves",
        .name = .{
            .original = "Haunted Gloves",
            .english = "Transfigured Haunted Gloves",
        },
        .description = .{
            .original = "Abilities and loot that hit for 100 damage or less now hit for " ++
                "100 damage, regardless of other loot effects.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .purplegreen,
    });

    item(.{
        .id = "it_transfigured_old_bonnet",
        .name = .{
            .original = "Old Bonnet",
            .english = "Transfigured Old Bonnet",
        },
        .description = .{
            .original = "Abilities and loot that hit once now deal 250 damage, regardless of " ++
                "other loot effects or ability effects.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .purplegreen,
    });

    item(.{
        .id = "it_transfigured_maid_outfit",
        .name = .{
            .original = "Maid Outfit",
            .english = "Transfigured Maid Outfit",
        },
        .description = .{
            .original = "Afflicts surrounding enemies with GHOSTFLAME when you gain " ++
                "invulnerability. Slightly increases movement speed.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .purplegreen,
    });

    item(.{
        .id = "it_transfigured_calling_bell",
        .name = .{
            .original = "Calling Bell",
            .english = "Transfigured Calling Bell",
        },
        .description = .{
            .original = "Every 12s, afflicts surrounding enemies with GHOSTFLAME.",
            .english = "Afflicts all enemies with [GHOSTFLAME-4] when an ability or " ++
                "loot with a cooldown is activated.",
        },
        // .itemFlags = .{ .starting_item = true },
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
    ttrg.players_opponent();
    tset.hbs_def();
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
        .steam_description_header = steam_description_header,
    });
    defer rns.end();

    item(.{
        .id = "it_transfigured_grandmaster_spear",
        .name = .{
            .original = "Grandmaster Spear",
            .english = "Transfigured Grandmaster Spear",
        },
        .description = .{
            .original = "Your Primary's damage increases by 40%. Your Special's cooldown  " ++
                "increases by 4s.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .bluered,
    });

    const teacher_knife_per_sec_mult = 0.01;
    item(.{
        .id = "it_transfigured_teacher_knife",
        .name = .{
            .original = "Teacher Knife",
            .english = "Transfigured Teacher Knife",
        },
        .description = .{
            .original = "Your Secondary's damage increases by 40%. 2s of cooldown is added to " ++
                "your Primary.",
            .english = "For each second of cooldown on your abilities your Secondary deals " ++
                "[VAR0_PERCENT] more damage.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .bluered,

        .hbVar0 = teacher_knife_per_sec_mult,
    });
    trig.strCalc1c(&.{});
    ttrg.hotbarslots_current_players();
    ttrg.hotbarslots_prune(thss.weaponType, .@"!=", WeaponType.potion);
    ttrg.hotbarslots_prune(thss.weaponType, .@"!=", WeaponType.loot);
    ttrg.hotbarslots_prune(thss.cooldown, .@">", 0);

    for ([_]TriggerVariables{ ths0, ths1, ths2, ths3 }) |ths| {
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
            .original = "Tactician Rod",
            .english = "Transfigured Tactician Rod",
        },
        .description = .{
            .original = "Your Special's damage increases by 30%. 2s of cooldown is added to " ++
                "your Secondary.",
            .english = "Your Special no longer has a cooldown, but deals [VAR0_PERCENT] less " ++
                "damage.",
        },
        // .itemFlags = .{ .starting_item = true },
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
            .original = "Spiked Shield",
            .english = "Transfigured Spiked Shield",
        },
        .description = .{
            .original = "When an ability or loot effect erases projectiles in a radius around " ++
                "you, deal 300 damage to that radius as well.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .bluered,
    });

    item(.{
        .id = "it_transfigured_battlemaiden_armor",
        .name = .{
            .original = "Battlemaiden Armor",
            .english = "Transfigured Battlemaiden Armor",
        },
        .description = .{
            .original = "Using your Defensive will reset loot and ability cooldowns with less " ++
                "than 8s left on their timer.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .bluered,
    });

    const gladiator_helmet_dmg_mult = 0.2;
    item(.{
        .id = "it_transfigured_gladiator_helmet",
        .name = .{
            .original = "Gladiator Helmet",
            .english = "Transfigured Gladiator Helmet",
        },
        .description = .{
            .original = "Abilities and loot that have cooldowns deal 20% more damage.",
            .english = "Abilities and loot that doesn't have cooldowns deal [VAR0_PERCENT] " ++
                "more damage.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .bluered,

        .hbVar0 = gladiator_helmet_dmg_mult,
    });
    trig.strCalc1c(&.{});
    ttrg.hotbarslots_current_players();
    ttrg.hotbarslots_prune(thss.weaponType, .@"!=", WeaponType.potion);
    ttrg.hotbarslots_prune(thss.cooldown, .@"==", 0);
    qpat.hb_add_strcalcbuff(.{ .amount = gladiator_helmet_dmg_mult });

    const lancer_gauntlets_mult = 0.35;
    item(.{
        .id = "it_transfigured_lancer_gauntlets",
        .name = .{
            .original = "Lancer Gauntlets",
            .english = "Transfigured Lancer Gauntlets",
        },
        .description = .{
            .original = "All damage is increased by 30%. Your Primary and Secondary gain " ++
                "cooldowns of 2s.",
            .english = "Abilities different from the one you used last deal [VAR0_PERCENT] " ++
                "more damage.",
        },
        // .itemFlags = .{ .starting_item = true },
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
        qpat.hb_reset_statchange();

        trig.strCalc0(&.{});
        cond.hb_check_square_var(.{ 0, i });
        qpat.hb_reset_statchange_norefresh();
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
            .original = "Lion Charm",
            .english = "Transfigured Lion Charm",
        },
        .description = .{
            .original = "Deal 180 damage to nearby enemies when an ability or loot with a " ++
                "cooldown is activated.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
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
        .steam_description_header = steam_description_header,
    });
    defer rns.end();

    item(.{
        .id = "it_transfigured_bluebolt_staff",
        .name = .{
            .original = "Bluebolt Staff",
            .english = "Transfigured Bluebolt Staff",
        },
        .description = .{
            .original = "Your Primary applies SPARK.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .blueyellow,
    });

    item(.{
        .id = "it_transfigured_lapis_sword",
        .name = .{
            .original = "Lapis Sword",
            .english = "Transfigured Lapis Sword",
        },
        .description = .{
            .original = "Your Secondary applies SPARK.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .blueyellow,
    });

    item(.{
        .id = "it_transfigured_shockwave_tome",
        .name = .{
            .original = "Shockwave Tome",
            .english = "Transfigured Shockwave Tome",
        },
        .description = .{
            .original = "Your Special applies SPARK.",
            .english = "Every [CD], apply [SPARK-5] to all enemies.",
        },
        // .itemFlags = .{ .starting_item = true },
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
    qpat.hb_run_cooldown();

    trig.hotbarUsed(&.{.hb_self});
    qpat.hb_run_cooldown();
    qpat.hb_flash_item(.{});
    ttrg.players_opponent();
    tset.hbs_def();
    apat.poisonfrog_charm(.{});

    const battery_shield_sparks = 8;
    const battery_shield_invul_dur = 5 * std.time.ms_per_s;
    item(.{
        .id = "it_transfigured_battery_shield",
        .name = .{
            .original = "Battery Shield",
            .english = "Transfigured Battery Shield",
        },
        .description = .{
            .original = "Every 30 times you or debuffs you apply deal damage to an enemy, " ++
                "your Defensive's cooldown resets.",
            .english = "When you use your Defensive, apply [SPARK-5] to all enemies.#" ++
                "Every [VAR0_TIMES] you inflict spark, deal [STR] damage to all enemies and " ++
                "gain invulnerability for [VAR1_SECONDS].",
        },
        // .itemFlags = .{ .starting_item = true },
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

        .strMult = 1300,
        .delay = 150,
    });
    trig.hotbarUsedProc(&.{.hb_defensive});
    qpat.hb_flash_item(.{});
    ttrg.players_opponent();
    tset.hbs_def();
    apat.poisonfrog_charm(.{});

    trig.hbsCreated(&.{.hbs_selfcast});
    cond.eval(s.statusId, .@">=", @intFromEnum(Hbs.sparks[0]));
    cond.eval(s.statusId, .@"<=", @intFromEnum(Hbs.sparks[Hbs.sparks.len - 1]));
    qpat.hb_square_add_var(.{ .varIndex = 0, .amount = 1 });
    cond.hb_check_square_var(.{ 0, battery_shield_sparks });
    qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 0 });
    qpat.hb_flash_item(.{});
    ttrg.player_self();
    apat.apply_invuln(.{ .duration = battery_shield_invul_dur });
    ttrg.players_opponent();
    tset.strength_def();
    apat.crown_of_storms(.{});

    item(.{
        .id = "it_transfigured_raiju_crown",
        .name = .{
            .original = "Raiju Crown",
            .english = "Transfigured Raiju Crown",
        },
        .description = .{
            .original = "Every 20 times you or debuffs you apply deal damage to an enemy, " ++
                "apply SPARK to all enemies.",
            .english = "At the start of each fight, inflict all enemies with [SPARK-6]",
        },
        // .itemFlags = .{ .starting_item = true },
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
    ttrg.players_opponent();
    tset.hbs_def();
    apat.poisonfrog_charm(.{});

    item(.{
        .id = "it_transfigured_staticshock_earrings",
        .name = .{
            .original = "Staticshock Earrings",
            .english = "Transfigured Staticshock Earrings",
        },
        .description = .{
            .original = "Every 10 times you or debuffs you apply deal damage to an enemy, " ++
                "deal 150 damage to all enemies.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .blueyellow,
    });

    const stormdance_gown_times_dmg_dealt = 40;
    item(.{
        .id = "it_transfigured_stormdance_gown",
        .name = .{
            .original = "Stormdance Gown",
            .english = "Transfigured Stormdance Gown",
        },
        .description = .{
            .original = "Every 40 times you or debuffs you apply deal damage to an enemy, " ++
                "gain invulnerability for 5s.",
            .english = "Every [VAR0] times you or debuffs you apply deal damage to an enemy, " ++
                "gain a random buff for [HBSL].",
        },
        // .itemFlags = .{ .starting_item = true },
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
    ttrg.player_self();
    tset.hbs_randombuff();
    apat.apply_hbs(.{});

    const blackbolt_ribbon_dmg = 100;
    item(.{
        .id = "it_transfigured_blackbolt_ribbon",
        .name = .{
            .original = "Blackbolt Ribbon",
            .english = "Transfigured Blackbolt Ribbon",
        },
        .description = .{
            .original = "Every 50 times you or debuffs you apply deal damage to an enemy, " ++
                "deal 1200 damage to all enemies.",
            .english = "After [CD], break and deal [STR] damage to all enemies.#" ++
                "This is increased by [VAR0] every time you or debuffs " ++
                "you apply deal damage. Resets at the start of each fight.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .blueyellow,

        .lootHbDispType = .cooldownVarAm,
        .cooldownType = .time,
        .cooldown = 20 * std.time.ms_per_s,
        .hbInput = .auto,

        .hbFlags = .{ .var0req = true },
        .showSqVar = true,
        .greySqVar0 = true,
        .autoOffSqVar0 = 0,

        .hbVar0 = blackbolt_ribbon_dmg,
        .strMult = blackbolt_ribbon_dmg,
        .delay = 150,
    });
    trig.autoStart(&.{.hb_auto_pl});
    qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 1 });
    qpat.hb_run_cooldown();

    trig.onDamageDone(&.{});
    cond.hb_check_square_var_false(.{ 0, 0 });
    qpat.hb_square_add_var(.{ .varIndex = 0, .amount = 1 });

    trig.hotbarUsed(&.{.hb_self});
    cond.hb_check_square_var_false(.{ 0, 0 });
    qpat.hb_flash_item(.{ .message = .broken });
    ttrg.players_opponent();
    tset.uservar2("u_str", r.sqVar0, .@"*", blackbolt_ribbon_dmg);
    tset.strength_def();
    tset.strength(.{"u_str"});
    apat.crown_of_storms(.{});
    qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 0 });
}

fn transfiguredSwiftflightSet() !void {
    const color = rgb(0x3d, 0xe6, 0xe8);
    rns.start(.{
        .name = "Transfigured Swiftflight Set",
        .image_path = "images/swiftflight.png",
        .thumbnail_path = "images/swiftflight_thumbnail.png",
        .steam_description_header = steam_description_header,
    });
    defer rns.end();

    item(.{
        .id = "it_transfigured_crane_katana",
        .name = .{
            .original = "Crane Katana",
            .english = "Transfigured Crane Katana",
        },
        .description = .{
            .original = "Gain FLOW-STR every time you move 15 rabbitleaps.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .bluegreen,
    });

    item(.{
        .id = "it_transfigured_falconfeather_dagger",
        .name = .{
            .original = "Falconfeather Dagger",
            .english = "Transfigured Falconfeather Dagger",
        },
        .description = .{
            .original = "Gain FLOW-DEX every time you move 15 rabbitleaps.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .bluegreen,
    });

    const tornado_staff_dist = 15;
    item(.{
        .id = "it_transfigured_tornado_staff",
        .name = .{
            .original = "Tornado Staff",
            .english = "Transfigured Tornado Staff",
        },
        .description = .{
            .original = "Gain FLOW-INT every time you move 15 rabbitleaps.",
            .english = "Gain a random buff every time you move [VAR0] rabbitleaps.",
        },
        // .itemFlags = .{ .starting_item = true },
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
    tset.hbs_randombuff();
    ttrg.player_self();
    apat.apply_hbs(.{});

    item(.{
        .id = "it_transfigured_cloud_guard",
        .name = .{
            .original = "Cloud Guard",
            .english = "Transfigured Cloud Guard",
        },
        .description = .{
            .original = "Gain invulnerability for 5s every time you move 25 rabbitleaps.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .bluegreen,
    });

    const hermes_bow_dmg_per_leap = 25;
    item(.{
        .id = "it_transfigured_hermes_bow",
        .name = .{
            .original = "Hermes Bow",
            .english = "Transfigured Hermes Bow",
        },
        .description = .{
            .original = "Every 10s, fires a projectile at your targeted enemy that deals 250 " ++
                "damage. Cooldown resets every time you move 10 rabbitleaps.",
            .english = "Every [CD], fires a projectile at your targeted enemy that deals " ++
                "[VAR0] damage per rabbitleap moved since last fired.",
        },
        // .itemFlags = .{ .starting_item = true },
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
    qpat.hb_run_cooldown();

    trig.distanceTickBattle(&.{.pl_self});
    qpat.hb_square_add_var(.{ .varIndex = 0, .amount = 1 });

    trig.hotbarUsed(&.{.hb_self});
    qpat.hb_run_cooldown();
    qpat.hb_flash_item(.{});
    ttrg.players_opponent();
    tset.uservar2("u_str", r.sqVar0, .@"*", hermes_bow_dmg_per_leap);
    tset.strength_def();
    tset.strength(.{"u_str"});
    apat.floral_bow(.{});
    qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 0 });

    const talon_charm_reduction = -(1 * std.time.ms_per_s);
    const talon_charm_distance = 10;
    item(.{
        .id = "it_transfigured_talon_charm",
        .name = .{
            .original = "Talon Charm",
            .english = "Transfigured Talon Charm",
        },
        .description = .{
            .original = "Deals 150 damage to all enemies every time you move 5 rabbitleaps.",
            .english = "Decreases all cooldowns by [VAR0_SECONDS] every time you move [VAR1] " ++
                "rabbitleaps.",
        },
        // .itemFlags = .{ .starting_item = true },
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
    ttrg.hotbarslots_current_players();
    ttrg.hotbarslots_prune(thss.cooldown, .@">", 0);
    qpat.hb_add_cooldown(.{ .amount = talon_charm_reduction });

    const tiny_wings_leaps = 10.0;
    const tiny_wings_dmg_per_leaps = 0.01;
    item(.{
        .id = "it_transfigured_tiny_wings",
        .name = .{
            .original = "Tiny Wings",
            .english = "Transfigured Tiny Wings",
        },
        .description = .{
            .original = "Dramatically increases movement speed.",
            .english = "You deal [VAR0_PERCENT] more damage per [VAR1] rabbitleaps moved since " ++
                "the start of each battle.",
        },
        // .itemFlags = .{ .starting_item = true },
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
    qpat.hb_run_cooldown();

    trig.distanceTickBattle(&.{.pl_self});
    qpat.hb_square_add_var(.{ .varIndex = 1, .amount = 1 });
    cond.hb_check_square_var(.{ 1, tiny_wings_leaps });
    qpat.hb_square_add_var(.{ .varIndex = 0, .amount = 1 });
    qpat.hb_square_set_var(.{ .varIndex = 1, .amount = 0 });
    qpat.hb_reset_statchange();

    trig.strCalc0(&.{});
    tset.uservar2("u_mult", r.sqVar0, .@"*", tiny_wings_dmg_per_leaps);
    qpat.hb_reset_statchange_norefresh();
    qpat.hb_add_statchange_norefresh(.{ .stat = .allMult, .amountStr = "u_mult" });

    const feathered_overcoat_mult = 0.25;
    item(.{
        .id = "it_transfigured_feathered_overcoat",
        .name = .{
            .original = "Feathered Overcoat",
            .english = "Transfigured Feathered Overcoat",
        },
        .description = .{
            .original = "Maxes out your movement speed while you're invulnerable.",
            .english = "You deal [VAR0_PERCENT] more damage while moving.",
        },
        // .itemFlags = .{ .starting_item = true },
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
    qpat.hb_reset_statchange();

    trig.standingStill(&.{});
    cond.hb_check_square_var(.{ 0, 1 });
    qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 0 });
    qpat.hb_reset_statchange();

    trig.distanceTick(&.{});
    cond.hb_check_square_var(.{ 0, 0 });
    qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 1 });
    qpat.hb_reset_statchange();

    trig.strCalc0(&.{});
    qpat.hb_reset_statchange_norefresh();
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
        .steam_description_header = steam_description_header,
    });
    defer rns.end();

    item(.{
        .id = "it_transfigured_sandpriestess_spear",
        .name = .{
            .original = "Sandpriestess Spear",
            .english = "Transfigured Sandpriestess Spear",
        },
        .description = .{
            .original = "Your Primary has a 40% chance to grant you FLASH-DEX.",
            .english = "Every [CD], gain [FLASH-STR].#" ++
                "When you lose [FLASH-STR], gain [FLASH-DEX].",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .redyellow,

        .lootHbDispType = .cooldown,
        .cooldownType = .time,
        .cooldown = 8 * std.time.ms_per_s,
        .hbInput = .auto,

        .hbsLength = 5 * std.time.ms_per_s,
        .hbsType = .flashstr,
    });
    trig.autoStart(&.{.hb_auto_pl});
    qpat.hb_run_cooldown();

    trig.hotbarUsed(&.{.hb_self});
    qpat.hb_run_cooldown();
    qpat.hb_flash_item(.{});
    ttrg.player_self();
    tset.hbs_def();
    apat.apply_hbs(.{});

    trig.hbsDestroyed(&.{.pl_self});
    cond.eval(s.statusId, .@"==", @intFromEnum(Hbs.flashstr));
    qpat.hb_flash_item(.{});
    ttrg.player_self();
    tset.hbskey(.{ Hbs.flashdex, r.hbsLength });
    apat.apply_hbs(.{});

    item(.{
        .id = "it_transfigured_flamedancer_dagger",
        .name = .{
            .original = "Flamedancer Dagger",
            .english = "Transfigured Flamedancer Dagger",
        },
        .description = .{
            .original = "Your Secondary has a 40% chance to grant you FLASH-STR.",
            .english = "Every [CD], gain [FLASH-DEX].#" ++
                "When you lose [FLASH-DEX], gain [FLASH-INT].",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .redyellow,

        .lootHbDispType = .cooldown,
        .cooldownType = .time,
        .cooldown = 8 * std.time.ms_per_s,
        .hbInput = .auto,

        .hbsLength = 5 * std.time.ms_per_s,
        .hbsType = .flashdex,
    });
    trig.autoStart(&.{.hb_auto_pl});
    qpat.hb_run_cooldown();

    trig.hotbarUsed(&.{.hb_self});
    qpat.hb_run_cooldown();
    qpat.hb_flash_item(.{});
    ttrg.player_self();
    tset.hbs_def();
    apat.apply_hbs(.{});

    trig.hbsDestroyed(&.{.pl_self});
    cond.eval(s.statusId, .@"==", @intFromEnum(Hbs.flashdex));
    qpat.hb_flash_item(.{});
    ttrg.player_self();
    tset.hbskey(.{ Hbs.flashint, r.hbsLength });
    apat.apply_hbs(.{});

    item(.{
        .id = "it_transfigured_whiteflame_staff",
        .name = .{
            .original = "Whiteflame Staff",
            .english = "Transfigured Whiteflame Staff",
        },
        .description = .{
            .original = "Every 2 times you use your Special, gain FLASH-STR.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .redyellow,
    });

    item(.{
        .id = "it_transfigured_sacred_shield",
        .name = .{
            .original = "Sacred Shield",
            .english = "Transfigured Sacred Shield",
        },
        .description = .{
            .original = "Every 2 times you use your Defensive, gain FLASH-INT.",
            .english = "Whenever you gain invulnerability, gain [FLASH-DEX].",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .redyellow,

        .hbsLength = 5 * std.time.ms_per_s,
        .hbsType = .flashdex,
    });
    trig.onInvuln(&.{.pl_self});
    qpat.hb_flash_item(.{});
    ttrg.player_self();
    tset.hbs_def();
    apat.apply_hbs(.{});

    const marble_clasp_mult = 0.15;
    item(.{
        .id = "it_transfigured_marble_clasp",
        .name = .{
            .original = "Marble Clasp",
            .english = "Transfigured Marble Clasp",
        },
        .description = .{
            .original = "Every 5 times you use an ability, gain FLASH-DEX.",
            .english = "You deal [VAR0_PERCENT] more damage.#" ++
                "When you gain [FLASH-STR], gain [FLOW-STR].#" ++
                "When you gain [FLASH-DEX], gain [FLOW-DEX].#" ++
                "When you gain [FLASH-INT], gain [FLOW-INT].",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .redyellow,

        .allMult = marble_clasp_mult,
        .hbVar0 = marble_clasp_mult,

        // Vanilla Redwhite Ribbon doesn't work if an items `hbsType` is not a buff
        .hbFlags = .{ .hidehbs = true },
        .hbsType = .flashstr,
        .hbsLength = 5 * std.time.ms_per_s,
    });

    for ([_][2]Hbs{
        .{ .flashstr, .flowstr },
        .{ .flashdex, .flowdex },
        .{ .flashint, .flowint },
    }) |hbs| {
        trig.hbsCreated(&.{.hbs_selfafl});
        cond.eval(s.statusId, .@"==", @intFromEnum(hbs[0]));
        qpat.hb_flash_item(.{});
        ttrg.player_afflicted_source();
        tset.hbskey(.{ hbs[1], r.hbsLength });
        apat.apply_hbs(.{});
    }

    const sun_pendant_times = 10;
    item(.{
        .id = "it_transfigured_sun_pendant",
        .name = .{
            .original = "Sun Pendant",
            .english = "Transfigured Sun Pendant",
        },
        .description = .{
            .original = "Every 10 times you use an ability, reset your Special's cooldown and " ++
                "gain FLASH-INT.",
            .english = "Every [VAR0_TIMES] you use an ability, gain [FLASH-STR], [FLASH-DEX] " ++
                "and [FLASH-INT].",
        },
        // .itemFlags = .{ .starting_item = true },
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
    ttrg.player_self();
    for ([_]Hbs{ .flashdex, .flashint, .flashstr }) |hbs| {
        tset.hbskey(.{ hbs, r.hbsLength });
        apat.apply_hbs(.{});
    }

    item(.{
        .id = "it_transfigured_tiny_hourglass",
        .name = .{
            .original = "Tiny Hourglass",
            .english = "Transfigured Tiny Hourglass",
        },
        .description = .{
            .original = "Every 12s, deal 120 damage to all enemies. Damage increase by 120 " ++
                "each time it activates.",
            .english = "Every [CD], deal [STR] damage to all enemies.",
        },
        // .itemFlags = .{ .starting_item = true },
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
    qpat.hb_run_cooldown();

    trig.hotbarUsed(&.{.hb_self});
    qpat.hb_run_cooldown();
    qpat.hb_flash_item(.{});
    ttrg.players_opponent();
    tset.strength_def();
    apat.crown_of_storms(.{});

    item(.{
        .id = "it_transfigured_desert_earrings",
        .name = .{
            .original = "Desert Earrings",
            .english = "Transfigured Desert Earrings",
        },
        .description = .{
            .original = "Every time you gain a buff, gain another random buff for 5s.",
            .english = "When your allies gain a buff, you gain a buff of the same type " ++
                "for [HBSL].",
        },
        // .itemFlags = .{ .starting_item = true },
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
        ttrg.player_self();
        apat.apply_hbs(.{});
    }
}

fn transfiguredRuinsSet() !void {
    const color = rgb(0x65, 0xe8, 0xa2);
    rns.start(.{
        .name = "Transfigured Ruins Set",
        .image_path = "images/ruins.png",
        .thumbnail_path = "images/ruins_thumbnail.png",
        .steam_description_header = steam_description_header,
    });
    defer rns.end();

    item(.{
        .id = "it_transfigured_giant_stone_club",
        .name = .{
            .original = "Giant Stone Club",
            .english = "Transfigured Giant Stone Club",
        },
        .description = .{
            .original = "Your Primary deals 70% more damage. Its GCD is increased by 0.6s. " ++
                "Your movement speed is also moderately reduced.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .redgreen,
    });

    item(.{
        .id = "it_transfigured_ruins_sword",
        .name = .{
            .original = "Ruins Sword",
            .english = "Transfigured Ruins Sword",
        },
        .description = .{
            .original = "Your Secondary deals 100% more damage. Its GCD is increased by 0.8s. " ++
                "Your movement speed is also slightly reduced.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .redgreen,
    });

    const mountain_staff_mult_per_gcd = 0.03;
    const mountain_staff_per_gcd = 0.2 * std.time.ms_per_s;
    item(.{
        .id = "it_transfigured_mountain_staff",
        .name = .{
            .original = "Mountain Staff",
            .english = "Transfigured Mountain Staff",
        },
        .description = .{
            .original = "Your Special deals 200% more damage. Its GCD is increased by 2.5s. " ++
                "Your movement speed is also moderately reduced.",
            .english = "Each ability deal [VAR0_PERCENT] more damage per [VAR1_SECONDS] GCD.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .redgreen,

        .hbVar0 = mountain_staff_mult_per_gcd,
        .hbVar1 = mountain_staff_per_gcd,
    });
    trig.strCalc1c(&.{});
    for (WeaponType.abilities_with_gcd) |weapon| {
        ttrg.hotbarslots_self_weapontype(.{weapon});
        tset.uservar2("u_mult", ths0.gcd, .@"/", mountain_staff_per_gcd);
        tset.uservar2("u_mult", "u_mult", .@"*", mountain_staff_mult_per_gcd);
        qpat.hb_add_strcalcbuff(.{ .amountStr = "u_mult" });
    }
    //

    item(.{
        .id = "it_transfigured_boulder_shield",
        .name = .{
            .original = "Boulder Shield",
            .english = "Transfigured Boulder Shield",
        },
        .description = .{
            .original = "Every 30s, using your Defensive will grant all allies STONESKIN. " ++
                "Starts battle off cooldown. Reduces your movement speed slightly.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .redgreen,
    });

    item(.{
        .id = "it_transfigured_golems_claymore",
        .name = .{
            .original = "Golem's Claymore",
            .english = "Transfigured Golem's Claymore",
        },
        .description = .{
            .original = "Every 20s, grants you Stoneskin and then slices the air around you, " ++
                "dealing 500 damage to nearby enemies. Also slows your movement speed slightly.",
            .english = "Every [CD], using your Secondary grants you [STONESKIN] for [HBSL].#" ++
                "When [STONESKIN] or [GRANITESKIN] shields you from damage slice the air " ++
                "around you, dealing [STR] damage to nearby enemies.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .redgreen,

        .lootHbDispType = .cooldown,
        .cooldownType = .time,
        .cooldown = 5 * std.time.ms_per_s,

        .hbsType = .stoneskin,
        .hbsLength = 0.7 * std.time.ms_per_s,

        .delay = 150,
        .radius = 400,
        .strMult = 500,
    });
    trig.hotbarUsedProc(&.{.hb_secondary});
    cond.hb_available();
    ttrg.player_self();
    qpat.hb_run_cooldown();
    qpat.hb_flash_item(.{});
    qpat.hb_cdloot_proc();
    tset.hbs_def();
    apat.apply_hbs(.{});

    trig.hbsShield2(&.{.pl_self});
    ttrg.player_self();
    ttrg.hbstatus_target();
    ttrg.hbstatus_prune(thbss.statusId, .@"==", @intFromEnum(Hbs.stoneskin));
    tset.uservar_hbscount(.{"u_stoneskins"});
    tset.uservar1("u_count", "u_stoneskins");
    ttrg.player_self();
    ttrg.hbstatus_target();
    ttrg.hbstatus_prune(thbss.statusId, .@"==", @intFromEnum(Hbs.graniteskin));
    tset.uservar_hbscount(.{"u_graniteskins"});
    tset.uservar2("u_count", "u_count", .@"+", "u_graniteskins");
    cond.eval("u_count", .@">", 0);
    qpat.hb_flash_item(.{});
    ttrg.players_opponent();
    tset.strength_def();
    apat.darkmagic_blade(.{});

    const stoneplate_armor_dmg_mult = 0.04;
    item(.{
        .id = "it_transfigured_stoneplate_armor",
        .name = .{
            .original = "Stoneplate Armor",
            .english = "Transfigured Stoneplate Armor",
        },
        .description = .{
            .original = "Start each battle with GRANITESKIN.",
            .english = "Every [CD], grants you [STONESKIN]. Starts battle off cooldown.#" ++
                "When [STONESKIN] or [GRANITESKIN] shields you from damage you permanently " ++
                "deal [VAR0_PERCENT] more damage.",
        },
        // .itemFlags = .{ .starting_item = true },
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
    qpat.hb_run_cooldown();

    trig.hotbarUsed(&.{.hb_self});
    ttrg.player_self();
    qpat.hb_run_cooldown();
    qpat.hb_flash_item(.{});
    tset.hbs_def();
    apat.apply_hbs(.{});

    trig.hbsShield2(&.{.pl_self});
    ttrg.player_self();
    ttrg.hbstatus_target();
    ttrg.hbstatus_prune(thbss.statusId, .@"==", @intFromEnum(Hbs.stoneskin));
    tset.uservar_hbscount(.{"u_stoneskins"});
    tset.uservar1("u_count", "u_stoneskins");
    ttrg.player_self();
    ttrg.hbstatus_target();
    ttrg.hbstatus_prune(thbss.statusId, .@"==", @intFromEnum(Hbs.graniteskin));
    tset.uservar_hbscount(.{"u_graniteskins"});
    tset.uservar2("u_count", "u_count", .@"+", "u_graniteskins");
    cond.eval("u_count", .@">", 0);
    qpat.hb_flash_item(.{});
    qpat.hb_square_add_var(.{ .varIndex = 0, .amount = 1 });
    qpat.hb_reset_statchange();

    trig.strCalc0(&.{});
    tset.uservar2("u_mult", r.sqVar0, .@"*", stoneplate_armor_dmg_mult);
    qpat.hb_reset_statchange_norefresh();
    qpat.hb_add_statchange_norefresh(.{ .stat = .allMult, .amountStr = "u_mult" });

    item(.{
        .id = "it_transfigured_sacredstone_charm",
        .name = .{
            .original = "Sacredstone Charm",
            .english = "Transfigured Sacredstone Charm",
        },
        .description = .{
            .original = "Abilities with a GCD equal to or higher than 1.5s deal 50% more damage.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .redgreen,
    });

    item(.{
        .id = "it_transfigured_clay_rabbit",
        .name = .{
            .original = "Clay Rabbit",
            .english = "Transfigured Clay Rabbit",
        },
        .description = .{
            .original = "Every 12s, standing still will grant you STONESKIN",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
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
        .steam_description_header = steam_description_header,
    });
    defer rns.end();

    item(.{
        .id = "it_transfigured_waterfall_polearm",
        .name = .{
            .original = "Waterfall Polearm",
            .english = "Transfigured Waterfall Polearm",
        },
        .description = .{
            .original = "Every 10s, when you use your Primary, gain FLOW-STR",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .yellowgreen,
    });

    item(.{
        .id = "it_transfigured_vorpal_dao",
        .name = .{
            .original = "Vorpal Dao",
            .english = "Transfigured Vorpal Dao",
        },
        .description = .{
            .original = "Every 10s, when you use your Secondary, gain FLOW-DEX.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .yellowgreen,
    });

    item(.{
        .id = "it_transfigured_jade_staff",
        .name = .{
            .original = "Jade Staff",
            .english = "Transfigured Jade Staff",
        },
        .description = .{
            .original = "Every 2 times you use your Special, gain TRANQUILITY.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .yellowgreen,
    });

    item(.{
        .id = "it_transfigured_reflection_shield",
        .name = .{
            .original = "Reflection Shield",
            .english = "Transfigured Reflection Shield",
        },
        .description = .{
            .original = "When you erase projectiles in a radius around you, gain COUNTER.",
            .english = "When you gain a buff, allies gain a buff of the same type for " ++
                "[HBSL].",
        },
        // .itemFlags = .{ .starting_item = true },
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
        ttrg.players_ally();
        ttrg.players_prune_self();
        apat.apply_hbs(.{});
    }

    item(.{
        .id = "it_transfigured_butterfly_hairpin",
        .name = .{
            .original = "Butterfly Hairpin",
            .english = "Transfigured Butterfly Hairpin",
        },
        .description = .{
            .original = "When you gain invincibility, gain a random buff for 5s.",
            .english = "When you inflict a debuff gain a random buff for [HBSL].",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .yellowgreen,

        // Vanilla Redwhite Ribbon doesn't work if an items `hbsType` is not a buff
        .hbFlags = .{ .hidehbs = true },
        .hbsType = .smite_0,
        .hbsLength = 5 * std.time.ms_per_s,
    });
    trig.hbsCreated(&.{});
    cond.false(.{s.isBuff});
    qpat.hb_flash_item(.{});
    ttrg.player_self();
    tset.hbs_randombuff();
    apat.apply_hbs(.{});

    item(.{
        .id = "it_transfigured_watermage_pendant",
        .name = .{
            .original = "Watermage Pendant",
            .english = "Transfigured Watermage Pendant",
        },
        .description = .{
            .original = "Every 12s, when you stand still, gain FLOW-INT.",
            .english = "Every [CD], rotate between gaining [FLOW-STR], [FLOW-DEX] or [FLOW-INT].",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        .treasureType = .yellowgreen,

        .lootHbDispType = .cooldown,
        .cooldownType = .time,
        .cooldown = 5 * std.time.ms_per_s,
        .hbInput = .auto,

        .autoOffSqVar0 = 0,

        // Vanilla Redwhite Ribbon doesn't work if an items `hbsType` is not a buff
        .hbFlags = .{ .hidehbs = true },
        .hbsType = .flashstr,
        .hbsLength = 5 * std.time.ms_per_s,
    });
    const watermage_pendant_buffs = [_]Hbs{ .flowstr, .flowdex, .flowint };
    for (watermage_pendant_buffs, 0..) |hbs, i| {
        trig.hotbarUsed(&.{.hb_self});
        cond.hb_check_square_var(.{ 0, i });
        qpat.hb_run_cooldown();
        qpat.hb_flash_item(.{});
        ttrg.player_self();
        tset.hbskey(.{ hbs, r.hbsLength });
        apat.apply_hbs(.{});
    }

    trig.hotbarUsed2(&.{.hb_self});
    qpat.hb_square_add_var(.{ .varIndex = 0, .amount = 1 });
    cond.hb_check_square_var(.{ 0, watermage_pendant_buffs.len });
    qpat.hb_square_set_var(.{ .varIndex = 0, .amount = 0 });

    item(.{
        .id = "it_transfigured_raindrop_earrings",
        .name = .{
            .original = "Raindrop Earrings",
            .english = "Transfigured Raindrop Earrings",
        },
        .description = .{
            .original = "Every 18s, when you stand still, gain REPEAT.",
            .english = "Not Implemented. Should not appear in a run.",
        },
        // .itemFlags = .{ .starting_item = true },
        .color = color,
        .type = .loot,
        .weaponType = .loot,
        // .treasureType = .yellowgreen,
    });

    item(.{
        .id = "it_transfigured_aquamarine_bracelet",
        .name = .{
            .original = "Aquamarine Bracelet",
            .english = "Transfigured Aquamarine Bracelet",
        },
        .description = .{
            .original = "Every 12s, gain a random buff for 10s.",
            .english = "At the start of each fight, gain 2 random buffs for [VAR0_SECONDS] " ++
                "seconds.",
        },
        // .itemFlags = .{ .starting_item = true },
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
    ttrg.player_self();
    tset.hbs_randombuff();
    apat.apply_hbs(.{});
    tset.hbs_randombuff();
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
const TriggerVariables = rns.TriggerVariables;
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
const ths4 = rns.ths4;
const ths5 = rns.ths5;
const thbss = rns.thbss;
const thbs0 = rns.thbs0;
const thbs1 = rns.thbs1;
const thbs2 = rns.thbs2;
const thbs3 = rns.thbs3;

test {
    _ = &main;
}

const rns = @import("rns.zig");
const std = @import("std");
