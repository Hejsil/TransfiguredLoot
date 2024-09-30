const gpa = std.heap.page_allocator;

var generating_mod: bool = false;
var written_items: usize = 0;
var have_trigger: bool = false;

var m_args: ?[][:0]u8 = null;

var mod: Mod = undefined;
var sheetlist: std.ArrayList(u8) = std.ArrayList(u8).init(gpa);
var item_csv: std.ArrayList(u8) = std.ArrayList(u8).init(gpa);
var item_ini: std.ArrayList(u8) = std.ArrayList(u8).init(gpa);
var item_names: std.ArrayList(u8) = std.ArrayList(u8).init(gpa);
var item_descriptions: std.ArrayList(u8) = std.ArrayList(u8).init(gpa);

pub const Mod = struct {
    name: []const u8,
    image_path: []const u8,
};

pub fn start(m: Mod) void {
    start2(m) catch |err| @panic(@errorName(err));
}

fn start2(m: Mod) !void {
    std.debug.assert(!generating_mod);

    try sheetlist.writer().print(
        \\Sheet Type,filename
        \\NameSheet,Mods/{[name]s}/Items_Names
        \\DescriptionSheet,Mods/{[name]s}/items_Descriptions
        \\ItemSheet,Mods/{[name]s}/Items
        \\
    ,
        .{ .name = m.name },
    );

    try item_names.writer().writeAll(
        \\key,level,English,Japanese,Chinese
        \\
    );
    try item_descriptions.writer().writeAll(
        \\key,level,English,Japanese,Chinese
        \\
    );

    mod = m;
    written_items = 0;
    generating_mod = true;
}

pub fn end() void {
    end2() catch |err| @panic(@errorName(err));
}

fn end2() !void {
    std.debug.assert(generating_mod);

    const args = m_args orelse blk: {
        m_args = try std.process.argsAlloc(gpa);
        break :blk m_args.?;
    };

    const cwd = std.fs.cwd();
    const output_dir_path = if (args.len >= 2) args[1] else blk: {
        const home = try std.process.getEnvVarOwned(gpa, "HOME");
        break :blk try std.fs.path.join(gpa, &.{
            home, ".local/share/Steam/steamapps/common/Rabbit and Steel/Mods",
        });
    };
    var output_parent_dir = try cwd.makeOpenPath(output_dir_path, .{});
    defer output_parent_dir.close();

    var output_dir = try output_parent_dir.makeOpenPath(mod.name, .{});
    defer output_dir.close();

    try cwd.copyFile(mod.image_path, output_dir, "items.png", .{});
    try output_dir.writeFile(.{
        .sub_path = "SheetList.csv",
        .data = sheetlist.items,
    });
    try output_dir.writeFile(.{
        .sub_path = "Items.csv",
        .data = try std.fmt.allocPrint(gpa,
            \\spriteNumber,{},,,,
            \\{s}
        , .{ written_items, item_csv.items }),
    });
    try output_dir.writeFile(.{
        .sub_path = "Items.ini",
        .data = item_ini.items,
    });
    try output_dir.writeFile(.{
        .sub_path = "Items_Names.csv",
        .data = item_names.items,
    });
    try output_dir.writeFile(.{
        .sub_path = "Items_Descriptions.csv",
        .data = item_descriptions.items,
    });

    sheetlist.shrinkRetainingCapacity(0);
    item_csv.shrinkRetainingCapacity(0);
    item_ini.shrinkRetainingCapacity(0);
    item_names.shrinkRetainingCapacity(0);
    item_descriptions.shrinkRetainingCapacity(0);
    generating_mod = false;
}

/// https://docs.google.com/spreadsheets/d/1shtFkpagAafUjjA70XGlYGruqFIbLpQlcDjWKNNm3_4/edit?pli=1&gid=0#gid=0
pub const Item = struct {
    id: []const u8,
    name: struct {
        english: []const u8,
        japanese: ?[]const u8 = null,
        chinese: ?[]const u8 = null,
    },
    description: struct {
        english: []const u8,
        japanese: ?[]const u8 = null,
        chinese: ?[]const u8 = null,
    },

    // "ITEM" VARIABLES
    // Variables around the item itself

    /// The type of item that this is.
    type: ?enum {
        none,
        character, // Refers to the hidden "item" that each character has.  Don't use this.
        weapon, // Refers to an ability on a character's hotbar.  Still working on supporting these
        loot, // Refers to loot that you get from treasure chests
        potion, // Potions that you buy from the shop, will go to your potion slots
        upgrade, // The upgrade gems you find in the shop.  Adding more of these might have strange effects.
    } = null,

    /// Used for upgraded versions of character abilities. A number 0-6
    /// 0: None
    /// 1: Diamond (unused in the unmodded game)
    /// 2: Opal
    /// 3: Sapphire
    /// 4: Ruby
    /// 5: Garnet
    /// 6: Emerald
    evoIcon: ?u32 = null,

    /// Used for Upgrade Gems in the shop, to specify what upgrade they give. A number 0-6
    /// 0: None
    /// 1: Diamond (unused in the unmodded game)
    /// 2: Opal
    /// 3: Sapphire
    /// 4: Ruby
    /// 5: Garnet
    /// 6: Emerald"
    element: ?u32 = null,

    /// Special flags for the item. This is a binary number, the values in the
    /// "accepted values" can be combined to give an item multiple properties
    ///
    /// A number, combined from all of the flags below you want to give the item:
    /// 1: ITM_FLAG_FULLHEAL - For the ""Full Heal"" item in the shop, does nothing on other items
    /// 2: ITM_FLAG_LEVELUP - For the ""Level Up"" item in the shop, does nothing on other items
    /// 4: Currently unused
    /// 8: ITM_FLAG_NO_LASTCHEST - This item will not appear in the last stage, either in stores or in chests
    /// 16: ITM_FLAG_NO_LASTCHEST_TWO - This item will not appear in the last two stages
    itemFlags: ?u32 = null,

    /// Shows the saved "Square" variable (sqVar0) for this item (the small counter on items
    /// like Butterfly Ocarina or Emerald Chestplate)
    showSqVar: ?bool = null,

    /// Changing this value will make a small image of this loot item appear next to your
    /// mini-hotbar, like Demon Horns or Spiderbite Bow
    lootHbDispType: ?enum {
        none, // Doesn't show a small item near your mini hotbars
        cooldown, // Shows a small cooldown for the item (Ex: Spiderbite Bow, Holy Greatsword)
        cooldownVarAm, // Shows a small cooldown for the item, but does not show if the item's sqVar0 is 0 (Currently only used for Sapphire Violin)
        glowing, // Item will glow if the item's sqVar0 is over 0 (Ex: Demon Horns, Ruby Circlet)
        varAm, // Will show the sqVar0 of the item (Ex: Tornado Staff, Marble Clasp, Staticshock Earrings)
    } = null,

    /// This will make the item appear greyed out when sqVar0 is 0, like Emerald Chestplate
    /// (or any of the breakable items)
    greySqVar0: ?bool = null,

    /// This will make the item glow when sqVar0 is greater than 0, like Phoenix Charm
    glowSqVar0: ?bool = null,

    /// This can set a value that the item's sqVar0 can be automatically set to when the
    /// character holding it is out of combat. For instance, the Blackbolt Ribbon has an
    /// autoSqVar0 of 50.  The Firescale Corset has this set to 1, so it reactivates whenever
    /// the character leaves combat.  If this value is set to a number below 0, sqVar0 won't
    /// be changed when you leave combat (it defaults to -1, so this is the default behavior).
    autoOffSqVar0: ?u32 = null,

    /// The color of the item, written as a hex code.  Will determine things like the color of
    /// the item's description.
    color: ?Color = null,

    /// Determines where this item can appear within the game.
    treasureType: ?enum {
        none, // - Will not appear in treasure chests
        all, // - Can appear in any treasure chest
        generic, // - Will only appear in White Treasures
        purple, // - Will only appear in Purple Treasures
        blue, // - etc. etc..
        red, //
        yellow, //
        green, //
        purpleblue, //
        purplered, //
        purpleyellow, //
        purplegreen, //
        bluered, //
        blueyellow, //
        bluegreen, //
        redyellow, //
        redgreen, //
        yellowgreen, //
        regenPotion, // - Will appear in the place of regen potions
        potion, // - Will appear in the shop alongside other potions
        upgradeP, // - Will appear in the shop in the Primary Upgrade Slot
        upgradeS, // - Don't use these yet tbh
        upgradeSp, //
        upgradeD, //
    } = null,

    /// "HITBOX" VARIABLES
    // Variables relating to the item doing damage, or the effects that the item has. Note
    // that values over what it says you can put in might *look* like they work on your
    // client, but will actually break or behave inconsistently if you're playing online
    //
    // The weapon type of the item, like if it's a Primary, Secondary, Loot etc..  Influences
    // what stat bonuses affect this item.

    /// The size of the area this item hits, in pixels. Effects might differ depending on the
    /// attack pattern the item uses.
    radius: ?u16 = null,

    /// The delay between the button being pressed and the hitbox appearing, in milliseconds.
    /// Effects might differ depending on the attack pattern the item uses. Would recommend
    /// setting this above 125, otherwise the rollback netcode might make the effect look
    /// weird.
    delay: ?u16 = null,

    /// The kind of input required to activate this item. Character abilities must be set to
    /// "press" or "hold" if you want players to be able to use them, or "auto" if they
    /// activate automatically on a cooldown. Items like Bows or Greatswords that activate on
    /// a cooldown have to be set to "auto".
    hbInput: ?enum {
        none, // There is no input
        press, // Button must be pressed to activate, unless they have the hold attack option enabled in their input settings (used for most abilities)
        hold, // Button can be held to activate item continuously
        auto, // Item will activate automatically if the character is in combat and the cooldown is available
    } = null,

    weaponType: ?WeaponType = null,

    /// The amount of damage this item does
    strMult: ?u16 = null,

    /// The number of times this item does damage (Must use an attack pattern that can deal
    /// damage multiple times)
    hitNumber: ?u16 = null,

    /// The key for the Status Effect this item applies.  For instance, if an item applies
    /// Curse, "hbs_curse_0"
    hbsType: ?Hbs = null,

    /// The amount of damage that the Status Effect does.
    /// For poison, it will deal this damage every tick, for ghostflame, the amount of
    /// damage each hit does, etc..
    hbsStrMult: ?u16 = null,

    /// The default length of the Status Effect, in milliseconds.
    hbsLength: ?u16 = null,

    /// Only used for the item description, will add a text blurb explaining a certain kind of
    /// "Charge".
    chargeType: ?ChargeType = null,

    /// The default chance of an item's random effect activating.
    /// Any decimal number 0 through 1:
    /// 0.2 : Item will activate 20% of the time
    /// 0.7 : Item will activate 70% of the time
    /// 0.85 : Item will activate 85% of the time
    /// etc.."
    procChance: ?f64 = null,

    /// Affects the color of attack patterns produced by this item. Would recommend making
    /// this a slightly dark color
    hbColor0: ?Color = null,

    /// Affects the color of attack patterns produced by this item. Would recommend making
    /// this a slightly bright/saturated color
    hbColor1: ?Color = null,

    /// Special flags for the item. This is a binary number, the values in the
    /// "accepted values" can be combined to give a hitbox multiple properties
    /// 1  HTB_FLAG_STEALTHY     - Using item doesn't break Vanish/Ghost
    /// 2  HTB_FLAG_UNRESETTABLE - Cooldown can't be reset by other loot effects
    /// 4  HTB_FLAG_HIDEHBS      - Hides Status Effect description on the item's description
    /// 8  HTB_FLAG_UNCHARGEABLE - For abilities that can't be charged by other abilities or
    ///                            loot
    /// 16 HTB_FLAG_COMBATREQ    - For abilities that can't be used outside combat
    /// 32 HTB_FLAG_VAR0REQ      - Item will not activate unless sqVar0 is greater than 0
    ///                            (like for items that break)
    /// 64 HTB_FLAG_HIDESTR      - Item's strength won't be shown in the window"
    hbFlags: ?u16 = null,

    /// Variable that can be set to any number; will replace [VAR0] in item descriptions
    hbVar0: ?f64 = null,

    /// Variable that can be set to any number; will replace [VAR1] in item descriptions
    hbVar1: ?f64 = null,

    /// Variable that can be set to any number; will replace [VAR2] in item descriptions
    hbVar2: ?f64 = null,

    /// Variable that can be set to any number; will replace [VAR3] in item descriptions
    hbVar3: ?f64 = null,

    // "COOLDOWN" VARIABLES
    // Variables relating to the cooldown, GCD, or uses of the item

    /// The type of cooldown that this item has.
    cooldownType: ?enum {
        none, // none
        time, // Only has a cooldown timer, no GCD (like most Defensives, or automatically activating loot like Greatswords)
        gcd, // Has a GCD (can also have a cooldown if one is specified, like most Specials)
        stock, // Has a certain number of uses, with a cooldown timer
        stockGcd, // Has a certain number of uses, with a GCD and a cooldown timer
        stockOnly, // Has a certain number of uses and no cooldown that restores them (such as Defender's Special).  Can have a cooldown, but it just prevents the ability from being used, rather than restoring uses
    } = null,

    /// The cooldown of the item, in milliseconds
    cooldown: ?u32 = null,

    /// The GCD of the item, in milliseconds
    /// Any integer 0 - 3276750
    gcdLength: ?u32 = null,

    /// A hidden cooldown of the item that prevents it from being used in rapid sucession
    /// Any integer 0 - 3276750
    hiddenCooldown: ?u32 = null,

    /// For stock items, how much the stock decreases with use
    /// Any integer 0 - 128
    stockDecrease: ?u8 = null,

    /// For stock items, how much the stock increases with cooldown/reset effects
    /// Any integer 0 - 128
    stockIncrease: ?u8 = null,

    /// The maximum stock the item can hold
    /// Any integer 0 - 9
    maxStock: ?u8 = null,

    // "STAT" VARIABLES
    // Variables for attaching permanent character stat changes to the item (such as making an
    // ability type deal more damage, or increasing character speed)

    /// Adjusts Max HP
    /// Any integer -9 to 9
    hp: ?i8 = null,

    /// Makes your Primary deal extra damage (as a percentage).  For example, inputting 0.2
    /// will make your Primary deal 20% more damage.  Inputting -0.5 will make your primary
    /// deal 50% less damage.
    primaryMult: ?f64 = null,

    /// Above, but for Secondary
    secondaryMult: ?f64 = null,

    /// Above, but for Special
    specialMult: ?f64 = null,

    /// Above, but for Defensive
    defensiveMult: ?f64 = null,

    /// Above, but for Loot items
    lootMult: ?f64 = null,

    /// Will make ALL damage you deal greater by a percentage
    allMult: ?f64 = null,

    /// Will make Status Effects you place deal more damage
    hbsMult: ?f64 = null,

    /// For the following variables, same as above, but they are added in later in
    /// calculations. These are only meant to be on Status Effects like Flash-Int, and should
    /// probably not be used for items.
    primaryMultHbs: ?f64 = null,
    secondaryMultHbs: ?f64 = null,
    specialMultHbs: ?f64 = null,
    defensiveMultHbs: ?f64 = null,
    lootMultHbs: ?f64 = null,
    allMultHbs: ?f64 = null,
    hbsMultHbs: ?f64 = null,

    /// This makes afflicted characters TAKE more damage by a percentage. It is used for things
    /// like Curse, and shouldn't be placed on items.
    damageMult: ?f64 = null,
    /// These make afflicted characters TAKE more damage by a flat number.  Used for Bleed's
    /// effect, and shouldn't be placed on items.
    damagePlusP0: ?f64 = null,
    damagePlusP1: ?f64 = null,
    damagePlusP2: ?f64 = null,
    damagePlusP3: ?f64 = null,

    /// Adds a flat value to all cooldowns this character has, measured in milliseconds.
    /// Currently only used on Firescale Corset. Any integer 0 - 3276750
    cdp: ?i32 = null,

    /// Increases or decreases GCDs by a percentage. Note that this being a negative number makes
    /// the GCD faster, and it being positive makes the GCD slower.
    /// If a character has multiple items that give haste, their effects are multiplied.
    /// Any number -1 to ~32760 (but should probably be kept in the -1 to 1 range)
    haste: ?f64 = null,

    /// Makes the character luckier by a percentage. Use wisely. Any number -1 to 1
    /// 0.15 : Chances will happen 15% more often (Mimick Rabbitfoot)
    /// 0.1 : Chances will happen 10% more often (Ballroom Gown)
    /// -1 means that proc chances won't happen unless they have some other item effects to
    /// offset them, and 1 means that procs will happen 100% of the time.
    ///
    /// Technically you can input smaller or larger numbers here, to offset any bonuses you
    /// might get from other items.
    luck: ?f64 = null,

    /// Makes critical hits deal more or less damage.
    /// Any number (recommended to be kept from -2ish to 2ish)
    /// 0     : Critical hits will deal 1.75x damage
    /// 1     : Critical hits will deal 2.75x damage
    /// 2     : Critical hits will deal 3.75x damage
    /// -0.5  : Critical hits will deal 1.25x damage
    /// -0.75 : Critical hits will deal 1x damage (and will no longer count as "critical" hits)
    critDamage: ?f64 = null,

    /// Makes your character START with more gold. This is only used in toybox mode to make
    /// Silver Coin work there. It won't affect anything mid-run.
    startingGold: ?u32 = null,

    /// Makes your character move faster or slower. Any number -99 to 99 (but should probably
    /// be kept in the -5 to 5 range)
    charspeed: ?f64 = null,

    /// Makes your character's hitbox larger or smaller. Used on Sunflower Crown and Evasion
    /// Potion, which have -10 each. Any number -2000 to 2000 (but should probably be kept in
    /// the -25 to 25 range)
    charradius: ?i32 = null,

    /// Make invulnerability effects last longer (or shorter) by a flat amount, in
    /// milliseconds. Any number -15000 to 15000 (but should probably be kept in the -3000 to
    /// 3000 range).  Note that invulnerability effects have a hard cap of 7.5 seconds, no
    /// matter what stats you have
    invulnPlus: ?u32 = null,

    /// Currently does nothing
    stockPlus: ?f64 = null,

    /// Special flags that affect your character in various ways.
    /// This is a binary number, so multiple values can be combined to have multiple effects.
    /// 1     HBS_FLAG_VANISH        - attacks are dodged, char invisible
    /// 2     HBS_FLAG_SHIELD        - activates onShieled triggers when damaged to see if you should be shielded
    /// 4     HBS_FLAG_FROZEN        - hotbars do not move (used for Twili's Timestop)
    /// 8     HBS_FLAG_STABLESPEED   - uneffected by speed changes (Midsummer Dress etc.)
    /// 16    HBS_FLAG_BIND          - movement tech (like Heavyblade's Special) won't work
    /// 32    HBS_FLAG_SUPER         - special super rainbow effect
    /// 64    HBS_FLAG_FADE          - draws faded afterimage as your character moves
    /// 128   HBS_FLAG_NOLUCKY       - lucky procs don't happen
    /// 256   HBS_FLAG_STABLEDAMAGE  - no crits and no random damage
    /// 512   HBS_FLAG_HOLYSHIELD    - used for Matti fight
    /// 1024  HBS_FLAG_NOINVULN      - Can't become invulnerable (used for Merran fight)
    /// 2048  HBS_FLAG_STILLDISPLAY  - for ""Tranquility"" status effect, draws the circle showing how far you can move
    /// 4096  HBS_FLAG_NOCRIT        - Can't hit for critical damage
    /// 8192  HBS_FLAG_EXTRACRIT     - Crits deal 175% instead of 75% more damage (Royal Crown effect)
    /// 16384 HBS_FLAG_SUPERLUCKY    - Lucky procs always happen (Rabbitluck effect)
    /// 32768 HBS_FLAG_EXTRADEADZONE - Adds an extra deadzone to people playing with the mouse ( for Turbulent Winds)"
    hbsFlag: ?u16 = null,

    /// Makes abilities on the mini-hotbar shine, indicating that they're stronger. Used on status
    /// effects like Flash-Int, Flow-Str or Super.
    /// Can also be used to cross them out and make them unusable.
    /// This is a binary number, so multiple values can be combined to have multiple effects.
    hbShineFlag: ?ShineFlag = null,
};

pub fn item(opt: Item) void {
    item2(opt) catch |err| @panic(@errorName(err));
}

fn item2(opt: Item) !void {
    const item_names_w = item_names.writer();
    try item_names_w.print("{s},0,", .{opt.id});
    try writeCsvString(item_names_w, opt.name.english);
    try item_names_w.writeAll(",");
    try writeCsvString(item_names_w, opt.name.japanese orelse opt.name.english);
    try item_names_w.writeAll(",");
    try writeCsvString(item_names_w, opt.name.chinese orelse opt.name.english);
    try item_names_w.writeAll("\n");

    const item_desc_w = item_descriptions.writer();
    try item_desc_w.print("{s},0,", .{opt.id});
    try writeCsvString(item_desc_w, opt.description.english);
    try item_desc_w.writeAll(",");
    try writeCsvString(item_desc_w, opt.description.japanese orelse opt.description.english);
    try item_desc_w.writeAll(",");
    try writeCsvString(item_desc_w, opt.description.chinese orelse opt.description.english);
    try item_desc_w.writeAll("\n");

    const item_ini_w = item_ini.writer();
    try item_ini_w.print("[{s}]\n", .{opt.id});
    inline for (@typeInfo(@TypeOf(opt)).@"struct".fields) |field| continue_blk: {
        if (comptime std.mem.eql(u8, field.name, "id"))
            break :continue_blk;
        if (comptime std.mem.eql(u8, field.name, "name"))
            break :continue_blk;
        if (comptime std.mem.eql(u8, field.name, "description"))
            break :continue_blk;
        if (comptime std.mem.eql(u8, field.name, "script"))
            break :continue_blk;

        if (@field(opt, field.name)) |value| {
            const T = @TypeOf(value);
            try item_ini_w.print("{s}=\"", .{field.name});
            if (T == Color) {
                try item_ini_w.print("#{x:02}{x:02}{x:02}", .{
                    value.r,
                    value.g,
                    value.b,
                });
            } else switch (@typeInfo(T)) {
                .bool => try item_ini_w.print("{d}", .{@intFromBool(value)}),
                .int, .float => try item_ini_w.print("{d}", .{value}),
                .@"enum", .@"struct", .@"union" => if (@hasDecl(@TypeOf(value), "toIniString")) {
                    try item_ini_w.writeAll(value.toIniString());
                } else if (@hasDecl(@TypeOf(value), "toIniInt")) {
                    try item_ini_w.print("{d}", .{value.toIniInt()});
                } else {
                    try item_ini_w.writeAll(@tagName(value));
                },
                else => try item_ini_w.writeAll(value),
            }
            try item_ini_w.writeAll("\"\n");
        }
    }

    try item_csv.writer().print(
        \\,,,,,
        \\{s},{},,,,
        \\
    ,
        .{ opt.id, written_items },
    );

    written_items += 1;
    have_trigger = false;
}

/// When certain things in the game happen (everything from you gaining gold, to using an ability,
/// to starting a run, to a % chance succeeding), a "Trigger" is called. You can make your items
/// react to these Triggers, to do the things they're supposed to do.
///
/// https://docs.google.com/spreadsheets/d/1shtFkpagAafUjjA70XGlYGruqFIbLpQlcDjWKNNm3_4/edit?pli=1&gid=1624073505#gid=1624073505
pub const Trigger = enum {
    /// Never called
    none,

    // The following are stat calculations, that are called in the order listed.

    // cdCalc0 and strCalc0 are typically used for items that give you a bonus on some kind of
    // condition; for instance, Amethyst Bracelet gives you a stat buff if it isn't broken, Demon
    // Horns gives you a bonus if its sqVar0 is 1 (and using your Defensive makes the sqVar0 0)

    /// Called before any other stat calculations (for Cooldowns).
    /// Currently unused
    cdCalc0,

    /// Called before any other stat calculations (for Strength).
    /// - Demon Horns, Royal Staff, Flamewalker Boots, Amethyst Bracelet
    strCalc0,

    // ----"Stats" that loot items give you are added here----

    /// Currently unused
    cdCalc1,

    /// Additions to cooldown/GCD (bad)
    /// - Mountain Staff, Tough Gauntlet, Teacher Knife, Dragonhead Spear
    cdCalc2a,

    /// Additions to cooldown/GCD (good)
    /// - Kappa Shield, Hawkfeather Fan, Mermaid Scale
    cdCalc2b,

    /// Currently only used for Altair Dagger
    cdCalc3,

    /// Set cooldown/GCD to a fixed value (bad)
    /// - Twinstar Earrings, Nova Crown
    cdCalc4a,

    /// Set cooldown/GCD to a fixed value (good)
    /// - Starry Cloak, Windbite Dagger
    cdCalc4b,

    /// Set cooldown/GCD to a fixed value (overwrites previous calculations)
    /// - Haste Boots, Timemage Cap
    cdCalc5,

    /// Set cooldown/GCD to a fixed value (overwrites previous calculations, again)
    /// - "Berserk" Status, Bruiser Emerald Special, Sniper Emerald Primary
    cdCalc6,

    /// Strength calculations that happen before the % boost from your levels
    /// - Cursed Candlestaff, Ghost Spear, Phantom Dagger
    strCalc1a,

    /// - Timespace Dagger, Darkglass Spear, Obsidian Rod
    strCalc1b,

    /// - Nightguard Gloves, Sacredstone Charm, Pocketwatch, Gladiator Helmet
    strCalc1c,

    // ----% boost from levels happen here----

    /// Additions to strength/radius
    /// - Shadow Bracelet, Kunoichi Hood, Killing Note, Grasswoven Bracelet
    strCalc2,

    /// Currently unused
    strCalc3,

    /// Currently unused
    strCalc4,

    /// Set strength to a fixed value
    /// - Old Bonnet, Haunted Gloves
    strCalc5,

    /// Mostly unused "Heavy" Status
    strCalc6,

    /// Currently only used to adjust for edge-cases with Altair Dagger and Shinsoku Katana when
    /// you gain Rabbitluck
    /// - Shinsoku Katana, Altair Dagger
    finalCalc,

    /// Certain loot can change the color of your abilities. These two triggers are used to do
    /// that.
    /// - Lots of items
    colorCalc,

    /// If there is one loot that should override the color of any other loot, it should use this
    /// instead
    /// - Shrinemaiden's Kosode, Sniper's Eyeglasses, Shinsoku Katana (when successful)
    colorCalc2,

    /// Called when you leave the first screen
    /// - Currently only used for unlocks
    adventureStart,

    /// Called when you begin a stage
    /// - Currently only used for unlocks
    hallwayStart,

    /// Called at the start of a fight, before you character is able to attack
    /// - Currently unused
    battleStart0,

    /// Called at the start of a fight, *just* before you character is able to attack (before
    /// autoStart)
    /// - Blood Vial, Lost Pendant "autoStart" trigger explanation is below
    battleStart2,

    /// Called at the start of a fight, *just* after your character is able to attack (after
    /// autoStart)
    /// - Stoneplate Armor, Mermaid Scale
    battleStart3,

    /// Called as soon as battle ends in victory Currently only used for unlocks
    battleEnd0,

    /// Called a little bit after battle, as your DPS scores are appearing
    /// - Topaz Charm, Blue Rose, Red Tanzaku (Healing effect)
    battleEnd1,

    /// - Red Tanzaku (Experience gift)
    battleEnd2,

    /// - Regen Potion (heal 2)
    battleEnd3,

    /// - Regen Potion (heal 1)
    battleEnd4,

    /// Called when a status effect is created
    /// - Crowfeather Hairpin, Sacred Bow
    hbsCreated,

    /// This trigger should ONLY be called and used by the status effect that is created
    hbsCreatedSelf,

    /// Called when a status effect is overwritten by an instance of the same status
    /// - Currently unused
    hbsRefreshed,

    /// Called when a status effect is destroyed
    /// - Stoneskin, Ghostflame, Snare, Burn
    hbsDestroyed,

    /// - Currently unused
    hbsFlagTrigger,

    /// The following are shield checks. If your character is hit while they have the
    /// HBS_FLAG_SHIELD flag (see hbsFlag on the Stats sheet), it will go through these triggers
    /// in order, and stop if the character is shielded
    /// - Rockdragon Mail
    hbsShield0,

    /// - Red Tanzaku
    hbsShield1,

    /// - Stoneskin
    hbsShield2,

    /// - Graniteskin
    hbsShield3,

    /// - Emerald chestplate
    hbsShield4,

    /// - Phoenix charm
    hbsShield5,

    /// Called when any item (ability, loot, potion) is used. This particular trigger should
    /// typically only be used by the item that was used.
    /// - Most items and abilities that do things
    hotbarUsed,

    /// Called when an item is used. This particular trigger should be used for items like "When
    /// your Defensive is used, do X" or "When an ability with a cooldown is used, do X" effects
    /// - Gemini Necklace, Necronomicon, Whiteflame Staff
    hotbarUsedProc,

    /// Called when an item is used. Should be used for secondary effects of an item being used
    /// (that need to happen after hotbarUsed)
    hotbarUsed2,

    /// Called when an item is used. This particular trigger should be used for items like "When
    /// your Defensive is used, do X" or "When an ability with a cooldown is used, do X" effects
    /// Will happen after "hotbarUsed2"
    /// - Battlemaiden Armor, Lion Charm, Moss Shield
    hotbarUsedProc2,

    /// Last trigger to be called when an ability is used. Typically used to delete statuses that
    /// disappear when you use an ability etc..
    /// - "Flash-Int", "Vanish", etc..
    hotbarUsed3,

    /// Called when a character takes damage. Currently only used on the items that break when you
    /// take damage
    /// - Amethyst Bracelet, Ruby Circlet
    onDamage,

    /// Called when a character is healed
    /// - Currently unused
    onHealed,

    /// Called when a character gains invulnerability
    /// - Obsidian Hairpin, Storm Petticoat, Butterfly Hairpin
    onInvuln,

    /// Called when your character deals damage to an enemy. If an item does something like "Your
    /// Primary applies Poison", then what it does is, when you deal damage, it checks to see if
    /// the damage came from your Primary, then applies Poison to the thing that took the damage
    /// - Staticshock Earrings, Ivy Staff, Darkstorm Knife, basically every item that makes your
    ///   attacks afflict status effects
    onDamageDone,

    /// - Currently unused
    onHealDone,

    /// Called when your character erases an area of bullets
    /// - Reflection Shield, Spiked Shield
    onEraseDone,

    /// Called once per second
    /// - Poison, Spark, Decay Statuses
    regenTick,

    /// Called each time your character moves a Rabbitleap (even out of battle). When I say "in
    /// battle" what I really mean is "while hbAuto is on".  Which means that the character is
    /// using attacks
    /// - Tranquility Status
    distanceTick,

    /// Called every 200ms when your character is standing still (even out of battle)
    /// - Shinobi Tabi, Iron Grieves
    standingStill,

    /// Called each time your character moves a Rabbitleap (in battle)
    /// - Tornado Staff, Cloud Guard, Talon Charm
    distanceTickBattle,

    /// Called every 200ms when your character is standing still (in battle)
    /// - Floral Bow, Raindrop Earrings, Clay Rabbit
    standingStillBattle,

    /// Happens when a % chance succeeds (Note: NOT AUTOMATIC, if you make loot with a random
    /// activation chance, please add a tpat_hb_luck_proc Quick Pattern when it activates)
    /// - Usagi Kamen, Lightning Bow, Poisonfrog Charm
    luckyProc,

    /// Happens when loot with a cooldown activates (Note: NOT AUTOMATIC, if you make loot with
    /// a cooldown that is not directly 'used', please add a tpat_hb_cdloot_proc Quick Pattern
    /// when it activates)
    /// - Blackhole Charm, Quartz Shield, Lion Charm
    cdLootProc,

    /// Happens when a player starts attacking, or when a combat encounter starts.
    /// You most likely want to use this instead of "battleStart".
    /// "battleStart" won't activate outside of combat with an enemy, while this will work even if
    /// a player begins attacking a Training Dummy or Treasuresphere" Tidal Greatsword, Golem's
    /// Claymore, every item that starts on cooldown tbh Loot/Abilities that "start on cooldown"
    /// should have an autoStart trigger that runs the cooldown
    autoStart,

    /// Happens 5 seconds after a player stops attacking, or when a combat encounter ends
    /// - Currently only used to reset the counter on Defender's Special
    autoEnd,

    /// These two are currently unavailable to use with mods; lets me code up a special condition
    /// for which an item should be activated/deactivated
    /// - Feathered Overcoat, Shrinemaiden's Kosode
    onSpecialCond0,

    ///
    onSpecialCond1,

    /// Activates when the item is first picked up from a Treasure. Items like Ruby Circlet and
    /// Emerald Chestplate use this trigger to set their sqVar0 to a number on pickup, representing
    /// the number of "charges" they have. Items like Midsummer Dress, Grasswoven Bracelet, and
    /// Vitality Potion that boost your Max HP use this trigger to heal you for 1 HP on pickup
    /// - Butterfly Ocarina, Silver Coin, Ruby Circlet, Midsummer Dress
    onSquarePickup,

    /// Activates when you gain/lose gold
    /// - Royal Staff (calls for a recalculation of your stats when trigger is called)
    onGoldChange,

    /// Activates when you level up
    /// - Currently only used for Small Rabbit trinket
    onLevelup,

    /// Activates when an enemy starts their Enrage cast
    /// - Currently only used for one of Red Tanzaku's effects
    enrageStart,

    /// Used for certain boss fights (probably best not to use this)
    patternSpecial,

    pub fn toCsvString(trigger: Trigger) []const u8 {
        return @tagName(trigger);
    }
};

const TriggerOpt = struct { ?Condition = null };

pub fn trig(trigger: Trigger, opt: TriggerOpt) void {
    trig2(trigger, opt) catch |err| @panic(@errorName(err));
}

fn trig2(trigger: Trigger, opt: TriggerOpt) !void {
    try item_csv.writer().print(
        \\,,,,,
        \\trigger,{s},{s},,,
        \\
    , .{
        trigger.toCsvString(),
        if (opt[0]) |condition| condition.toCsvString() else "",
    });
    have_trigger = true;
}

/// https://docs.google.com/spreadsheets/d/1shtFkpagAafUjjA70XGlYGruqFIbLpQlcDjWKNNm3_4/edit?pli=1&gid=75351937#gid=75351937
pub const Condition = enum {
    /// Always returns false
    none,

    /// flag0 (an integer representing a binary number)
    /// flag1 (an integer representing a binary number)
    /// Returns true if the binary "&" between these two integers is greater than 0
    check_flag,

    /// flag0 (an integer representing a binary number)
    /// flag1 (an integer representing a binary number)
    /// Returns true if the binary "&" between these two integers is 0
    check_no_flag,

    /// Exclusively used for "onDamageDone" trigger;
    /// returns true if damage amount is large enough to get the special flashy text
    dmg_islarge,

    /// Exclusively used for "onDamageDone" trigger;
    /// returns true if the damage done was caused by your Defensive
    dmg_self_defensive,

    /// Exclusively used for "onDamageDone" trigger;
    /// returns true if the damage done was caused by your Primary
    dmg_self_primary,

    /// Exclusively used for "onDamageDone" trigger;
    /// returns true if the damage done was caused by your Secondary
    dmg_self_secondary,

    /// Exclusively used for "onDamageDone" trigger;
    /// returns true if the damage done was caused by your Special
    dmg_self_special,

    /// Exclusively used for "onDamageDone" trigger;
    /// returns true if the damage done was caused by this item
    dmg_self_thishb,

    /// value0 (any number)
    /// value1 (any number)
    /// Returns true if the values are equal
    equal,

    /// value0 (any number)
    /// value1 (any number)
    /// Returns true if the values are unequal
    unequal,

    /// value0 (any number)
    /// comparitor (a string)
    /// value1 (any number)
    /// Returns true if the comparison is true
    /// Comparitors:
    /// "<" less than
    /// "<=" less than or equal
    /// ">" greater than
    /// ">=" greater than or equal
    /// "==" equal
    /// "!=" not equal"
    eval,

    /// bool0 (a boolean)
    /// Returns true if the boolean is false
    false,

    /// bool0 (a boolean)
    /// Returns true if the boolean is true
    true,

    /// Exclusively for use with "autoStart" trigger.
    /// Returns true if YOUR player was the one that started attacking.
    hb_auto_pl,

    /// Returns true if this item is off cooldown and available to use.
    hb_available,

    /// varIndex (a number 0-3)
    /// amount (any number)
    /// Checks to see if the item's sqVar is equal to a number.
    hb_check_square_var,

    /// varIndex (a number 0-3)
    /// amount (any number)
    /// Checks to see if the item's sqVar is NOT equal to a number.
    hb_check_square_var_false,

    /// varIndex (a number 0-3)
    /// amount (any number)
    /// Checks to see if the item's sqVar is greater than or equal to a number.
    hb_check_square_var_gte,

    /// varIndex (a number 0-3)
    /// amount (any number)
    /// Checks to see if the item's sqVar is less than or equal to a number.
    hb_check_square_var_lte,

    /// Exclusively for use with "hotbarUsed" "hotbarUsedProc" "hotbarUsed2" etc..
    /// Returns true if the hotbar used was your own player's Primary.
    hb_primary,

    /// Exclusively for use with "hotbarUsed" "hotbarUsedProc" "hotbarUsed2" etc..
    /// Returns true if the hotbar used was your own player's Secondary.
    hb_secondary,

    /// Exclusively for use with "hotbarUsed" "hotbarUsedProc" "hotbarUsed2" etc..
    /// Returns true if the hotbar used was your own player's Special.
    hb_special,

    /// Exclusively for use with "hotbarUsed" "hotbarUsedProc" "hotbarUsed2" etc..
    /// Returns true if the hotbar used was your own player's Defensive.
    hb_defensive,

    /// Exclusively for use with "hotbarUsed" "hotbarUsedProc" "hotbarUsed2" etc..
    /// Returns true if the hotbar used was your own player's loot.
    hb_loot,

    /// Returns true if the hotbar calling the trigger is different than the hotbar receiving this
    /// trigger
    hb_not_self,

    /// Returns true if the hotbar calling the trigger is the same as the hotbar receiving this
    /// trigger
    hb_self,

    /// Returns true if the hotbar calling the trigger is an Attack (aka Primary, Secondary or
    /// Special), and used by your player
    hb_self_attack,

    /// Returns true if the hotbar calling the trigger is an Ability (including Defensive) used by
    /// your player
    hb_self_weapon,

    /// Returns true if the hotbar calling the trigger was used by your player
    hb_selfcast,

    /// Returns true if the hotbar calling the trigger was used by anyone on your team
    hb_team,

    /// Returns true if the hotbar calling the triggers is a "weapon" item type
    hb_type_weapon,

    /// For use from status effects, checks if the hotbar just used was from the player afflicted
    /// with this status
    hbs_aflplayer,

    /// For use from status effects, checks if the hotbar just used was from the player afflicted
    /// with this status, and that the hotbar was an Attack (not Defensive or Loot)
    hbs_aflplayer_attack,

    /// For use from status effects, checks if a status effect calling a trigger is the same as
    /// this status effect
    hbs_self,

    /// Exclusively for use with "hbsCreated".
    /// Returns true if the Status Effect that called the trigger was created by this hotbar.
    hbs_thishbcast,

    /// Exclusively for use with "hbsCreated".
    /// Returns true if the Status Effect that called the trigger was not created by this hotbar.
    hbs_not_thishbcast,

    /// Exclusively for use with "hbsCreated".
    /// Returns true if the Status Effect that called the trigger was placed ON this player.
    hbs_selfafl,

    /// "Exclusively for use with "hbsCreated".
    /// Returns true if the Status Effect that called the trigger was placed BY this player.
    hbs_selfcast,

    /// Returns true if the TARGETED hotbars are chargeable (not the item this trigger belongs to)
    hb_check_chargeable0,

    /// Returns true if the TARGETED hotbars are resettable (not the item this trigger belongs to)
    /// IMPORTANT: This should always be checked before you reset a cooldown.
    hb_check_resettable0,

    /// amount (any number)
    /// Returns true if the player receiving this trigger is missing at least "amount" health
    missing_health,

    /// Checks if the current player is currently attacking or in battle (currently only used for
    /// Ancient Emerald Defensive)
    pl_autocheck,

    /// Checks if trigger is coming from this player (or one of their hotbars)
    pl_self,

    /// comparitor (string)
    /// numberOfPlayers (integer)
    /// Returns true if the number of players this code is currently targetting matches the
    /// comparison. Currently only used on Wolf Hood, Reaper Cloak, and Bloodflower Brooch to
    /// count number of players facing away from you
    /// Comparitors:
    /// "<" less than
    /// "<=" less than or equal
    /// ">" greater than
    /// ">=" greater than or equal
    /// "==" equal
    /// "!=" not equal
    player_target_count,

    /// comparitor (string)
    /// numberOfHBS (integer)
    /// Same as tcond_player_target_count, but for status effects
    hbs_target_count,

    /// comparitor (string)
    /// numberOfSlots (integer)
    /// Same as tcond_player_target_count, but for hotbarslots
    slot_target_count,

    /// percentChance (a number between 0 and 1)
    /// Will return true percentChance% of the time. Number should be between 0 and 1, with 0
    /// being a 0% chance and 1 being a 100% chance. If the player has a luck-increasing item,
    /// this percent chance will be that more likely to happen.
    random,

    /// Will return true based on the item's procChance (in Stats, the hitbox variable). If the
    /// player has a luck-increasing item, this percent chance will be that more likely to happen.
    random_def,

    /// Exclusively for use with "onSquarePickup".
    /// Checks to see if this is the item that was picked up.
    square_self,

    /// amount (an integer)
    /// Exclusively for use with "regenTick". Returns true every nth tick.
    tick_every,

    /// amount (an integer)
    /// For use with trinkets; checks if the Trinket's internal counter is equal to this number.
    trinket_counter_equal,

    /// amount (an integer)
    /// For use with trinkets; checks if the Trinket's internal counter is greater than or equal
    /// to this number.
    trinket_counter_greaterequal,

    /// bocInd (an integer representing Book of Cheat's RNG number) Don't use this
    bookofcheats_varcheck,

    pub fn toCsvString(condition: Condition) []const u8 {
        return switch (condition) {
            .none => "tcond_none",
            .check_flag => "tcond_check_flag",
            .check_no_flag => "tcond_check_no_flag",
            .dmg_islarge => "tcond_dmg_islarge",
            .dmg_self_defensive => "tcond_dmg_self_defensive",
            .dmg_self_primary => "tcond_dmg_self_primary",
            .dmg_self_secondary => "tcond_dmg_self_secondary",
            .dmg_self_special => "tcond_dmg_self_special",
            .dmg_self_thishb => "tcond_dmg_self_thishb",
            .equal => "tcond_equal",
            .unequal => "tcond_unequal",
            .eval => "tcond_eval",
            .false => "tcond_false",
            .true => "tcond_true",
            .hb_auto_pl => "tcond_hb_auto_pl",
            .hb_available => "tcond_hb_available",
            .hb_check_square_var => "tcond_hb_check_square_var",
            .hb_check_square_var_false => "tcond_hb_check_square_var_false",
            .hb_check_square_var_gte => "tcond_hb_check_square_var_gte",
            .hb_check_square_var_lte => "tcond_hb_check_square_var_lte",
            .hb_primary => "tcond_hb_primary",
            .hb_secondary => "tcond_hb_secondary",
            .hb_special => "tcond_hb_special",
            .hb_defensive => "tcond_hb_defensive",
            .hb_loot => "tcond_hb_loot",
            .hb_not_self => "tcond_hb_not_self",
            .hb_self => "tcond_hb_self",
            .hb_self_attack => "tcond_hb_self_attack",
            .hb_self_weapon => "tcond_hb_self_weapon",
            .hb_selfcast => "tcond_hb_selfcast",
            .hb_team => "tcond_hb_team",
            .hb_type_weapon => "tcond_hb_type_weapon",
            .hbs_aflplayer => "tcond_hbs_aflplayer",
            .hbs_aflplayer_attack => "tcond_hbs_aflplayer_attack",
            .hbs_self => "tcond_hbs_self",
            .hbs_thishbcast => "tcond_hbs_thishbcast",
            .hbs_not_thishbcast => "tcond_hbs_not_thishbcast",
            .hbs_selfafl => "tcond_hbs_selfafl",
            .hbs_selfcast => "tcond_hbs_selfcast",
            .hb_check_chargeable0 => "tcond_hb_check_chargeable0",
            .hb_check_resettable0 => "tcond_hb_check_resettable0",
            .missing_health => "tcond_missing_health",
            .pl_autocheck => "tcond_pl_autocheck",
            .pl_self => "tcond_pl_self",
            .player_target_count => "tcond_player_target_count",
            .hbs_target_count => "tcond_hbs_target_count",
            .slot_target_count => "tcond_slot_target_count",
            .random => "tcond_random",
            .random_def => "tcond_random_def",
            .square_self => "tcond_square_self",
            .tick_every => "tcond_tick_every",
            .trinket_counter_equal => "tcond_trinket_counter_equal",
            .trinket_counter_greaterequal => "tcond_trinket_counter_greaterequal",
            .bookofcheats_varcheck => "tcond_bookofcheats_varcheck",
        };
    }
};

pub fn cond(condition: Condition, args: anytype) void {
    switch (condition) {
        .eval => unreachable, // Call cond_eval2 instead
        else => {},
    }
    cond2(condition, args) catch |err| @panic(@errorName(err));
}

fn cond2(condition: Condition, args: anytype) !void {
    std.debug.assert(have_trigger);
    try item_csv.writer().print("condition,{s}", .{condition.toCsvString()});
    try writeArgs(item_csv.writer(), args);
}

/// Typesafe wrapper around `cond(.eval, .{a, op, b})`
pub fn cond_eval2(a: anytype, op: Compare, b: anytype) void {
    cond2(.eval, .{ a, op, b }) catch |err| @panic(@errorName(err));
}

/// "Quick" patterns are functions that are called immediately, in line. They include things like
/// resetting cooldowns, running GCDs, changing variables, etc..
///
/// The way that Parameters work for both Quick and Attack patterns are slightly different than
/// Set Functions and Trigger Functions. Rather than having a certain number of parameters that
/// need to be specified, they instead have key-value pairs that are passed in, all of which are
/// optional and have default values.
///
/// So for instance, if you wanted to use "tpat_hb_add_cooldown" to add 5 seconds to the cooldown
/// of your targeted hotbarslots, tpat_hb_add_cooldown has one parameter called "amount".
///
/// quickPattern,tpat_hb_add_cooldown,amount,5000,
///
/// If you wanted to use "tpat_hb_square_set_var" to set the sqVar0 of an item to "5",
/// tpat_hb_square_set_var has two parameters: "varIndex" and "amount".
///
/// quickPattern,tpat_hb_square_set_var,varIndex,0,amount,5,
///
///https://docs.google.com/spreadsheets/d/1shtFkpagAafUjjA70XGlYGruqFIbLpQlcDjWKNNm3_4/edit?pli=1&gid=1513724686#gid=1513724686
pub const QuickPattern = enum {
    /// Does nothing
    nothing,

    /// Adds the current list of targets to your debug log.
    debug_targets,

    /// "To be used during strCalc.
    /// Adds to the player's hitbox size.
    /// The default hitbox size is 5 pixels."
    player_add_radius,

    /// "stat" (a stat to add, see "STAT" in enum reference)
    /// "amount" (a number to add)
    /// Adds some stat amount to targetted players.
    player_add_stat,

    /// Randomizes your levitation ring color (used on the Paintbrush trinket)
    player_change_color_rand,

    /// Resets the distance ticker for targeted players to 0 (used for the "Tranquility" status
    /// effect to accurately measure 1 rabbitleap)
    player_distcounter_reset,

    /// "length" (time in milliseconds)
    /// Locks targeted players in place for the specified length of time.
    /// NOTE: This function currently doesn't work correctly online.
    player_movelock,

    /// "mult" (move speed multiplier)
    /// "length" (time in milliseconds)
    /// Slows/speeds up players for a brief amount of time.
    /// NOTE: This function currently doesn't work correctly online.
    player_movemult,

    /// "length" (time in milliseconds)
    /// Runs GCD for specified amount of time
    player_run_gcd,

    /// "amount" (size in pixels)
    /// Sets hitbox size for players; meant to be used in strCalc
    player_set_radius,

    /// "stat" (a stat to add, see "STAT" in enum reference)
    /// "amount" (a number to add)
    /// Sets a base stat for targeted players to an amount.
    player_set_stat,

    /// To be used during "hbsShield" triggers to indicate the player was successfully shielded
    /// from damage. Use this trigger for loot/ability effects.
    player_shield,

    /// To be used during "hbsShield" triggers to indicate the player was successfully shielded
    /// from damage. Use this trigger for status effects (like Stoneskin).
    player_shield_hbs,

    /// "amount" (a number)
    /// Add to the targeted player's hidden trinket counter.
    player_trinket_counter_add,

    /// "amount" (a number)
    /// "minAm" (a number, default 0)
    /// "maxAm" (a number, default 1000)
    /// Add to the targeted player's hidden trinket counter, but keep the counter inbetween the
    /// specified values.
    player_trinket_counter_add_bounded,

    /// "minAm" (a number, default 0)
    /// "maxAm" (a number, default 5)
    /// Randomize the hidden trinket counter between the two values
    player_trinket_counter_randomize,

    /// "amount" (a number)
    /// Set the target player's hidden trinket counter
    player_trinket_counter_set,

    /// Make the targeted player's trinket flash/sparkle/animate
    player_trinket_flash,

    /// "amount" (a number, in milliseconds)
    /// Adds (or subtracts, if amount is negative) an amount from targeted hotbarslot's
    /// current cooldown.
    hb_add_cooldown,

    /// "amount" (a number, in milliseconds)
    /// To be used during cdCalc, adds (or subtracts) an amount from targeted hotbarslot's
    /// overall cooldown
    hb_add_cooldown_permanent,

    /// "flag" (a binary)
    /// Adds a hitbox flag to a hotbarslot (see hbFlags on the "Stats" sheet)
    hb_add_flag,

    /// ""varIndex" (an integer from 0-3)
    /// "amount" (a number)"
    /// Adds the amount to the indicated hidden variable on the targeted hotbarslots.
    hb_add_hitbox_var,

    /// "varIndex" (an integer from 0-3)
    /// "amount" (a number)
    /// Adds the amount to the indicated hidden variable on the targeted hotbarslots.
    hb_add_statchange,

    /// "stat" (a stat enum, see STAT in enum reference)
    /// "amount" (a number)
    /// "calc" (a statChangerCalc enum, see STATCHANGERCALC in enum reference, defaults to
    ///         statChangerCalc.addFlag)
    /// DO NOT USE IN STRCALC, as you will get an infinite loop of changing the stat, then
    /// recalculating it over and over.
    /// Adds a stat to the item, which will boost the stat on the player who's holding it
    hb_add_gcd_permanent,

    /// "stat" (a stat enum, see STAT in enum reference)
    /// "amount" (a number)
    /// "calc" (a statChangerCalc enum, see STATCHANGERCALC in enum reference, defaults to
    ///         statChangerCalc.addFlag)
    /// To be used in strCalc. Adds a stat to the item, which will boost the stat on the player
    /// who's holding it. Added stats are permanent, unless reset with
    /// tpat_hb_reset_statchange_norefresh
    hb_add_statchange_norefresh,

    /// "amount" (a number)
    /// To be used in strCalc1a,strCalc1b,strCalc1c, to add a percentage increase in damage to
    /// targeted hotbarslots.
    hb_add_strcalcbuff,

    /// "amount" (a number)
    /// To be used in strCalc2, adds an amount to strength of targeted hotbarslots
    hb_add_strength,

    /// "amount" (a number)
    /// To be used in strCalc2, adds an amount to hbsStrength of targeted hotbarslots
    hb_add_strength_hbs,

    /// Must be called whenever a loot item with a cooldown that isn't directly "used" (aka isn't
    /// an auto hotbarslot) is activated.
    hb_cdloot_proc,

    /// "num" (a number of charges to give)
    /// "maxNum" (maximum number of charges that can be held at once, default 1)
    /// "type" (chargeTypes enum designating the type of Charge)
    /// Gives specified hotbarslots Charge.
    hb_charge,

    /// Clears specified hotbarslots of all Charge.
    hb_charge_clear,

    /// "messageIndex" (hbFlashMessage enum, default "none")
    /// "quiet" (a boolean that, if true, will prevent the flash from making sound. Defaults to false)
    /// Flashes an image of the targeted hotbarslots overhead. I recommend you use this when your
    /// item "activates". If this item procs extremely frequently, I'd recommend setting it to
    /// "quiet" so it isn't annoying to players who pick it up
    hb_flash_item,

    /// "messageIndex" (hbFlashMessage enum, default "none")
    /// "quiet" (a boolean that, if true, will prevent the flash from making sound. Defaults to false)
    /// Flashes an image of the RECEIVER hotbarslot overhead. Useful if you want to target a bunch
    /// of other hotbarslots to perform other calculations before calling the flash.
    hb_flash_item_source,

    /// Must be called whenever an ability, for whatever reason, is activated via some effect
    /// other than activating itself (such as Heavyblade's Garnet Primary, or Druids Sapphire
    /// Primary) so they can proc other items
    hb_hbuse_proc,

    /// "varIndex" (an integer between 0-3 indicating the variable number)
    /// "amount" (a number)
    /// Adds an amount to the hotbar's hidden variables
    hb_inc_var,

    /// "amount" (an integer)
    /// Adds an amount to the uses of stock, stockGCD, and stockOnly hotbarslots that are targeted.
    hb_increase_stock,

    /// Must be called whenever an item "succeeds" in a random proc chance, in order to activate
    /// other items. This will indicate that all hotbars targeted have proc'd."
    hb_lucky_proc,

    /// Alternatively, this function can be called. This will indicate that the RECEIVER hotbar
    /// has proc'd.
    hb_lucky_proc_source,

    /// "mult" (a number)
    /// "minimum" (a time in milliseconds, default 200)
    /// To be used during cdCalc, multiplies GCDs of targeted hotbarslots by a certain amount.
    hb_mult_gcd_permanent,

    /// "varIndex" (an integer between 0-3 indicating the variable number)
    /// "mult" (a number)
    /// Multiplies the targeted hotbar's hidden variable by a certain amount
    hb_mult_hitbox_var,

    /// "mult" (a number)
    /// Multiplies the targeted hotbar's hbsLength by a certain amount
    hb_mult_length_hbs,

    /// "mult" (a number)
    /// Multiplies the targeted hotbar's strength by a certain amount
    hb_mult_strength,

    /// "mult" (a number)
    /// Multiplies the targeted hotbar's hbsStrength by a certain amount
    hb_mult_strength_hbs,

    /// Forces a recalculation of color
    hb_recalc_color,

    /// "amount" (an integer)
    /// Reduces the stock of stock, stockGcd, and stockOnly hotbarslots targeted.
    hb_reduce_stock,

    /// Resets the cooldown of targeted hotbarslots. tcond_hb_check_resettable0 or
    /// ttrg_hotbarslots_prune_noreset should be run before using this to avoid resetting slots
    /// that aren't meant to be resettable.
    hb_reset_cooldown,

    /// Removes stat changes added via "tpat_hb_add_statchange" from targeted hotbarslots. Will
    /// also refresh strCalc. Not to be used during strCalc, or you will get an infinite refresh
    /// loop.
    hb_reset_statchange,

    /// Removes stat changes added via "tpat_hb_add_statchange" from targeted hotbarslots. Can be
    /// used during strCalc.
    hb_reset_statchange_norefresh,

    /// Runs cooldown of targeted hotbarslots.
    hb_run_cooldown,

    /// "length" (time in milliseconds)
    /// Runs cooldown of targeted hotbarslots for a specified amount.
    hb_run_cooldown_ext,

    /// "length" (time in milliseconds)
    /// Runs hidden cooldown of targeted hotbarslots for a specified amount.
    hb_run_cooldown_hidden,

    /// Changes the color of the targeted hotbarslots to the color of the RECEIVER of the original
    /// trigger. If your item upgrades an ability, you should add a colorCalc trigger that calls
    /// this on that ability, to add a bit of flair to your item!
    hb_set_color_def,

    /// "time" (in milliseconds)
    /// To be called during cdCalc, sets the cooldown of targeted hotbarslots to specified amount.
    hb_set_cooldown_permanent,

    /// "amount" (in milliseconds)
    /// "minimum" (in milliseconds, default 200)
    /// To be called during cdCalc, sets the GCD of targeted hotbarslots to specified amount.
    hb_set_gcd_permanent,

    /// "amount" (an integer)
    /// Sets stock of stock, stockGcd, and stockOnly hotbarslots to a specific amount.
    hb_set_stock,

    /// "amount" (a number)
    /// To be caled during strCalc, sets the strength of hotbarslots to a specific amount.
    hb_set_strength,

    /// "ratio" (a number)
    /// "maxAmount" (a number)
    /// Special function for Darkglass Spear
    hb_set_strength_darkglass_spear,

    /// "ratio" (a number)
    /// "maxAmount" (a number)
    /// Special function for Obsidian Rod
    hb_set_strength_obsidian_rod,

    /// "ratio" (a number)
    /// "maxAmount" (a number)
    /// Special function for Timespace Dagger
    hb_set_strength_timespace_dagger,

    /// Special function for Tidal Greatsword
    hb_set_tidalgreatsword,

    /// Special function for Tidal Greatsword
    hb_set_tidalgreatsword_start,

    /// "varIndex" (an integer between 0-3 indicating the variable number)
    /// "amount" (a number)
    /// Sets targeted hotbarslot's hidden variable to a specific amount
    hb_set_var,

    /// "varIndex" (an integer between 0-3 indicating the variable number)
    /// "minAmount" (a number)
    /// "maxAmount" (a number)
    /// Sets targeted hotbarslot's hidden variable to a random number between the two parameters
    hb_set_var_random_range,

    /// "varIndex" (an integer between 0-3 indicating the variable number)
    /// "amount" (a number)
    /// "minAmount" (a number, defaults to 0)
    /// "maxAmount" (a number, defaults to 100000)
    /// "netcallThreshold" (a number, defaults to 1)
    /// Adds to the targeted hotbarslot's sqVar. Keeps the sqVar between the min and max amount.
    /// "netcallThreshold" can be used to limit the number of pings this item makes to the
    /// others in your lobby, by only pinging every X increases. If you make an item like those
    /// in the Sparkblade set that changes sqVar0 constantly, you might want to set
    /// netcallThreshold to 5 or so.
    hb_square_add_var,

    /// "varIndex" (an integer between 0-3 indicating the variable number)
    /// "amount" (a number)
    /// Sets the targeted hotbarslot's sqVar.
    hb_square_set_var,

    /// For stock, stockGcd and stockOnly hotbarslots, zeros out stock and starts the slot's
    /// cooldown.
    hb_zero_stock,

    /// "flag" (a binary number representing an hbsFlag)
    /// Adds an HBS flag to targeted status effects (see hbsFlag on the "Stats" sheet)
    hbs_add_hbsflag,

    /// "flag" (a binary number representing an hbsShineFlag)
    /// Adds an HBS shine flag to targeted status effects (see hbShineFlag on the "Stats" sheet)
    hbs_add_shineflag,

    /// "stat" (a stat enum, see STAT in enum reference)
    /// "amount" (a number)
    /// "calc" (a statChangerCalc enum, see STATCHANGERCALC in enum reference, defaults to
    ///         statChangerCalc.addFlag)
    /// Adds a stat to the targeted status effect, which will boost the stat on the player who's
    /// holding it (Recommend that you use this during hbsCreatedSelf trigger)
    hbs_add_statchange,

    /// "playerId" (an integer repesenting a playerID)
    /// "amount" (an amount of bleed)
    /// Adds appropriate damagePlus stats to a status effect for Bleed status
    hbs_add_statchange_bleed,

    /// "amount" (an amount of bleed)
    /// Adds appropriate damagePlus stats to a status effect for Sap status
    hbs_add_statchange_sap,

    /// Destroys targeted status effects
    hbs_destroy,

    /// "mult" (a number)
    /// Multiplies strength of status effects targeted by specified number
    hbs_mult_str,

    /// Resets stats added to targeted status effects via tpat_hbs_add_statchange
    hbs_reset_statchange,

    /// Don't use this
    bookofcheats_set_random,

    pub fn toCsvString(pat: QuickPattern) []const u8 {
        return switch (pat) {
            .nothing => "tpat_nothing",
            .debug_targets => "tpat_debug_targets",
            .player_add_radius => "tpat_player_add_radius",
            .player_add_stat => "tpat_player_add_stat",
            .player_change_color_rand => "tpat_player_change_color_rand",
            .player_distcounter_reset => "tpat_player_distcounter_reset",
            .player_movelock => "tpat_player_movelock",
            .player_movemult => "tpat_player_movemult",
            .player_run_gcd => "tpat_player_run_gcd",
            .player_set_radius => "tpat_player_set_radius",
            .player_set_stat => "tpat_player_set_stat",
            .player_shield => "tpat_player_shield",
            .player_shield_hbs => "tpat_player_shield_hbs",
            .player_trinket_counter_add => "tpat_player_trinket_counter_add",
            .player_trinket_counter_add_bounded => "tpat_player_trinket_counter_add_bounded",
            .player_trinket_counter_randomize => "tpat_player_trinket_counter_randomize",
            .player_trinket_counter_set => "tpat_player_trinket_counter_set",
            .player_trinket_flash => "tpat_player_trinket_flash",
            .hb_add_cooldown => "tpat_hb_add_cooldown",
            .hb_add_cooldown_permanent => "tpat_hb_add_cooldown_permanent",
            .hb_add_flag => "tpat_hb_add_flag",
            .hb_add_hitbox_var => "tpat_hb_add_hitbox_var",
            .hb_add_statchange => "tpat_hb_add_statchange",
            .hb_add_gcd_permanent => "tpat_hb_add_gcd_permanent",
            .hb_add_statchange_norefresh => "tpat_hb_add_statchange_norefresh",
            .hb_add_strcalcbuff => "tpat_hb_add_strcalcbuff",
            .hb_add_strength => "tpat_hb_add_strength",
            .hb_add_strength_hbs => "tpat_hb_add_strength_hbs",
            .hb_cdloot_proc => "tpat_hb_cdloot_proc",
            .hb_charge => "tpat_hb_charge",
            .hb_charge_clear => "tpat_hb_charge_clear",
            .hb_flash_item => "tpat_hb_flash_item",
            .hb_flash_item_source => "tpat_hb_flash_item_source",
            .hb_hbuse_proc => "tpat_hb_hbuse_proc",
            .hb_inc_var => "tpat_hb_inc_var",
            .hb_increase_stock => "tpat_hb_increase_stock",
            .hb_lucky_proc => "tpat_hb_lucky_proc",
            .hb_lucky_proc_source => "tpat_hb_lucky_proc_source",
            .hb_mult_gcd_permanent => "tpat_hb_mult_gcd_permanent",
            .hb_mult_hitbox_var => "tpat_hb_mult_hitbox_var",
            .hb_mult_length_hbs => "tpat_hb_mult_length_hbs",
            .hb_mult_strength => "tpat_hb_mult_strength",
            .hb_mult_strength_hbs => "tpat_hb_mult_strength_hbs",
            .hb_recalc_color => "tpat_hb_recalc_color",
            .hb_reduce_stock => "tpat_hb_reduce_stock",
            .hb_reset_cooldown => "tpat_hb_reset_cooldown",
            .hb_reset_statchange => "tpat_hb_reset_statchange",
            .hb_reset_statchange_norefresh => "tpat_hb_reset_statchange_norefresh",
            .hb_run_cooldown => "tpat_hb_run_cooldown",
            .hb_run_cooldown_ext => "tpat_hb_run_cooldown_ext",
            .hb_run_cooldown_hidden => "tpat_hb_run_cooldown_hidden",
            .hb_set_color_def => "tpat_hb_set_color_def",
            .hb_set_cooldown_permanent => "tpat_hb_set_cooldown_permanent",
            .hb_set_gcd_permanent => "tpat_hb_set_gcd_permanent",
            .hb_set_stock => "tpat_hb_set_stock",
            .hb_set_strength => "tpat_hb_set_strength",
            .hb_set_strength_darkglass_spear => "tpat_hb_set_strength_darkglass_spear",
            .hb_set_strength_obsidian_rod => "tpat_hb_set_strength_obsidian_rod",
            .hb_set_strength_timespace_dagger => "tpat_hb_set_strength_timespace_dagger",
            .hb_set_tidalgreatsword => "tpat_hb_set_tidalgreatsword",
            .hb_set_tidalgreatsword_start => "tpat_hb_set_tidalgreatsword_start",
            .hb_set_var => "tpat_hb_set_var",
            .hb_set_var_random_range => "tpat_hb_set_var_random_range",
            .hb_square_add_var => "tpat_hb_square_add_var",
            .hb_square_set_var => "tpat_hb_square_set_var",
            .hb_zero_stock => "tpat_hb_zero_stock",
            .hbs_add_hbsflag => "tpat_hbs_add_hbsflag",
            .hbs_add_shineflag => "tpat_hbs_add_shineflag",
            .hbs_add_statchange => "tpat_hbs_add_statchange",
            .hbs_add_statchange_bleed => "tpat_hbs_add_statchange_bleed",
            .hbs_add_statchange_sap => "tpat_hbs_add_statchange_sap",
            .hbs_destroy => "tpat_hbs_destroy",
            .hbs_mult_str => "tpat_hbs_mult_str",
            .hbs_reset_statchange => "tpat_hbs_reset_statchange",
            .bookofcheats_set_random => "tpat_bookofcheats_set_random",
        };
    }
};

pub const QuickPatternArgs = struct {
    varIndex: ?usize = null,
    hitboxVar: ?Hitbox = null,
    stat: ?Stat = null,
    type: ?ChargeType = null,
    message: ?FlashMessage = null,
    time: ?usize = null,
    mult: ?f64 = null,
    multStr: ?[]const u8 = null,
    amount: ?f64 = null,
    amountStr: ?[]const u8 = null,
    amountR: ?Receiver = null,
    amountS: ?Source = null,

    pub fn notNullFieldCount(args: QuickPatternArgs) usize {
        var res: usize = 0;
        inline for (@typeInfo(QuickPatternArgs).@"struct".fields) |field| {
            res += @intFromBool(@field(args, field.name) != null);
        }

        return res;
    }
};

pub fn qpat(pat: QuickPattern, args: QuickPatternArgs) void {
    qpat2(pat, args) catch |err| @panic(@errorName(err));
}

fn qpat2(pat: QuickPattern, args: QuickPatternArgs) !void {
    std.debug.assert(have_trigger);
    const writer = item_csv.writer();
    try writer.print("quickPattern,{s}", .{pat.toCsvString()});

    if (args.varIndex) |varIndex|
        try writer.print(",varIndex,{d}", .{varIndex});
    if (args.hitboxVar) |hitboxVar|
        try writer.print(",varIndex,{s}", .{hitboxVar.toCsvString()});
    if (args.stat) |stat|
        try writer.print(",stat,{s}", .{stat.toCsvString()});
    if (args.type) |typ|
        try writer.print(",type,{s}", .{typ.toCsvString()});
    if (args.message) |message|
        try writer.print(",messageIndex,{s}", .{message.toCsvString()});
    if (args.time) |time|
        try writer.print(",time,{d}", .{time});
    if (args.mult) |mult|
        try writer.print(",mult,{d}", .{mult});
    if (args.multStr) |mult|
        try writer.print(",mult,{s}", .{mult});
    if (args.amount) |amount|
        try writer.print(",amount,{d}", .{amount});
    if (args.amountStr) |amount|
        try writer.print(",amount,{s}", .{amount});
    if (args.amountR) |amount|
        try writer.print(",amount,{s}", .{amount.toCsvString()});
    if (args.amountS) |amount|
        try writer.print(",amount,{s}", .{amount.toCsvString()});

    try writer.writeByteNTimes(',', 4 - args.notNullFieldCount() * 2);
    try writer.writeAll("\n");
}

/// "Attack" patterns are things that are placed into the game, to take place over time. They
/// include things like most attacks, healing, or other things that "happen" in the game.
///
/// The way that Parameters work for both Quick and Attack patterns are slightly different than
/// Set Functions and Trigger Functions. Rather than having a certain number of parameters that
/// need to be specified, they instead have key-value pairs that are passed in, all of which are
/// optional and have default values.
///
/// So for instance, if you wanted to use "ipat_winged_cap" to double your character's speed for 3
/// seconds, ipat_winged_cap has three parameters: "delay", "speedMult", "speedDuration". However,
/// we don't need to fill in "delay" if we don't intend to change it from its default value.
///
/// attackPattern,ipat_winged_cap,speedMult,2,speedDuration,3000
///
/// NOTE: Many attack patterns work with the following variables. These are filled in
/// automatically with parameters from the player/item, unless they are overwritten. You *can*
/// overwrite them, but I generally wouldn't unless you have a good reason to; as it might mess up
/// certain item combinations (like items that increase the radius of other items not working if
/// you change "radius")
///
/// "x"      : The player's x position
/// "y"      : The player's y position
/// "delay"  : The "delay" variable from the item's hitbox variables. Inserts a small delay before
///            the pattern takes effect.
/// "radius" : The "radius" variable from the item's hitbox variables. Dictates the size of the
///            attack; effects might vary from attack to attack.
/// "number" : The "hitNumber" variable from the item's hitbox variables. Changes how many times
///            the attack hits its target.  Doesn't work with all attacks, but works with many of
///            them.
/// "frot"   : Set to 0 if the player is facing right, 180 if the player is facing left. Used to
///            aim some attacks.
/// "fdir"   : Set to 1 if the player is facing right, -1 if the player is facing left. Used to
///            aim some attacks.
/// "rot"    : The angle from the player to its target reticule.
/// "fx"     : The x position of the player's target reticule
/// "fy"     : The y position of the player's target reticule
///
/// https://docs.google.com/spreadsheets/d/1shtFkpagAafUjjA70XGlYGruqFIbLpQlcDjWKNNm3_4/edit?pli=1&gid=258117569#gid=258117569
pub const AttackPattern = enum {
    /// "hbsColorInd" (an integer representing a color palette)
    /// These are all status patterns for poison ticks and the like; the hbsColorInd refers to the
    /// status's ID. It's probably best not to use these functions unless I add in custom status
    /// effects in later.
    bleed,

    /// "hbsColorInd" (an integer representing a color palette)
    burn,

    /// "hbsColorInd" (an integer representing a color palette)
    curse,

    /// "hbsColorInd" (an integer representing a color palette)
    poison,

    /// "hbsColorInd" (an integer representing a color palette)
    spark,

    /// "hbsColorInd" (an integer representing a color palette)
    /// Makes a flash effect based off the color of the status ID passed in.
    starflash_hbs,

    /// "hbsColorInd" (an integer representing a color palette)
    /// Erases an area, with color based off the status ID passed in.
    erase_area_hbs,

    /// "displayNumber" (an integer representing a hotbar slot; default 10)
    /// Applies a status effect set by tset_hbs or tset_hbs_def. If displayNumber is 0-3, then
    /// this will add a timer to the corresponding character's hotbarslot matching the debuff
    /// timer. (Similar to Sniper's Secondary)
    apply_hbs,

    /// "displayNumber" (an integer representing a hotbar slot; default 10)
    /// Applies a status effect set by tset_hbs or tset_hbs_def. (with a bit of a "flash" to
    /// indicate something happened). If displayNumber is 0-3, then this will add a timer to the
    /// corresponding character's hotbarslot matching the debuff timer. (Similar to Sniper's
    /// Secondary)
    apply_hbs_starflash,

    /// "duration" (length of invuln, in milliseconds, default 3000)
    /// Applies invulnerability for the specified duration.
    apply_invuln,

    /// "number"
    /// "radius"
    /// Hits with a slashing effect at your targeted position
    black_wakizashi,

    /// "number"
    /// Hits all enemies the specified number of times.
    blackhole_charm,

    /// "amount" (an integer representing an xp amount, default 0)
    /// At the end of the battle, will give targeted players an additional "amount" exp. Calling
    /// this creates a new, hidden object in the background, and creating a whole lot of them in
    /// one fight might lag the game. I'd recommend NOT calling this frequently during a single
    /// battle, but rather designing items in a way that this only needs to be called once per
    /// battle or so. For instance, if you wanted an item that gave 1 xp per time the character
    /// hit an enemy, instead of calling this every time you hit an enemy, increment a hidden
    /// variable each time you hit the enemy, then call this once at the end of battle to give
    /// the character their xp.
    blue_rose,

    /// "amount" (an integer representing an amount to heal, default 0)
    /// Heals targeted players for the specified amount.
    butterly_ocarina,

    /// Deals damage to all enemies, with the "spark" effect.
    crown_of_storms,

    /// Deals damage to targeted enemies. Despite the name, this is actually the Crescentmoon
    /// Dagger effect.
    curse_talon,

    /// "x"
    /// "y"
    /// "radius"
    /// Deals damage in a radius around the player.
    darkmagic_blade,

    /// "x"
    /// "y"
    /// "radius"
    /// Erases area in a radius around the player. Despite the name, Divine Mirror doesn't do this
    /// anymore; but items like Peridot Rapier do.
    divine_mirror,

    /// "fx"
    /// "fy"
    /// "radius"
    /// "rot"
    /// Fires a bow shot at your target. NOTE: "radius" here is actually the maximum distance the
    /// bow shot will travel, not the size of the impact.
    floral_bow,

    /// "time" (length of invuln, in milliseconds, default 0)
    /// Makes the player using the item invulnerable for the specified length of time.
    garnet_staff,

    /// "amount" (an integer representing an amount to heal, default 0)
    /// Heals targeted players for the specified amount.
    heal_light,

    /// "amount" (an integer representing an amount to heal, default 0)
    /// Heals targeted players for the specified amount. This should be used after a max health
    /// increase, as it includes extra network calls to make sure there's no desyncs (where, for
    /// instance, on one client a player heals before their max HP increases, resulting in
    /// mismatched health)
    heal_light_maxhealth,

    /// "amount" (an integer representing an amount to heal, default 0)
    /// "duration" (length of invuln, in milliseconds, default 3000)
    /// Heals targeted players AND grants them invulnerability for a specified length of time.
    heal_revive,

    /// "fx"
    /// "fy"
    /// "radius"
    /// Hydrous blob attack
    hydrous_blob,

    /// "type" (a weaponType enum, see enum reference)
    /// "duration" (length of cooldown in milliseconds, default 500)
    /// Runs specified cooldown. If type is "weaponType.none", it will run ALL your ability
    /// cooldowns for the specified amount."
    lullaby_harp,

    /// "number"
    /// Hits the targeted enemies the specified number of times.
    melee_hit,

    /// "fx"
    /// "fy"
    /// "radius"
    /// Deals damage once in a radius around your target (old Meteor Staff effect)
    meteor_staff,

    /// "x"
    /// "y"
    /// "radius"
    /// Deals damage once in a radius around the player
    moon_pendant,

    /// "fx"
    /// "fy"
    /// "radius"
    /// Deals damage once in a radius around your target (old Nightstar Grimoire effect)
    nightstar_grimoire,

    /// Applies status effect to all targeted players. Generally used for party buffs (uses
    /// "important" network alpha setting)
    ornamental_bell,

    /// "amount" (an integer representing an amount to heal, default 0)
    /// Heals targeted players for the specified amount. Looks fancier than other heal effects.
    phoenix_charm,

    /// Applies status effect to all targeted players. Generally used for applying debuffs (uses
    /// player's network alpha setting)
    poisonfrog_charm,

    /// "fx"
    /// "fy"
    /// "radius"
    /// Deals damage once in a radius around your target
    potion_throw,

    /// "x"
    /// "y"
    /// Deals damage to all enemies. Effect is centered on specified position.
    pulse_damage,

    /// "number"
    /// Deals damage to targeted enemies, with a "backstab" effect on the text.
    reaper_cloak,

    /// Makes a big flashy effect, that does nothing by itself.
    red_tanzaku,

    /// Deals damage once in a radius around your target. Projectile is similar to Wizard's
    /// Primary
    sleeping_greatbow,

    /// Deals damage to all enemies. Visual effect is very subtle, lending itself well to items
    /// that trigger frequently.
    sparrow_feather,

    /// Makes a flash effect around the player, indicating something has happened.
    starflash,

    /// Makes a dark-red flash effect around the player, indicating something has happened.
    starflash_failure,

    /// Adds a status effect and speeds up player's movement.
    thiefs_coat,

    /// Adds a status effect to targeted players. Recommended for buffs that target only yourself.
    timewarp_wand,

    /// "amount" (an integer representing a gold amount)
    /// At the end of the battle, will give targeted players an additional "amount" of gold.
    /// Calling this creates a new, hidden object in the background, and creating a whole lot of
    /// them in one fight might lag the game. I'd recommend NOT calling this frequently during a
    /// single battle, but rather designing items in a way that this only needs to be called once
    /// per battle or so. For instance, if you wanted an item that gave 1 gold per time the
    /// character hit an enemy, instead of calling this every time you hit an enemy, increment a
    /// hidden variable each time you hit the enemy, then call this once at the end of battle to
    /// give the character their gold.
    topaz_charm,

    /// "speedMult" (a number representing a multiplier to character speed)
    /// "speedDuration" (duration of speed increase)
    /// Increases speed by a multiplier for the specified duration.
    winged_cap,

    // Below this point are functions for Abilities. Currently, invulnerability times and
    // animations are included within the ability itself, but I'd like to refactor this so that
    // you'll be able to specify them for custom abilities. This might take me a bit. For now, I'm
    // leaving the below parts blank, and will fill them in at a later date.

    none_0,
    none_1,
    none_2,
    none_3,

    ancient_0,
    ancient_0_petonly,
    ancient_0_pt2,
    ancient_0_rabbitonly,
    ancient_1,
    ancient_1_auto,
    ancient_1_pt2,
    ancient_2,
    ancient_2_auto,
    ancient_2_pt2,
    ancient_3,
    ancient_3_emerald,
    ancient_3_emerald_pt2,
    ancient_3_emerald_pt3,

    assassin_0,
    assassin_0_ruby,
    assassin_1,
    assassin_1_garnet,
    assassin_1_ruby,
    assassin_1_sapphire,
    assassin_2,
    assassin_2_opal,
    assassin_3,
    assassin_3_opal,
    assassin_3_ruby,

    bruiser_0,
    bruiser_0_saph,
    bruiser_1,
    bruiser_2,
    bruiser_3,
    bruiser_3_pt2,
    bruiser_3_ruby,

    dancer_0,
    dancer_0_opal,
    dancer_1,
    dancer_1_emerald,
    dancer_2,
    dancer_2_saph,
    dancer_3,
    dancer_3_emerald,

    defender_0,
    defender_0_fast,
    defender_0_ruby,
    defender_1,
    defender_1_opal,
    defender_1_saph,
    defender_2,
    defender_2_emerald,
    defender_3,
    defender_3_pt2,

    druid_0,
    druid_0_emerald,
    druid_0_ruby,
    druid_0_saph,
    druid_1,
    druid_1_emerald,
    druid_1_garnet,
    druid_1_ruby,
    druid_2,
    druid_2_2,
    druid_2_2_garnet,
    druid_2_garnet,
    druid_2_ruby,
    druid_3,
    druid_3_emerald,
    druid_3_opal,
    druid_3_ruby,
    druid_3_saph,

    hblade_0,
    hblade_0_garnet,
    hblade_0_garnet_pt2,
    hblade_1,
    hblade_1_garnet,
    hblade_1_ruby,
    hblade_1_saph,
    hblade_2,
    hblade_2_emerald,
    hblade_2_pt2,
    hblade_3,
    hblade_3_garnet,
    hblade_3_opal,
    hblade_3_ruby,

    sniper_0,
    sniper_0_emerald,
    sniper_0_garnet,
    sniper_0_saph,
    sniper_1,
    sniper_1_ruby,
    sniper_2,
    sniper_2_emerald,
    sniper_3,

    spsword_0,
    spsword_0_pt2,
    spsword_1,
    spsword_1_emerald,
    spsword_1_pt2,
    spsword_2,
    spsword_2_pt2,
    spsword_3,
    spsword_3_pt2,

    wizard_0,
    wizard_0_ruby,
    wizard_1,
    wizard_1_garnet,
    wizard_1_garnet_pt2,
    wizard_1_opal,
    wizard_2,
    wizard_2_saph,
    wizard_3,
    wizard_3_emerald,
    wizard_3_opal,

    pub fn toCsvString(pat: AttackPattern) []const u8 {
        return switch (pat) {
            .bleed => "hpat_bleed",
            .burn => "hpat_burn",
            .curse => "hpat_curse",
            .poison => "hpat_poison",
            .spark => "hpat_spark",
            .ancient_0 => "ipat_ancient_0",
            .ancient_0_petonly => "ipat_ancient_0_petonly",
            .ancient_0_pt2 => "ipat_ancient_0_pt2",
            .ancient_0_rabbitonly => "ipat_ancient_0_rabbitonly",
            .ancient_1 => "ipat_ancient_1",
            .ancient_1_auto => "ipat_ancient_1_auto",
            .ancient_1_pt2 => "ipat_ancient_1_pt2",
            .ancient_2 => "ipat_ancient_2",
            .ancient_2_auto => "ipat_ancient_2_auto",
            .ancient_2_pt2 => "ipat_ancient_2_pt2",
            .ancient_3 => "ipat_ancient_3",
            .ancient_3_emerald => "ipat_ancient_3_emerald",
            .ancient_3_emerald_pt2 => "ipat_ancient_3_emerald_pt2",
            .ancient_3_emerald_pt3 => "ipat_ancient_3_emerald_pt3",
            .apply_hbs => "ipat_apply_hbs",
            .apply_hbs_starflash => "ipat_apply_hbs_starflash",
            .apply_invuln => "ipat_apply_invuln",
            .starflash_hbs => "ipat_starflash_hbs",
            .assassin_0 => "ipat_assassin_0",
            .assassin_0_ruby => "ipat_assassin_0_ruby",
            .assassin_1 => "ipat_assassin_1",
            .assassin_1_garnet => "ipat_assassin_1_garnet",
            .assassin_1_ruby => "ipat_assassin_1_ruby",
            .assassin_1_sapphire => "ipat_assassin_1_sapphire",
            .assassin_2 => "ipat_assassin_2",
            .assassin_2_opal => "ipat_assassin_2_opal",
            .assassin_3 => "ipat_assassin_3",
            .assassin_3_opal => "ipat_assassin_3_opal",
            .assassin_3_ruby => "ipat_assassin_3_ruby",
            .black_wakizashi => "ipat_black_wakizashi",
            .blackhole_charm => "ipat_blackhole_charm",
            .blue_rose => "ipat_blue_rose",
            .bruiser_0 => "ipat_bruiser_0",
            .bruiser_0_saph => "ipat_bruiser_0_saph",
            .bruiser_1 => "ipat_bruiser_1",
            .bruiser_2 => "ipat_bruiser_2",
            .bruiser_3 => "ipat_bruiser_3",
            .bruiser_3_pt2 => "ipat_bruiser_3_pt2",
            .bruiser_3_ruby => "ipat_bruiser_3_ruby",
            .butterly_ocarina => "ipat_butterly_ocarina",
            .crown_of_storms => "ipat_crown_of_storms",
            .curse_talon => "ipat_curse_talon",
            .dancer_0 => "ipat_dancer_0",
            .dancer_0_opal => "ipat_dancer_0_opal",
            .dancer_1 => "ipat_dancer_1",
            .dancer_1_emerald => "ipat_dancer_1_emerald",
            .dancer_2 => "ipat_dancer_2",
            .dancer_2_saph => "ipat_dancer_2_saph",
            .dancer_3 => "ipat_dancer_3",
            .dancer_3_emerald => "ipat_dancer_3_emerald",
            .darkmagic_blade => "ipat_darkmagic_blade",
            .defender_0 => "ipat_defender_0",
            .defender_0_fast => "ipat_defender_0_fast",
            .defender_0_ruby => "ipat_defender_0_ruby",
            .defender_1 => "ipat_defender_1",
            .defender_1_opal => "ipat_defender_1_opal",
            .defender_1_saph => "ipat_defender_1_saph",
            .defender_2 => "ipat_defender_2",
            .defender_2_emerald => "ipat_defender_2_emerald",
            .defender_3 => "ipat_defender_3",
            .defender_3_pt2 => "ipat_defender_3_pt2",
            .divine_mirror => "ipat_divine_mirror",
            .druid_0 => "ipat_druid_0",
            .druid_0_emerald => "ipat_druid_0_emerald",
            .druid_0_ruby => "ipat_druid_0_ruby",
            .druid_0_saph => "ipat_druid_0_saph",
            .druid_1 => "ipat_druid_1",
            .druid_1_emerald => "ipat_druid_1_emerald",
            .druid_1_garnet => "ipat_druid_1_garnet",
            .druid_1_ruby => "ipat_druid_1_ruby",
            .druid_2 => "ipat_druid_2",
            .druid_2_2 => "ipat_druid_2_2",
            .druid_2_2_garnet => "ipat_druid_2_2_garnet",
            .druid_2_garnet => "ipat_druid_2_garnet",
            .druid_2_ruby => "ipat_druid_2_ruby",
            .druid_3 => "ipat_druid_3",
            .druid_3_emerald => "ipat_druid_3_emerald",
            .druid_3_opal => "ipat_druid_3_opal",
            .druid_3_ruby => "ipat_druid_3_ruby",
            .druid_3_saph => "ipat_druid_3_saph",
            .erase_area_hbs => "ipat_erase_area_hbs",
            .floral_bow => "ipat_floral_bow",
            .garnet_staff => "ipat_garnet_staff",
            .hblade_0 => "ipat_hblade_0",
            .hblade_0_garnet => "ipat_hblade_0_garnet",
            .hblade_0_garnet_pt2 => "ipat_hblade_0_garnet_pt2",
            .hblade_1 => "ipat_hblade_1",
            .hblade_1_garnet => "ipat_hblade_1_garnet",
            .hblade_1_ruby => "ipat_hblade_1_ruby",
            .hblade_1_saph => "ipat_hblade_1_saph",
            .hblade_2 => "ipat_hblade_2",
            .hblade_2_emerald => "ipat_hblade_2_emerald",
            .hblade_2_pt2 => "ipat_hblade_2_pt2",
            .hblade_3 => "ipat_hblade_3",
            .hblade_3_garnet => "ipat_hblade_3_garnet",
            .hblade_3_opal => "ipat_hblade_3_opal",
            .hblade_3_ruby => "ipat_hblade_3_ruby",
            .heal_light => "ipat_heal_light",
            .heal_light_maxhealth => "ipat_heal_light_maxhealth",
            .heal_revive => "ipat_heal_revive",
            .hydrous_blob => "ipat_hydrous_blob",
            .lullaby_harp => "ipat_lullaby_harp",
            .melee_hit => "ipat_melee_hit",
            .meteor_staff => "ipat_meteor_staff",
            .moon_pendant => "ipat_moon_pendant",
            .nightstar_grimoire => "ipat_nightstar_grimoire",
            .none_0 => "ipat_none_0",
            .none_1 => "ipat_none_1",
            .none_2 => "ipat_none_2",
            .none_3 => "ipat_none_3",
            .ornamental_bell => "ipat_ornamental_bell",
            .phoenix_charm => "ipat_phoenix_charm",
            .poisonfrog_charm => "ipat_poisonfrog_charm",
            .potion_throw => "ipat_potion_throw",
            .pulse_damage => "ipat_pulse_damage",
            .reaper_cloak => "ipat_reaper_cloak",
            .red_tanzaku => "ipat_red_tanzaku",
            .sleeping_greatbow => "ipat_sleeping_greatbow",
            .sniper_0 => "ipat_sniper_0",
            .sniper_0_emerald => "ipat_sniper_0_emerald",
            .sniper_0_garnet => "ipat_sniper_0_garnet",
            .sniper_0_saph => "ipat_sniper_0_saph",
            .sniper_1 => "ipat_sniper_1",
            .sniper_1_ruby => "ipat_sniper_1_ruby",
            .sniper_2 => "ipat_sniper_2",
            .sniper_2_emerald => "ipat_sniper_2_emerald",
            .sniper_3 => "ipat_sniper_3",
            .sparrow_feather => "ipat_sparrow_feather",
            .spsword_0 => "ipat_spsword_0",
            .spsword_0_pt2 => "ipat_spsword_0_pt2",
            .spsword_1 => "ipat_spsword_1",
            .spsword_1_emerald => "ipat_spsword_1_emerald",
            .spsword_1_pt2 => "ipat_spsword_1_pt2",
            .spsword_2 => "ipat_spsword_2",
            .spsword_2_pt2 => "ipat_spsword_2_pt2",
            .spsword_3 => "ipat_spsword_3",
            .spsword_3_pt2 => "ipat_spsword_3_pt2",
            .starflash => "ipat_starflash",
            .starflash_failure => "ipat_starflash_failure",
            .thiefs_coat => "ipat_thiefs_coat",
            .timewarp_wand => "ipat_timewarp_wand",
            .topaz_charm => "ipat_topaz_charm",
            .winged_cap => "ipat_winged_cap",
            .wizard_0 => "ipat_wizard_0",
            .wizard_0_ruby => "ipat_wizard_0_ruby",
            .wizard_1 => "ipat_wizard_1",
            .wizard_1_garnet => "ipat_wizard_1_garnet",
            .wizard_1_garnet_pt2 => "ipat_wizard_1_garnet_pt2",
            .wizard_1_opal => "ipat_wizard_1_opal",
            .wizard_2 => "ipat_wizard_2",
            .wizard_2_saph => "ipat_wizard_2_saph",
            .wizard_3 => "ipat_wizard_3",
            .wizard_3_emerald => "ipat_wizard_3_emerald",
            .wizard_3_opal => "ipat_wizard_3_opal",
        };
    }
};

pub const AttackPatternArgs = struct {
    fxStr: ?[]const u8 = null,
    fyStr: ?[]const u8 = null,
    duration: ?u16 = null,
    number: ?u16 = null,
    numberR: ?Receiver = null,
    numberS: ?Source = null,
    radius: ?u16 = null,

    pub fn notNullFieldCount(args: AttackPatternArgs) usize {
        var res: usize = 0;
        inline for (@typeInfo(AttackPatternArgs).@"struct".fields) |field| {
            res += @intFromBool(@field(args, field.name) != null);
        }

        return res;
    }
};

pub fn apat(pat: AttackPattern, args: AttackPatternArgs) void {
    apat2(pat, args) catch |err| @panic(@errorName(err));
}

fn apat2(pat: AttackPattern, args: AttackPatternArgs) !void {
    std.debug.assert(have_trigger);
    const writer = item_csv.writer();
    try writer.print("addPattern,{s}", .{pat.toCsvString()});

    if (args.fxStr) |fxStr|
        try writer.print(",fx,{s}", .{fxStr});
    if (args.fyStr) |fyStr|
        try writer.print(",fy,{s}", .{fyStr});
    if (args.duration) |duration|
        try writer.print(",duration,{d}", .{duration});
    if (args.number) |number|
        try writer.print(",number,{d}", .{number});
    if (args.numberR) |number|
        try writer.print(",number,{s}", .{number.toCsvString()});
    if (args.numberS) |number|
        try writer.print(",number,{s}", .{number.toCsvString()});
    if (args.radius) |radius|
        try writer.print(",radius,{d}", .{radius});

    try writer.writeByteNTimes(',', 4 - args.notNullFieldCount() * 2);
    try writer.writeAll("\n");
}

/// When a trigger is running, it has 3 lists of "targets".
/// 1) A list of players/enemies
/// 2) A list of hotbar slots (items/abilities)
/// 3) A list of status effects"
///
/// When a trigger is received by a player, the list of players starts with that player in the
/// target list.
///
/// When a trigger is received by a hotbar slot (items/abilities) the list of players starts with
/// the player that's holding that slot, and the list of slots starts with the hotbar slot that
/// received it.
///
/// When a trigger is received by a status effect, the list of players starts with the player that
/// APPLIED it, the list of slots starts with the hotbar slot that applied it (if any) and the
/// status effect list starts with itself in it.
///
/// When Quick Patterns are run, they affect whatever objects are in the respective lists.
///
/// When an Attack Pattern is run, it only affects whatever players are in the player target list
/// at the time.
///
/// https://docs.google.com/spreadsheets/d/1shtFkpagAafUjjA70XGlYGruqFIbLpQlcDjWKNNm3_4/edit?pli=1&gid=1880256260#gid=1880256260
pub const Target = enum {
    /// Clears all lists.
    none,

    // PLAYERS

    /// From a status effect receiving a trigger, target only the player afflicted with this
    /// status.
    player_afflicted,

    player_afflicted_source,

    /// When a status effect is the SOURCE of the trigger, target the player afflicted by that
    /// status effect.
    /// From an "onDamageDone" trigger, target the player that was damaged.
    player_damaged,

    /// flag (a binary number)
    ///
    /// Prune the current list of players to include only those that have a certain hbsFlag.
    player_prune_hbsflag,

    /// Target the player receiving this trigger; if the trigger is received by a hotbar slot, it
    /// will target the player who owns that slot.
    player_self,

    /// Targets all "players" (meaning, both allies and enemies).
    players_all,

    /// Targets all the players that are on the same team as the person receiving this trigger.
    /// For loot items, this means all of the rabbit players, but if an enemy were to call this,
    /// it would target all the enemies. Also, this excludes KO'd players.
    players_ally,

    /// excludeID (an integer)
    ///
    /// Targets all players on the same team, excluding KO'd players, and excluding the playerID
    /// passed in.
    players_ally_exclude,

    /// Targets all players on the same team. Includes KO'd players.
    players_ally_include_ko,

    /// Despite the name, this actually targets the player who's MISSING the most HP, not the
    /// actual lowest HP player. I must have written this a long time ago. Also, it excludes KO'd
    /// players.
    players_ally_lowest_hp,

    /// numberOfPlayers (an integer; this is an optional parameter)
    ///
    /// Targets a random selection of your teammates. If a number is passed in, it will try to
    /// target that many players. If no number is passed in, it will target 1.
    players_ally_random,

    /// Clears player list.
    players_none,

    /// Targets all the players that are on the OPPOSITE team as the person receiving this trigger.
    /// For loot items, this means all of your enemies.
    players_opponent,

    /// Targets all of your enemies that are facing away from you.
    players_opponent_backstab,

    /// trgBinary (a binary number representing player IDs)
    ///
    /// Targets your enemies based off a binary number.
    /// 1 : 0001 : Just player 0
    /// 2 : 0010 : Just player 1
    /// 3 : 0011 : Player 0 and Player 1
    /// 5 : 0101 : Player 0 and Player 2
    /// etc..
    players_opponent_binary,

    /// excludeID (an integer)
    ///
    /// Targets all players on the enemy team, excluding KO'd players, and excluding the playerID
    /// passed in.
    players_opponent_exclude,

    /// Targets whatever player this player is currently targetting.
    players_opponent_focus,

    /// numberOfPlayers (an integer; this is an optional parameter)
    ///
    /// Targets a random selection of your enemies.  If a number is passed in, it will try to
    /// target that many players.  If no number is passed in, it will target 1.
    players_opponent_random,

    /// param0 (any number)
    /// comparitor (a string)
    /// param1 (any number)
    ///
    /// Prunes current list of players to only include those that match the equation given.
    /// For instance, to target all allies that have more that 2 HP:
    ///
    /// target, ttrg_players_ally
    /// target, ttrg_players_prune, tp#_hp, >, 2
    ///
    /// When using "prune" functions, "#" is replaced with the appropriate variable for that item
    /// in the target list.
    players_prune,

    /// Removes the player receiving this trigger from the player list, if it is in there.
    players_prune_self,

    /// Targets the player who is the source of this trigger.
    players_source,

    /// numberOfPlayers (an integer; this is an optional parameter)
    ///
    /// Targets a random selection of the players that are currently in the list. If a number is
    /// passed in, it will try to target that many players. If no number is passed in, it will
    /// target 1.
    players_target_random,

    /// allyBin (a binary number representing player IDs)
    /// enemyBin (a binary number representing player IDs)
    ///
    /// Targets both allies and enemies based off binary numbers.
    /// 1 : 0001 : Just player 0
    /// 2 : 0010 : Just player 1
    /// 3 : 0011 : Player 0 and Player 1
    /// 5 : 0101 : Player 0 and Player 2
    /// etc..
    players_team_binary,

    // HOTBAR SLOTS (ITEMS/ABILITIES)

    /// Targets the hotbar slot receiving this trigger
    hotbarslot_self,

    /// Targets ALL active hotbar slots
    hotbarslots_all,

    /// Targets all hotbar slots on your team
    hotbarslots_ally,

    /// Targets all the hotbar slots of the players in the "players" list
    hotbarslots_current_players,

    /// Targets all the hotbar slots on your enemy's team
    hotbarslots_opponent,

    /// param0 (any number)
    /// comparitor (a string)
    /// param1 (any number)
    ///
    /// Prunes current list of hotbar slots to only include those that match the equation given.
    /// For instance, to target all of the current player's hotbar slots that have more than a
    /// 10 second cooldown:
    ///
    /// target, ttrg_player_self
    /// target, ttrg_hotbarslots_current_players,
    /// target, ttrg_hotbarslots_prune, ths#_cooldown, >, 10000
    ///
    /// When using "prune" functions, "#" is replaced with the appropriate variable for that item
    /// in the target list."
    hotbarslots_prune,

    /// Prune the current list of hotbar slots to only include items that have strength.
    hotbarslots_prune_base_has_str,

    /// param0 (a variable that differs per target)
    /// param1 (a boolean)
    ///
    /// Prune the current list of hotbar slots to only include items for which a boolean matches.
    hotbarslots_prune_bool,

    /// isBuff (if true, gets slots with buffs, if false, gets slots with debuffs)
    ///
    /// Prune the current list of hotbar slots to include items that have a Buff or Debuff they
    /// apply.
    hotbarslots_prune_bufftype,

    /// type (an integer representing a cooldown type)
    ///
    /// Prune the current list of hotbar slots to include items that have a specific cooldown type.
    /// 0 : None
    /// 1 : Time (only cooldown, such as Defensives/most loot)
    /// 2 : GCD (Most Primaries, Specials, etc.)
    /// 3 : Stock (Multiple uses, like Wizard Defensive)
    /// 4 : StockGCD (Multiple uses + a GCD, like Heavyblade Special)
    /// 5 : StockOnly (Cooldown doesn't make it gain stock, like Defender Special)
    hotbarslots_prune_cdtype,

    /// Prune the current list of hotbar slots to only include items that can be reset.
    hotbarslots_prune_noreset,

    /// Removes the hotbar slot receiving this trigger from the list of hotbar slots, if it's in
    /// there.
    hotbarslots_prune_self,

    /// Targets the abilities of the player receiving this trigger.
    hotbarslots_self_abilities,

    /// Targets the ability of the player receiving this trigger with the highest strength number
    /// (if it's tied, multiple abilities will be targeted)
    hotbarslots_self_higheststrweapon,

    /// Targets the loot of the player receiving this trigger
    hotbarslots_self_loot,

    /// wpType (an integer representing a weapon type)
    ///
    /// Targets a particular ability of the player receiving this trigger.
    /// 0 : None
    /// 1 : Primary
    /// 2 : Secondary
    /// 3 : Special
    /// 4 : Defensive
    hotbarslots_self_weapontype,

    /// wpType (an integer representing a weapon type)
    ///
    /// Same as ttrg_hotbarslots_self_weapontype, but will only target the ability if it has a base
    /// strength; otherwise it will simply result in an empty list.
    hotbarslots_self_weapontype_withstr,

    // STATUS EFFECTS

    /// Targets all status effects that are currently active
    hbstatus_all,

    /// Targets all status effects that have been APPLIED by your allies
    hbstatus_ally,

    /// Targets all status effects that have been APPLIED by your opponent
    hbstatus_opponent,

    /// Prunes current list of status effects to only include those that match the equation given.
    /// For instance, to target all of the status effects afflicting allies that are buffs:
    ///
    /// target, ttrg_hbstatus_all
    /// target, ttrg_hbstatus_prune,  thbs#_aflTeamId, ==, 0
    /// target, ttrg_hotbarslots_prune, thbs#_isBuff, ==, 1
    ///
    /// When using "prune" functions, "#" is replaced with the appropriate variable for that item
    /// in the target list.
    hbstatus_prune,

    /// Targets the status effect receiving this trigger.
    hbstatus_self,

    /// Targets the status effect that was the source of this trigger.
    hbstatus_source,

    /// Targets all of the status effects that have been applied by the current list of players.
    hbstatus_target,

    pub fn toCsvString(target: Target) []const u8 {
        return switch (target) {
            .none => "ttrg_none",
            .player_afflicted => "ttrg_player_afflicted",
            .player_afflicted_source => "ttrg_player_afflicted_source",
            .player_damaged => "ttrg_player_damaged",
            .player_prune_hbsflag => "ttrg_player_prune_hbsflag",
            .player_self => "ttrg_player_self",
            .players_all => "ttrg_players_all",
            .players_ally => "ttrg_players_ally",
            .players_ally_exclude => "ttrg_players_ally_exclude",
            .players_ally_include_ko => "ttrg_players_ally_include_ko",
            .players_ally_lowest_hp => "ttrg_players_ally_lowest_hp",
            .players_ally_random => "ttrg_players_ally_random",
            .players_none => "ttrg_players_none",
            .players_opponent => "ttrg_players_opponent",
            .players_opponent_backstab => "ttrg_players_opponent_backstab",
            .players_opponent_binary => "ttrg_players_opponent_binary",
            .players_opponent_exclude => "ttrg_players_opponent_exclude",
            .players_opponent_focus => "ttrg_players_opponent_focus",
            .players_opponent_random => "ttrg_players_opponent_random",
            .players_prune => "ttrg_players_prune",
            .players_prune_self => "ttrg_players_prune_self",
            .players_source => "ttrg_players_source",
            .players_target_random => "ttrg_players_target_random",
            .players_team_binary => "ttrg_players_team_binary",
            .hotbarslot_self => "ttrg_hotbarslot_self",
            .hotbarslots_all => "ttrg_hotbarslots_all",
            .hotbarslots_ally => "ttrg_hotbarslots_ally",
            .hotbarslots_current_players => "ttrg_hotbarslots_current_players",
            .hotbarslots_opponent => "ttrg_hotbarslots_opponent",
            .hotbarslots_prune => "ttrg_hotbarslots_prune",
            .hotbarslots_prune_base_has_str => "ttrg_hotbarslots_prune_base_has_str",
            .hotbarslots_prune_bool => "ttrg_hotbarslots_prune_bool",
            .hotbarslots_prune_bufftype => "ttrg_hotbarslots_prune_bufftype",
            .hotbarslots_prune_cdtype => "ttrg_hotbarslots_prune_cdtype",
            .hotbarslots_prune_noreset => "ttrg_hotbarslots_prune_noreset",
            .hotbarslots_prune_self => "ttrg_hotbarslots_prune_self",
            .hotbarslots_self_abilities => "ttrg_hotbarslots_self_abilities",
            .hotbarslots_self_higheststrweapon => "ttrg_hotbarslots_self_higheststrweapon",
            .hotbarslots_self_loot => "ttrg_hotbarslots_self_loot",
            .hotbarslots_self_weapontype => "ttrg_hotbarslots_self_weapontype",
            .hotbarslots_self_weapontype_withstr => "ttrg_hotbarslots_self_weapontype_withstr",
            .hbstatus_all => "ttrg_hbstatus_all",
            .hbstatus_ally => "ttrg_hbstatus_ally",
            .hbstatus_opponent => "ttrg_hbstatus_opponent",
            .hbstatus_prune => "ttrg_hbstatus_prune",
            .hbstatus_self => "ttrg_hbstatus_self",
            .hbstatus_source => "ttrg_hbstatus_source",
            .hbstatus_target => "ttrg_hbstatus_target",
        };
    }
};

pub fn ttrg(targ: Target, args: anytype) void {
    switch (targ) {
        .hotbarslots_prune => unreachable, // Call ttrg_hotbarslots_prune instead
        .hbstatus_prune => unreachable, // Call ttrg_hbstatus_prune instead
        else => {},
    }
    ttrg2(targ, args) catch |err| @panic(@errorName(err));
}

fn ttrg2(targ: Target, args: anytype) !void {
    std.debug.assert(have_trigger);
    try item_csv.writer().print("target,{s}", .{targ.toCsvString()});
    try writeArgs(item_csv.writer(), args);
}

/// Typesafe wrapper for `ttrg(.hotbarslots_prune, .{a, op, b})`
pub fn ttrg_hotbarslots_prune(a: anytype, op: Compare, b: anytype) void {
    ttrg2(.hotbarslots_prune, .{ a, op, b }) catch |err| @panic(@errorName(err));
}

/// Typesafe wrapper for `ttrg(.hbstatus_prune, .{a, op, b})`
pub fn ttrg_hbstatus_prune(a: anytype, op: Compare, b: anytype) void {
    ttrg2(.hbstatus_prune, .{ a, op, b }) catch |err| @panic(@errorName(err));
}

/// Set functions can be used to setup different variables, as well as set parameters for Attack
/// patterns.
///
/// There's also a few helpful things, like a debug print function.
///
/// https://docs.google.com/spreadsheets/d/1shtFkpagAafUjjA70XGlYGruqFIbLpQlcDjWKNNm3_4/edit?pli=1&gid=1105686251#gid=1105686251
pub const Set = enum {
    /// Currently non-functional; but I will make it work soon-ish
    animation,

    /// percent (a number between 0 - 1)
    /// Sets the critical hit chance for attack patterns.
    /// Note that this doesn't need to be set outside of special conditions (such as if you want
    /// something to always crit, or never crit)
    /// 0 : 0%
    /// 1 : 100%
    /// 0.5 : 50%
    critratio,

    /// flags (a binary representing a number of damage flags)
    /// Sets damage flags for upcoming attack patterns. This is a binary number, so numbers can be
    /// added together to have multiple flags.
    ///
    /// 1 : DMG_FLAG_HBS (Damage comes from a status effect)
    /// 2 : DMG_FLAG_QUIET (This damage will not make the enemy sprite "shake", recommended for
    ///                     Poison/Spark effects)
    /// 4 : DMG_FLAG_INVULNPIERCE (This damage will go through invulnerability)
    /// 8 : DMG_FLAG_DARKFLAME (Special flag for Spellsword Rabbit)
    damage_flags,

    /// param (any number or variable)
    /// Will print out that number. Currently doesn't do anything, but I will add it to the mod
    /// debug log in the next update.
    debug,

    /// Will set the appropriate strength for applying Burn. Must be used from an onDamageDone
    /// trigger before Burn is applied.
    hbs_burnhit,

    /// Will set the appropriate strength/length for a Buff or Debuff, based on the item's stats.
    /// Should be used before a buff or debuff is applied. The next Attack pattern will apply that
    /// Buff/Debuff on hit.
    hbs_def,

    /// Similar to tset_hbs_def, but will pick a random buff (for effects like Usagi Kamen)
    hbs_randombuff,

    /// hbsKey (a string that is a key to a status effect)
    /// Will set a custom debuff to be applied.
    hbskey,

    /// amount (an integer)
    /// Will set a custom debuff strength.
    hbsstr,

    /// percent (a number between 0 - 1 )
    /// Will set a custom hit variation. Usually used to set it to 0, in the case you want
    /// something to hit for a consistent amount each time. (Like Fire Potion, or Burn)
    randomness,

    /// amount (an integer)
    /// Will set a custom strength for Attack patterns.
    strength,

    /// Exculsively used for Defender's Ruby Secondary; sets a strength based off number of
    /// charges the move has.
    strength_chargecount,

    /// Sets the default strength for the move, based on the hotbar slot. You should usually use
    /// this before adding attack patterns that deal damage.
    strength_def,

    /// amount (an integer)
    /// Will set a custom strength for Attack patterns; this will take into account bonus damage
    /// that loot gets from items like Darkcloud Necklace
    strength_loot,

    /// amount (any number)
    /// Will set a bonus multiplier for enemies that you backstab with Attack patterns.
    /// 1   : 1x multiplier (normal damage)
    /// 1.3 : 1.3x multiplier (Assassin Special)
    /// 1.5 : 1.5x multiplier (Assassin Emerald Special)
    strmult_backstab,

    /// amount (any number)
    /// Will add a percentage bonus for every debuff the target has on them. This used to be one
    /// of Assassin's upgrades, but it sucked so I removed it.
    strmult_debuffcount,

    // You can also save user variables with certain Set Functions like tset_uservar. These
    // variables should always start with "u_"

    /// key (string)
    /// param0 (any number)
    /// mathSign (string)
    /// param1 (any number)
    /// .....
    ///
    /// Sets a uservar based on a mathematical formula.
    ///
    /// Set a uservar "u_amount" to the cooldown of the source of this trigger:
    /// set,tset_uservar,u_amount,s_cooldown
    ///
    /// Set a uservar "u_amount" to the HP of the source of this trigger, times 100
    /// set,tset_uservar,u_amount,s_hp,*,100,
    ///
    /// Set a uservar "u_amount" to the max HP of the source of this trigger, minus its current HP,
    /// plus 1, then times 1000
    /// set,tset_uservar,u_amount,s_hpMax,-,s_hp,+,1,*,1000
    ///
    /// Math formulas will execute one by one, in the order that they're in the line, regardless
    /// of order of operations
    uservar,

    /// For hotbar statuses, creates two uservariables "u_aflX" and "u_aflY" based on the position
    /// of the afflicted player.
    uservar_aflplayer_pos,

    /// key (string)
    /// cooldownAm (number)
    /// minimumCd (number)
    /// incrementCd (number)
    /// maxAm (number)
    /// A set function specifically to make Blackhole Charm work (saves a variable based off how
    /// long a cooldown is)
    uservar_blackhole_charm_calc,

    /// "key (string)
    /// onEqual (anything)
    /// onUnequal (anything)
    /// checkVarNum (integer)
    /// checkVarAm (number)
    /// If the squareVar indicated by checkVarNum is equal to checkVarAm, saves "onEqual" to the
    /// key provided. Otherwise, saves "onUnequal" to the key provided.
    uservar_cond_squarevar_equal,

    /// maxAm (integer)
    /// For Spellblade, saves the amount of darkflame this ability will consume to "u_darkflame".
    /// If an ability consumes 4 darkflame normally, and you have more than 4 darkflame, it will
    /// be set to 4.  If it normally consumes 4 and you only have 2 darkflame, it will be set to 2.
    uservar_darkflame,

    /// key (string)
    /// param0 (any number)
    /// mathSign (string)
    /// param1 (any number)
    ///
    /// Similar to tset_uservar, but it will loop through all of the players in your targetted player
    /// list, and save a uservariable for each player. Unlike tset_uservar, this only can do one
    /// mathSign at a time. "#" is replaced with the position of the player in the list.
    ///
    /// For each player, set a uservar "u_amount#" to their Max HP minus their current HP (where #
    /// is replaced with their position in the list)
    /// set,tset_uservar_each_target_player,u_amount#,s_hpMax,-,s_hp
    uservar_each_target_player,

    /// key (string)
    /// playerId (integer)
    /// Creates a user variable from that key, representing the player's gold
    uservar_gold,

    /// percentChance (number between 0 and 1)
    /// key (string)
    /// onSuccess (anything)
    /// onFail (anything)
    ///
    /// Flips a weighted coin based on the percentChance and the player's luck stat, and saves the
    /// result to a uservar based on whether or not it succeeded.
    uservar_random,

    /// key (string)
    /// minimumAmount (number)
    /// maximumAmount (number)
    ///
    /// Saves a random number between the minimum and maximum amount to a uservar.
    uservar_random_range,

    uservar_slotcount,
    uservar_hbscount,
    uservar_playercount,

    pub fn toCsvString(set: Set) []const u8 {
        return switch (set) {
            .animation => "tset_animation",
            .critratio => "tset_critratio",
            .damage_flags => "tset_damage_flags",
            .debug => "tset_debug",
            .hbs_burnhit => "tset_hbs_burnhit",
            .hbs_def => "tset_hbs_def",
            .hbs_randombuff => "tset_hbs_randombuff",
            .hbskey => "tset_hbskey",
            .hbsstr => "tset_hbsstr",
            .randomness => "tset_randomness",
            .strength => "tset_strength",
            .strength_chargecount => "tset_strength_chargecount",
            .strength_def => "tset_strength_def",
            .strength_loot => "tset_strength_loot",
            .strmult_backstab => "tset_strmult_backstab",
            .strmult_debuffcount => "tset_strmult_debuffcount",
            .uservar => "tset_uservar",
            .uservar_aflplayer_pos => "tset_uservar_aflplayer_pos",
            .uservar_blackhole_charm_calc => "tset_uservar_blackhole_charm_calc",
            .uservar_cond_squarevar_equal => "tset_uservar_cond_squarevar_equal",
            .uservar_darkflame => "tset_uservar_darkflame",
            .uservar_each_target_player => "tset_uservar_each_target_player",
            .uservar_gold => "tset_uservar_gold",
            .uservar_random => "tset_uservar_random",
            .uservar_random_range => "tset_uservar_random_range",
            .uservar_slotcount => "tset_uservar_slotcount",
            .uservar_hbscount => "tset_uservar_hbscount",
            .uservar_playercount => "tset_uservar_playercount",
        };
    }
};

pub fn tset(s: Set, args: anytype) void {
    switch (s) {
        .uservar => unreachable, // Call tset_uservar1 or tset_uservar2 instead
        else => {},
    }
    tset2(s, args) catch |err| @panic(@errorName(err));
}

fn tset2(s: Set, args: anytype) !void {
    std.debug.assert(have_trigger);
    try item_csv.writer().print("set,{s}", .{s.toCsvString()});
    try writeArgs(item_csv.writer(), args);
}

/// Typesafe wrapper for `tset(.uservar, .{name, v})`
pub fn tset_uservar1(name: []const u8, v: anytype) void {
    tset2(.uservar, .{ name, v }) catch |err| @panic(@errorName(err));
}

/// Typesafe wrapper for `tset(.uservar, .{name, a, op, b})`
pub fn tset_uservar2(name: []const u8, a: anytype, op: MathSign, b: anytype) void {
    tset2(.uservar, .{ name, a, op, b }) catch |err| @panic(@errorName(err));
}

fn writeArgs(writer: anytype, args: anytype) !void {
    inline for (args) |arg| {
        const T = @TypeOf(arg);
        switch (@typeInfo(T)) {
            .int, .comptime_int => try writer.print(",{}", .{arg}),
            .float, .comptime_float => try writer.print(",{d}", .{arg}),
            .@"enum", .@"union", .@"struct" => try writer.print(",{s}", .{arg.toCsvString()}),
            else => {
                try writer.writeAll(",");
                try writeCsvString(writer, arg);
            },
        }
    }

    try writer.writeByteNTimes(',', 4 - args.len);
    try writer.writeAll("\n");
}

fn writeCsvString(writer: anytype, string: []const u8) !void {
    if (std.mem.count(u8, string, "\"") != 0)
        unreachable; // TODO
    if (std.mem.count(u8, string, ",") != 0)
        return writer.print("\"{s}\"", .{string});

    return writer.writeAll(string);
}

pub const Color = struct {
    r: u8,
    g: u8,
    b: u8,
};

pub fn rgb(r: u8, g: u8, b: u8) Color {
    return .{ .r = r, .g = g, .b = b };
}

/// https://docs.google.com/spreadsheets/d/1Mcj2EbtQD15Aq-lIVE6_GeW_w7_N_aDKhgZzWg4vx54/edit?gid=68441595#gid=68441595
pub const Hbs = enum(u8) {
    smite_0 = 1,
    smite_1 = 2,
    smite_2 = 3,
    smite_3 = 4,

    elegy_0 = 5,
    elegy_1 = 6,
    elegy_2 = 7,

    haste_0 = 8,
    haste_1 = 9,
    haste_2 = 10,

    stoneskin = 11,
    lucky = 13,
    super = 14,
    flutterstep = 15,

    counter_0 = 16,
    counter_1 = 17,
    counter_2 = 18,

    blackstrike = 19,
    stillness = 20,
    repeat = 21,
    flowstr = 22,
    flowdex = 23,
    flowint = 24,
    flashstr = 25,
    flashdex = 26,
    flashint = 27,
    vanish = 28,
    ghost = 29,
    warcry = 30,
    astra = 31,
    berserk = 34,
    abyssrage = 35,

    sap,

    hex = 52,
    hex_super = 53,
    hex_poison = 54,

    hex_anti = 55,

    curse_0 = 56,
    curse_1 = 57,
    curse_2 = 58,
    curse_3 = 59,
    curse_4 = 60,
    curse_5 = 61,

    bleed_0 = 62,
    bleed_1 = 63,
    bleed_2 = 64,
    bleed_3 = 65,

    spark_0 = 69,
    spark_1 = 70,
    spark_2 = 71,
    spark_3 = 72,
    spark_4 = 73,
    spark_5 = 74,
    spark_6 = 75,

    poison_0 = 84,
    poison_1 = 85,
    poison_2 = 86,
    poison_3 = 87,
    poison_4 = 88,
    poison_5 = 89,
    poison_6 = 90,

    burn_0 = 91,
    burn_1 = 92,
    burn_2 = 93,
    burn_3 = 94,
    burn_4 = 95,
    burn_5 = 96,
    burn_6 = 97,

    decay_0,
    decay_1,
    decay_2,
    decay_3,
    decay_4,
    decay_5,
    decay_6,
    decay_7,
    decay_8,
    decay_9,

    ghostflame_0,
    ghostflame_1,
    ghostflame_2,
    ghostflame_3,
    ghostflame_4,
    ghostflame_5,

    snare_0,
    snare_1,
    snare_2,
    snare_3,
    snare_4,
    snare_5,
    snare_6,
    snare_7,

    snare2_0,
    snare2_1,
    snare2_2,
    snare2_3,
    snare2_4,
    snare2_5,
    snare2_6,
    snare2_7,

    pub const buffs = [_]Hbs{
        .abyssrage,
        .astra,
        .berserk,
        .blackstrike,
        .counter_0,
        .counter_1,
        .counter_2,
        .elegy_0,
        .elegy_1,
        .elegy_2,
        .flashdex,
        .flashint,
        .flashstr,
        .flowdex,
        .flowint,
        .flowstr,
        .flutterstep,
        .ghost,
        .haste_0,
        .haste_1,
        .haste_2,
        .hex_anti,
        .lucky,
        .repeat,
        .smite_0,
        .smite_1,
        .smite_2,
        .smite_3,
        .stillness,
        .stoneskin,
        .super,
        .vanish,
        .warcry,
    };

    pub const debuffs = [_]Hbs{
        .bleed_0,
        .bleed_1,
        .bleed_2,
        .bleed_3,
        .burn_0,
        .burn_1,
        .burn_2,
        .burn_3,
        .burn_4,
        .burn_5,
        .burn_6,
        .curse_0,
        .curse_1,
        .curse_2,
        .curse_3,
        .curse_4,
        .curse_5,
        .decay_0,
        .decay_1,
        .decay_2,
        .decay_3,
        .decay_4,
        .decay_5,
        .decay_6,
        .decay_7,
        .decay_8,
        .decay_9,
        .ghostflame_0,
        .ghostflame_1,
        .ghostflame_2,
        .ghostflame_3,
        .ghostflame_4,
        .ghostflame_5,
        .hex,
        .hex_poison,
        .hex_super,
        .poison_0,
        .poison_1,
        .poison_2,
        .poison_3,
        .poison_4,
        .poison_5,
        .poison_6,
        .sap,
        .snare_0,
        .snare_1,
        .snare_2,
        .snare2_0,
        .snare2_1,
        .snare2_2,
        .snare2_3,
        .snare2_4,
        .snare2_5,
        .snare2_6,
        .snare2_7,
        .snare_3,
        .snare_4,
        .snare_5,
        .snare_6,
        .snare_7,
        .spark_0,
        .spark_1,
        .spark_2,
        .spark_3,
        .spark_4,
        .spark_5,
        .spark_6,
    };

    pub const toCsvString = toString;
    pub const toIniString = toString;

    pub fn toString(hbs: Hbs) []const u8 {
        return switch (hbs) {
            .vanish => "hbs_vanish",
            .ghost => "hbs_ghost",
            .warcry => "hbs_warcry",
            .flutterstep => "hbs_flutterstep",
            .lucky => "hbs_lucky",
            .stoneskin => "hbs_stoneskin",
            .super => "hbs_super",
            .blackstrike => "hbs_blackstrike",
            .repeat => "hbs_repeat",
            .flowstr => "hbs_flowstr",
            .flowdex => "hbs_flowdex",
            .flowint => "hbs_flowint",
            .flashstr => "hbs_flashstr",
            .flashdex => "hbs_flashdex",
            .flashint => "hbs_flashint",
            .berserk => "hbs_berserk",
            .astra => "hbs_astra",
            .abyssrage => "hbs_abyssrage",
            .hex_anti => "hbs_hex_anti",
            .stillness => "hbs_stillness",
            .elegy_0 => "hbs_elegy_0",
            .elegy_1 => "hbs_elegy_1",
            .elegy_2 => "hbs_elegy_2",
            .haste_0 => "hbs_haste_0",
            .haste_1 => "hbs_haste_1",
            .haste_2 => "hbs_haste_2",
            .smite_0 => "hbs_smite_0",
            .smite_1 => "hbs_smite_1",
            .smite_2 => "hbs_smite_2",
            .smite_3 => "hbs_smite_3",
            .counter_0 => "hbs_counter_0",
            .counter_1 => "hbs_counter_1",
            .counter_2 => "hbs_counter_2",
            .sap => "hbs_sap",
            .hex => "hbs_hex",
            .hex_super => "hbs_hex_super",
            .hex_poison => "hbs_hex_poison",
            .curse_0 => "hbs_curse_0",
            .curse_1 => "hbs_curse_1",
            .curse_2 => "hbs_curse_2",
            .curse_3 => "hbs_curse_3",
            .curse_4 => "hbs_curse_4",
            .curse_5 => "hbs_curse_5",
            .spark_0 => "hbs_spark_0",
            .spark_1 => "hbs_spark_1",
            .spark_2 => "hbs_spark_2",
            .spark_3 => "hbs_spark_3",
            .spark_4 => "hbs_spark_4",
            .spark_5 => "hbs_spark_5",
            .spark_6 => "hbs_spark_6",
            .burn_0 => "hbs_burn_0",
            .burn_1 => "hbs_burn_1",
            .burn_2 => "hbs_burn_2",
            .burn_3 => "hbs_burn_3",
            .burn_4 => "hbs_burn_4",
            .burn_5 => "hbs_burn_5",
            .burn_6 => "hbs_burn_6",
            .decay_0 => "hbs_decay_0",
            .decay_1 => "hbs_decay_1",
            .decay_2 => "hbs_decay_2",
            .decay_3 => "hbs_decay_3",
            .decay_4 => "hbs_decay_4",
            .decay_5 => "hbs_decay_5",
            .decay_6 => "hbs_decay_6",
            .decay_7 => "hbs_decay_7",
            .decay_8 => "hbs_decay_8",
            .decay_9 => "hbs_decay_9",
            .poison_0 => "hbs_poison_0",
            .poison_1 => "hbs_poison_1",
            .poison_2 => "hbs_poison_2",
            .poison_3 => "hbs_poison_3",
            .poison_4 => "hbs_poison_4",
            .poison_5 => "hbs_poison_5",
            .poison_6 => "hbs_poison_6",
            .bleed_0 => "hbs_bleed_0",
            .bleed_1 => "hbs_bleed_1",
            .bleed_2 => "hbs_bleed_2",
            .bleed_3 => "hbs_bleed_3",
            .ghostflame_0 => "hbs_ghostflame_0",
            .ghostflame_1 => "hbs_ghostflame_1",
            .ghostflame_2 => "hbs_ghostflame_2",
            .ghostflame_3 => "hbs_ghostflame_3",
            .ghostflame_4 => "hbs_ghostflame_4",
            .ghostflame_5 => "hbs_ghostflame_5",
            .snare_0 => "hbs_snare_0",
            .snare_1 => "hbs_snare_1",
            .snare_2 => "hbs_snare_2",
            .snare_3 => "hbs_snare_3",
            .snare_4 => "hbs_snare_4",
            .snare_5 => "hbs_snare_5",
            .snare_6 => "hbs_snare_6",
            .snare_7 => "hbs_snare_7",
            .snare2_0 => "hbs_snare2_0",
            .snare2_1 => "hbs_snare2_1",
            .snare2_2 => "hbs_snare2_2",
            .snare2_3 => "hbs_snare2_3",
            .snare2_4 => "hbs_snare2_4",
            .snare2_5 => "hbs_snare2_5",
            .snare2_6 => "hbs_snare2_6",
            .snare2_7 => "hbs_snare2_7",
        };
    }
};

/// https://docs.google.com/spreadsheets/d/1shtFkpagAafUjjA70XGlYGruqFIbLpQlcDjWKNNm3_4/edit?pli=1&gid=1987338796#gid=1987338796&range=A82
pub const WeaponType = enum {
    none,
    primary,
    secondary,
    special,
    defensive,
    loot,
    potion,

    pub const abilities = [_]WeaponType{
        .primary,
        .secondary,
        .special,
        .defensive,
    };

    pub const abilities_with_gcd = [_]WeaponType{
        .primary,
        .secondary,
        .special,
    };

    pub fn toIniString(wt: WeaponType) []const u8 {
        return switch (wt) {
            .none => "none",
            .primary => "primary",
            .secondary => "secondary",
            .special => "special",
            .defensive => "defensive",
            .loot => "loot",
            .potion => "potion",
        };
    }

    pub fn toCsvString(wt: WeaponType) []const u8 {
        return switch (wt) {
            .none => "weaponType.none",
            .primary => "weaponType.primary",
            .secondary => "weaponType.secondary",
            .special => "weaponType.special",
            .defensive => "weaponType.defensive",
            .loot => "weaponType.loot",
            .potion => "weaponType.potion",
        };
    }
};

/// https://docs.google.com/spreadsheets/d/1shtFkpagAafUjjA70XGlYGruqFIbLpQlcDjWKNNm3_4/edit?pli=1&gid=1987338796#gid=1987338796&range=A105
pub const ChargeType = enum {
    charge,
    supercharge,
    ultracharge,
    omegacharge,
    darkspell,

    pub fn toIniString(ct: ChargeType) []const u8 {
        return switch (ct) {
            .charge => "charge",
            .supercharge => "supercharge",
            .ultracharge => "ultracharge",
            .omegacharge => "omegacharge",
            .darkspell => "darkspell",
        };
    }

    pub fn toCsvString(ct: ChargeType) []const u8 {
        return switch (ct) {
            .charge => "chargeTypes.charge",
            .supercharge => "chargeTypes.supercharge",
            .ultracharge => "chargeTypes.ultracharge",
            .omegacharge => "chargeTypes.omegacharge",
            .darkspell => "chargeTypes.darkspell",
        };
    }
};

/// https://docs.google.com/spreadsheets/d/1shtFkpagAafUjjA70XGlYGruqFIbLpQlcDjWKNNm3_4/edit?pli=1&gid=1987338796#gid=1987338796&range=A5
pub const Stat = enum {
    none,

    /// Adjusts Max HP
    hp,

    /// Makes your Primary deal extra damage (as a percentage). For example, inputting 0.2 will
    /// make your Primary deal 20% more damage. Inputting -0.5 will make your primary deal 50%
    /// less damage.
    primaryMult,

    /// Above, but for Secondary
    secondaryMult,

    /// Above, but for Special
    specialMult,

    /// Above, but for Defensive
    defensiveMult,

    /// Above, but for Loot items
    lootMult,

    /// Will make ALL damage you deal greater by a percentage
    allMult,

    /// Will make Status Effects deal you place deal more damage
    hbsMult,

    // For the following variables, same as above, but they are added in later in calculations.
    // These are only meant to be on Status Effects like Flash-Int, and should probably not be
    // used for items.

    primaryMultHbs,
    secondaryMultHbs,
    specialMultHbs,
    defensiveMultHbs,
    lootMultHbs,
    allMultHbs,
    hbsMultHbs,

    /// This makes afflicted characters TAKE more damage by a percentage. It is used for things
    /// like Curse, and shouldn't be placed on items.
    damageMult,

    // These make afflicted characters TAKE more damage by a flat number. Used for Bleed's effect,
    // and shouldn't be placed on items.

    damagePlusP0,
    damagePlusP1,
    damagePlusP2,
    damagePlusP3,

    /// Adds a flat value to all cooldowns this character has, measured in milliseconds. Currently
    /// only used on Firescale Corset.
    cdp,

    /// Increases or decreases GCDs by a percentage. Note that this being a negative number makes
    /// the GCD faster, and it being positive makes the GCD slower. If a character has multiple
    /// items that give haste, their effects are multiplied.
    haste,

    /// Makes critical hits deal more or less damage.
    critDamage,

    /// Makes the character luckier by a percentage. Use wisely.
    luck,

    /// Makes your character START with more gold. This is only used in toybox mode to make Silver
    /// Coin work there. It won't affect anything mid-run.
    startingGold,

    /// Makes your character move faster or slower.
    charspeed,

    /// Makes your character's hitbox larger or smaller. Used on Sunflower Crown and Evasion
    /// Potion, which have -10 each
    radius,

    /// Make invulnerability effects last longer (or shorter) by a flat amount, in milliseconds.
    invulnPlus,

    /// Currently does nothing
    stockPlus,

    /// Special flags that affect your character in various ways. This is a binary number, so
    /// multiple values can be combined to have multiple effects.
    hbsFlag,

    /// Makes abilities on the mini-hotbar shine, indicating that they're stronger. Used on status
    /// effects like Flash-Int, Flow-Str or Super. Can also be used to cross them out and make
    /// them unusable. This is a binary number, so multiple values can be combined to have multiple
    /// effects.
    hbShineFlag,

    pub fn toCsvString(stat: Stat) []const u8 {
        return switch (stat) {
            .none => "stat.none",
            .hp => "stat.hp",
            .primaryMult => "stat.primaryMult",
            .secondaryMult => "stat.secondaryMult",
            .specialMult => "stat.specialMult",
            .defensiveMult => "stat.defensiveMult",
            .lootMult => "stat.lootMult",
            .allMult => "stat.allMult",
            .hbsMult => "stat.hbsMult",
            .primaryMultHbs => "stat.primaryMultHbs",
            .secondaryMultHbs => "stat.secondaryMultHbs",
            .specialMultHbs => "stat.specialMultHbs",
            .defensiveMultHbs => "stat.defensiveMultHbs",
            .lootMultHbs => "stat.lootMultHbs",
            .allMultHbs => "stat.allMultHbs",
            .hbsMultHbs => "stat.hbsMultHbs",
            .damageMult => "stat.damageMult",
            .damagePlusP0 => "stat.damagePlusP0",
            .damagePlusP1 => "stat.damagePlusP1",
            .damagePlusP2 => "stat.damagePlusP2",
            .damagePlusP3 => "stat.damagePlusP3",
            .cdp => "stat.cdp",
            .haste => "stat.haste",
            .critDamage => "stat.critDamage",
            .luck => "stat.luck",
            .startingGold => "stat.startingGold",
            .charspeed => "stat.charspeed",
            .radius => "stat.radius",
            .invulnPlus => "stat.invulnPlus",
            .stockPlus => "stat.stockPlus",
            .hbsFlag => "stat.hbsFlag",
            .hbShineFlag => "stat.hbShineFlag",
        };
    }
};

/// https://docs.google.com/spreadsheets/d/1shtFkpagAafUjjA70XGlYGruqFIbLpQlcDjWKNNm3_4/edit?pli=1&gid=1987338796#gid=1987338796&range=A146
pub const Hitbox = enum {
    radius,
    delay,
    hbInput,
    weaponType,
    strMult,
    number,
    hbsType,
    hbsStrMult,
    hbsLength,
    chargeType,
    luck,

    pub fn toCsvString(hitbox: Hitbox) []const u8 {
        return switch (hitbox) {
            .radius => "hitbox.radius",
            .delay => "hitbox.delay",
            .hbInput => "hitbox.hbInput",
            .weaponType => "hitbox.weaponType",
            .strMult => "hitbox.strMult",
            .number => "hitbox.number",
            .hbsType => "hitbox.hbsType",
            .hbsStrMult => "hitbox.hbsStrMult",
            .hbsLength => "hitbox.hbsLength",
            .chargeType => "hitbox.chargeType",
            .luck => "hitbox.luck",
        };
    }
};

/// https://docs.google.com/spreadsheets/d/1shtFkpagAafUjjA70XGlYGruqFIbLpQlcDjWKNNm3_4/edit?pli=1&gid=1987338796#gid=1987338796&range=A172
pub const FlashMessage = enum {
    none,
    reset,
    proc,
    plus,
    failed,
    shield,
    broken,

    pub fn toCsvString(message: FlashMessage) []const u8 {
        return switch (message) {
            .none => "hbFlashMessage.none",
            .reset => "hbFlashMessage.reset",
            .proc => "hbFlashMessage.proc",
            .plus => "hbFlashMessage.plus",
            .failed => "hbFlashMessage.failed",
            .shield => "hbFlashMessage.shield",
            .broken => "hbFlashMessage.broken",
        };
    }
};

pub const MathSign = enum {
    @"*",
    @"+",
    @"/",
    @"-",

    pub fn toCsvString(op: MathSign) []const u8 {
        return switch (op) {
            .@"*" => "*",
            .@"+" => "+",
            .@"/" => "/",
            .@"-" => "-",
        };
    }
};

pub const Compare = enum {
    @"<",
    @"<=",
    @">",
    @">=",
    @"==",
    @"!=",

    pub fn toCsvString(op: Compare) []const u8 {
        return switch (op) {
            .@"<" => "<",
            .@"<=" => "<=",
            .@">" => ">",
            .@">=" => ">=",
            .@"==" => "==",
            .@"!=" => "!=",
        };
    }
};

/// While trigger code is being run, various variables are stored into a few different ds_maps (Or
/// hashtable or dictionary or whatever you want to call them)
///
/// * Whatever object calls the trigger is the SOURCE. Variables relating to the source of the
///   trigger start with "s_".
/// * Whatever object is receiving the trigger is the RECEIVER. Variables relating to the receiver
///   of the trigger start with "r_".
///
/// Trigger code is also capable of targetting lists of players, items, and status effects.
///
/// When you target a list of players, the variables relating to those players will start with
/// "tp#_", where # is replaced with the index. For instance, if you have 4 players and target all
/// of them, their HPs will be "tp0_hp" "tp1_hp" "tp2_hp" "tp3_hp".
///
/// When you target a list of items (hotbars), the variables relating
/// to those will start with "ths#_", where # is replaced with the index. ths is short for
/// "Targeted Hotbar Slot". For instance, if you target all of one player's abilities, their
/// cooldowns will be "ths0_cooldown" "ths1_cooldown" "ths2_cooldown" "ths3_cooldown".
///
/// When you target a list of status effects, the variables relating to those players will start
/// with "thbs#_", where # is replaced with the index. thbs is short for "Targeted Hotbar Status".
/// Status effects are called "HBS" everywhere because they used to go onto the hotbars, not the
/// players. Deepest lore. For instance, if you target a list of 3 status effects on one player,
/// whether or not those are buffs or not will be "thbs0_isBuff" "thbs1_isBuff" "thbs2_isBuff"
/// "thbs3_isBuff""
///
/// When using "prune" target functions, "#" will automatically be replaced with the appropriate
/// number as it goes through the list. For instance, to target all allies that have more that 2
/// HP:
///
/// target, ttrg_players_ally
/// target, ttrg_players_prune, tp#_hp, >, 2
///
/// Also, it's a bit complicated, but Items like Loot and Abilities and Potions all take up
/// "Hotbar Slots" that are persistent so when I talk about "Hotbars" and "Hotbar Slots" that's
/// what I mean, the Loot and Abilities on your character's hud at the bottom that do things
///
/// https://docs.google.com/spreadsheets/d/1shtFkpagAafUjjA70XGlYGruqFIbLpQlcDjWKNNm3_4/edit?pli=1&gid=1235653286#gid=1235653286
fn TriggerVariable(comptime prefix: []const u8) type {
    return enum {
        /// 0: Allies
        /// 1: Enemies
        teamId,

        /// A number 0-3
        /// Player IDs are assigned in the order that they FINISH selecting their character, not
        /// the order in which they're displayed at the bottom. Enemies also have IDs from 0-9,
        /// with 0 being the first enemy that spawns in any given battle.
        playerId,

        /// The player ID of the enemy that this player is focused on
        focusId,

        /// The current HP of the player
        hp,

        /// The Max HP of the player
        hpMax,

        /// A binary number, combined from all the items or statuses that give them the hbsFlag
        /// Stat (see Item Variable sheet)
        hbsFlag,

        /// The current number of buffs on this player
        hbsBuffCount,

        /// The current number of debuffs on this player
        hbsDebuffCount,

        /// The player's current x position (measured in pixels)
        xpos,

        /// The player's current y position (measured in pixels)
        ypos,

        /// The unique ID of this hotbar slot, numbered 0-80ish (each player has 20 I think)
        hbId,

        /// The "type" of the item
        /// 0: Character
        /// 1: "Weapon" (Which really means Ability)
        /// 2: Loot
        /// 3: Potion
        /// 4: Pickup (Full Heals + Level Ups in the store)
        /// 5: Upgrade (The upgrade gems in the store)
        type,

        /// The item ID of this hotbar slot (determined by the Item it is, like Obsidian Hairpin's
        /// ID is different from Mountain Staff)
        dataId,

        /// The amount of milliseconds before this particular item can be used again (the max of
        /// cooldown, hidden cooldown, GCD, etc..)
        milSecLeft,

        /// The amount of milliseconds left on its cooldown (disregarding GCD etc..)
        cdSecLeft,

        /// Whether or not this item can be "reset" (will be false if cdSecLeft is less than 600ms
        /// or if it's an unresettable item)
        resettable,

        /// The cooldown type of this item, compare using "cdType" enum
        cooldownType,

        /// The cooldown of this item, in milliseconds
        cooldown,

        /// The GCD of this item, in milliseconds
        gcd,

        /// The current number of uses on this item
        stock,

        /// The maximum number of uses on this item
        maxStock,

        /// The number of Charges on this item
        chargeCount,

        /// The strength of this item (Charge bonus is counted in)
        strength,

        /// The strength of the status effect on this item
        hbsStrength,

        /// The status effect ID of this item
        hbsType,

        hbsLength,

        /// The weapon type of this item, compare using "weaponType" enum
        weaponType,

        /// The strength of this item before calculations (I think, you probably shouldn't use
        /// this tbh)
        strengthMult,

        /// The radius of this item
        radius,

        /// The number of times this item deals damage per use (Like Assassin's Primary is 2,
        /// Golden Katana is 5)
        number,

        /// The delay between activation and hit for this item
        delay,

        /// The input type of this item, compare using "hitboxInput" enum
        hbInput,

        /// The item's proc chance ("procChance" on the Item Variable page, NOT "luck")
        luck,

        /// The item's hitbox flags ("hbFlags" on the Item Variable page, NOT "flags")
        flags,

        // These are hidden variables on the hotbar slots you can set
        vars0,
        vars1,
        vars2,
        vars3,

        sqVar0,
        sqVar1,
        sqVar2,
        sqVar3,

        /// The unique ID of the item that applied the status
        originHbId,

        /// The status ID (As in, Curse's ID is different from Vanish's ID)
        statusId,

        /// A unique number given to this particular instance of a status effect; starts at 0,
        /// increments with each new status application, and resets when the run resets
        uniqueId,

        /// The team ID of the player AFFLICTED with the status
        aflTeamId,

        /// The player ID of the player AFFLICTED with the status
        aflPlayerId,

        /// True if it's a buff, false if it's a debuff
        isBuff,

        /// True if it's a crit
        isCrit,

        /// A saved number on this trinket that can be used for various things. For instance, the
        /// Floof Ball is 'perfect' while its counter is 0; and its counter increments when you're
        /// hit, changing it to a ruffled Floof Ball
        counter,

        pub fn toCsvString(variable: @This()) []const u8 {
            return switch (variable) {
                .teamId => prefix ++ "teamId",
                .playerId => prefix ++ "playerId",
                .focusId => prefix ++ "focusId",
                .hp => prefix ++ "hp",
                .hpMax => prefix ++ "hpMax",
                .hbsFlag => prefix ++ "hbsFlag",
                .hbsBuffCount => prefix ++ "hbsBuffCount",
                .hbsDebuffCount => prefix ++ "hbsDebuffCount",
                .xpos => prefix ++ "xpos",
                .ypos => prefix ++ "ypos",
                .hbId => prefix ++ "hbId",
                .type => prefix ++ "type",
                .dataId => prefix ++ "dataId",
                .milSecLeft => prefix ++ "milSecLeft",
                .cdSecLeft => prefix ++ "cdSecLeft",
                .resettable => prefix ++ "resettable",
                .cooldownType => prefix ++ "cooldownType",
                .cooldown => prefix ++ "cooldown",
                .gcd => prefix ++ "gcd",
                .stock => prefix ++ "stock",
                .maxStock => prefix ++ "maxStock",
                .chargeCount => prefix ++ "chargeCount",
                .strength => prefix ++ "strength",
                .hbsStrength => prefix ++ "hbsStrength",
                .hbsType => prefix ++ "hbsType",
                .hbsLength => prefix ++ "hbsLength",
                .weaponType => prefix ++ "weaponType",
                .strengthMult => prefix ++ "strengthMult",
                .radius => prefix ++ "radius",
                .number => prefix ++ "number",
                .delay => prefix ++ "delay",
                .hbInput => prefix ++ "hbInput",
                .luck => prefix ++ "luck",
                .flags => prefix ++ "flags",
                .vars0 => prefix ++ "vars0",
                .vars1 => prefix ++ "vars1",
                .vars2 => prefix ++ "vars2",
                .vars3 => prefix ++ "vars3",
                .sqVar0 => prefix ++ "sqVar0",
                .sqVar1 => prefix ++ "sqVar1",
                .sqVar2 => prefix ++ "sqVar2",
                .sqVar3 => prefix ++ "sqVar3",
                .originHbId => prefix ++ "originHbId",
                .statusId => prefix ++ "statusId",
                .uniqueId => prefix ++ "uniqueId",
                .aflTeamId => prefix ++ "aflTeamId",
                .aflPlayerId => prefix ++ "aflPlayerId",
                .isBuff => prefix ++ "isBuff",
                .isCrit => prefix ++ "isCrit",
                .counter => prefix ++ "counter",
            };
        }
    };
}

pub const Source = TriggerVariable("s_");
pub const Receiver = TriggerVariable("r_");
pub const TargetPlayers = TriggerVariable("tp#_");
pub const TargetPlayer0 = TriggerVariable("tp0_");
pub const TargetPlayer1 = TriggerVariable("tp1_");
pub const TargetPlayer2 = TriggerVariable("tp2_");
pub const TargetPlayer3 = TriggerVariable("tp3_");
pub const TargetHotbars = TriggerVariable("ths#_");
pub const TargetHotbar0 = TriggerVariable("ths0_");
pub const TargetHotbar1 = TriggerVariable("ths1_");
pub const TargetHotbar2 = TriggerVariable("ths2_");
pub const TargetHotbar3 = TriggerVariable("ths3_");
pub const TargetStatuses = TriggerVariable("thbs#_");
pub const TargetStatus0 = TriggerVariable("thbs0_");
pub const TargetStatus1 = TriggerVariable("thbs1_");
pub const TargetStatus2 = TriggerVariable("thbs2_");
pub const TargetStatus3 = TriggerVariable("thbs3_");

pub const charspeed = struct {
    pub const slightly = 1;
    pub const moderately = 2;
    pub const significantly = 3;
};

pub const luck = struct {
    pub const slightly = 0.10;
    pub const significantly = 0.15;
};

/// 1   HBSHINE_PRIMARY   - Makes Primary shine
/// 2   HBSHINE_SECONDARY - Makes Secondary shine
/// 4   HBSHINE_SPECIAL   - Makes Special shine
/// 8   HBSHINE_DEFENSIVE - Makes Defensive shine
/// 16  HBCROSS_PRIMARY   - Makes Primary unusable
/// 32  HBCROSS_SECONDARY - Makes Secondary unusable
/// 64  HBCROSS_SPECIAL   - Makes Special unusable
/// 128 HBCROSS_DEFENSIVE - Makes Defensive unusable
pub const ShineFlag = packed struct(u8) {
    shine_primary: bool = false,
    shine_secondary: bool = false,
    shine_special: bool = false,
    shine_defensive: bool = false,
    cross_primary: bool = false,
    cross_secondary: bool = false,
    cross_special: bool = false,
    cross_defensive: bool = false,

    pub fn toIniInt(flags: ShineFlag) u8 {
        return @bitCast(flags);
    }
};

comptime {
    std.debug.assert((ShineFlag{ .shine_primary = true }).toIniInt() == 1);
    std.debug.assert((ShineFlag{ .shine_secondary = true }).toIniInt() == 2);
    std.debug.assert((ShineFlag{ .shine_special = true }).toIniInt() == 4);
    std.debug.assert((ShineFlag{ .shine_defensive = true }).toIniInt() == 8);
    std.debug.assert((ShineFlag{ .cross_primary = true }).toIniInt() == 16);
    std.debug.assert((ShineFlag{ .cross_secondary = true }).toIniInt() == 32);
    std.debug.assert((ShineFlag{ .cross_special = true }).toIniInt() == 64);
    std.debug.assert((ShineFlag{ .cross_defensive = true }).toIniInt() == 128);
}

const std = @import("std");
