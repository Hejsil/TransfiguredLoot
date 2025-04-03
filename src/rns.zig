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

const JsonWriteStream = std.json.WriteStream(std.ArrayList(u8).Writer, .assumed_correct);
var items_json_string: std.ArrayList(u8) = std.ArrayList(u8).init(gpa);
var items_json: JsonWriteStream = undefined;

pub const Mod = struct {
    name: []const u8,
    image_path: []const u8,
    thumbnail_path: []const u8,
};

pub fn start(m: Mod) void {
    start2(m) catch |err| @panic(@errorName(err));
}

fn start2(m: Mod) !void {
    std.debug.assert(!generating_mod);

    const initial_capacity = 1024 * 8;
    try sheetlist.ensureTotalCapacity(initial_capacity);
    try item_csv.ensureTotalCapacity(initial_capacity);
    try item_ini.ensureTotalCapacity(initial_capacity);
    try item_names.ensureTotalCapacity(initial_capacity);
    try item_descriptions.ensureTotalCapacity(initial_capacity);
    try items_json_string.ensureTotalCapacity(initial_capacity);

    try sheetlist.writer().writeAll(
        \\Sheet Type,filename
        \\NameSheet,Items_Names
        \\DescriptionSheet,Items_Descriptions
        \\ItemSheet,Items
        \\
    );

    try item_names.writer().writeAll(
        \\key,level,English,Japanese,Chinese
        \\
    );
    try item_descriptions.writer().writeAll(
        \\key,level,English,Japanese,Chinese
        \\
    );
    items_json = JsonWriteStream.init(gpa, items_json_string.writer(), .{
        .whitespace = .indent_4,
    });
    try items_json.beginObject();

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
    try cwd.copyFile(mod.thumbnail_path, output_dir, "thumbnail.png", .{});
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

    try items_json.endObject();
    try output_dir.writeFile(.{
        .sub_path = "Items.json",
        .data = items_json_string.items,
    });

    items_json.deinit();

    sheetlist.shrinkRetainingCapacity(0);
    item_csv.shrinkRetainingCapacity(0);
    item_ini.shrinkRetainingCapacity(0);
    item_names.shrinkRetainingCapacity(0);
    item_descriptions.shrinkRetainingCapacity(0);
    items_json_string.shrinkRetainingCapacity(0);
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
    hbFlags: ?HbFlag = null,

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
    hbsFlag: ?HbsFlag = null,

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
    const is_not_implemented = std.mem.eql(u8, opt.description.english, "Not Implemented. Should not appear in a run.");
    std.debug.assert(
        (is_not_implemented and opt.treasureType == null) or
            (!is_not_implemented and opt.treasureType != null),
    );

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

    var arena_state = std.heap.ArenaAllocator.init(gpa);
    const arena = arena_state.allocator();
    defer arena_state.deinit();

    const replacements = [_][2][]const u8{
        .{ "[VAR0]", try std.fmt.allocPrint(arena, "{d}", .{opt.hbVar0 orelse 0}) },
        .{ "[VAR1]", try std.fmt.allocPrint(arena, "{d}", .{opt.hbVar1 orelse 0}) },
        .{ "[VAR2]", try std.fmt.allocPrint(arena, "{d}", .{opt.hbVar2 orelse 0}) },
        .{ "[VAR3]", try std.fmt.allocPrint(arena, "{d}", .{opt.hbVar3 orelse 0}) },
        .{ "[VAR0_SECONDS]", try std.fmt.allocPrint(arena, "{d} seconds", .{(opt.hbVar0 orelse 0) / std.time.ms_per_s}) },
        .{ "[VAR1_SECONDS]", try std.fmt.allocPrint(arena, "{d} seconds", .{(opt.hbVar1 orelse 0) / std.time.ms_per_s}) },
        .{ "[VAR2_SECONDS]", try std.fmt.allocPrint(arena, "{d} seconds", .{(opt.hbVar2 orelse 0) / std.time.ms_per_s}) },
        .{ "[VAR3_SECONDS]", try std.fmt.allocPrint(arena, "{d} seconds", .{(opt.hbVar3 orelse 0) / std.time.ms_per_s}) },
        .{ "[VAR0_SECOND]", try std.fmt.allocPrint(arena, "{d} second", .{(opt.hbVar0 orelse 0) / std.time.ms_per_s}) },
        .{ "[VAR1_SECOND]", try std.fmt.allocPrint(arena, "{d} second", .{(opt.hbVar1 orelse 0) / std.time.ms_per_s}) },
        .{ "[VAR2_SECOND]", try std.fmt.allocPrint(arena, "{d} second", .{(opt.hbVar2 orelse 0) / std.time.ms_per_s}) },
        .{ "[VAR3_SECOND]", try std.fmt.allocPrint(arena, "{d} second", .{(opt.hbVar3 orelse 0) / std.time.ms_per_s}) },
        .{ "[VAR0_PERCENT]", try std.fmt.allocPrint(arena, "{d}%", .{(opt.hbVar0 orelse 0) * 100}) },
        .{ "[VAR1_PERCENT]", try std.fmt.allocPrint(arena, "{d}%", .{(opt.hbVar1 orelse 0) * 100}) },
        .{ "[VAR2_PERCENT]", try std.fmt.allocPrint(arena, "{d}%", .{(opt.hbVar2 orelse 0) * 100}) },
        .{ "[VAR3_PERCENT]", try std.fmt.allocPrint(arena, "{d}%", .{(opt.hbVar3 orelse 0) * 100}) },
        .{ "[VAR0_TIMES]", try std.fmt.allocPrint(arena, "{d} times", .{opt.hbVar0 orelse 0}) },
        .{ "[VAR1_TIMES]", try std.fmt.allocPrint(arena, "{d} times", .{opt.hbVar1 orelse 0}) },
        .{ "[VAR2_TIMES]", try std.fmt.allocPrint(arena, "{d} times", .{opt.hbVar2 orelse 0}) },
        .{ "[VAR3_TIMES]", try std.fmt.allocPrint(arena, "{d} times", .{opt.hbVar3 orelse 0}) },
        .{ "[STR]", try std.fmt.allocPrint(arena, "{d}", .{opt.strMult orelse 0}) },
        .{ "[HBSSTR]", try std.fmt.allocPrint(arena, "{d}", .{opt.hbsStrMult orelse 0}) },
        .{ "[HBSL]", try std.fmt.allocPrint(arena, "{d} seconds", .{@as(f64, @floatFromInt(opt.hbsLength orelse 0)) / std.time.ms_per_s}) },
        .{ "[CD]", try std.fmt.allocPrint(arena, "{d} seconds", .{@as(f64, @floatFromInt(opt.cooldown orelse 0)) / std.time.ms_per_s}) },
        .{ "[GCD]", try std.fmt.allocPrint(arena, "{d} seconds", .{@as(f64, @floatFromInt(opt.gcdLength orelse 0)) / std.time.ms_per_s}) },
        .{ "[LUCK]", try std.fmt.allocPrint(arena, "{d}%", .{(opt.procChance orelse 0) * 100}) },
        .{ "[CHARGE]", "Charge" },
        .{ "[CHARGES]", "Charges" },
        .{ "[SUPERCHARGE]", "SUPERCHARGE" },
        .{ "[SUPERCHARGES]", "SUPERCHARGES" },
        .{ "[ULTRACHARGE]", "ULTRACHARGE" },
        .{ "[ULTRACHARGES]", "ULTRACHARGES" },
        .{ "[OMEGACHARGE]", "OMEGACHARGE" },
        .{ "[OMEGACHARGES]", "OMEGACHARGES" },
        .{ "[DARKSPELL]", "DARKSPELL" },
        .{ "[VANISH]", "VANISH" },
        .{ "[GHOST]", "GHOST" },
        .{ "[ASTRA]", "ASTRA" },
        .{ "[NOVA]", "NOVA" },
        .{ "[WARCRY]", "WARCRY" },
        .{ "[FLUTTERSTEP]", "FLUTTERSTEP" },
        .{ "[LUCKY]", "LUCKY" },
        .{ "[STONESKIN]", "STONESKIN" },
        .{ "[GRANITESKIN]", "GRANITESKIN" },
        .{ "[SUPER]", "SUPER" },
        .{ "[BERSERK]", "BERSERK" },
        .{ "[ABYSSRAGE]", "ABYSSRAGE" },
        .{ "[HEX]", "HEX" },
        .{ "[HEXS]", "HEXS" },
        .{ "[HEXP]", "HEXP" },
        .{ "[ANTIHEX]", "ANTIHEX" },
        .{ "[BLACKSTRIKE]", "BLACKSTRIKE" },
        .{ "[STILLNESS]", "STILLNESS" },
        .{ "[QUICKNESS]", "QUICKNESS" },
        .{ "[REPEAT]", "REPEAT" },
        .{ "[FLOW-STR]", "FLOW-STR" },
        .{ "[FLOW-DEX]", "FLOW-DEX" },
        .{ "[FLOW-INT]", "FLOW-INT" },
        .{ "[FLASH-STR]", "FLASH-STR" },
        .{ "[FLASH-DEX]", "FLASH-DEX" },
        .{ "[FLASH-INT]", "FLASH-INT" },
        .{ "[SNARE-X]", "SNARE-X" },
        .{ "[SNARE-X]", "SNARE-X" },
        .{ "[HASTE-0]", "HASTE" },
        .{ "[HASTE-1]", "HASTE" },
        .{ "[SMITE-0]", "SMITE" },
        .{ "[SMITE-1]", "SMITE" },
        .{ "[COUNTER-0]", "COUNTER" },
        .{ "[COUNTER-1]", "COUNTER" },
        .{ "[COUNTER-2]", "COUNTER" },
        .{ "[COUNTER-3]", "COUNTER" },
        .{ "[COUNTER-4]", "COUNTER" },
        .{ "[COUNTER-5]", "COUNTER" },
        .{ "[COUNTER-6]", "COUNTER" },
        .{ "[COUNTER-7]", "COUNTER" },
        .{ "[COUNTER-8]", "COUNTER" },
        .{ "[COUNTER-9]", "COUNTER" },
        .{ "[POISON-0]", "POISON" },
        .{ "[POISON-1]", "POISON" },
        .{ "[POISON-2]", "POISON" },
        .{ "[POISON-3]", "POISON" },
        .{ "[POISON-4]", "POISON" },
        .{ "[POISON-5]", "POISON" },
        .{ "[POISON-6]", "POISON" },
        .{ "[POISON-7]", "POISON" },
        .{ "[POISON-8]", "POISON" },
        .{ "[POISON-9]", "POISON" },
        .{ "[DECAY-0]", "DECAY" },
        .{ "[DECAY-1]", "DECAY" },
        .{ "[DECAY-2]", "DECAY" },
        .{ "[DECAY-3]", "DECAY" },
        .{ "[DECAY-4]", "DECAY" },
        .{ "[DECAY-5]", "DECAY" },
        .{ "[DECAY-6]", "DECAY" },
        .{ "[DECAY-7]", "DECAY" },
        .{ "[DECAY-8]", "DECAY" },
        .{ "[DECAY-9]", "DECAY" },
        .{ "[BURN-0]", "BURN" },
        .{ "[BURN-1]", "BURN" },
        .{ "[BURN-2]", "BURN" },
        .{ "[BURN-3]", "BURN" },
        .{ "[BURN-4]", "BURN" },
        .{ "[BURN-5]", "BURN" },
        .{ "[BURN-6]", "BURN" },
        .{ "[BURN-7]", "BURN" },
        .{ "[BURN-8]", "BURN" },
        .{ "[BURN-9]", "BURN" },
        .{ "[CURSE-0]", "CURSE" },
        .{ "[CURSE-1]", "CURSE" },
        .{ "[CURSE-2]", "CURSE" },
        .{ "[CURSE-3]", "CURSE" },
        .{ "[CURSE-4]", "CURSE" },
        .{ "[CURSE-5]", "CURSE" },
        .{ "[CURSE-6]", "CURSE" },
        .{ "[CURSE-7]", "CURSE" },
        .{ "[CURSE-8]", "CURSE" },
        .{ "[CURSE-9]", "CURSE" },
        .{ "[BLEED-0]", "BLEED" },
        .{ "[BLEED-1]", "BLEED" },
        .{ "[BLEED-2]", "BLEED" },
        .{ "[BLEED-3]", "BLEED" },
        .{ "[BLEED-4]", "BLEED" },
        .{ "[BLEED-5]", "BLEED" },
        .{ "[BLEED-6]", "BLEED" },
        .{ "[BLEED-7]", "BLEED" },
        .{ "[BLEED-8]", "BLEED" },
        .{ "[BLEED-9]", "BLEED" },
        .{ "[SPARK-0]", "SPARK" },
        .{ "[SPARK-1]", "SPARK" },
        .{ "[SPARK-2]", "SPARK" },
        .{ "[SPARK-3]", "SPARK" },
        .{ "[SPARK-4]", "SPARK" },
        .{ "[SPARK-5]", "SPARK" },
        .{ "[SPARK-6]", "SPARK" },
        .{ "[SPARK-7]", "SPARK" },
        .{ "[SPARK-8]", "SPARK" },
        .{ "[SPARK-9]", "SPARK" },
        .{ "[GHOSTFLAME-0]", "GHOSTFLAME" },
        .{ "[GHOSTFLAME-1]", "GHOSTFLAME" },
        .{ "[GHOSTFLAME-2]", "GHOSTFLAME" },
        .{ "[GHOSTFLAME-3]", "GHOSTFLAME" },
        .{ "[GHOSTFLAME-4]", "GHOSTFLAME" },
        .{ "[GHOSTFLAME-5]", "GHOSTFLAME" },
        .{ "[GHOSTFLAME-6]", "GHOSTFLAME" },
        .{ "[GHOSTFLAME-7]", "GHOSTFLAME" },
        .{ "[GHOSTFLAME-8]", "GHOSTFLAME" },
        .{ "[GHOSTFLAME-9]", "GHOSTFLAME" },
        .{ "[ELEGY-0]", "ELEGY" },
        .{ "[ELEGY-1]", "ELEGY" },
        .{ "[ELEGY-2]", "ELEGY" },
        .{ "[ELEGY-3]", "ELEGY" },
        .{ "[ELEGY-4]", "ELEGY" },
        .{ "[ELEGY-5]", "ELEGY" },
        .{ "[ELEGY-6]", "ELEGY" },
        .{ "[ELEGY-7]", "ELEGY" },
        .{ "[ELEGY-8]", "ELEGY" },
        .{ "[ELEGY-9]", "ELEGY" },
        .{ "[SAP]", "SAP" },
    };

    var description: []const u8 = opt.description.english;
    for (replacements) |replacement| {
        _ = std.mem.indexOfScalar(u8, description, '[') orelse break;
        description = try std.mem.replaceOwned(
            u8,
            arena,
            description,
            replacement[0],
            replacement[1],
        );
    }

    try items_json.objectField(opt.name.english);
    try items_json.write(description);

    written_items += 1;
    have_trigger = false;
}

/// When certain things in the game happen (everything from you gaining gold, to using an ability,
/// to starting a run, to a % chance succeeding), a "Trigger" is called. You can make your items
/// react to these Triggers, to do the things they're supposed to do.
///
/// https://docs.google.com/spreadsheets/d/1shtFkpagAafUjjA70XGlYGruqFIbLpQlcDjWKNNm3_4/edit?pli=1&gid=1624073505#gid=1624073505
pub const trig = opaque {
    /// Never called
    pub fn none(conds: []const Condition) void {
        write("none", conds) catch |err| @panic(@errorName(err));
    }

    // The following are stat calculations, that are called in the order listed.

    // cdCalc0 and strCalc0 are typically used for items that give you a bonus on some kind of
    // condition; for instance, Amethyst Bracelet gives you a stat buff if it isn't broken, Demon
    // Horns gives you a bonus if its sqVar0 is 1 (and using your Defensive makes the sqVar0 0)

    /// Called before any other stat calculations (for Cooldowns).
    /// Currently unused
    pub fn cdCalc0(conds: []const Condition) void {
        write("cdCalc0", conds) catch |err| @panic(@errorName(err));
    }

    /// Called before any other stat calculations (for Strength).
    /// - Demon Horns, Royal Staff, Flamewalker Boots, Amethyst Bracelet
    pub fn strCalc0(conds: []const Condition) void {
        write("strCalc0", conds) catch |err| @panic(@errorName(err));
    }

    // ----"Stats" that loot items give you are added here----

    /// Currently unused
    pub fn cdCalc1(conds: []const Condition) void {
        write("cdCalc1", conds) catch |err| @panic(@errorName(err));
    }

    /// Additions to cooldown/GCD (bad)
    /// - Mountain Staff, Tough Gauntlet, Teacher Knife, Dragonhead Spear
    pub fn cdCalc2a(conds: []const Condition) void {
        write("cdCalc2a", conds) catch |err| @panic(@errorName(err));
    }

    /// Additions to cooldown/GCD (good)
    /// - Kappa Shield, Hawkfeather Fan, Mermaid Scale
    pub fn cdCalc2b(conds: []const Condition) void {
        write("cdCalc2b", conds) catch |err| @panic(@errorName(err));
    }

    /// Currently only used for Altair Dagger
    pub fn cdCalc3(conds: []const Condition) void {
        write("cdCalc3", conds) catch |err| @panic(@errorName(err));
    }

    /// Set cooldown/GCD to a fixed value (bad)
    /// - Twinstar Earrings, Nova Crown
    pub fn cdCalc4a(conds: []const Condition) void {
        write("cdCalc4a", conds) catch |err| @panic(@errorName(err));
    }

    /// Set cooldown/GCD to a fixed value (good)
    /// - Starry Cloak, Windbite Dagger
    pub fn cdCalc4b(conds: []const Condition) void {
        write("cdCalc4b", conds) catch |err| @panic(@errorName(err));
    }

    /// Set cooldown/GCD to a fixed value (overwrites previous calculations)
    /// - Haste Boots, Timemage Cap
    pub fn cdCalc5(conds: []const Condition) void {
        write("cdCalc5", conds) catch |err| @panic(@errorName(err));
    }

    /// Set cooldown/GCD to a fixed value (overwrites previous calculations, again)
    /// - "Berserk" Status, Bruiser Emerald Special, Sniper Emerald Primary
    pub fn cdCalc6(conds: []const Condition) void {
        write("cdCalc6", conds) catch |err| @panic(@errorName(err));
    }

    /// Strength calculations that happen before the % boost from your levels
    /// - Cursed Candlestaff, Ghost Spear, Phantom Dagger
    pub fn strCalc1a(conds: []const Condition) void {
        write("strCalc1a", conds) catch |err| @panic(@errorName(err));
    }

    /// - Timespace Dagger, Darkglass Spear, Obsidian Rod
    pub fn strCalc1b(conds: []const Condition) void {
        write("strCalc1b", conds) catch |err| @panic(@errorName(err));
    }

    /// - Nightguard Gloves, Sacredstone Charm, Pocketwatch, Gladiator Helmet
    pub fn strCalc1c(conds: []const Condition) void {
        write("strCalc1c", conds) catch |err| @panic(@errorName(err));
    }

    // ----% boost from levels happen here----

    /// - Shadow Bracelet, Kunoichi Hood, Killing Note, Grasswoven Bracelet
    pub fn strCalc2(conds: []const Condition) void {
        write("strCalc2", conds) catch |err| @panic(@errorName(err));
    }

    /// Currently unused
    pub fn strCalc3(conds: []const Condition) void {
        write("strCalc3", conds) catch |err| @panic(@errorName(err));
    }

    /// Currently unused
    pub fn strCalc4(conds: []const Condition) void {
        write("strCalc4", conds) catch |err| @panic(@errorName(err));
    }

    /// Set strength to a fixed value
    /// - Old Bonnet, Haunted Gloves
    pub fn strCalc5(conds: []const Condition) void {
        write("strCalc5", conds) catch |err| @panic(@errorName(err));
    }

    /// Mostly unused "Heavy" Status
    pub fn strCalc6(conds: []const Condition) void {
        write("strCalc6", conds) catch |err| @panic(@errorName(err));
    }

    /// Currently only used to adjust for edge-cases with Altair Dagger and Shinsoku Katana when
    /// you gain Rabbitluck
    /// - Shinsoku Katana, Altair Dagger
    pub fn finalCalc(conds: []const Condition) void {
        write("finalCalc", conds) catch |err| @panic(@errorName(err));
    }

    /// Certain loot can change the color of your abilities. These two triggers are used to do
    /// that.
    /// - Lots of items
    pub fn colorCalc(conds: []const Condition) void {
        write("colorCalc", conds) catch |err| @panic(@errorName(err));
    }

    /// If there is one loot that should override the color of any other loot, it should use this
    /// instead
    /// - Shrinemaiden's Kosode, Sniper's Eyeglasses, Shinsoku Katana (when successful)
    pub fn colorCalc2(conds: []const Condition) void {
        write("colorCalc2", conds) catch |err| @panic(@errorName(err));
    }

    /// Called when you leave the first screen
    /// - Currently only used for unlocks
    pub fn adventureStart(conds: []const Condition) void {
        write("adventureStart", conds) catch |err| @panic(@errorName(err));
    }

    /// Called when you begin a stage
    /// - Currently only used for unlocks
    pub fn hallwayStart(conds: []const Condition) void {
        write("hallwayStart", conds) catch |err| @panic(@errorName(err));
    }

    /// Called at the start of a fight, before you character is able to attack
    /// - Currently unused
    pub fn battleStart0(conds: []const Condition) void {
        write("battleStart0", conds) catch |err| @panic(@errorName(err));
    }

    /// Called at the start of a fight, *just* before you character is able to attack (before
    /// autoStart)
    /// - Blood Vial, Lost Pendant "autoStart" trigger explanation is below
    pub fn battleStart2(conds: []const Condition) void {
        write("battleStart2", conds) catch |err| @panic(@errorName(err));
    }

    /// Called at the start of a fight, *just* after your character is able to attack (after
    /// autoStart)
    /// - Stoneplate Armor, Mermaid Scale
    pub fn battleStart3(conds: []const Condition) void {
        write("battleStart3", conds) catch |err| @panic(@errorName(err));
    }

    /// Called as soon as battle ends in victory Currently only used for unlocks
    pub fn battleEnd0(conds: []const Condition) void {
        write("battleEnd0", conds) catch |err| @panic(@errorName(err));
    }

    /// Called a little bit after battle, as your DPS scores are appearing
    /// - Topaz Charm, Blue Rose, Red Tanzaku (Healing effect)
    pub fn battleEnd1(conds: []const Condition) void {
        write("battleEnd1", conds) catch |err| @panic(@errorName(err));
    }

    /// - Red Tanzaku (Experience gift)
    pub fn battleEnd2(conds: []const Condition) void {
        write("battleEnd2", conds) catch |err| @panic(@errorName(err));
    }

    /// - Regen Potion (heal 2)
    pub fn battleEnd3(conds: []const Condition) void {
        write("battleEnd3", conds) catch |err| @panic(@errorName(err));
    }

    /// - Regen Potion (heal 1)
    pub fn battleEnd4(conds: []const Condition) void {
        write("battleEnd4", conds) catch |err| @panic(@errorName(err));
    }

    /// Called when a status effect is created
    /// - Crowfeather Hairpin, Sacred Bow
    pub fn hbsCreated(conds: []const Condition) void {
        write("hbsCreated", conds) catch |err| @panic(@errorName(err));
    }

    /// This trigger should ONLY be called and used by the status effect that is created
    pub fn hbsCreatedSelf(conds: []const Condition) void {
        write("hbsCreatedSelf", conds) catch |err| @panic(@errorName(err));
    }

    /// Called when a status effect is overwritten by an instance of the same status
    /// - Currently unused
    pub fn hbsRefreshed(conds: []const Condition) void {
        write("hbsRefreshed", conds) catch |err| @panic(@errorName(err));
    }

    /// Called when a status effect is destroyed
    /// - Stoneskin, Ghostflame, Snare, Burn
    pub fn hbsDestroyed(conds: []const Condition) void {
        write("hbsDestroyed", conds) catch |err| @panic(@errorName(err));
    }

    /// - Currently unused
    pub fn hbsFlagTrigger(conds: []const Condition) void {
        write("hbsFlagTrigger", conds) catch |err| @panic(@errorName(err));
    }

    /// The following are shield checks. If your character is hit while they have the
    /// HBS_FLAG_SHIELD flag (see hbsFlag on the Stats sheet), it will go through these triggers
    /// in order, and stop if the character is shielded
    /// - Rockdragon Mail
    pub fn hbsShield0(conds: []const Condition) void {
        write("hbsShield0", conds) catch |err| @panic(@errorName(err));
    }

    /// - Red Tanzaku
    pub fn hbsShield1(conds: []const Condition) void {
        write("hbsShield1", conds) catch |err| @panic(@errorName(err));
    }

    /// Additions to strength/radius
    /// - Stoneskin
    pub fn hbsShield2(conds: []const Condition) void {
        write("hbsShield2", conds) catch |err| @panic(@errorName(err));
    }

    /// - Graniteskin
    pub fn hbsShield3(conds: []const Condition) void {
        write("hbsShield3", conds) catch |err| @panic(@errorName(err));
    }

    /// - Emerald chestplate
    pub fn hbsShield4(conds: []const Condition) void {
        write("hbsShield4", conds) catch |err| @panic(@errorName(err));
    }

    /// - Phoenix charm
    pub fn hbsShield5(conds: []const Condition) void {
        write("hbsShield5", conds) catch |err| @panic(@errorName(err));
    }

    /// Called when any item (ability, loot, potion) is used. This particular trigger should
    /// typically only be used by the item that was used.
    /// - Most items and abilities that do things
    pub fn hotbarUsed(conds: []const Condition) void {
        write("hotbarUsed", conds) catch |err| @panic(@errorName(err));
    }

    /// Called when an item is used. This particular trigger should be used for items like "When
    /// your Defensive is used, do X" or "When an ability with a cooldown is used, do X" effects
    /// - Gemini Necklace, Necronomicon, Whiteflame Staff
    pub fn hotbarUsedProc(conds: []const Condition) void {
        write("hotbarUsedProc", conds) catch |err| @panic(@errorName(err));
    }

    /// Called when an item is used. Should be used for secondary effects of an item being used
    /// (that need to happen after hotbarUsed)
    pub fn hotbarUsed2(conds: []const Condition) void {
        write("hotbarUsed2", conds) catch |err| @panic(@errorName(err));
    }

    /// Called when an item is used. This particular trigger should be used for items like "When
    /// your Defensive is used, do X" or "When an ability with a cooldown is used, do X" effects
    /// Will happen after "hotbarUsed2"
    /// - Battlemaiden Armor, Lion Charm, Moss Shield
    pub fn hotbarUsedProc2(conds: []const Condition) void {
        write("hotbarUsedProc2", conds) catch |err| @panic(@errorName(err));
    }

    /// Last trigger to be called when an ability is used. Typically used to delete statuses that
    /// disappear when you use an ability etc..
    /// - "Flash-Int", "Vanish", etc..
    pub fn hotbarUsed3(conds: []const Condition) void {
        write("hotbarUsed3", conds) catch |err| @panic(@errorName(err));
    }

    /// Called when a character takes damage. Currently only used on the items that break when you
    /// take damage
    /// - Amethyst Bracelet, Ruby Circlet
    pub fn onDamage(conds: []const Condition) void {
        write("onDamage", conds) catch |err| @panic(@errorName(err));
    }

    /// Called when a character is healed
    /// - Currently unused
    pub fn onHealed(conds: []const Condition) void {
        write("onHealed", conds) catch |err| @panic(@errorName(err));
    }

    /// Called when a character gains invulnerability
    /// - Obsidian Hairpin, Storm Petticoat, Butterfly Hairpin
    pub fn onInvuln(conds: []const Condition) void {
        write("onInvuln", conds) catch |err| @panic(@errorName(err));
    }

    /// Called when your character deals damage to an enemy. If an item does something like "Your
    /// Primary applies Poison", then what it does is, when you deal damage, it checks to see if
    /// the damage came from your Primary, then applies Poison to the thing that took the damage
    /// - Staticshock Earrings, Ivy Staff, Darkstorm Knife, basically every item that makes your
    ///   attacks afflict status effects
    pub fn onDamageDone(conds: []const Condition) void {
        write("onDamageDone", conds) catch |err| @panic(@errorName(err));
    }

    /// - Currently unused
    pub fn onHealDone(conds: []const Condition) void {
        write("onHealDone", conds) catch |err| @panic(@errorName(err));
    }

    /// Called when your character erases an area of bullets
    /// - Reflection Shield, Spiked Shield
    pub fn onEraseDone(conds: []const Condition) void {
        write("onEraseDone", conds) catch |err| @panic(@errorName(err));
    }

    /// Called once per second
    /// - Poison, Spark, Decay Statuses
    pub fn regenTick(conds: []const Condition) void {
        write("regenTick", conds) catch |err| @panic(@errorName(err));
    }

    /// Called each time your character moves a Rabbitleap (even out of battle). When I say "in
    /// battle" what I really mean is "while hbAuto is on".  Which means that the character is
    /// using attacks
    /// - Tranquility Status
    pub fn distanceTick(conds: []const Condition) void {
        write("distanceTick", conds) catch |err| @panic(@errorName(err));
    }

    /// Called every 200ms when your character is standing still (even out of battle)
    /// - Shinobi Tabi, Iron Grieves
    pub fn standingStill(conds: []const Condition) void {
        write("standingStill", conds) catch |err| @panic(@errorName(err));
    }

    /// Called each time your character moves a Rabbitleap (in battle)
    /// - Tornado Staff, Cloud Guard, Talon Charm
    pub fn distanceTickBattle(conds: []const Condition) void {
        write("distanceTickBattle", conds) catch |err| @panic(@errorName(err));
    }

    /// Called every 200ms when your character is standing still (in battle)
    /// - Floral Bow, Raindrop Earrings, Clay Rabbit
    pub fn standingStillBattle(conds: []const Condition) void {
        write("standingStillBattle", conds) catch |err| @panic(@errorName(err));
    }

    /// Happens when a % chance succeeds (Note: NOT AUTOMATIC, if you make loot with a random
    /// activation chance, please add a tpat_hb_luck_proc Quick Pattern when it activates)
    /// - Usagi Kamen, Lightning Bow, Poisonfrog Charm
    pub fn luckyProc(conds: []const Condition) void {
        write("luckyProc", conds) catch |err| @panic(@errorName(err));
    }

    /// Happens when loot with a cooldown activates (Note: NOT AUTOMATIC, if you make loot with
    /// a cooldown that is not directly 'used', please add a tpat_hb_cdloot_proc Quick Pattern
    /// when it activates)
    /// - Blackhole Charm, Quartz Shield, Lion Charm
    pub fn cdLootProc(conds: []const Condition) void {
        write("cdLootProc", conds) catch |err| @panic(@errorName(err));
    }

    /// Happens when a player starts attacking, or when a combat encounter starts.
    /// You most likely want to use this instead of "battleStart".
    /// "battleStart" won't activate outside of combat with an enemy, while this will work even if
    /// a player begins attacking a Training Dummy or Treasuresphere" Tidal Greatsword, Golem's
    /// Claymore, every item that starts on cooldown tbh Loot/Abilities that "start on cooldown"
    /// should have an autoStart trigger that runs the cooldown
    pub fn autoStart(conds: []const Condition) void {
        write("autoStart", conds) catch |err| @panic(@errorName(err));
    }

    /// Happens 5 seconds after a player stops attacking, or when a combat encounter ends
    /// - Currently only used to reset the counter on Defender's Special
    pub fn autoEnd(conds: []const Condition) void {
        write("autoEnd", conds) catch |err| @panic(@errorName(err));
    }

    /// These two are currently unavailable to use with mods; lets me code up a special condition
    /// for which an item should be activated/deactivated
    /// - Feathered Overcoat, Shrinemaiden's Kosode
    pub fn onSpecialCond0(conds: []const Condition) void {
        write("onSpecialCond0", conds) catch |err| @panic(@errorName(err));
    }

    ///
    pub fn onSpecialCond1(conds: []const Condition) void {
        write("onSpecialCond1", conds) catch |err| @panic(@errorName(err));
    }

    /// Activates when the item is first picked up from a Treasure. Items like Ruby Circlet and
    /// Emerald Chestplate use this trigger to set their sqVar0 to a number on pickup, representing
    /// the number of "charges" they have. Items like Midsummer Dress, Grasswoven Bracelet, and
    /// Vitality Potion that boost your Max HP use this trigger to heal you for 1 HP on pickup
    /// - Butterfly Ocarina, Silver Coin, Ruby Circlet, Midsummer Dress
    pub fn onSquarePickup(conds: []const Condition) void {
        write("onSquarePickup", conds) catch |err| @panic(@errorName(err));
    }

    /// Activates when you gain/lose gold
    /// - Royal Staff (calls for a recalculation of your stats when trigger is called)
    pub fn onGoldChange(conds: []const Condition) void {
        write("onGoldChange", conds) catch |err| @panic(@errorName(err));
    }

    /// Activates when you level up
    /// - Currently only used for Small Rabbit trinket
    pub fn onLevelup(conds: []const Condition) void {
        write("onLevelup", conds) catch |err| @panic(@errorName(err));
    }

    /// Activates when an enemy starts their Enrage cast
    /// - Currently only used for one of Red Tanzaku's effects
    pub fn enrageStart(conds: []const Condition) void {
        write("enrageStart", conds) catch |err| @panic(@errorName(err));
    }

    /// Used for certain boss fights (probably best not to use this)
    pub fn patternSpecial(conds: []const Condition) void {
        write("patternSpecial", conds) catch |err| @panic(@errorName(err));
    }

    pub fn write(trigger: []const u8, conds: []const Condition) !void {
        const item_csv_writer = item_csv.writer();
        try item_csv_writer.print(
            \\,,,,,
            \\trigger,{s}
        , .{trigger});

        for (conds) |c|
            try item_csv_writer.print(",{s}", .{c.toCsvString()});
        for (conds.len..4) |_|
            try item_csv_writer.writeAll(",");
        try item_csv_writer.writeAll("\n");

        have_trigger = true;
    }
};

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

pub const cond = opaque {
    pub fn none(args: anytype) void {
        cond2(.none, args) catch |err| @panic(@errorName(err));
    }
    pub fn check_flag(args: anytype) void {
        cond2(.check_flag, args) catch |err| @panic(@errorName(err));
    }
    pub fn check_no_flag(args: anytype) void {
        cond2(.check_no_flag, args) catch |err| @panic(@errorName(err));
    }
    pub fn dmg_islarge(args: anytype) void {
        cond2(.dmg_islarge, args) catch |err| @panic(@errorName(err));
    }
    pub fn dmg_self_defensive(args: anytype) void {
        cond2(.dmg_self_defensive, args) catch |err| @panic(@errorName(err));
    }
    pub fn dmg_self_primary(args: anytype) void {
        cond2(.dmg_self_primary, args) catch |err| @panic(@errorName(err));
    }
    pub fn dmg_self_secondary(args: anytype) void {
        cond2(.dmg_self_secondary, args) catch |err| @panic(@errorName(err));
    }
    pub fn dmg_self_special(args: anytype) void {
        cond2(.dmg_self_special, args) catch |err| @panic(@errorName(err));
    }
    pub fn dmg_self_thishb(args: anytype) void {
        cond2(.dmg_self_thishb, args) catch |err| @panic(@errorName(err));
    }
    pub fn equal(args: anytype) void {
        cond2(.equal, args) catch |err| @panic(@errorName(err));
    }
    pub fn unequal(args: anytype) void {
        cond2(.unequal, args) catch |err| @panic(@errorName(err));
    }
    pub fn eval(a: anytype, op: Compare, b: anytype) void {
        cond2(.eval, .{ a, op, b }) catch |err| @panic(@errorName(err));
    }
    pub fn @"false"(args: anytype) void {
        cond2(.false, args) catch |err| @panic(@errorName(err));
    }
    pub fn @"true"(args: anytype) void {
        cond2(.true, args) catch |err| @panic(@errorName(err));
    }
    pub fn hb_auto_pl(args: anytype) void {
        cond2(.hb_auto_pl, args) catch |err| @panic(@errorName(err));
    }
    pub fn hb_available(args: anytype) void {
        cond2(.hb_available, args) catch |err| @panic(@errorName(err));
    }
    pub fn hb_check_square_var(args: anytype) void {
        cond2(.hb_check_square_var, args) catch |err| @panic(@errorName(err));
    }
    pub fn hb_check_square_var_false(args: anytype) void {
        cond2(.hb_check_square_var_false, args) catch |err| @panic(@errorName(err));
    }
    pub fn hb_check_square_var_gte(args: anytype) void {
        cond2(.hb_check_square_var_gte, args) catch |err| @panic(@errorName(err));
    }
    pub fn hb_check_square_var_lte(args: anytype) void {
        cond2(.hb_check_square_var_lte, args) catch |err| @panic(@errorName(err));
    }
    pub fn hb_primary(args: anytype) void {
        cond2(.hb_primary, args) catch |err| @panic(@errorName(err));
    }
    pub fn hb_secondary(args: anytype) void {
        cond2(.hb_secondary, args) catch |err| @panic(@errorName(err));
    }
    pub fn hb_special(args: anytype) void {
        cond2(.hb_special, args) catch |err| @panic(@errorName(err));
    }
    pub fn hb_defensive(args: anytype) void {
        cond2(.hb_defensive, args) catch |err| @panic(@errorName(err));
    }
    pub fn hb_loot(args: anytype) void {
        cond2(.hb_loot, args) catch |err| @panic(@errorName(err));
    }
    pub fn hb_not_self(args: anytype) void {
        cond2(.hb_not_self, args) catch |err| @panic(@errorName(err));
    }
    pub fn hb_self(args: anytype) void {
        cond2(.hb_self, args) catch |err| @panic(@errorName(err));
    }
    pub fn hb_self_attack(args: anytype) void {
        cond2(.hb_self_attack, args) catch |err| @panic(@errorName(err));
    }
    pub fn hb_self_weapon(args: anytype) void {
        cond2(.hb_self_weapon, args) catch |err| @panic(@errorName(err));
    }
    pub fn hb_selfcast(args: anytype) void {
        cond2(.hb_selfcast, args) catch |err| @panic(@errorName(err));
    }
    pub fn hb_team(args: anytype) void {
        cond2(.hb_team, args) catch |err| @panic(@errorName(err));
    }
    pub fn hb_type_weapon(args: anytype) void {
        cond2(.hb_type_weapon, args) catch |err| @panic(@errorName(err));
    }
    pub fn hbs_aflplayer(args: anytype) void {
        cond2(.hbs_aflplayer, args) catch |err| @panic(@errorName(err));
    }
    pub fn hbs_aflplayer_attack(args: anytype) void {
        cond2(.hbs_aflplayer_attack, args) catch |err| @panic(@errorName(err));
    }
    pub fn hbs_self(args: anytype) void {
        cond2(.hbs_self, args) catch |err| @panic(@errorName(err));
    }
    pub fn hbs_thishbcast(args: anytype) void {
        cond2(.hbs_thishbcast, args) catch |err| @panic(@errorName(err));
    }
    pub fn hbs_not_thishbcast(args: anytype) void {
        cond2(.hbs_not_thishbcast, args) catch |err| @panic(@errorName(err));
    }
    pub fn hbs_selfafl(args: anytype) void {
        cond2(.hbs_selfafl, args) catch |err| @panic(@errorName(err));
    }
    pub fn hbs_selfcast(args: anytype) void {
        cond2(.hbs_selfcast, args) catch |err| @panic(@errorName(err));
    }
    pub fn hb_check_chargeable0(args: anytype) void {
        cond2(.hb_check_chargeable0, args) catch |err| @panic(@errorName(err));
    }
    pub fn hb_check_resettable0(args: anytype) void {
        cond2(.hb_check_resettable0, args) catch |err| @panic(@errorName(err));
    }
    pub fn missing_health(args: anytype) void {
        cond2(.missing_health, args) catch |err| @panic(@errorName(err));
    }
    pub fn pl_autocheck(args: anytype) void {
        cond2(.pl_autocheck, args) catch |err| @panic(@errorName(err));
    }
    pub fn pl_self(args: anytype) void {
        cond2(.pl_self, args) catch |err| @panic(@errorName(err));
    }
    pub fn player_target_count(args: anytype) void {
        cond2(.player_target_count, args) catch |err| @panic(@errorName(err));
    }
    pub fn hbs_target_count(args: anytype) void {
        cond2(.hbs_target_count, args) catch |err| @panic(@errorName(err));
    }
    pub fn slot_target_count(args: anytype) void {
        cond2(.slot_target_count, args) catch |err| @panic(@errorName(err));
    }
    pub fn random(args: anytype) void {
        cond2(.random, args) catch |err| @panic(@errorName(err));
    }
    pub fn random_def(args: anytype) void {
        cond2(.random_def, args) catch |err| @panic(@errorName(err));
    }
    pub fn square_self(args: anytype) void {
        cond2(.square_self, args) catch |err| @panic(@errorName(err));
    }
    pub fn tick_every(args: anytype) void {
        cond2(.tick_every, args) catch |err| @panic(@errorName(err));
    }
    pub fn trinket_counter_equal(args: anytype) void {
        cond2(.trinket_counter_equal, args) catch |err| @panic(@errorName(err));
    }
    pub fn trinket_counter_greaterequal(args: anytype) void {
        cond2(.trinket_counter_greaterequal, args) catch |err| @panic(@errorName(err));
    }
    pub fn bookofcheats_varcheck(args: anytype) void {
        cond2(.bookofcheats_varcheck, args) catch |err| @panic(@errorName(err));
    }
    fn cond2(condition: Condition, args: anytype) !void {
        std.debug.assert(have_trigger);
        try item_csv.writer().print("condition,{s}", .{condition.toCsvString()});
        try writeArgs(item_csv.writer(), args);
    }
};

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
/// https://docs.google.com/spreadsheets/d/1shtFkpagAafUjjA70XGlYGruqFIbLpQlcDjWKNNm3_4/edit?pli=1&gid=1513724686#gid=1513724686
pub const qpat = opaque {
    /// Does nothing
    pub fn nothing() void {
        write("tpat_nothing", .{}) catch |err| @panic(@errorName(err));
    }

    /// Adds the current list of targets to your debug log.
    pub fn debug_targets() void {
        write("tpat_debug_targets", .{}) catch |err| @panic(@errorName(err));
    }

    /// To be used during strCalc.
    /// Adds to the player's hitbox size.
    /// The default hitbox size is 5 pixels.
    pub fn player_add_radius(args: Args) void {
        write("tpat_player_add_radius", args) catch |err| @panic(@errorName(err));
    }

    /// "stat" (a stat to add, see "STAT" in enum reference)
    /// "amount" (a number to add)
    /// Adds some stat amount to targetted players.
    pub fn player_add_stat(args: Args) void {
        write("tpat_player_add_stat", args) catch |err| @panic(@errorName(err));
    }

    /// Randomizes your levitation ring color (used on the Paintbrush trinket)
    pub fn player_change_color_rand() void {
        write("tpat_player_change_color_rand", .{}) catch |err| @panic(@errorName(err));
    }

    /// Resets the distance ticker for targeted players to 0 (used for the "Tranquility" status
    /// effect to accurately measure 1 rabbitleap)
    pub fn player_distcounter_reset() void {
        write("tpat_player_distcounter_reset", .{}) catch |err| @panic(@errorName(err));
    }

    /// "length" (time in milliseconds)
    /// Locks targeted players in place for the specified length of time.
    /// NOTE: This function currently doesn't work correctly online.
    pub fn player_movelock(args: Args) void {
        write("tpat_player_movelock", args) catch |err| @panic(@errorName(err));
    }

    /// "mult" (move speed multiplier)
    /// "length" (time in milliseconds)
    /// Slows/speeds up players for a brief amount of time.
    /// NOTE: This function currently doesn't work correctly online.
    pub fn player_movemult(args: Args) void {
        write("tpat_player_movemult", args) catch |err| @panic(@errorName(err));
    }

    /// "length" (time in milliseconds)
    /// Runs GCD for specified amount of time
    pub fn player_run_gcd(args: Args) void {
        write("tpat_player_run_gcd", args) catch |err| @panic(@errorName(err));
    }

    /// "amount" (size in pixels)
    /// Sets hitbox size for players; meant to be used in strCalc
    pub fn player_set_radius(args: Args) void {
        write("tpat_player_set_radius", args) catch |err| @panic(@errorName(err));
    }

    /// "stat" (a stat to add, see "STAT" in enum reference)
    /// "amount" (a number to add)
    /// Sets a base stat for targeted players to an amount.
    pub fn player_set_stat(args: Args) void {
        write("tpat_player_set_stat", args) catch |err| @panic(@errorName(err));
    }

    /// To be used during "hbsShield" triggers to indicate the player was successfully shielded
    /// from damage. Use this trigger for loot/ability effects.
    pub fn player_shield() void {
        write("tpat_player_shield", .{}) catch |err| @panic(@errorName(err));
    }

    /// To be used during "hbsShield" triggers to indicate the player was successfully shielded
    /// from damage. Use this trigger for status effects (like Stoneskin).
    pub fn player_shield_hbs() void {
        write("tpat_player_shield_hbs", .{}) catch |err| @panic(@errorName(err));
    }

    /// "amount" (a number)
    /// Add to the targeted player's hidden trinket counter.
    pub fn player_trinket_counter_add(args: Args) void {
        write("tpat_player_trinket_counter_add", args) catch |err| @panic(@errorName(err));
    }

    /// "amount" (a number)
    /// "minAm" (a number, default 0)
    /// "maxAm" (a number, default 1000)
    /// Add to the targeted player's hidden trinket counter, but keep the counter inbetween the
    /// specified values.
    pub fn player_trinket_counter_add_bounded(args: Args) void {
        write("tpat_player_trinket_counter_add_bounded", args) catch |err| @panic(@errorName(err));
    }

    /// "minAm" (a number, default 0)
    /// "maxAm" (a number, default 5)
    /// Randomize the hidden trinket counter between the two values
    pub fn player_trinket_counter_randomize(args: Args) void {
        write("tpat_player_trinket_counter_randomize", args) catch |err| @panic(@errorName(err));
    }

    /// "amount" (a number)
    /// Set the target player's hidden trinket counter
    pub fn player_trinket_counter_set(args: Args) void {
        write("tpat_player_trinket_counter_set", args) catch |err| @panic(@errorName(err));
    }

    /// Make the targeted player's trinket flash/sparkle/animate
    pub fn player_trinket_flash() void {
        write("tpat_player_trinket_flash", .{}) catch |err| @panic(@errorName(err));
    }

    pub fn player_add_hp(args: Args) void {
        write("tpat_player_add_hp", args) catch |err| @panic(@errorName(err));
    }

    pub fn player_set_hp(args: Args) void {
        write("tpat_player_set_hp", args) catch |err| @panic(@errorName(err));
    }

    pub fn player_add_gold(args: Args) void {
        write("tpat_player_add_gold", args) catch |err| @panic(@errorName(err));
    }

    pub fn player_set_gold(args: Args) void {
        write("tpat_player_set_gold", args) catch |err| @panic(@errorName(err));
    }

    pub fn player_add_level(args: Args) void {
        write("tpat_player_add_level", args) catch |err| @panic(@errorName(err));
    }

    pub fn player_set_level(args: Args) void {
        write("tpat_player_set_level", args) catch |err| @panic(@errorName(err));
    }

    /// "amount" (a number, in milliseconds)
    /// Adds (or subtracts, if amount is negative) an amount from targeted hotbarslot's
    /// current cooldown.
    pub fn hb_add_cooldown(args: Args) void {
        write("tpat_hb_add_cooldown", args) catch |err| @panic(@errorName(err));
    }

    /// "amount" (a number, in milliseconds)
    /// To be used during cdCalc, adds (or subtracts) an amount from targeted hotbarslot's
    /// overall cooldown
    pub fn hb_add_cooldown_permanent(args: Args) void {
        write("tpat_hb_add_cooldown_permanent", args) catch |err| @panic(@errorName(err));
    }

    /// "flag" (a binary)
    /// Adds a hitbox flag to a hotbarslot (see hbFlags on the "Stats" sheet)
    pub fn hb_add_flag(args: Args) void {
        write("tpat_hb_add_flag", args) catch |err| @panic(@errorName(err));
    }

    /// "varIndex" (an integer from 0-3)
    /// "amount" (a number)
    /// Adds the amount to the indicated hidden variable on the targeted hotbarslots.
    pub fn hb_add_hitbox_var(args: Args) void {
        write("tpat_hb_add_hitbox_var", args) catch |err| @panic(@errorName(err));
    }

    /// "varIndex" (an integer from 0-3)
    /// "amount" (a number)
    /// Adds the amount to the indicated hidden variable on the targeted hotbarslots.
    pub fn hb_add_statchange(args: Args) void {
        write("tpat_hb_add_statchange", args) catch |err| @panic(@errorName(err));
    }

    /// "stat" (a stat enum, see STAT in enum reference)
    /// "amount" (a number)
    /// "calc" (a statChangerCalc enum, see STATCHANGERCALC in enum reference, defaults to
    ///         statChangerCalc.addFlag)
    /// DO NOT USE IN STRCALC, as you will get an infinite loop of changing the stat, then
    /// recalculating it over and over.
    /// Adds a stat to the item, which will boost the stat on the player who's holding it
    pub fn hb_add_gcd_permanent(args: Args) void {
        write("tpat_hb_add_gcd_permanent", args) catch |err| @panic(@errorName(err));
    }

    /// "stat" (a stat enum, see STAT in enum reference)
    /// "amount" (a number)
    /// "calc" (a statChangerCalc enum, see STATCHANGERCALC in enum reference, defaults to
    ///         statChangerCalc.addFlag)
    /// To be used in strCalc. Adds a stat to the item, which will boost the stat on the player
    /// who's holding it. Added stats are permanent, unless reset with
    /// tpat_hb_reset_statchange_norefresh
    pub fn hb_add_statchange_norefresh(args: Args) void {
        write("tpat_hb_add_statchange_norefresh", args) catch |err| @panic(@errorName(err));
    }

    /// "amount" (a number)
    /// To be used in strCalc1a,strCalc1b,strCalc1c, to add a percentage increase in damage to
    /// targeted hotbarslots.
    pub fn hb_add_strcalcbuff(args: Args) void {
        write("tpat_hb_add_strcalcbuff", args) catch |err| @panic(@errorName(err));
    }

    /// "amount" (a number)
    /// To be used in strCalc2, adds an amount to strength of targeted hotbarslots
    pub fn hb_add_strength(args: Args) void {
        write("tpat_hb_add_strength", args) catch |err| @panic(@errorName(err));
    }

    /// "amount" (a number)
    /// To be used in strCalc2, adds an amount to hbsStrength of targeted hotbarslots
    pub fn hb_add_strength_hbs(args: Args) void {
        write("tpat_hb_add_strength_hbs", args) catch |err| @panic(@errorName(err));
    }

    /// Must be called whenever a loot item with a cooldown that isn't directly "used" (aka isn't
    /// an auto hotbarslot) is activated.
    pub fn hb_cdloot_proc() void {
        write("tpat_hb_cdloot_proc", .{}) catch |err| @panic(@errorName(err));
    }

    /// "num" (a number of charges to give)
    /// "maxNum" (maximum number of charges that can be held at once, default 1)
    /// "type" (chargeTypes enum designating the type of Charge)
    /// Gives specified hotbarslots Charge.
    pub fn hb_charge(args: Args) void {
        write("tpat_hb_charge", args) catch |err| @panic(@errorName(err));
    }

    /// Clears specified hotbarslots of all Charge.
    pub fn hb_charge_clear() void {
        write("tpat_hb_charge_clear", .{}) catch |err| @panic(@errorName(err));
    }

    /// "messageIndex" (hbFlashMessage enum, default "none")
    /// "quiet" (a boolean that, if true, will prevent the flash from making sound. Defaults to false)
    /// Flashes an image of the targeted hotbarslots overhead. I recommend you use this when your
    /// item "activates". If this item procs extremely frequently, I'd recommend setting it to
    /// "quiet" so it isn't annoying to players who pick it up
    pub fn hb_flash_item(args: Args) void {
        write("tpat_hb_flash_item", args) catch |err| @panic(@errorName(err));
    }

    /// "messageIndex" (hbFlashMessage enum, default "none")
    /// "quiet" (a boolean that, if true, will prevent the flash from making sound. Defaults to false)
    /// Flashes an image of the RECEIVER hotbarslot overhead. Useful if you want to target a bunch
    /// of other hotbarslots to perform other calculations before calling the flash.
    pub fn hb_flash_item_source(args: Args) void {
        write("tpat_hb_flash_item_source", args) catch |err| @panic(@errorName(err));
    }

    /// Must be called whenever an ability, for whatever reason, is activated via some effect
    /// other than activating itself (such as Heavyblade's Garnet Primary, or Druids Sapphire
    /// Primary) so they can proc other items
    pub fn hb_hbuse_proc() void {
        write("tpat_hb_hbuse_proc", .{}) catch |err| @panic(@errorName(err));
    }

    /// "varIndex" (an integer between 0-3 indicating the variable number)
    /// "amount" (a number)
    /// Adds an amount to the hotbar's hidden variables
    pub fn hb_inc_var(args: Args) void {
        write("tpat_hb_inc_var", args) catch |err| @panic(@errorName(err));
    }

    /// "amount" (an integer)
    /// Adds an amount to the uses of stock, stockGCD, and stockOnly hotbarslots that are targeted.
    pub fn hb_increase_stock(args: Args) void {
        write("tpat_hb_increase_stock", args) catch |err| @panic(@errorName(err));
    }

    /// Must be called whenever an item "succeeds" in a random proc chance, in order to activate
    /// other items. This will indicate that all hotbars targeted have proc'd."
    pub fn hb_lucky_proc() void {
        write("tpat_hb_lucky_proc", .{}) catch |err| @panic(@errorName(err));
    }

    /// Alternatively, this function can be called. This will indicate that the RECEIVER hotbar
    /// has proc'd.
    pub fn hb_lucky_proc_source() void {
        write("tpat_hb_lucky_proc_source", .{}) catch |err| @panic(@errorName(err));
    }

    /// "mult" (a number)
    /// "minimum" (a time in milliseconds, default 200)
    /// To be used during cdCalc, multiplies GCDs of targeted hotbarslots by a certain amount.
    pub fn hb_mult_gcd_permanent(args: Args) void {
        write("tpat_hb_mult_gcd_permanent", args) catch |err| @panic(@errorName(err));
    }

    /// "varIndex" (an integer between 0-3 indicating the variable number)
    /// "mult" (a number)
    /// Multiplies the targeted hotbar's hidden variable by a certain amount
    pub fn hb_mult_hitbox_var(args: Args) void {
        write("tpat_hb_mult_hitbox_var", args) catch |err| @panic(@errorName(err));
    }

    /// "mult" (a number)
    /// Multiplies the targeted hotbar's hbsLength by a certain amount
    pub fn hb_mult_length_hbs(args: Args) void {
        write("tpat_hb_mult_length_hbs", args) catch |err| @panic(@errorName(err));
    }

    /// "mult" (a number)
    /// Multiplies the targeted hotbar's strength by a certain amount
    pub fn hb_mult_strength(args: Args) void {
        write("tpat_hb_mult_strength", args) catch |err| @panic(@errorName(err));
    }

    /// "mult" (a number)
    /// Multiplies the targeted hotbar's hbsStrength by a certain amount
    pub fn hb_mult_strength_hbs(args: Args) void {
        write("tpat_hb_mult_strength_hbs", args) catch |err| @panic(@errorName(err));
    }

    /// Forces a recalculation of color
    pub fn hb_recalc_color() void {
        write("tpat_hb_recalc_color", .{}) catch |err| @panic(@errorName(err));
    }

    /// "amount" (an integer)
    /// Reduces the stock of stock, stockGcd, and stockOnly hotbarslots targeted.
    pub fn hb_reduce_stock(args: Args) void {
        write("tpat_hb_reduce_stock", args) catch |err| @panic(@errorName(err));
    }

    /// Resets the cooldown of targeted hotbarslots. tcond_hb_check_resettable0 or
    /// ttrg_hotbarslots_prune_noreset should be run before using this to avoid resetting slots
    /// that aren't meant to be resettable.
    pub fn hb_reset_cooldown() void {
        write("tpat_hb_reset_cooldown", .{}) catch |err| @panic(@errorName(err));
    }

    /// Removes stat changes added via "tpat_hb_add_statchange" from targeted hotbarslots. Will
    /// also refresh strCalc. Not to be used during strCalc, or you will get an infinite refresh
    /// loop.
    pub fn hb_reset_statchange() void {
        write("tpat_hb_reset_statchange", .{}) catch |err| @panic(@errorName(err));
    }

    /// Removes stat changes added via "tpat_hb_add_statchange" from targeted hotbarslots. Can be
    /// used during strCalc.
    pub fn hb_reset_statchange_norefresh() void {
        write("tpat_hb_reset_statchange_norefresh", .{}) catch |err| @panic(@errorName(err));
    }

    /// Runs cooldown of targeted hotbarslots.
    pub fn hb_run_cooldown() void {
        write("tpat_hb_run_cooldown", .{}) catch |err| @panic(@errorName(err));
    }

    /// "length" (time in milliseconds)
    /// Runs cooldown of targeted hotbarslots for a specified amount.
    pub fn hb_run_cooldown_ext(args: Args) void {
        write("tpat_hb_run_cooldown_ext", args) catch |err| @panic(@errorName(err));
    }

    /// "length" (time in milliseconds)
    /// Runs hidden cooldown of targeted hotbarslots for a specified amount.
    pub fn hb_run_cooldown_hidden(args: Args) void {
        write("tpat_hb_run_cooldown_hidden", args) catch |err| @panic(@errorName(err));
    }

    /// Changes the color of the targeted hotbarslots to the color of the RECEIVER of the original
    /// trigger. If your item upgrades an ability, you should add a colorCalc trigger that calls
    /// this on that ability, to add a bit of flair to your item!
    pub fn hb_set_color_def() void {
        write("tpat_hb_set_color_def", .{}) catch |err| @panic(@errorName(err));
    }

    /// "time" (in milliseconds)
    /// To be called during cdCalc, sets the cooldown of targeted hotbarslots to specified amount.
    pub fn hb_set_cooldown_permanent(args: Args) void {
        write("tpat_hb_set_cooldown_permanent", args) catch |err| @panic(@errorName(err));
    }

    /// "amount" (in milliseconds)
    /// "minimum" (in milliseconds, default 200)
    /// To be called during cdCalc, sets the GCD of targeted hotbarslots to specified amount.
    pub fn hb_set_gcd_permanent(args: Args) void {
        write("tpat_hb_set_gcd_permanent", args) catch |err| @panic(@errorName(err));
    }

    /// "amount" (an integer)
    /// Sets stock of stock, stockGcd, and stockOnly hotbarslots to a specific amount.
    pub fn hb_set_stock(args: Args) void {
        write("tpat_hb_set_stock", args) catch |err| @panic(@errorName(err));
    }

    /// "amount" (a number)
    /// To be caled during strCalc, sets the strength of hotbarslots to a specific amount.
    pub fn hb_set_strength(args: Args) void {
        write("tpat_hb_set_strength", args) catch |err| @panic(@errorName(err));
    }

    /// "ratio" (a number)
    /// "maxAmount" (a number)
    /// Special function for Darkglass Spear
    pub fn hb_set_strength_darkglass_spear(args: Args) void {
        write("tpat_hb_set_strength_darkglass_spear", args) catch |err| @panic(@errorName(err));
    }

    /// "ratio" (a number)
    /// "maxAmount" (a number)
    /// Special function for Obsidian Rod
    pub fn hb_set_strength_obsidian_rod(args: Args) void {
        write("tpat_hb_set_strength_obsidian_rod", args) catch |err| @panic(@errorName(err));
    }

    /// "ratio" (a number)
    /// "maxAmount" (a number)
    /// Special function for Timespace Dagger
    pub fn hb_set_strength_timespace_dagger(args: Args) void {
        write("tpat_hb_set_strength_timespace_dagger", args) catch |err| @panic(@errorName(err));
    }

    /// Special function for Tidal Greatsword
    pub fn hb_set_tidalgreatsword() void {
        write("tpat_hb_set_tidalgreatsword", .{}) catch |err| @panic(@errorName(err));
    }

    /// Special function for Tidal Greatsword
    pub fn hb_set_tidalgreatsword_start() void {
        write("tpat_hb_set_tidalgreatsword_start", .{}) catch |err| @panic(@errorName(err));
    }

    /// "varIndex" (an integer between 0-3 indicating the variable number)
    /// "amount" (a number)
    /// Sets targeted hotbarslot's hidden variable to a specific amount
    pub fn hb_set_var(args: Args) void {
        write("tpat_hb_set_var", args) catch |err| @panic(@errorName(err));
    }

    /// "varIndex" (an integer between 0-3 indicating the variable number)
    /// "minAmount" (a number)
    /// "maxAmount" (a number)
    /// Sets targeted hotbarslot's hidden variable to a random number between the two parameters
    pub fn hb_set_var_random_range(args: Args) void {
        write("tpat_hb_set_var_random_range", args) catch |err| @panic(@errorName(err));
    }

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
    pub fn hb_square_add_var(args: Args) void {
        write("tpat_hb_square_add_var", args) catch |err| @panic(@errorName(err));
    }

    /// "varIndex" (an integer between 0-3 indicating the variable number)
    /// "amount" (a number)
    /// Sets the targeted hotbarslot's sqVar.
    pub fn hb_square_set_var(args: Args) void {
        write("tpat_hb_square_set_var", args) catch |err| @panic(@errorName(err));
    }

    /// For stock, stockGcd and stockOnly hotbarslots, zeros out stock and starts the slot's
    /// cooldown.
    pub fn hb_zero_stock() void {
        write("tpat_hb_zero_stock", .{}) catch |err| @panic(@errorName(err));
    }

    /// "flag" (a binary number representing an hbsFlag)
    /// Adds an HBS flag to targeted status effects (see hbsFlag on the "Stats" sheet)
    pub fn hbs_add_hbsflag(args: Args) void {
        write("tpat_hbs_add_hbsflag", args) catch |err| @panic(@errorName(err));
    }

    /// "flag" (a binary number representing an hbsShineFlag)
    /// Adds an HBS shine flag to targeted status effects (see hbShineFlag on the "Stats" sheet)
    pub fn hbs_add_shineflag(args: Args) void {
        write("tpat_hbs_add_shineflag", args) catch |err| @panic(@errorName(err));
    }

    /// "stat" (a stat enum, see STAT in enum reference)
    /// "amount" (a number)
    /// "calc" (a statChangerCalc enum, see STATCHANGERCALC in enum reference, defaults to
    ///         statChangerCalc.addFlag)
    /// Adds a stat to the targeted status effect, which will boost the stat on the player who's
    /// holding it (Recommend that you use this during hbsCreatedSelf trigger)
    pub fn hbs_add_statchange(args: Args) void {
        write("tpat_hbs_add_statchange", args) catch |err| @panic(@errorName(err));
    }

    /// "playerId" (an integer repesenting a playerID)
    /// "amount" (an amount of bleed)
    /// Adds appropriate damagePlus stats to a status effect for Bleed status
    pub fn hbs_add_statchange_bleed(args: Args) void {
        write("tpat_hbs_add_statchange_bleed", args) catch |err| @panic(@errorName(err));
    }

    /// "amount" (an amount of bleed)
    /// Adds appropriate damagePlus stats to a status effect for Sap status
    pub fn hbs_add_statchange_sap(args: Args) void {
        write("tpat_hbs_add_statchange_sap", args) catch |err| @panic(@errorName(err));
    }

    /// Destroys targeted status effects
    pub fn hbs_destroy() void {
        write("tpat_hbs_destroy", .{}) catch |err| @panic(@errorName(err));
    }

    /// "mult" (a number)
    /// Multiplies strength of status effects targeted by specified number
    pub fn hbs_mult_str(args: Args) void {
        write("tpat_hbs_mult_str", args) catch |err| @panic(@errorName(err));
    }

    /// Resets stats added to targeted status effects via tpat_hbs_add_statchange
    pub fn hbs_reset_statchange() void {
        write("tpat_hbs_reset_statchange", .{}) catch |err| @panic(@errorName(err));
    }

    /// Don't use this
    pub fn bookofcheats_set_random() void {
        write("tpat_bookofcheats_set_random", .{}) catch |err| @panic(@errorName(err));
    }

    fn write(pat: []const u8, args: Args) !void {
        std.debug.assert(have_trigger);
        const writer = item_csv.writer();
        try writer.print("quickPattern,{s}", .{pat});

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
        if (args.timeStr) |time|
            try writer.print(",time,{s}", .{time});
        if (args.length) |length|
            try writer.print(",length,{d}", .{length});
        if (args.mult) |mult|
            try writer.print(",mult,{d}", .{mult});
        if (args.multStr) |mult|
            try writer.print(",mult,{s}", .{mult});
        if (args.amount) |amount|
            try writer.print(",amount,{d}", .{amount});
        if (args.amountStr) |amount|
            try writer.print(",amount,{s}", .{amount});

        try writer.writeByteNTimes(',', 4 - args.notNullFieldCount() * 2);
        try writer.writeAll("\n");
    }

    pub const Args = struct {
        varIndex: ?usize = null,
        hitboxVar: ?Hitbox = null,
        stat: ?Stat = null,
        type: ?ChargeType = null,
        message: ?FlashMessage = null,
        time: ?usize = null,
        timeStr: ?[]const u8 = null,
        length: ?usize = null,
        mult: ?f64 = null,
        multStr: ?[]const u8 = null,
        amount: ?f64 = null,
        amountStr: ?[]const u8 = null,

        pub fn notNullFieldCount(args: Args) usize {
            var res: usize = 0;
            inline for (@typeInfo(Args).@"struct".fields) |field| {
                res += @intFromBool(@field(args, field.name) != null);
            }

            return res;
        }
    };
};

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
pub const apat = opaque {
    /// "hbsColorInd" (an integer representing a color palette)
    /// These are all status patterns for poison ticks and the like; the hbsColorInd refers to the
    /// status's ID. It's probably best not to use these functions unless I add in custom status
    /// effects in later.
    pub fn bleed(args: Args) void {
        write("ipat_bleed", args) catch |err| @panic(@errorName(err));
    }

    /// "hbsColorInd" (an integer representing a color palette)
    pub fn burn(args: Args) void {
        write("ipat_burn", args) catch |err| @panic(@errorName(err));
    }

    /// "hbsColorInd" (an integer representing a color palette)
    pub fn curse(args: Args) void {
        write("ipat_curse", args) catch |err| @panic(@errorName(err));
    }

    /// "hbsColorInd" (an integer representing a color palette)
    pub fn poison(args: Args) void {
        write("ipat_poison", args) catch |err| @panic(@errorName(err));
    }

    /// "hbsColorInd" (an integer representing a color palette)
    pub fn spark(args: Args) void {
        write("ipat_spark", args) catch |err| @panic(@errorName(err));
    }

    /// "hbsColorInd" (an integer representing a color palette)
    /// Makes a flash effect based off the color of the status ID passed in.
    pub fn starflash_hbs(args: Args) void {
        write("ipat_starflash_hbs", args) catch |err| @panic(@errorName(err));
    }

    /// "hbsColorInd" (an integer representing a color palette)
    /// Erases an area, with color based off the status ID passed in.
    pub fn erase_area_hbs(args: Args) void {
        write("ipat_erase_area_hbs", args) catch |err| @panic(@errorName(err));
    }

    /// "displayNumber" (an integer representing a hotbar slot; default 10)
    /// Applies a status effect set by tset_hbs or tset_hbs_def. If displayNumber is 0-3, then
    /// this will add a timer to the corresponding character's hotbarslot matching the debuff
    /// timer. (Similar to Sniper's Secondary)
    pub fn apply_hbs(args: Args) void {
        write("ipat_apply_hbs", args) catch |err| @panic(@errorName(err));
    }

    /// "displayNumber" (an integer representing a hotbar slot; default 10)
    /// Applies a status effect set by tset_hbs or tset_hbs_def. (with a bit of a "flash" to
    /// indicate something happened). If displayNumber is 0-3, then this will add a timer to the
    /// corresponding character's hotbarslot matching the debuff timer. (Similar to Sniper's
    /// Secondary)
    pub fn apply_hbs_starflash(args: Args) void {
        write("ipat_apply_hbs_starflash", args) catch |err| @panic(@errorName(err));
    }

    /// "duration" (length of invuln, in milliseconds, default 3000)
    /// Applies invulnerability for the specified duration.
    pub fn apply_invuln(args: Args) void {
        write("ipat_apply_invuln", args) catch |err| @panic(@errorName(err));
    }

    /// "number"
    /// "radius"
    /// Hits with a slashing effect at your targeted position
    pub fn black_wakizashi(args: Args) void {
        write("ipat_black_wakizashi", args) catch |err| @panic(@errorName(err));
    }

    /// "number"
    /// Hits all enemies the specified number of times.
    pub fn blackhole_charm(args: Args) void {
        write("ipat_blackhole_charm", args) catch |err| @panic(@errorName(err));
    }

    /// "amount" (an integer representing an xp amount, default 0)
    /// At the end of the battle, will give targeted players an additional "amount" exp. Calling
    /// this creates a new, hidden object in the background, and creating a whole lot of them in
    /// one fight might lag the game. I'd recommend NOT calling this frequently during a single
    /// battle, but rather designing items in a way that this only needs to be called once per
    /// battle or so. For instance, if you wanted an item that gave 1 xp per time the character
    /// hit an enemy, instead of calling this every time you hit an enemy, increment a hidden
    /// variable each time you hit the enemy, then call this once at the end of battle to give
    /// the character their xp.
    pub fn blue_rose(args: Args) void {
        write("ipat_blue_rose", args) catch |err| @panic(@errorName(err));
    }

    /// "amount" (an integer representing an amount to heal, default 0)
    /// Heals targeted players for the specified amount.
    pub fn butterly_ocarina(args: Args) void {
        write("ipat_butterly_ocarina", args) catch |err| @panic(@errorName(err));
    }

    /// Deals damage to all enemies, with the "spark" effect.
    pub fn crown_of_storms(args: Args) void {
        write("ipat_crown_of_storms", args) catch |err| @panic(@errorName(err));
    }

    /// Deals damage to targeted enemies. Despite the name, this is actually the Crescentmoon
    /// Dagger effect.
    pub fn curse_talon(args: Args) void {
        write("ipat_curse_talon", args) catch |err| @panic(@errorName(err));
    }

    /// "x"
    /// "y"
    /// "radius"
    /// Deals damage in a radius around the player.
    pub fn darkmagic_blade(args: Args) void {
        write("ipat_darkmagic_blade", args) catch |err| @panic(@errorName(err));
    }

    /// "x"
    /// "y"
    /// "radius"
    /// Erases area in a radius around the player. Despite the name, Divine Mirror doesn't do this
    /// anymore; but items like Peridot Rapier do.
    pub fn divine_mirror(args: Args) void {
        write("ipat_divine_mirror", args) catch |err| @panic(@errorName(err));
    }

    /// "fx"
    /// "fy"
    /// "radius"
    /// "rot"
    /// Fires a bow shot at your target. NOTE: "radius" here is actually the maximum distance the
    /// bow shot will travel, not the size of the impact.
    pub fn floral_bow(args: Args) void {
        write("ipat_floral_bow", args) catch |err| @panic(@errorName(err));
    }

    /// "time" (length of invuln, in milliseconds, default 0)
    /// Makes the player using the item invulnerable for the specified length of time.
    pub fn garnet_staff(args: Args) void {
        write("ipat_garnet_staff", args) catch |err| @panic(@errorName(err));
    }

    /// "amount" (an integer representing an amount to heal, default 0)
    /// Heals targeted players for the specified amount.
    pub fn heal_light(args: Args) void {
        write("ipat_heal_light", args) catch |err| @panic(@errorName(err));
    }

    /// "amount" (an integer representing an amount to heal, default 0)
    /// Heals targeted players for the specified amount. This should be used after a max health
    /// increase, as it includes extra network calls to make sure there's no desyncs (where, for
    /// instance, on one client a player heals before their max HP increases, resulting in
    /// mismatched health)
    pub fn heal_light_maxhealth(args: Args) void {
        write("ipat_heal_light_maxhealth", args) catch |err| @panic(@errorName(err));
    }

    /// "amount" (an integer representing an amount to heal, default 0)
    /// "duration" (length of invuln, in milliseconds, default 3000)
    /// Heals targeted players AND grants them invulnerability for a specified length of time.
    pub fn heal_revive(args: Args) void {
        write("ipat_heal_revive", args) catch |err| @panic(@errorName(err));
    }

    /// "fx"
    /// "fy"
    /// "radius"
    /// Hydrous blob attack
    pub fn hydrous_blob(args: Args) void {
        write("ipat_hydrous_blob", args) catch |err| @panic(@errorName(err));
    }

    /// "type" (a weaponType enum, see enum reference)
    /// "duration" (length of cooldown in milliseconds, default 500)
    /// Runs specified cooldown. If type is "weaponType.none", it will run ALL your ability
    /// cooldowns for the specified amount."
    pub fn lullaby_harp(args: Args) void {
        write("ipat_lullaby_harp", args) catch |err| @panic(@errorName(err));
    }

    /// "number"
    ///
    /// Hits the targeted enemies the specified number of times.
    pub fn magic_hit(args: Args) void {
        write("ipat_magic_hit", args) catch |err| @panic(@errorName(err));
    }

    /// "number"
    ///
    /// Hits the targeted enemies the specified number of times.
    pub fn melee_hit(args: Args) void {
        write("ipat_melee_hit", args) catch |err| @panic(@errorName(err));
    }

    /// "fx"
    /// "fy"
    /// "radius"
    /// Deals damage once in a radius around your target (old Meteor Staff effect)
    pub fn meteor_staff(args: Args) void {
        write("ipat_meteor_staff", args) catch |err| @panic(@errorName(err));
    }

    /// "x"
    /// "y"
    /// "radius"
    /// Deals damage once in a radius around the player
    pub fn moon_pendant(args: Args) void {
        write("ipat_moon_pendant", args) catch |err| @panic(@errorName(err));
    }

    /// "fx"
    /// "fy"
    /// "radius"
    /// Deals damage once in a radius around your target (old Nightstar Grimoire effect)
    pub fn nightstar_grimoire(args: Args) void {
        write("ipat_nightstar_grimoire", args) catch |err| @panic(@errorName(err));
    }

    /// Applies status effect to all targeted players. Generally used for party buffs (uses
    /// "important" network alpha setting)
    pub fn ornamental_bell(args: Args) void {
        write("ipat_ornamental_bell", args) catch |err| @panic(@errorName(err));
    }

    /// "amount" (an integer representing an amount to heal, default 0)
    /// Heals targeted players for the specified amount. Looks fancier than other heal effects.
    pub fn phoenix_charm(args: Args) void {
        write("ipat_phoenix_charm", args) catch |err| @panic(@errorName(err));
    }

    /// Applies status effect to all targeted players. Generally used for applying debuffs (uses
    /// player's network alpha setting)
    pub fn poisonfrog_charm(args: Args) void {
        write("ipat_poisonfrog_charm", args) catch |err| @panic(@errorName(err));
    }

    /// "fx"
    /// "fy"
    /// "radius"
    /// Deals damage once in a radius around your target
    pub fn potion_throw(args: Args) void {
        write("ipat_potion_throw", args) catch |err| @panic(@errorName(err));
    }

    /// "x"
    /// "y"
    /// Deals damage to all enemies. Effect is centered on specified position.
    pub fn pulse_damage(args: Args) void {
        write("ipat_pulse_damage", args) catch |err| @panic(@errorName(err));
    }

    /// "number"
    /// Deals damage to targeted enemies, with a "backstab" effect on the text.
    pub fn reaper_cloak(args: Args) void {
        write("ipat_reaper_cloak", args) catch |err| @panic(@errorName(err));
    }

    /// Makes a big flashy effect, that does nothing by itself.
    pub fn red_tanzaku(args: Args) void {
        write("ipat_red_tanzaku", args) catch |err| @panic(@errorName(err));
    }

    /// Deals damage once in a radius around your target. Projectile is similar to Wizard's
    /// Primary
    pub fn sleeping_greatbow(args: Args) void {
        write("ipat_sleeping_greatbow", args) catch |err| @panic(@errorName(err));
    }

    /// Deals damage to all enemies. Visual effect is very subtle, lending itself well to items
    /// that trigger frequently.
    pub fn sparrow_feather(args: Args) void {
        write("ipat_sparrow_feather", args) catch |err| @panic(@errorName(err));
    }

    /// Makes a flash effect around the player, indicating something has happened.
    pub fn starflash(args: Args) void {
        write("ipat_starflash", args) catch |err| @panic(@errorName(err));
    }

    /// Makes a dark-red flash effect around the player, indicating something has happened.
    pub fn starflash_failure(args: Args) void {
        write("ipat_starflash_failure", args) catch |err| @panic(@errorName(err));
    }

    /// Adds a status effect and speeds up player's movement.
    pub fn thiefs_coat(args: Args) void {
        write("ipat_thiefs_coat", args) catch |err| @panic(@errorName(err));
    }

    /// Adds a status effect to targeted players. Recommended for buffs that target only yourself.
    pub fn timewarp_wand(args: Args) void {
        write("ipat_timewarp_wand", args) catch |err| @panic(@errorName(err));
    }

    /// "amount" (an integer representing a gold amount)
    /// At the end of the battle, will give targeted players an additional "amount" of gold.
    /// Calling this creates a new, hidden object in the background, and creating a whole lot of
    /// them in one fight might lag the game. I'd recommend NOT calling this frequently during a
    /// single battle, but rather designing items in a way that this only needs to be called once
    /// per battle or so. For instance, if you wanted an item that gave 1 gold per time the
    /// character hit an enemy, instead of calling this every time you hit an enemy, increment a
    /// hidden variable each time you hit the enemy, then call this once at the end of battle to
    /// give the character their gold.
    pub fn topaz_charm(args: Args) void {
        write("ipat_topaz_charm", args) catch |err| @panic(@errorName(err));
    }

    /// "speedMult" (a number representing a multiplier to character speed)
    /// "speedDuration" (duration of speed increase)
    /// Increases speed by a multiplier for the specified duration.
    pub fn winged_cap(args: Args) void {
        write("ipat_winged_cap", args) catch |err| @panic(@errorName(err));
    }

    /// "x"
    /// "y"
    /// "duration"
    /// "radius"
    ///
    /// Creates a shield similar to Defender's Defensive that erases bullets and makes allies invulnerable.
    pub fn light_shield(args: Args) void {
        write("ipat_light_shield", args) catch |err| @panic(@errorName(err));
    }

    /// "x"
    /// "y"
    /// "duration"
    /// "radius"
    ///
    /// Creates a shield similar to Heavyblade's Defensive that erases bullets and makes allies invulnerable.
    pub fn dark_shield(args: Args) void {
        write("ipat_dark_shield", args) catch |err| @panic(@errorName(err));
    }

    // Below this point are functions for Abilities. Currently, invulnerability times and
    // animations are included within the ability itself, but I'd like to refactor this so that
    // you'll be able to specify them for custom abilities. This might take me a bit. For now, I'm
    // leaving the below parts blank, and will fill them in at a later date.
    pub fn none_0(args: Args) void {
        write("ipat_none_0", args) catch |err| @panic(@errorName(err));
    }
    pub fn none_1(args: Args) void {
        write("ipat_none_1", args) catch |err| @panic(@errorName(err));
    }
    pub fn none_2(args: Args) void {
        write("ipat_none_2", args) catch |err| @panic(@errorName(err));
    }
    pub fn none_3(args: Args) void {
        write("ipat_none_3", args) catch |err| @panic(@errorName(err));
    }
    pub fn ancient_0(args: Args) void {
        write("ipat_ancient_0", args) catch |err| @panic(@errorName(err));
    }
    pub fn ancient_0_petonly(args: Args) void {
        write("ipat_ancient_0_petonly", args) catch |err| @panic(@errorName(err));
    }
    pub fn ancient_0_pt2(args: Args) void {
        write("ipat_ancient_0_pt2", args) catch |err| @panic(@errorName(err));
    }
    pub fn ancient_0_rabbitonly(args: Args) void {
        write("ipat_ancient_0_rabbitonly", args) catch |err| @panic(@errorName(err));
    }
    pub fn ancient_1(args: Args) void {
        write("ipat_ancient_1", args) catch |err| @panic(@errorName(err));
    }
    pub fn ancient_1_auto(args: Args) void {
        write("ipat_ancient_1_auto", args) catch |err| @panic(@errorName(err));
    }
    pub fn ancient_1_pt2(args: Args) void {
        write("ipat_ancient_1_pt2", args) catch |err| @panic(@errorName(err));
    }
    pub fn ancient_2(args: Args) void {
        write("ipat_ancient_2", args) catch |err| @panic(@errorName(err));
    }
    pub fn ancient_2_auto(args: Args) void {
        write("ipat_ancient_2_auto", args) catch |err| @panic(@errorName(err));
    }
    pub fn ancient_2_pt2(args: Args) void {
        write("ipat_ancient_2_pt2", args) catch |err| @panic(@errorName(err));
    }
    pub fn ancient_3(args: Args) void {
        write("ipat_ancient_3", args) catch |err| @panic(@errorName(err));
    }
    pub fn ancient_3_emerald(args: Args) void {
        write("ipat_ancient_3_emerald", args) catch |err| @panic(@errorName(err));
    }
    pub fn ancient_3_emerald_pt2(args: Args) void {
        write("ipat_ancient_3_emerald_pt2", args) catch |err| @panic(@errorName(err));
    }
    pub fn ancient_3_emerald_pt3(args: Args) void {
        write("ipat_ancient_3_emerald_pt3", args) catch |err| @panic(@errorName(err));
    }
    pub fn assassin_0(args: Args) void {
        write("ipat_assassin_0", args) catch |err| @panic(@errorName(err));
    }
    pub fn assassin_0_ruby(args: Args) void {
        write("ipat_assassin_0_ruby", args) catch |err| @panic(@errorName(err));
    }
    pub fn assassin_1(args: Args) void {
        write("ipat_assassin_1", args) catch |err| @panic(@errorName(err));
    }
    pub fn assassin_1_garnet(args: Args) void {
        write("ipat_assassin_1_garnet", args) catch |err| @panic(@errorName(err));
    }
    pub fn assassin_1_ruby(args: Args) void {
        write("ipat_assassin_1_ruby", args) catch |err| @panic(@errorName(err));
    }
    pub fn assassin_1_sapphire(args: Args) void {
        write("ipat_assassin_1_sapphire", args) catch |err| @panic(@errorName(err));
    }
    pub fn assassin_2(args: Args) void {
        write("ipat_assassin_2", args) catch |err| @panic(@errorName(err));
    }
    pub fn assassin_2_opal(args: Args) void {
        write("ipat_assassin_2_opal", args) catch |err| @panic(@errorName(err));
    }
    pub fn assassin_3(args: Args) void {
        write("ipat_assassin_3", args) catch |err| @panic(@errorName(err));
    }
    pub fn assassin_3_opal(args: Args) void {
        write("ipat_assassin_3_opal", args) catch |err| @panic(@errorName(err));
    }
    pub fn assassin_3_ruby(args: Args) void {
        write("ipat_assassin_3_ruby", args) catch |err| @panic(@errorName(err));
    }
    pub fn bruiser_0(args: Args) void {
        write("ipat_bruiser_0", args) catch |err| @panic(@errorName(err));
    }
    pub fn bruiser_0_saph(args: Args) void {
        write("ipat_bruiser_0_saph", args) catch |err| @panic(@errorName(err));
    }
    pub fn bruiser_1(args: Args) void {
        write("ipat_bruiser_1", args) catch |err| @panic(@errorName(err));
    }
    pub fn bruiser_2(args: Args) void {
        write("ipat_bruiser_2", args) catch |err| @panic(@errorName(err));
    }
    pub fn bruiser_3(args: Args) void {
        write("ipat_bruiser_3", args) catch |err| @panic(@errorName(err));
    }
    pub fn bruiser_3_pt2(args: Args) void {
        write("ipat_bruiser_3_pt2", args) catch |err| @panic(@errorName(err));
    }
    pub fn bruiser_3_ruby(args: Args) void {
        write("ipat_bruiser_3_ruby", args) catch |err| @panic(@errorName(err));
    }
    pub fn dancer_0(args: Args) void {
        write("ipat_dancer_0", args) catch |err| @panic(@errorName(err));
    }
    pub fn dancer_0_opal(args: Args) void {
        write("ipat_dancer_0_opal", args) catch |err| @panic(@errorName(err));
    }
    pub fn dancer_1(args: Args) void {
        write("ipat_dancer_1", args) catch |err| @panic(@errorName(err));
    }
    pub fn dancer_1_emerald(args: Args) void {
        write("ipat_dancer_1_emerald", args) catch |err| @panic(@errorName(err));
    }
    pub fn dancer_2(args: Args) void {
        write("ipat_dancer_2", args) catch |err| @panic(@errorName(err));
    }
    pub fn dancer_2_saph(args: Args) void {
        write("ipat_dancer_2_saph", args) catch |err| @panic(@errorName(err));
    }
    pub fn dancer_3(args: Args) void {
        write("ipat_dancer_3", args) catch |err| @panic(@errorName(err));
    }
    pub fn dancer_3_emerald(args: Args) void {
        write("ipat_dancer_3_emerald", args) catch |err| @panic(@errorName(err));
    }
    pub fn defender_0(args: Args) void {
        write("ipat_defender_0", args) catch |err| @panic(@errorName(err));
    }
    pub fn defender_0_fast(args: Args) void {
        write("ipat_defender_0_fast", args) catch |err| @panic(@errorName(err));
    }
    pub fn defender_0_ruby(args: Args) void {
        write("ipat_defender_0_ruby", args) catch |err| @panic(@errorName(err));
    }
    pub fn defender_1(args: Args) void {
        write("ipat_defender_1", args) catch |err| @panic(@errorName(err));
    }
    pub fn defender_1_opal(args: Args) void {
        write("ipat_defender_1_opal", args) catch |err| @panic(@errorName(err));
    }
    pub fn defender_1_saph(args: Args) void {
        write("ipat_defender_1_saph", args) catch |err| @panic(@errorName(err));
    }
    pub fn defender_2(args: Args) void {
        write("ipat_defender_2", args) catch |err| @panic(@errorName(err));
    }
    pub fn defender_2_emerald(args: Args) void {
        write("ipat_defender_2_emerald", args) catch |err| @panic(@errorName(err));
    }
    pub fn defender_3(args: Args) void {
        write("ipat_defender_3", args) catch |err| @panic(@errorName(err));
    }
    pub fn defender_3_pt2(args: Args) void {
        write("ipat_defender_3_pt2", args) catch |err| @panic(@errorName(err));
    }
    pub fn druid_0(args: Args) void {
        write("ipat_druid_0", args) catch |err| @panic(@errorName(err));
    }
    pub fn druid_0_emerald(args: Args) void {
        write("ipat_druid_0_emerald", args) catch |err| @panic(@errorName(err));
    }
    pub fn druid_0_ruby(args: Args) void {
        write("ipat_druid_0_ruby", args) catch |err| @panic(@errorName(err));
    }
    pub fn druid_0_saph(args: Args) void {
        write("ipat_druid_0_saph", args) catch |err| @panic(@errorName(err));
    }
    pub fn druid_1(args: Args) void {
        write("ipat_druid_1", args) catch |err| @panic(@errorName(err));
    }
    pub fn druid_1_emerald(args: Args) void {
        write("ipat_druid_1_emerald", args) catch |err| @panic(@errorName(err));
    }
    pub fn druid_1_garnet(args: Args) void {
        write("ipat_druid_1_garnet", args) catch |err| @panic(@errorName(err));
    }
    pub fn druid_1_ruby(args: Args) void {
        write("ipat_druid_1_ruby", args) catch |err| @panic(@errorName(err));
    }
    pub fn druid_2(args: Args) void {
        write("ipat_druid_2", args) catch |err| @panic(@errorName(err));
    }
    pub fn druid_2_2(args: Args) void {
        write("ipat_druid_2_2", args) catch |err| @panic(@errorName(err));
    }
    pub fn druid_2_2_garnet(args: Args) void {
        write("ipat_druid_2_2_garnet", args) catch |err| @panic(@errorName(err));
    }
    pub fn druid_2_garnet(args: Args) void {
        write("ipat_druid_2_garnet", args) catch |err| @panic(@errorName(err));
    }
    pub fn druid_2_ruby(args: Args) void {
        write("ipat_druid_2_ruby", args) catch |err| @panic(@errorName(err));
    }
    pub fn druid_3(args: Args) void {
        write("ipat_druid_3", args) catch |err| @panic(@errorName(err));
    }
    pub fn druid_3_emerald(args: Args) void {
        write("ipat_druid_3_emerald", args) catch |err| @panic(@errorName(err));
    }
    pub fn druid_3_opal(args: Args) void {
        write("ipat_druid_3_opal", args) catch |err| @panic(@errorName(err));
    }
    pub fn druid_3_ruby(args: Args) void {
        write("ipat_druid_3_ruby", args) catch |err| @panic(@errorName(err));
    }
    pub fn druid_3_saph(args: Args) void {
        write("ipat_druid_3_saph", args) catch |err| @panic(@errorName(err));
    }
    pub fn hblade_0(args: Args) void {
        write("ipat_hblade_0", args) catch |err| @panic(@errorName(err));
    }
    pub fn hblade_0_garnet(args: Args) void {
        write("ipat_hblade_0_garnet", args) catch |err| @panic(@errorName(err));
    }
    pub fn hblade_0_garnet_pt2(args: Args) void {
        write("ipat_hblade_0_garnet_pt2", args) catch |err| @panic(@errorName(err));
    }
    pub fn hblade_1(args: Args) void {
        write("ipat_hblade_1", args) catch |err| @panic(@errorName(err));
    }
    pub fn hblade_1_garnet(args: Args) void {
        write("ipat_hblade_1_garnet", args) catch |err| @panic(@errorName(err));
    }
    pub fn hblade_1_ruby(args: Args) void {
        write("ipat_hblade_1_ruby", args) catch |err| @panic(@errorName(err));
    }
    pub fn hblade_1_saph(args: Args) void {
        write("ipat_hblade_1_saph", args) catch |err| @panic(@errorName(err));
    }
    pub fn hblade_2(args: Args) void {
        write("ipat_hblade_2", args) catch |err| @panic(@errorName(err));
    }
    pub fn hblade_2_emerald(args: Args) void {
        write("ipat_hblade_2_emerald", args) catch |err| @panic(@errorName(err));
    }
    pub fn hblade_2_pt2(args: Args) void {
        write("ipat_hblade_2_pt2", args) catch |err| @panic(@errorName(err));
    }
    pub fn hblade_3(args: Args) void {
        write("ipat_hblade_3", args) catch |err| @panic(@errorName(err));
    }
    pub fn hblade_3_garnet(args: Args) void {
        write("ipat_hblade_3_garnet", args) catch |err| @panic(@errorName(err));
    }
    pub fn hblade_3_opal(args: Args) void {
        write("ipat_hblade_3_opal", args) catch |err| @panic(@errorName(err));
    }
    pub fn hblade_3_ruby(args: Args) void {
        write("ipat_hblade_3_ruby", args) catch |err| @panic(@errorName(err));
    }
    pub fn sniper_0(args: Args) void {
        write("ipat_sniper_0", args) catch |err| @panic(@errorName(err));
    }
    pub fn sniper_0_emerald(args: Args) void {
        write("ipat_sniper_0_emerald", args) catch |err| @panic(@errorName(err));
    }
    pub fn sniper_0_garnet(args: Args) void {
        write("ipat_sniper_0_garnet", args) catch |err| @panic(@errorName(err));
    }
    pub fn sniper_0_saph(args: Args) void {
        write("ipat_sniper_0_saph", args) catch |err| @panic(@errorName(err));
    }
    pub fn sniper_1(args: Args) void {
        write("ipat_sniper_1", args) catch |err| @panic(@errorName(err));
    }
    pub fn sniper_1_ruby(args: Args) void {
        write("ipat_sniper_1_ruby", args) catch |err| @panic(@errorName(err));
    }
    pub fn sniper_2(args: Args) void {
        write("ipat_sniper_2", args) catch |err| @panic(@errorName(err));
    }
    pub fn sniper_2_emerald(args: Args) void {
        write("ipat_sniper_2_emerald", args) catch |err| @panic(@errorName(err));
    }
    pub fn sniper_3(args: Args) void {
        write("ipat_sniper_3", args) catch |err| @panic(@errorName(err));
    }
    pub fn spsword_0(args: Args) void {
        write("ipat_spsword_0", args) catch |err| @panic(@errorName(err));
    }
    pub fn spsword_0_pt2(args: Args) void {
        write("ipat_spsword_0_pt2", args) catch |err| @panic(@errorName(err));
    }
    pub fn spsword_1(args: Args) void {
        write("ipat_spsword_1", args) catch |err| @panic(@errorName(err));
    }
    pub fn spsword_1_emerald(args: Args) void {
        write("ipat_spsword_1_emerald", args) catch |err| @panic(@errorName(err));
    }
    pub fn spsword_1_pt2(args: Args) void {
        write("ipat_spsword_1_pt2", args) catch |err| @panic(@errorName(err));
    }
    pub fn spsword_2(args: Args) void {
        write("ipat_spsword_2", args) catch |err| @panic(@errorName(err));
    }
    pub fn spsword_2_pt2(args: Args) void {
        write("ipat_spsword_2_pt2", args) catch |err| @panic(@errorName(err));
    }
    pub fn spsword_3(args: Args) void {
        write("ipat_spsword_3", args) catch |err| @panic(@errorName(err));
    }
    pub fn spsword_3_pt2(args: Args) void {
        write("ipat_spsword_3_pt2", args) catch |err| @panic(@errorName(err));
    }
    pub fn wizard_0(args: Args) void {
        write("ipat_wizard_0", args) catch |err| @panic(@errorName(err));
    }
    pub fn wizard_0_ruby(args: Args) void {
        write("ipat_wizard_0_ruby", args) catch |err| @panic(@errorName(err));
    }
    pub fn wizard_1(args: Args) void {
        write("ipat_wizard_1", args) catch |err| @panic(@errorName(err));
    }
    pub fn wizard_1_garnet(args: Args) void {
        write("ipat_wizard_1_garnet", args) catch |err| @panic(@errorName(err));
    }
    pub fn wizard_1_garnet_pt2(args: Args) void {
        write("ipat_wizard_1_garnet_pt2", args) catch |err| @panic(@errorName(err));
    }
    pub fn wizard_1_opal(args: Args) void {
        write("ipat_wizard_1_opal", args) catch |err| @panic(@errorName(err));
    }
    pub fn wizard_2(args: Args) void {
        write("ipat_wizard_2", args) catch |err| @panic(@errorName(err));
    }
    pub fn wizard_2_saph(args: Args) void {
        write("ipat_wizard_2_saph", args) catch |err| @panic(@errorName(err));
    }
    pub fn wizard_3(args: Args) void {
        write("ipat_wizard_3", args) catch |err| @panic(@errorName(err));
    }
    pub fn wizard_3_emerald(args: Args) void {
        write("ipat_wizard_3_emerald", args) catch |err| @panic(@errorName(err));
    }
    pub fn wizard_3_opal(args: Args) void {
        write("ipat_wizard_3_opal", args) catch |err| @panic(@errorName(err));
    }

    fn write(pat: []const u8, args: Args) !void {
        std.debug.assert(have_trigger);
        const writer = item_csv.writer();
        try writer.print("addPattern,{s}", .{pat});

        if (args.fxStr) |fxStr|
            try writer.print(",fx,{s}", .{fxStr});
        if (args.fyStr) |fyStr|
            try writer.print(",fy,{s}", .{fyStr});
        if (args.duration) |duration|
            try writer.print(",duration,{d}", .{duration});
        if (args.number) |number|
            try writer.print(",number,{d}", .{number});
        if (args.numberStr) |number|
            try writer.print(",number,{s}", .{number});
        if (args.numberR) |number|
            try writer.print(",number,{s}", .{number.toCsvString()});
        if (args.numberS) |number|
            try writer.print(",number,{s}", .{number.toCsvString()});
        if (args.radius) |radius|
            try writer.print(",radius,{d}", .{radius});
        if (args.amount) |amount|
            try writer.print(",amount,{d}", .{amount});

        try writer.writeByteNTimes(',', 4 - args.notNullFieldCount() * 2);
        try writer.writeAll("\n");
    }

    pub const Args = struct {
        fxStr: ?[]const u8 = null,
        fyStr: ?[]const u8 = null,
        duration: ?u16 = null,
        number: ?u16 = null,
        numberStr: ?[]const u8 = null,
        numberR: ?r = null,
        numberS: ?s = null,
        radius: ?u16 = null,
        amount: ?u16 = null,

        pub fn notNullFieldCount(args: Args) usize {
            var res: usize = 0;
            inline for (@typeInfo(Args).@"struct".fields) |field| {
                res += @intFromBool(@field(args, field.name) != null);
            }

            return res;
        }
    };
};

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
pub const ttrg = opaque {
    /// Clears all lists.
    pub fn none() void {
        write("ttrg_none", .{}) catch |err| @panic(@errorName(err));
    }

    /// From a status effect receiving a trigger, target only the player afflicted with this
    /// status.
    pub fn player_afflicted() void {
        write("ttrg_player_afflicted", .{}) catch |err| @panic(@errorName(err));
    }
    pub fn player_afflicted_source() void {
        write("ttrg_player_afflicted_source", .{}) catch |err| @panic(@errorName(err));
    }

    /// When a status effect is the SOURCE of the trigger, target the player afflicted by that
    /// status effect.
    /// From an "onDamageDone" trigger, target the player that was damaged.
    pub fn player_damaged() void {
        write("ttrg_player_damaged", .{}) catch |err| @panic(@errorName(err));
    }

    /// flag (a binary number)
    ///
    /// Prune the current list of players to include only those that have a certain hbsFlag.
    pub fn player_prune_hbsflag(args: anytype) void {
        write("ttrg_player_prune_hbsflag", args) catch |err| @panic(@errorName(err));
    }

    /// Target the player receiving this trigger; if the trigger is received by a hotbar slot, it
    /// will target the player who owns that slot.
    pub fn player_self() void {
        write("ttrg_player_self", .{}) catch |err| @panic(@errorName(err));
    }

    /// Targets all "players" (meaning, both allies and enemies).
    pub fn players_all() void {
        write("ttrg_players_all", .{}) catch |err| @panic(@errorName(err));
    }

    /// Targets all the players that are on the same team as the person receiving this trigger.
    /// For loot items, this means all of the rabbit players, but if an enemy were to call this,
    /// it would target all the enemies. Also, this excludes KO'd players.
    pub fn players_ally() void {
        write("ttrg_players_ally", .{}) catch |err| @panic(@errorName(err));
    }

    /// excludeID (an integer)
    ///
    /// Targets all players on the same team, excluding KO'd players, and excluding the playerID
    /// passed in.
    pub fn players_ally_exclude(args: anytype) void {
        write("ttrg_players_ally_exclude", args) catch |err| @panic(@errorName(err));
    }

    /// Targets all players on the same team. Includes KO'd players.
    pub fn players_ally_include_ko() void {
        write("ttrg_players_ally_include_ko", .{}) catch |err| @panic(@errorName(err));
    }

    /// Despite the name, this actually targets the player who's MISSING the most HP, not the
    /// actual lowest HP player. I must have written this a long time ago. Also, it excludes KO'd
    /// players.
    pub fn players_ally_lowest_hp() void {
        write("ttrg_players_ally_lowest_hp", .{}) catch |err| @panic(@errorName(err));
    }

    /// numberOfPlayers (an integer; this is an optional parameter)
    ///
    /// Targets a random selection of your teammates. If a number is passed in, it will try to
    /// target that many players. If no number is passed in, it will target 1.
    pub fn players_ally_random(args: anytype) void {
        write("ttrg_players_ally_random", args) catch |err| @panic(@errorName(err));
    }

    /// Clears player list.
    pub fn players_none() void {
        write("ttrg_players_none", .{}) catch |err| @panic(@errorName(err));
    }

    /// Targets all the players that are on the OPPOSITE team as the person receiving this trigger.
    /// For loot items, this means all of your enemies.
    pub fn players_opponent() void {
        write("ttrg_players_opponent", .{}) catch |err| @panic(@errorName(err));
    }

    /// Targets all of your enemies that are facing away from you.
    pub fn players_opponent_backstab() void {
        write("ttrg_players_opponent_backstab", .{}) catch |err| @panic(@errorName(err));
    }

    /// trgBinary (a binary number representing player IDs)
    ///
    /// Targets your enemies based off a binary number.
    /// 1 : 0001 : Just player 0
    /// 2 : 0010 : Just player 1
    /// 3 : 0011 : Player 0 and Player 1
    /// 5 : 0101 : Player 0 and Player 2
    /// etc..
    pub fn players_opponent_binary(args: anytype) void {
        write("ttrg_players_opponent_binary", args) catch |err| @panic(@errorName(err));
    }

    /// excludeID (an integer)
    ///
    /// Targets all players on the enemy team, excluding KO'd players, and excluding the playerID
    /// passed in.
    pub fn players_opponent_exclude(args: anytype) void {
        write("ttrg_players_opponent_exclude", args) catch |err| @panic(@errorName(err));
    }

    /// Targets whatever player this player is currently targetting.
    pub fn players_opponent_focus() void {
        write("ttrg_players_opponent_focus", .{}) catch |err| @panic(@errorName(err));
    }

    /// numberOfPlayers (an integer; this is an optional parameter)
    ///
    /// Targets a random selection of your enemies.  If a number is passed in, it will try to
    /// target that many players.  If no number is passed in, it will target 1.
    pub fn players_opponent_random(args: anytype) void {
        write("ttrg_players_opponent_random", args) catch |err| @panic(@errorName(err));
    }

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
    pub fn players_prune(args: anytype) void {
        write("ttrg_players_prune", args) catch |err| @panic(@errorName(err));
    }

    /// Removes the player receiving this trigger from the player list, if it is in there.
    pub fn players_prune_self() void {
        write("ttrg_players_prune_self", .{}) catch |err| @panic(@errorName(err));
    }

    /// Targets the player who is the source of this trigger.
    pub fn players_source() void {
        write("ttrg_players_source", .{}) catch |err| @panic(@errorName(err));
    }

    /// numberOfPlayers (an integer; this is an optional parameter)
    ///
    /// Targets a random selection of the players that are currently in the list. If a number is
    /// passed in, it will try to target that many players. If no number is passed in, it will
    /// target 1.
    pub fn players_target_random(args: anytype) void {
        write("ttrg_players_target_random", args) catch |err| @panic(@errorName(err));
    }

    /// allyBin (a binary number representing player IDs)
    /// enemyBin (a binary number representing player IDs)
    ///
    /// Targets both allies and enemies based off binary numbers.
    /// 1 : 0001 : Just player 0
    /// 2 : 0010 : Just player 1
    /// 3 : 0011 : Player 0 and Player 1
    /// 5 : 0101 : Player 0 and Player 2
    /// etc..
    pub fn players_team_binary(args: anytype) void {
        write("ttrg_players_team_binary", args) catch |err| @panic(@errorName(err));
    }

    /// Targets the hotbar slot receiving this trigger
    pub fn hotbarslot_self() void {
        write("ttrg_hotbarslot_self", .{}) catch |err| @panic(@errorName(err));
    }

    /// Targets ALL active hotbar slots
    pub fn hotbarslots_all() void {
        write("ttrg_hotbarslots_all", .{}) catch |err| @panic(@errorName(err));
    }

    /// Targets all hotbar slots on your team
    pub fn hotbarslots_ally() void {
        write("ttrg_hotbarslots_ally", .{}) catch |err| @panic(@errorName(err));
    }

    /// Targets all the hotbar slots of the players in the "players" list
    pub fn hotbarslots_current_players() void {
        write("ttrg_hotbarslots_current_players", .{}) catch |err| @panic(@errorName(err));
    }

    /// Targets all the hotbar slots on your enemy's team
    pub fn hotbarslots_opponent() void {
        write("ttrg_hotbarslots_opponent", .{}) catch |err| @panic(@errorName(err));
    }

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
    pub fn hotbarslots_prune(a: anytype, op: Compare, b: anytype) void {
        write("ttrg_hotbarslots_prune", .{ a, op, b }) catch |err| @panic(@errorName(err));
    }

    /// Prune the current list of hotbar slots to only include items that have strength.
    pub fn hotbarslots_prune_base_has_str() void {
        write("ttrg_hotbarslots_prune_base_has_str", .{}) catch |err| @panic(@errorName(err));
    }

    /// param0 (a variable that differs per target)
    /// param1 (a boolean)
    ///
    /// Prune the current list of hotbar slots to only include items for which a boolean matches.
    pub fn hotbarslots_prune_bool(args: anytype) void {
        write("ttrg_hotbarslots_prune_bool", args) catch |err| @panic(@errorName(err));
    }

    /// isBuff (if true, gets slots with buffs, if false, gets slots with debuffs)
    ///
    /// Prune the current list of hotbar slots to include items that have a Buff or Debuff they
    /// apply.
    pub fn hotbarslots_prune_bufftype(args: anytype) void {
        write("ttrg_hotbarslots_prune_bufftype", args) catch |err| @panic(@errorName(err));
    }

    /// type (an integer representing a cooldown type)
    ///
    /// Prune the current list of hotbar slots to include items that have a specific cooldown type.
    /// 0 : None
    /// 1 : Time (only cooldown, such as Defensives/most loot)
    /// 2 : GCD (Most Primaries, Specials, etc.)
    /// 3 : Stock (Multiple uses, like Wizard Defensive)
    /// 4 : StockGCD (Multiple uses + a GCD, like Heavyblade Special)
    /// 5 : StockOnly (Cooldown doesn't make it gain stock, like Defender Special)
    pub fn hotbarslots_prune_cdtype(args: anytype) void {
        write("ttrg_hotbarslots_prune_cdtype", args) catch |err| @panic(@errorName(err));
    }

    /// Prune the current list of hotbar slots to only include items that can be reset.
    pub fn hotbarslots_prune_noreset() void {
        write("ttrg_hotbarslots_prune_noreset", .{}) catch |err| @panic(@errorName(err));
    }

    /// Removes the hotbar slot receiving this trigger from the list of hotbar slots, if it's in
    /// there.
    pub fn hotbarslots_prune_self() void {
        write("ttrg_hotbarslots_prune_self", .{}) catch |err| @panic(@errorName(err));
    }

    /// Targets the abilities of the player receiving this trigger.
    pub fn hotbarslots_self_abilities() void {
        write("ttrg_hotbarslots_self_abilities", .{}) catch |err| @panic(@errorName(err));
    }

    /// Targets the ability of the player receiving this trigger with the highest strength number
    /// (if it's tied, multiple abilities will be targeted)
    pub fn hotbarslots_self_higheststrweapon() void {
        write("ttrg_hotbarslots_self_higheststrweapon", .{}) catch |err| @panic(@errorName(err));
    }

    /// Targets the loot of the player receiving this trigger
    pub fn hotbarslots_self_loot() void {
        write("ttrg_hotbarslots_self_loot", .{}) catch |err| @panic(@errorName(err));
    }

    /// wpType (an integer representing a weapon type)
    ///
    /// Targets a particular ability of the player receiving this trigger.
    /// 0 : None
    /// 1 : Primary
    /// 2 : Secondary
    /// 3 : Special
    /// 4 : Defensive
    pub fn hotbarslots_self_weapontype(args: anytype) void {
        write("ttrg_hotbarslots_self_weapontype", args) catch |err| @panic(@errorName(err));
    }

    /// wpType (an integer representing a weapon type)
    ///
    /// Same as ttrg_hotbarslots_self_weapontype, but will only target the ability if it has a base
    /// strength; otherwise it will simply result in an empty list.
    pub fn hotbarslots_self_weapontype_withstr(args: anytype) void {
        write("ttrg_hotbarslots_self_weapontype_withstr", args) catch |err| @panic(@errorName(err));
    }

    /// Targets all status effects that are currently active
    pub fn hbstatus_all() void {
        write("ttrg_hbstatus_all", .{}) catch |err| @panic(@errorName(err));
    }

    /// Targets all status effects that have been APPLIED by your allies
    pub fn hbstatus_ally() void {
        write("ttrg_hbstatus_ally", .{}) catch |err| @panic(@errorName(err));
    }

    /// Targets all status effects that have been APPLIED by your opponent
    pub fn hbstatus_opponent() void {
        write("ttrg_hbstatus_opponent", .{}) catch |err| @panic(@errorName(err));
    }

    /// Prunes current list of status effects to only include those that match the equation given.
    /// For instance, to target all of the status effects afflicting allies that are buffs:
    ///
    /// target, ttrg_hbstatus_all
    /// target, ttrg_hbstatus_prune,  thbs#_aflTeamId, ==, 0
    /// target, ttrg_hotbarslots_prune, thbs#_isBuff, ==, 1
    ///
    /// When using "prune" functions, "#" is replaced with the appropriate variable for that item
    /// in the target list.
    pub fn hbstatus_prune(a: anytype, op: Compare, b: anytype) void {
        write("ttrg_hbstatus_prune", .{ a, op, b }) catch |err| @panic(@errorName(err));
    }

    /// Targets the status effect receiving this trigger.
    pub fn hbstatus_self() void {
        write("ttrg_hbstatus_self", .{}) catch |err| @panic(@errorName(err));
    }

    /// Targets the status effect that was the source of this trigger.
    pub fn hbstatus_source() void {
        write("ttrg_hbstatus_source", .{}) catch |err| @panic(@errorName(err));
    }

    /// Targets all of the status effects that have been applied by the current list of players.
    pub fn hbstatus_target() void {
        write("ttrg_hbstatus_target", .{}) catch |err| @panic(@errorName(err));
    }

    fn write(targ: []const u8, args: anytype) !void {
        std.debug.assert(have_trigger);
        try item_csv.writer().print("target,{s}", .{targ});
        try writeArgs(item_csv.writer(), args);
    }
};

/// Set functions can be used to setup different variables, as well as set parameters for Attack
/// patterns.
///
/// There's also a few helpful things, like a debug print function.
///
/// https://docs.google.com/spreadsheets/d/1shtFkpagAafUjjA70XGlYGruqFIbLpQlcDjWKNNm3_4/edit?pli=1&gid=1105686251#gid=1105686251
pub const tset = opaque {
    /// Currently non-functional; but I will make it work soon-ish
    pub fn animation(args: anytype) void {
        write("tset_animation", args) catch |err| @panic(@errorName(err));
    }

    /// percent (a number between 0 - 1)
    /// Sets the critical hit chance for attack patterns.
    /// Note that this doesn't need to be set outside of special conditions (such as if you want
    /// something to always crit, or never crit)
    /// 0 : 0%
    /// 1 : 100%
    /// 0.5 : 50%
    pub fn critratio(args: anytype) void {
        write("tset_critratio", args) catch |err| @panic(@errorName(err));
    }

    /// flags (a binary representing a number of damage flags)
    /// Sets damage flags for upcoming attack patterns. This is a binary number, so numbers can be
    /// added together to have multiple flags.
    ///
    /// 1 : DMG_FLAG_HBS (Damage comes from a status effect)
    /// 2 : DMG_FLAG_QUIET (This damage will not make the enemy sprite "shake", recommended for
    ///                     Poison/Spark effects)
    /// 4 : DMG_FLAG_INVULNPIERCE (This damage will go through invulnerability)
    /// 8 : DMG_FLAG_DARKFLAME (Special flag for Spellsword Rabbit)
    pub fn damage_flags(args: anytype) void {
        write("tset_damage_flags", args) catch |err| @panic(@errorName(err));
    }

    /// param (any number or variable)
    /// Will print out that number. Currently doesn't do anything, but I will add it to the mod
    /// debug log in the next update.
    pub fn debug(param: anytype) void {
        write("tset_debug", .{param}) catch |err| @panic(@errorName(err));
    }

    /// Will set the appropriate strength for applying Burn. Must be used from an onDamageDone
    /// trigger before Burn is applied.
    pub fn hbs_burnhit() void {
        write("tset_hbs_burnhit", .{}) catch |err| @panic(@errorName(err));
    }

    /// Will set the appropriate strength/length for a Buff or Debuff, based on the item's stats.
    /// Should be used before a buff or debuff is applied. The next Attack pattern will apply that
    /// Buff/Debuff on hit.
    pub fn hbs_def() void {
        write("tset_hbs_def", .{}) catch |err| @panic(@errorName(err));
    }

    /// Similar to tset_hbs_def, but will pick a random buff (for effects like Usagi Kamen)
    pub fn hbs_randombuff() void {
        write("tset_hbs_randombuff", .{}) catch |err| @panic(@errorName(err));
    }

    /// hbsKey (a string that is a key to a status effect)
    /// Will set a custom debuff to be applied.
    pub fn hbskey(args: anytype) void {
        write("tset_hbskey", args) catch |err| @panic(@errorName(err));
    }

    /// amount (an integer)
    /// Will set a custom debuff strength.
    pub fn hbsstr(args: anytype) void {
        write("tset_hbsstr", args) catch |err| @panic(@errorName(err));
    }

    /// percent (a number between 0 - 1 )
    /// Will set a custom hit variation. Usually used to set it to 0, in the case you want
    /// something to hit for a consistent amount each time. (Like Fire Potion, or Burn)
    pub fn randomness(args: anytype) void {
        write("tset_randomness", args) catch |err| @panic(@errorName(err));
    }

    /// amount (an integer)
    /// Will set a custom strength for Attack patterns.
    pub fn strength(args: anytype) void {
        write("tset_strength", args) catch |err| @panic(@errorName(err));
    }

    /// Exculsively used for Defender's Ruby Secondary; sets a strength based off number of
    /// charges the move has.
    pub fn strength_chargecount() void {
        write("tset_strength_chargecount", .{}) catch |err| @panic(@errorName(err));
    }

    /// Sets the default strength for the move, based on the hotbar slot. You should usually use
    /// this before adding attack patterns that deal damage.
    pub fn strength_def() void {
        write("tset_strength_def", .{}) catch |err| @panic(@errorName(err));
    }

    /// amount (an integer)
    /// Will set a custom strength for Attack patterns; this will take into account bonus damage
    /// that loot gets from items like Darkcloud Necklace
    pub fn strength_loot(args: anytype) void {
        write("tset_strength_loot", args) catch |err| @panic(@errorName(err));
    }

    /// amount (any number)
    /// Will set a bonus multiplier for enemies that you backstab with Attack patterns.
    /// 1   : 1x multiplier (normal damage)
    /// 1.3 : 1.3x multiplier (Assassin Special)
    /// 1.5 : 1.5x multiplier (Assassin Emerald Special)
    pub fn strmult_backstab(args: anytype) void {
        write("tset_strmult_backstab", args) catch |err| @panic(@errorName(err));
    }

    /// amount (any number)
    /// Will add a percentage bonus for every debuff the target has on them. This used to be one
    /// of Assassin's upgrades, but it sucked so I removed it.
    pub fn strmult_debuffcount(args: anytype) void {
        write("tset_strmult_debuffcount", args) catch |err| @panic(@errorName(err));
    }
    pub fn uservar1(name: []const u8, v: anytype) void {
        write("tset_uservar", .{ name, v }) catch |err| @panic(@errorName(err));
    }
    pub fn uservar2(name: []const u8, a: anytype, op: MathSign, b: anytype) void {
        write("tset_uservar", .{ name, a, op, b }) catch |err| @panic(@errorName(err));
    }

    /// For hotbar statuses, creates two uservariables "u_aflX" and "u_aflY" based on the position
    /// of the afflicted player.
    pub fn uservar_aflplayer_pos(args: anytype) void {
        write("tset_uservar_aflplayer_pos", args) catch |err| @panic(@errorName(err));
    }

    /// key (string)
    /// cooldownAm (number)
    /// minimumCd (number)
    /// incrementCd (number)
    /// maxAm (number)
    /// A set function specifically to make Blackhole Charm work (saves a variable based off how
    /// long a cooldown is)
    pub fn uservar_blackhole_charm_calc(args: anytype) void {
        write("tset_uservar_blackhole_charm_calc", args) catch |err| @panic(@errorName(err));
    }

    /// "key (string)
    /// onEqual (anything)
    /// onUnequal (anything)
    /// checkVarNum (integer)
    /// checkVarAm (number)
    /// If the squareVar indicated by checkVarNum is equal to checkVarAm, saves "onEqual" to the
    /// key provided. Otherwise, saves "onUnequal" to the key provided.
    pub fn uservar_cond_squarevar_equal(args: anytype) void {
        write("tset_uservar_cond_squarevar_equal", args) catch |err| @panic(@errorName(err));
    }

    /// maxAm (integer)
    /// For Spellblade, saves the amount of darkflame this ability will consume to "u_darkflame".
    /// If an ability consumes 4 darkflame normally, and you have more than 4 darkflame, it will
    /// be set to 4.  If it normally consumes 4 and you only have 2 darkflame, it will be set to 2.
    pub fn uservar_darkflame(args: anytype) void {
        write("tset_uservar_darkflame", args) catch |err| @panic(@errorName(err));
    }

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
    /// For each player, set a uservar "u_amount#" to their Max HP minus their current HP (where #
    /// is replaced with their position in the list)
    /// set,tset_uservar_each_target_player,u_amount#,s_hpMax,-,s_hp
    pub fn uservar_each_target_player(args: anytype) void {
        write("tset_uservar_each_target_player", args) catch |err| @panic(@errorName(err));
    }

    /// key (string)
    /// playerId (integer)
    /// Creates a user variable from that key, representing the player's gold
    pub fn uservar_gold(args: anytype) void {
        write("tset_uservar_gold", args) catch |err| @panic(@errorName(err));
    }

    /// percentChance (number between 0 and 1)
    /// key (string)
    /// onSuccess (anything)
    /// onFail (anything)
    ///
    /// Flips a weighted coin based on the percentChance and the player's luck stat, and saves the
    /// result to a uservar based on whether or not it succeeded.
    pub fn uservar_random(args: anytype) void {
        write("tset_uservar_random", args) catch |err| @panic(@errorName(err));
    }

    /// key (string)
    /// minimumAmount (number)
    /// maximumAmount (number)
    ///
    /// Saves a random number between the minimum and maximum amount to a uservar.
    pub fn uservar_random_range(args: anytype) void {
        write("tset_uservar_random_range", args) catch |err| @panic(@errorName(err));
    }

    /// key (string)
    /// minimumAmount (number)
    /// maximumAmount (number)
    ///
    /// Saves a random number between the minimum and maximum amount to a uservar.
    pub fn userver_random_range_int(args: anytype) void {
        write("tset_userver_random_range_int", args) catch |err| @panic(@errorName(err));
    }

    pub fn uservar_switch(args: anytype) void {
        write("tset_uservar_switch", args) catch |err| @panic(@errorName(err));
    }
    pub fn uservar_difficulty(args: anytype) void {
        write("tset_uservar_difficulty", args) catch |err| @panic(@errorName(err));
    }
    pub fn uservar_hallwaycount(args: anytype) void {
        write("tset_uservar_hallwaycount", args) catch |err| @panic(@errorName(err));
    }
    pub fn uservar_stage(args: anytype) void {
        write("tset_uservar_stage", args) catch |err| @panic(@errorName(err));
    }
    pub fn uservar_hb_cooldownvar(args: anytype) void {
        write("tset_uservar_hb_cooldownvar", args) catch |err| @panic(@errorName(err));
    }
    pub fn uservar_hb_hitboxvar(args: anytype) void {
        write("tset_uservar_hb_hitboxvar", args) catch |err| @panic(@errorName(err));
    }
    pub fn uservar_hb_itemvar(args: anytype) void {
        write("tset_uservar_hb_itemvar", args) catch |err| @panic(@errorName(err));
    }
    pub fn uservar_hb_stat(args: anytype) void {
        write("tset_uservar_hb_stat", args) catch |err| @panic(@errorName(err));
    }
    pub fn uservar_player_stat(args: anytype) void {
        write("tset_uservar_player_stat", args) catch |err| @panic(@errorName(err));
    }
    pub fn uservar_slotcount(args: anytype) void {
        write("tset_uservar_slotcount", args) catch |err| @panic(@errorName(err));
    }
    pub fn uservar_hbscount(args: anytype) void {
        write("tset_uservar_hbscount", args) catch |err| @panic(@errorName(err));
    }
    pub fn uservar_playercount(args: anytype) void {
        write("tset_uservar_playercount", args) catch |err| @panic(@errorName(err));
    }

    fn write(set: []const u8, args: anytype) !void {
        std.debug.assert(have_trigger);
        try item_csv.writer().print("set,{s}", .{set});
        try writeArgs(item_csv.writer(), args);
    }
};

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

pub fn rgb(red: u8, green: u8, blue: u8) Color {
    return .{ .r = red, .g = green, .b = blue };
}

/// https://docs.google.com/spreadsheets/d/1Mcj2EbtQD15Aq-lIVE6_GeW_w7_N_aDKhgZzWg4vx54/edit?gid=68441595#gid=68441595
/// https://canary.discord.com/channels/496640298844422149/1239731124952105100/1340341730775662613
pub const Hbs = enum(u8) {
    none = 0,
    smite = 1,
    smite_0 = 2,
    smite_1 = 3,
    smite_2 = 4,
    smite_3 = 5,
    elegy = 6,
    elegy_0 = 7,
    elegy_1 = 8,
    elegy_2 = 9,
    haste = 10,
    haste_0 = 11,
    haste_1 = 12,
    haste_2 = 13,
    stoneskin = 14,
    graniteskin = 15,
    lucky = 16,
    super = 17,
    flutterstep = 18,
    counter = 19,
    counter_0 = 20,
    counter_1 = 21,
    counter_2 = 22,
    blackstrike = 23,
    stillness = 24,
    repeat = 25,
    flowstr = 26,
    flowdex = 27,
    flowint = 28,
    flashstr = 29,
    flashdex = 30,
    flashint = 31,
    vanish = 32,
    ghost = 33,
    warcry = 34,
    astra = 35,
    astra2 = 36,
    nova = 37,
    berserk = 38,
    abyssrage = 39,
    snare = 40,
    snare_0 = 41,
    snare_1 = 42,
    snare_2 = 43,
    snare_3 = 44,
    snare_4 = 45,
    snare_5 = 46,
    snare_6 = 47,
    snare_7 = 48,
    snare2 = 49,
    snare2_0 = 50,
    snare2_1 = 51,
    snare2_2 = 52,
    snare2_3 = 53,
    snare2_4 = 54,
    snare2_5 = 55,
    snare2_6 = 56,
    snare2_7 = 57,
    hex = 58,
    hex_super = 59,
    hex_poison = 60,
    hex_anti = 61,
    curse = 62,
    curse_0 = 63,
    curse_1 = 64,
    curse_2 = 65,
    curse_3 = 66,
    curse_4 = 67,
    curse_5 = 68,
    bleed = 69,
    bleed_0 = 70,
    bleed_1 = 71,
    bleed_2 = 72,
    bleed_3 = 73,
    sap = 74,
    spark = 75,
    spark_0 = 76,
    spark_1 = 77,
    spark_2 = 78,
    spark_3 = 79,
    spark_4 = 80,
    spark_5 = 81,
    spark_6 = 82,
    decay = 83,
    decay_0 = 84,
    decay_1 = 85,
    decay_2 = 86,
    decay_3 = 87,
    decay_4 = 88,
    decay_5 = 89,
    decay_6 = 90,
    decay_7 = 91,
    decay_8 = 92,
    decay_9 = 93,
    poison = 94,
    poison_0 = 95,
    poison_1 = 96,
    poison_2 = 97,
    poison_3 = 98,
    poison_4 = 99,
    poison_5 = 100,
    poison_6 = 101,
    burn = 102,
    burn_0 = 103,
    burn_1 = 104,
    burn_2 = 105,
    burn_3 = 106,
    burn_4 = 107,
    burn_5 = 108,
    burn_6 = 109,
    burn_assassin_0 = 110,
    burn_assassin_1 = 111,
    burn_assassin_2 = 112,
    burn_assassin_3 = 113,
    burn_assassin_4 = 114,
    burn_assassin_5 = 115,
    burn_assassin_6 = 116,
    burn_assassin_7 = 117,
    burn_dancer_0 = 118,
    burn_dancer_1 = 119,
    burn_dancer_2 = 120,
    burn_dancer_3 = 121,
    burn_dancer_4 = 122,
    burn_dancer_5 = 123,
    burn_dancer_6 = 124,
    burn_dancer_7 = 125,
    burn_sniper_0 = 126,
    burn_sniper_1 = 127,
    burn_sniper_2 = 128,
    burn_sniper_3 = 129,
    burn_sniper_4 = 130,
    burn_sniper_5 = 131,
    burn_sniper_6 = 132,
    burn_sniper_7 = 133,
    ghostflame = 134,
    ghostflame_0 = 135,
    ghostflame_1 = 136,
    ghostflame_2 = 137,
    ghostflame_3 = 138,
    ghostflame_4 = 139,
    ghostflame_5 = 140,
    gravity = 141,
    gravity2 = 142,
    bind = 143,
    teleport = 144,
    teleport2 = 145,
    teleport3 = 146,
    timestop = 147,
    tether = 148,
    tether_permanent = 149,
    heavy = 150,
    heavy2 = 151,
    heavyextra = 152,
    heavyextra2 = 153,
    holyshield = 154,
    tailwind = 155,
    tailwind2 = 156,
    vanishenemy = 157,
    vanishenemy_perm = 158,
    vanishenemy_temp = 159,
    nodefense = 160,
    fieldlimit_0 = 161,
    fieldlimit2_0 = 162,
    fieldlimit_1 = 163,
    fieldlimit2_1 = 164,
    fieldlimit_2 = 165,
    fieldlimit2_2 = 166,
    fieldlimit_3 = 167,
    fieldlimit2_3 = 168,
    fieldlimit_4 = 169,
    fieldlimit2_4 = 170,
    order_0 = 171,
    order_1 = 172,
    order_2 = 173,
    order_3 = 174,
    group_0 = 175,
    group_1 = 176,
    group_2 = 177,
    group_3 = 178,

    pub const buffs = [_]Hbs{
        .none,
        .smite,
        .smite_0,
        .smite_1,
        .smite_2,
        .smite_3,
        .elegy,
        .elegy_0,
        .elegy_1,
        .elegy_2,
        .haste,
        .haste_0,
        .haste_1,
        .haste_2,
        .stoneskin,
        .graniteskin,
        .lucky,
        .super,
        .flutterstep,
        .counter,
        .counter_0,
        .counter_1,
        .counter_2,
        .blackstrike,
        .stillness,
        .repeat,
        .flowstr,
        .flowdex,
        .flowint,
        .flashstr,
        .flashdex,
        .flashint,
        .vanish,
        .ghost,
        .warcry,
        .astra,
        .astra2,
        .nova,
        .berserk,
        .abyssrage,
        .hex_anti,
    };

    pub const hastes = [_]Hbs{
        .haste,
        .haste_0,
        .haste_1,
        .haste_2,
    };

    comptime {
        for (hastes, @intFromEnum(hastes[0])..) |haste, i|
            std.debug.assert(@intFromEnum(haste) == i);
    }

    pub const bleeds = [_]Hbs{
        .bleed,
        .bleed_0,
        .bleed_1,
        .bleed_2,
        .bleed_3,
    };

    comptime {
        for (bleeds, @intFromEnum(bleeds[0])..) |bleed, i|
            std.debug.assert(@intFromEnum(bleed) == i);
    }

    pub const sparks = [_]Hbs{
        .spark,
        .spark_0,
        .spark_1,
        .spark_2,
        .spark_3,
        .spark_4,
        .spark_5,
        .spark_6,
    };

    comptime {
        for (sparks, @intFromEnum(sparks[0])..) |spark, i|
            std.debug.assert(@intFromEnum(spark) == i);
    }

    pub const decays = [_]Hbs{
        .decay,
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
    };

    comptime {
        for (decays, @intFromEnum(decays[0])..) |decay, i|
            std.debug.assert(@intFromEnum(decay) == i);
    }

    pub const burns = [_]Hbs{
        .burn,
        .burn_0,
        .burn_1,
        .burn_2,
        .burn_3,
        .burn_4,
        .burn_5,
        .burn_6,
    };

    comptime {
        for (burns, @intFromEnum(burns[0])..) |burn, i|
            std.debug.assert(@intFromEnum(burn) == i);
    }

    pub const poisons = [_]Hbs{
        .poison,
        .poison_0,
        .poison_1,
        .poison_2,
        .poison_3,
        .poison_4,
        .poison_5,
        .poison_6,
    };

    comptime {
        for (poisons, @intFromEnum(poisons[0])..) |poison, i|
            std.debug.assert(@intFromEnum(poison) == i);
    }

    pub const curses = [_]Hbs{
        .curse,
        .curse_0,
        .curse_1,
        .curse_2,
        .curse_3,
        .curse_4,
        .curse_5,
    };

    comptime {
        for (curses, @intFromEnum(curses[0])..) |curse, i|
            std.debug.assert(@intFromEnum(curse) == i);
    }

    pub const hexes = [_]Hbs{
        .hex,
        .hex_super,
        .hex_poison,
    };

    comptime {
        for (hexes, @intFromEnum(hexes[0])..) |hex, i|
            std.debug.assert(@intFromEnum(hex) == i);
    }

    pub const toCsvString = toString;
    pub const toIniString = toString;

    pub fn toString(hbs: Hbs) []const u8 {
        return switch (hbs) {
            .none => "hbs_none",
            .smite => "hbs_smite",
            .smite_0 => "hbs_smite_0",
            .smite_1 => "hbs_smite_1",
            .smite_2 => "hbs_smite_2",
            .smite_3 => "hbs_smite_3",
            .elegy => "hbs_elegy",
            .elegy_0 => "hbs_elegy_0",
            .elegy_1 => "hbs_elegy_1",
            .elegy_2 => "hbs_elegy_2",
            .haste => "hbs_haste",
            .haste_0 => "hbs_haste_0",
            .haste_1 => "hbs_haste_1",
            .haste_2 => "hbs_haste_2",
            .stoneskin => "hbs_stoneskin",
            .graniteskin => "hbs_graniteskin",
            .lucky => "hbs_lucky",
            .super => "hbs_super",
            .flutterstep => "hbs_flutterstep",
            .counter => "hbs_counter",
            .counter_0 => "hbs_counter_0",
            .counter_1 => "hbs_counter_1",
            .counter_2 => "hbs_counter_2",
            .blackstrike => "hbs_blackstrike",
            .stillness => "hbs_stillness",
            .repeat => "hbs_repeat",
            .flowstr => "hbs_flowstr",
            .flowdex => "hbs_flowdex",
            .flowint => "hbs_flowint",
            .flashstr => "hbs_flashstr",
            .flashdex => "hbs_flashdex",
            .flashint => "hbs_flashint",
            .vanish => "hbs_vanish",
            .ghost => "hbs_ghost",
            .warcry => "hbs_warcry",
            .astra => "hbs_astra",
            .astra2 => "hbs_astra2",
            .nova => "hbs_nova",
            .berserk => "hbs_berserk",
            .abyssrage => "hbs_abyssrage",
            .snare => "hbs_snare",
            .snare_0 => "hbs_snare_0",
            .snare_1 => "hbs_snare_1",
            .snare_2 => "hbs_snare_2",
            .snare_3 => "hbs_snare_3",
            .snare_4 => "hbs_snare_4",
            .snare_5 => "hbs_snare_5",
            .snare_6 => "hbs_snare_6",
            .snare_7 => "hbs_snare_7",
            .snare2 => "hbs_snare2",
            .snare2_0 => "hbs_snare2_0",
            .snare2_1 => "hbs_snare2_1",
            .snare2_2 => "hbs_snare2_2",
            .snare2_3 => "hbs_snare2_3",
            .snare2_4 => "hbs_snare2_4",
            .snare2_5 => "hbs_snare2_5",
            .snare2_6 => "hbs_snare2_6",
            .snare2_7 => "hbs_snare2_7",
            .hex => "hbs_hex",
            .hex_super => "hbs_hex_super",
            .hex_poison => "hbs_hex_poison",
            .hex_anti => "hbs_hex_anti",
            .curse => "hbs_curse",
            .curse_0 => "hbs_curse_0",
            .curse_1 => "hbs_curse_1",
            .curse_2 => "hbs_curse_2",
            .curse_3 => "hbs_curse_3",
            .curse_4 => "hbs_curse_4",
            .curse_5 => "hbs_curse_5",
            .bleed => "hbs_bleed",
            .bleed_0 => "hbs_bleed_0",
            .bleed_1 => "hbs_bleed_1",
            .bleed_2 => "hbs_bleed_2",
            .bleed_3 => "hbs_bleed_3",
            .sap => "hbs_sap",
            .spark => "hbs_spark",
            .spark_0 => "hbs_spark_0",
            .spark_1 => "hbs_spark_1",
            .spark_2 => "hbs_spark_2",
            .spark_3 => "hbs_spark_3",
            .spark_4 => "hbs_spark_4",
            .spark_5 => "hbs_spark_5",
            .spark_6 => "hbs_spark_6",
            .decay => "hbs_decay",
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
            .poison => "hbs_poison",
            .poison_0 => "hbs_poison_0",
            .poison_1 => "hbs_poison_1",
            .poison_2 => "hbs_poison_2",
            .poison_3 => "hbs_poison_3",
            .poison_4 => "hbs_poison_4",
            .poison_5 => "hbs_poison_5",
            .poison_6 => "hbs_poison_6",
            .burn => "hbs_burn",
            .burn_0 => "hbs_burn_0",
            .burn_1 => "hbs_burn_1",
            .burn_2 => "hbs_burn_2",
            .burn_3 => "hbs_burn_3",
            .burn_4 => "hbs_burn_4",
            .burn_5 => "hbs_burn_5",
            .burn_6 => "hbs_burn_6",
            .burn_assassin_0 => "hbs_burn_assassin_0",
            .burn_assassin_1 => "hbs_burn_assassin_1",
            .burn_assassin_2 => "hbs_burn_assassin_2",
            .burn_assassin_3 => "hbs_burn_assassin_3",
            .burn_assassin_4 => "hbs_burn_assassin_4",
            .burn_assassin_5 => "hbs_burn_assassin_5",
            .burn_assassin_6 => "hbs_burn_assassin_6",
            .burn_assassin_7 => "hbs_burn_assassin_7",
            .burn_dancer_0 => "hbs_burn_dancer_0",
            .burn_dancer_1 => "hbs_burn_dancer_1",
            .burn_dancer_2 => "hbs_burn_dancer_2",
            .burn_dancer_3 => "hbs_burn_dancer_3",
            .burn_dancer_4 => "hbs_burn_dancer_4",
            .burn_dancer_5 => "hbs_burn_dancer_5",
            .burn_dancer_6 => "hbs_burn_dancer_6",
            .burn_dancer_7 => "hbs_burn_dancer_7",
            .burn_sniper_0 => "hbs_burn_sniper_0",
            .burn_sniper_1 => "hbs_burn_sniper_1",
            .burn_sniper_2 => "hbs_burn_sniper_2",
            .burn_sniper_3 => "hbs_burn_sniper_3",
            .burn_sniper_4 => "hbs_burn_sniper_4",
            .burn_sniper_5 => "hbs_burn_sniper_5",
            .burn_sniper_6 => "hbs_burn_sniper_6",
            .burn_sniper_7 => "hbs_burn_sniper_7",
            .ghostflame => "hbs_ghostflame",
            .ghostflame_0 => "hbs_ghostflame_0",
            .ghostflame_1 => "hbs_ghostflame_1",
            .ghostflame_2 => "hbs_ghostflame_2",
            .ghostflame_3 => "hbs_ghostflame_3",
            .ghostflame_4 => "hbs_ghostflame_4",
            .ghostflame_5 => "hbs_ghostflame_5",
            .gravity => "hbs_gravity",
            .gravity2 => "hbs_gravity2",
            .bind => "hbs_bind",
            .teleport => "hbs_teleport",
            .teleport2 => "hbs_teleport2",
            .teleport3 => "hbs_teleport3",
            .timestop => "hbs_timestop",
            .tether => "hbs_tether",
            .tether_permanent => "hbs_tether_permanent",
            .heavy => "hbs_heavy",
            .heavy2 => "hbs_heavy2",
            .heavyextra => "hbs_heavyextra",
            .heavyextra2 => "hbs_heavyextra2",
            .holyshield => "hbs_holyshield",
            .tailwind => "hbs_tailwind",
            .tailwind2 => "hbs_tailwind2",
            .vanishenemy => "hbs_vanishenemy",
            .vanishenemy_perm => "hbs_vanishenemy_perm",
            .vanishenemy_temp => "hbs_vanishenemy_temp",
            .nodefense => "hbs_nodefense",
            .fieldlimit_0 => "hbs_fieldlimit_0",
            .fieldlimit2_0 => "hbs_fieldlimit2_0",
            .fieldlimit_1 => "hbs_fieldlimit_1",
            .fieldlimit2_1 => "hbs_fieldlimit2_1",
            .fieldlimit_2 => "hbs_fieldlimit_2",
            .fieldlimit2_2 => "hbs_fieldlimit2_2",
            .fieldlimit_3 => "hbs_fieldlimit_3",
            .fieldlimit2_3 => "hbs_fieldlimit2_3",
            .fieldlimit_4 => "hbs_fieldlimit_4",
            .fieldlimit2_4 => "hbs_fieldlimit2_4",
            .order_0 => "hbs_order_0",
            .order_1 => "hbs_order_1",
            .order_2 => "hbs_order_2",
            .order_3 => "hbs_order_3",
            .group_0 => "hbs_group_0",
            .group_1 => "hbs_group_1",
            .group_2 => "hbs_group_2",
            .group_3 => "hbs_group_3",
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

pub const Difficulty = enum {
    cute,
    normal,
    hard,
    lunar,

    pub fn toCsvString(difficulty: Difficulty) []const u8 {
        return switch (difficulty) {
            .cute => "difficulty.cute",
            .normal => "difficulty.normal",
            .hard => "difficulty.hard",
            .lunar => "difficulty.lunar",
        };
    }
};

pub const Stage = enum {
    @"test",
    outskirts,
    nest,
    arsenal,
    lighthouse,
    streets,
    lakeside,
    keep,
    pinnacle,

    pub fn toCsvString(difficulty: Difficulty) []const u8 {
        return switch (difficulty) {
            .@"test" => "stage.test",
            .outskirts => "stage.outskirts",
            .nest => "stage.nest",
            .arsenal => "stage.arsenal",
            .lighthouse => "stage.lighthouse",
            .streets => "stage.streets",
            .lakeside => "stage.lakeside",
            .keep => "stage.keep",
            .pinnacle => "stage.pinnacle",
        };
    }
};

pub const GoldSource = enum {
    battleRewards,
    store,
    loot,
    debug,

    pub fn toCsvString(difficulty: Difficulty) []const u8 {
        return switch (difficulty) {
            .battleRewards => "goldSource.battleRewards",
            .store => "goldSource.store",
            .loot => "goldSource.loot",
            .debug => "goldSource.debug",
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

        /// The damage flags of the attack that hit (see tset_damage_flags)
        damageFlags,

        /// The team ID of the damaged player
        dmgTeamId,

        /// The player ID of the damaged player
        dmgPlayerId,

        /// The amount of damage dealt
        amount,

        /// True if it's a crit
        isCrit,

        /// A saved number on this trinket that can be used for various things. For instance, the
        /// Floof Ball is 'perfect' while its counter is 0; and its counter increments when you're
        /// hit, changing it to a ruffled Floof Ball
        counter,

        /// The length of invuln, in milliseconds
        invulnTime,

        /// The "tick" count since the start of the last battle
        tickNum,

        /// a binary number specifying which players started attacking; to be used with tcond_hb_auto_pl
        autoBinary,

        /// Square ID of the item that was picked up (a "Square" is a specific instance of an item, held by one player)
        sqId,

        /// The data ID of the Square (the ID matching to a particular kind of item, like "Necronomicon")
        dtId,

        /// The level that was reached
        level,

        changeAmount,
        newAmount,
        sourceType,
        sourceHb,

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
                .damageFlags => prefix ++ "damageFlags",
                .dmgTeamId => prefix ++ "dmgTeamId",
                .dmgPlayerId => prefix ++ "dmgPlayerId",
                .amount => prefix ++ "amount",
                .isCrit => prefix ++ "isCrit",
                .counter => prefix ++ "counter",
                .invulnTime => prefix ++ "invulnTime",
                .tickNum => prefix ++ "tickNum",
                .autoBinary => prefix ++ "autoBinary",
                .sqId => prefix ++ "sqId",
                .dtId => prefix ++ "dtId",
                .level => prefix ++ "level",
                .changeAmount => prefix ++ "changeAmount",
                .newAmount => prefix ++ "newAmount",
                .sourceType => prefix ++ "sourceType",
                .sourceHb => prefix ++ "sourceHb",
            };
        }
    };
}

pub const s = TriggerVariable("s_");
pub const r = TriggerVariable("r_");
pub const tps = TriggerVariable("tp#_");
pub const tp0 = TriggerVariable("tp0_");
pub const tp1 = TriggerVariable("tp1_");
pub const tp2 = TriggerVariable("tp2_");
pub const tp3 = TriggerVariable("tp3_");
pub const thss = TriggerVariable("ths#_");
pub const ths0 = TriggerVariable("ths0_");
pub const ths1 = TriggerVariable("ths1_");
pub const ths2 = TriggerVariable("ths2_");
pub const ths3 = TriggerVariable("ths3_");
pub const thbss = TriggerVariable("thbs#_");
pub const thbs0 = TriggerVariable("thbs0_");
pub const thbs1 = TriggerVariable("thbs1_");
pub const thbs2 = TriggerVariable("thbs2_");
pub const thbs3 = TriggerVariable("thbs3_");

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

/// 1  HTB_FLAG_STEALTHY     - Using item doesn't break Vanish/Ghost
/// 2  HTB_FLAG_UNRESETTABLE - Cooldown can't be reset by other loot effects
/// 4  HTB_FLAG_HIDEHBS      - Hides Status Effect description on the item's description
/// 8  HTB_FLAG_UNCHARGEABLE - For abilities that can't be charged by other abilities or
///                            loot
/// 16 HTB_FLAG_COMBATREQ    - For abilities that can't be used outside combat
/// 32 HTB_FLAG_VAR0REQ      - Item will not activate unless sqVar0 is greater than 0
///                            (like for items that break)
/// 64 HTB_FLAG_HIDESTR      - Item's strength won't be shown in the window
pub const HbFlag = packed struct(u8) {
    stealthy: bool = false,
    unresettable: bool = false,
    hidehbs: bool = false,
    unchargeable: bool = false,
    combatreq: bool = false,
    var0req: bool = false,
    hidestr: bool = false,
    __pad: bool = false,

    pub fn toIniInt(flags: HbFlag) u8 {
        return @bitCast(flags);
    }
};

comptime {
    std.debug.assert((HbFlag{ .stealthy = true }).toIniInt() == 1);
    std.debug.assert((HbFlag{ .unresettable = true }).toIniInt() == 2);
    std.debug.assert((HbFlag{ .hidehbs = true }).toIniInt() == 4);
    std.debug.assert((HbFlag{ .unchargeable = true }).toIniInt() == 8);
    std.debug.assert((HbFlag{ .combatreq = true }).toIniInt() == 16);
    std.debug.assert((HbFlag{ .var0req = true }).toIniInt() == 32);
    std.debug.assert((HbFlag{ .hidestr = true }).toIniInt() == 64);
}

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
/// 32768 HBS_FLAG_EXTRADEADZONE - Adds an extra deadzone to people playing with the mouse (for Turbulent Winds)
pub const HbsFlag = packed struct(u16) {
    vanish: bool = false,
    shield: bool = false,
    frozen: bool = false,
    stablespeed: bool = false,
    bind: bool = false,
    super: bool = false,
    fade: bool = false,
    nolucky: bool = false,
    stabledamage: bool = false,
    holyshield: bool = false,
    noinvuln: bool = false,
    stilldisplay: bool = false,
    nocrit: bool = false,
    extracrit: bool = false,
    superlucky: bool = false,
    extradeadzone: bool = false,

    pub fn toIniInt(flags: HbsFlag) u16 {
        return @bitCast(flags);
    }
};

comptime {
    std.debug.assert((HbsFlag{ .vanish = true }).toIniInt() == 1);
    std.debug.assert((HbsFlag{ .shield = true }).toIniInt() == 2);
    std.debug.assert((HbsFlag{ .frozen = true }).toIniInt() == 4);
    std.debug.assert((HbsFlag{ .stablespeed = true }).toIniInt() == 8);
    std.debug.assert((HbsFlag{ .bind = true }).toIniInt() == 16);
    std.debug.assert((HbsFlag{ .super = true }).toIniInt() == 32);
    std.debug.assert((HbsFlag{ .fade = true }).toIniInt() == 64);
    std.debug.assert((HbsFlag{ .nolucky = true }).toIniInt() == 128);
    std.debug.assert((HbsFlag{ .stabledamage = true }).toIniInt() == 256);
    std.debug.assert((HbsFlag{ .holyshield = true }).toIniInt() == 512);
    std.debug.assert((HbsFlag{ .noinvuln = true }).toIniInt() == 1024);
    std.debug.assert((HbsFlag{ .stilldisplay = true }).toIniInt() == 2048);
    std.debug.assert((HbsFlag{ .nocrit = true }).toIniInt() == 4096);
    std.debug.assert((HbsFlag{ .extracrit = true }).toIniInt() == 8192);
    std.debug.assert((HbsFlag{ .superlucky = true }).toIniInt() == 16384);
    std.debug.assert((HbsFlag{ .extradeadzone = true }).toIniInt() == 32768);
}

const std = @import("std");
