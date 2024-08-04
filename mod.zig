var total_items: usize = 0;
var written_items: usize = 0;
var first_trigger: bool = true;
var sheetlist_buf: std.io.BufferedWriter(4096, std.fs.File.Writer) = undefined;
var item_csv_buf: std.io.BufferedWriter(4096, std.fs.File.Writer) = undefined;
var item_ini_buf: std.io.BufferedWriter(4096, std.fs.File.Writer) = undefined;
var item_names_buf: std.io.BufferedWriter(4096, std.fs.File.Writer) = undefined;
var item_descriptions_buf: std.io.BufferedWriter(4096, std.fs.File.Writer) = undefined;
var sheetlist: std.io.BufferedWriter(4096, std.fs.File.Writer).Writer = undefined;
var item_csv: std.io.BufferedWriter(4096, std.fs.File.Writer).Writer = undefined;
var item_ini: std.io.BufferedWriter(4096, std.fs.File.Writer).Writer = undefined;
var item_names: std.io.BufferedWriter(4096, std.fs.File.Writer).Writer = undefined;
var item_descriptions: std.io.BufferedWriter(4096, std.fs.File.Writer).Writer = undefined;

pub fn start(amount: usize) void {
    start2(amount) catch |err| @panic(@errorName(err));
}

fn start2(amount: usize) !void {
    const cwd = std.fs.cwd();
    sheetlist_buf = std.io.bufferedWriter(
        (try cwd.createFile("SheetList.csv", .{})).writer(),
    );
    item_csv_buf = std.io.bufferedWriter(
        (try cwd.createFile("Items.csv", .{})).writer(),
    );
    item_ini_buf = std.io.bufferedWriter(
        (try cwd.createFile("Items.ini", .{})).writer(),
    );
    item_names_buf = std.io.bufferedWriter(
        (try cwd.createFile("Items_Names.csv", .{})).writer(),
    );
    item_descriptions_buf = std.io.bufferedWriter(
        (try cwd.createFile("Items_Descriptions.csv", .{})).writer(),
    );
    sheetlist = sheetlist_buf.writer();
    item_csv = item_csv_buf.writer();
    item_ini = item_ini_buf.writer();
    item_names = item_names_buf.writer();
    item_descriptions = item_descriptions_buf.writer();

    var path_buf: [std.fs.max_path_bytes]u8 = undefined;
    const path = try cwd.realpath(".", &path_buf);
    const name = std.fs.path.basename(path);

    try sheetlist.print(
        \\Sheet Type,filename
        \\NameSheet,Mods/{[name]s}/Items_Names
        \\DescriptionSheet,Mods/{[name]s}/items_Descriptions
        \\ItemSheet,Mods/{[name]s}/Items
        \\
    ,
        .{ .name = name },
    );

    try item_names.writeAll(
        \\key,level,English,Japanese,Chinese
        \\,,,,
        \\
    );
    try item_descriptions.writeAll(
        \\key,level,English,Japanese,Chinese
        \\,,,,
        \\
    );
    try item_csv.print(
        \\spriteNumber,{},,,,
        \\,,,,,
        \\
    ,
        .{amount},
    );

    total_items = amount;
    written_items = 0;
}

pub fn end() void {
    flush() catch |err| @panic(@errorName(err));
    close();
    std.debug.assert(written_items == total_items);
}

fn flush() !void {
    const res1 = sheetlist.context.flush();
    const res2 = item_csv.context.flush();
    const res3 = item_ini.context.flush();
    const res4 = item_names.context.flush();
    const res5 = item_descriptions.context.flush();
    try res1;
    try res2;
    try res3;
    try res4;
    try res5;
}

fn close() void {
    sheetlist.context.unbuffered_writer.context.close();
    item_csv.context.unbuffered_writer.context.close();
    item_ini.context.unbuffered_writer.context.close();
    item_names.context.unbuffered_writer.context.close();
    item_descriptions.context.unbuffered_writer.context.close();
}

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
    color: ?[]const u8 = null,

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

    weaponType: ?enum {
        none, // - No type
        primary, // - Primary
        secondary, // - Secondary
        special, // - Special
        defensive, // - Defensive
        loot, // - Loot
        potion, // - Potion
    } = null,

    /// The amount of damage this item does
    strMult: ?u16 = null,

    /// The number of times this item does damage (Must use an attack pattern that can deal
    /// damage multiple times)
    hitNumber: ?u16 = null,

    /// The key for the Status Effect this item applies.  For instance, if an item applies
    /// Curse, "hbs_curse_0"
    hbsType: ?[]const u8 = null,

    /// The amount of damage that the Status Effect does.
    /// For poison, it will deal this damage every tick, for ghostflame, the amount of
    /// damage each hit does, etc..
    hbsStrMult: ?u16 = null,

    /// The default length of the Status Effect, in milliseconds.
    hbsLength: ?u16 = null,

    /// Only used for the item description, will add a text blurb explaining a certain kind of
    /// "Charge".
    chargeType: ?enum {
        charge,
        supercharge,
        ultracharge,
        omegacharge,
        darkspell,
    } = null,

    /// The default chance of an item's random effect activating.
    /// Any decimal number 0 through 1:
    /// 0.2 : Item will activate 20% of the time
    /// 0.7 : Item will activate 70% of the time
    /// 0.85 : Item will activate 85% of the time
    /// etc.."
    procChance: ?f64 = null,

    /// Affects the color of attack patterns produced by this item. Would recommend making
    /// this a slightly dark color
    hbColor0: ?[]const u8 = null,

    /// Affects the color of attack patterns produced by this item. Would recommend making
    /// this a slightly bright/saturated color
    hbColor1: ?[]const u8 = null,

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
    cdp: ?u32 = null,

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

    /// Makes your character START with more gold. This is only used in toybox mode to make
    /// Silver Coin work there. It won't affect anything mid-run.
    startingGold: ?u32 = null,

    /// Makes your character move faster or slower. Any number -99 to 99 (but should probably
    /// be kept in the -5 to 5 range)
    charspeed: ?f64 = null,

    /// Makes your character's hitbox larger or smaller. Used on Sunflower Crown and Evasion
    /// Potion, which have -10 each. Any number -2000 to 2000 (but should probably be kept in
    /// the -25 to 25 range)
    charradius: ?f64 = null,

    /// Make invulnerability effects last longer (or shorter) by a flat amount, in
    /// milliseconds. Any number -15000 to 15000 (but should probably be kept in the -3000 to
    /// 3000 range).  Note that invulnerability effects have a hard cap of 7.5 seconds, no
    /// matter what stats you have
    invulnPlus: ?f64 = null,

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
    /// 1  HBSHINE_PRIMARY   - Makes Primary shine
    /// 2  HBSHINE_SECONDARY - Makes Secondary shine
    /// 4  HBSHINE_SPECIAL   - Makes Special shine
    /// 8  HBSHINE_DEFENSIVE - Makes Defensive shine
    /// 16 HBCROSS_PRIMARY   - Makes Primary unusable
    /// 16 HBCROSS_SECONDARY - Makes Secondary unusable
    /// 16 HBCROSS_SPECIAL   - Makes Special unusable
    /// 16 HBCROSS_DEFENSIVE - Makes Defensive unusable
    hbShineFlag: ?u8 = null,
};

pub fn item(opt: Item) void {
    item2(opt) catch |err| @panic(@errorName(err));
}

fn item2(opt: Item) !void {
    try item_names.print("{s},0,\"{s}\",\"{s}\",\"{s}\"\n", .{
        opt.id,
        opt.name.english,
        opt.name.japanese orelse opt.name.english,
        opt.name.chinese orelse opt.name.english,
    });
    try item_descriptions.print("{s},0,\"{s}\",\"{s}\",\"{s}\"\n", .{
        opt.id,
        opt.description.english,
        opt.description.japanese orelse opt.description.english,
        opt.description.chinese orelse opt.description.english,
    });

    try item_ini.print("[{s}]\n", .{opt.id});
    inline for (@typeInfo(@TypeOf(opt)).Struct.fields) |field| continue_blk: {
        if (comptime std.mem.eql(u8, field.name, "id"))
            break :continue_blk;
        if (comptime std.mem.eql(u8, field.name, "name"))
            break :continue_blk;
        if (comptime std.mem.eql(u8, field.name, "description"))
            break :continue_blk;
        if (comptime std.mem.eql(u8, field.name, "script"))
            break :continue_blk;

        if (@field(opt, field.name)) |value| switch (@TypeOf(value)) {
            bool => try item_ini.print("{s}=\"{d}\"\n", .{ field.name, @intFromBool(value) }),
            i8, u8, u16, u32, f64 => try item_ini.print("{s}=\"{d}\"\n", .{ field.name, value }),
            []const u8 => try item_ini.print("{s}=\"{s}\"\n", .{ field.name, value }),
            else => try item_ini.print("{s}=\"{s}\"\n", .{ field.name, @tagName(value) }),
        };
    }

    if (written_items != 0) {
        try item_csv.writeAll(
            \\,,,,,
            \\,,,,,
            \\
        );
    }

    try item_csv.print(
        \\{s},{},,,,
        \\,,,,,
        \\
    ,
        .{ opt.id, written_items },
    );

    written_items += 1;
    first_trigger = true;
}

/// When certain things in the game happen (everything from you gaining gold, to using an ability,
/// to starting a run, to a % chance succeeding), a "Trigger" is called. You can make your items
/// react to these Triggers, to do the things they're supposed to do.
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

    /// "Happens when a player starts attacking, or when a combat encounter starts.
    /// You most likely want to use this instead of ""battleStart"".
    /// ""battleStart"" won't activate outside of combat with an enemy, while this will work even if a player begins attacking a Training Dummy or Treasuresphere" Tidal Greatsword, Golem's Claymore, every item that starts on cooldown tbh Loot/Abilities that "start on cooldown" should have an autoStart trigger that runs the cooldown
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
};

const TriggerOpt = struct { ?Condition = null };

pub fn trigger(trig: Trigger, opt: TriggerOpt) void {
    trigger2(trig, opt) catch |err| @panic(@errorName(err));
}

fn trigger2(trig: Trigger, opt: TriggerOpt) !void {
    if (!first_trigger)
        try item_csv.writeAll(",,,,,\n");

    try item_csv.print("trigger,{s},{s},,,\n", .{
        @tagName(trig),
        if (opt[0]) |cond| @tagName(cond) else "",
    });
    first_trigger = false;
}

pub const Condition = enum {
    /// Always returns false
    tcond_none,

    /// flag0 (an integer representing a binary number)
    /// flag1 (an integer representing a binary number)
    /// Returns true if the binary "&" between these two integers is greater than 0
    tcond_check_flag,

    /// flag0 (an integer representing a binary number)
    /// flag1 (an integer representing a binary number)
    /// Returns true if the binary "&" between these two integers is 0
    tcond_check_no_flag,

    /// Exclusively used for "onDamageDone" trigger;
    /// returns true if damage amount is large enough to get the special flashy text
    tcond_dmg_islarge,

    /// Exclusively used for "onDamageDone" trigger;
    /// returns true if the damage done was caused by your Defensive
    tcond_dmg_self_defensive,

    /// Exclusively used for "onDamageDone" trigger;
    /// returns true if the damage done was caused by your Primary
    tcond_dmg_self_primary,

    /// Exclusively used for "onDamageDone" trigger;
    /// returns true if the damage done was caused by your Secondary
    tcond_dmg_self_secondary,

    /// Exclusively used for "onDamageDone" trigger;
    /// returns true if the damage done was caused by your Special
    tcond_dmg_self_special,

    /// Exclusively used for "onDamageDone" trigger;
    /// returns true if the damage done was caused by this item
    tcond_dmg_self_thishb,

    /// value0 (any number)
    /// value1 (any number)
    /// Returns true if the values are equal
    tcond_equal,

    /// value0 (any number)
    /// value1 (any number)
    /// Returns true if the values are unequal
    tcond_unequal,

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
    tcond_eval,

    /// bool0 (a boolean)
    /// Returns true if the boolean is false
    tcond_false,

    /// bool0 (a boolean)
    /// Returns true if the boolean is true
    tcond_true,

    /// Exclusively for use with "autoStart" trigger.
    /// Returns true if YOUR player was the one that started attacking.
    tcond_hb_auto_pl,

    /// Returns true if this item is off cooldown and available to use.
    tcond_hb_available,

    /// varIndex (a number 0-3)
    /// amount (any number)
    /// Checks to see if the item's sqVar is equal to a number.
    tcond_hb_check_square_var,

    /// varIndex (a number 0-3)
    /// amount (any number)
    /// Checks to see if the item's sqVar is NOT equal to a number.
    tcond_hb_check_square_var_false,

    /// varIndex (a number 0-3)
    /// amount (any number)
    /// Checks to see if the item's sqVar is greater than or equal to a number.
    tcond_hb_check_square_var_gte,

    /// varIndex (a number 0-3)
    /// amount (any number)
    /// Checks to see if the item's sqVar is less than or equal to a number.
    tcond_hb_check_square_var_lte,

    /// Exclusively for use with "hotbarUsed" "hotbarUsedProc" "hotbarUsed2" etc..
    /// Returns true if the hotbar used was your own player's Primary.
    tcond_hb_primary,

    /// Exclusively for use with "hotbarUsed" "hotbarUsedProc" "hotbarUsed2" etc..
    /// Returns true if the hotbar used was your own player's Secondary.
    tcond_hb_secondary,

    /// Exclusively for use with "hotbarUsed" "hotbarUsedProc" "hotbarUsed2" etc..
    /// Returns true if the hotbar used was your own player's Special.
    tcond_hb_special,

    /// Exclusively for use with "hotbarUsed" "hotbarUsedProc" "hotbarUsed2" etc..
    /// Returns true if the hotbar used was your own player's Defensive.
    tcond_hb_defensive,

    /// Exclusively for use with "hotbarUsed" "hotbarUsedProc" "hotbarUsed2" etc..
    /// Returns true if the hotbar used was your own player's loot.
    tcond_hb_loot,

    /// Returns true if the hotbar calling the trigger is different than the hotbar receiving this
    /// trigger
    tcond_hb_not_self,

    /// Returns true if the hotbar calling the trigger is the same as the hotbar receiving this
    /// trigger
    tcond_hb_self,

    /// Returns true if the hotbar calling the trigger is an Attack (aka Primary, Secondary or
    /// Special), and used by your player
    tcond_hb_self_attack,

    /// Returns true if the hotbar calling the trigger is an Ability (including Defensive) used by
    /// your player
    tcond_hb_self_weapon,

    /// Returns true if the hotbar calling the trigger was used by your player
    tcond_hb_selfcast,

    /// Returns true if the hotbar calling the trigger was used by anyone on your team
    tcond_hb_team,

    /// Returns true if the hotbar calling the triggers is a "weapon" item type
    tcond_hb_type_weapon,

    /// For use from status effects, checks if the hotbar just used was from the player afflicted
    /// with this status
    tcond_hbs_aflplayer,

    /// For use from status effects, checks if the hotbar just used was from the player afflicted
    /// with this status, and that the hotbar was an Attack (not Defensive or Loot)
    tcond_hbs_aflplayer_attack,

    /// For use from status effects, checks if a status effect calling a trigger is the same as
    /// this status effect
    tcond_hbs_self,

    /// Exclusively for use with "hbsCreated".
    /// Returns true if the Status Effect that called the trigger was created by this hotbar.
    tcond_hbs_thishbcast,
    /// Exclusively for use with "hbsCreated".
    /// Returns true if the Status Effect that called the trigger was not created by this hotbar.
    tcond_hbs_not_thishbcast,
    /// Exclusively for use with "hbsCreated".
    /// Returns true if the Status Effect that called the trigger was placed ON this player.
    tcond_hbs_selfafl,
    /// "Exclusively for use with "hbsCreated".
    /// Returns true if the Status Effect that called the trigger was placed BY this player.
    tcond_hbs_selfcast,

    /// Returns true if the TARGETED hotbars are chargeable (not the item this trigger belongs to)
    tcond_hb_check_chargeable0,

    /// Returns true if the TARGETED hotbars are resettable (not the item this trigger belongs to)
    /// IMPORTANT: This should always be checked before you reset a cooldown.
    tcond_hb_check_resettable0,

    /// amount (any number)
    /// Returns true if the player receiving this trigger is missing at least "amount" health
    tcond_missing_health,
    /// Checks if the current player is currently attacking or in battle (currently only used for
    /// Ancient Emerald Defensive)
    tcond_pl_autocheck,
    /// Checks if trigger is coming from this player (or one of their hotbars)
    tcond_pl_self,

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
    tcond_player_target_count,

    /// percentChance (a number between 0 and 1)
    /// Will return true percentChance% of the time. Number should be between 0 and 1, with 0
    /// being a 0% chance and 1 being a 100% chance. If the player has a luck-increasing item,
    /// this percent chance will be that more likely to happen.
    tcond_random,

    /// Will return true based on the item's procChance (in Stats, the hitbox variable). If the
    /// player has a luck-increasing item, this percent chance will be that more likely to happen.
    tcond_random_def,

    /// Exclusively for use with "onSquarePickup".
    /// Checks to see if this is the item that was picked up.
    tcond_square_self,

    /// amount (an integer)
    /// Exclusively for use with "regenTick". Returns true every nth tick.
    tcond_tick_every,

    /// amount (an integer)
    /// For use with trinkets; checks if the Trinket's internal counter is equal to this number.
    tcond_trinket_counter_equal,

    /// amount (an integer)
    /// For use with trinkets; checks if the Trinket's internal counter is greater than or equal
    /// to this number.
    tcond_trinket_counter_greaterequal,

    /// bocInd (an integer representing Book of Cheat's RNG number) Don't use this
    tcond_bookofcheats_varcheck,
};

pub fn condition(cond: Condition, args: anytype) void {
    condition2(cond, args) catch |err| @panic(@errorName(err));
}

fn condition2(cond: Condition, args: anytype) !void {
    try item_csv.print("condition,{s}", .{@tagName(cond)});
    try writeArgs(args);
}

pub const QuickPattern = enum {
    tpat_add_gold,
    tpat_bookofcheats_set_random,
    tpat_debug_targets,
    tpat_hb_add_cooldown,
    tpat_hb_add_cooldown_permanent,
    tpat_hb_add_flag,
    tpat_hb_add_gcd_permanent,
    tpat_hb_add_hitbox_var,
    tpat_hb_add_statchange,
    tpat_hb_add_statchange_norefresh,
    tpat_hb_add_strcalcbuff,
    tpat_hb_add_strength,
    tpat_hb_add_strength_hbs,
    tpat_hb_cdloot_proc,
    tpat_hb_charge,
    tpat_hb_charge_clear,
    tpat_hb_flash_item,
    tpat_hb_flash_item_source,
    tpat_hb_hbuse_proc,
    tpat_hb_inc_var,
    tpat_hb_increase_stock,
    tpat_hb_lucky_proc,
    tpat_hb_lucky_proc_source,
    tpat_hb_mult_gcd_permanent,
    tpat_hb_mult_hitbox_var,
    tpat_hb_mult_length_hbs,
    tpat_hb_mult_strength,
    tpat_hb_mult_strength_hbs,
    tpat_hb_recalc_color,
    tpat_hb_reduce_stock,
    tpat_hb_reset_cooldown,
    tpat_hb_reset_statchange,
    tpat_hb_reset_statchange_norefresh,
    tpat_hb_run_cooldown,
    tpat_hb_run_cooldown_ext,
    tpat_hb_run_cooldown_hidden,
    tpat_hb_set_color_def,
    tpat_hb_set_cooldown_permanent,
    tpat_hb_set_gcd_permanent,
    tpat_hb_set_stock,
    tpat_hb_set_strength,
    tpat_hb_set_strength_cd,
    tpat_hb_set_strength_darkglass_spear,
    tpat_hb_set_strength_gcd,
    tpat_hb_set_strength_obsidian_rod,
    tpat_hb_set_strength_timespace_dagger,
    tpat_hb_set_tidalgreatsword,
    tpat_hb_set_tidalgreatsword_start,
    tpat_hb_set_var,
    tpat_hb_set_var_random_range,
    tpat_hb_square_add_var,
    tpat_hb_square_set_var,
    tpat_hb_zero_stock,
    tpat_hbs_add_hbsflag,
    tpat_hbs_add_shineflag,
    tpat_hbs_add_statchange,
    tpat_hbs_add_statchange_bleed,
    tpat_hbs_add_statchange_sap,
    tpat_hbs_destroy,
    tpat_hbs_mult_str,
    tpat_hbs_reset_statchange,
    tpat_nothing,
    tpat_player_add_radius,
    tpat_player_add_stat,
    tpat_player_change_color_rand,
    tpat_player_distcounter_reset,
    tpat_player_movelock,
    tpat_player_movemult,
    tpat_player_run_gcd,
    tpat_player_set_radius,
    tpat_player_set_stat,
    tpat_player_shield,
    tpat_player_shield_hbs,
    tpat_player_trinket_counter_add,
    tpat_player_trinket_counter_add_bounded,
    tpat_player_trinket_counter_randomize,
    tpat_player_trinket_counter_set,
    tpat_player_trinket_flash,
};

pub fn quickPattern(pat: QuickPattern, args: anytype) void {
    quickPattern2(pat, args) catch |err| @panic(@errorName(err));
}

fn quickPattern2(pat: QuickPattern, args: anytype) !void {
    try item_csv.print("quickPattern,{s}", .{@tagName(pat)});
    try writeArgs(args);
}

pub const AddPattern = enum {
    hpat_bleed,
    hpat_burn,
    hpat_curse,
    hpat_poison,
    hpat_spark,
    ipat_ancient_0,
    ipat_ancient_0_petonly,
    ipat_ancient_0_pt2,
    ipat_ancient_0_rabbitonly,
    ipat_ancient_1,
    ipat_ancient_1_auto,
    ipat_ancient_1_pt2,
    ipat_ancient_2,
    ipat_ancient_2_auto,
    ipat_ancient_2_pt2,
    ipat_ancient_3,
    ipat_ancient_3_emerald,
    ipat_ancient_3_emerald_pt2,
    ipat_ancient_3_emerald_pt3,
    ipat_apply_hbs,
    ipat_apply_hbs_starflash,
    ipat_apply_invuln,
    ipat_starflash_hbs,
    ipat_assassin_0,
    ipat_assassin_0_ruby,
    ipat_assassin_1,
    ipat_assassin_1_garnet,
    ipat_assassin_1_ruby,
    ipat_assassin_1_sapphire,
    ipat_assassin_2,
    ipat_assassin_2_opal,
    ipat_assassin_3,
    ipat_assassin_3_opal,
    ipat_assassin_3_ruby,
    ipat_black_wakizashi,
    ipat_blackhole_charm,
    ipat_blue_rose,
    ipat_bruiser_0,
    ipat_bruiser_0_saph,
    ipat_bruiser_1,
    ipat_bruiser_2,
    ipat_bruiser_3,
    ipat_bruiser_3_pt2,
    ipat_bruiser_3_ruby,
    ipat_butterly_ocarina,
    ipat_crown_of_storms,
    ipat_curse_talon,
    ipat_dancer_0,
    ipat_dancer_0_opal,
    ipat_dancer_1,
    ipat_dancer_1_emerald,
    ipat_dancer_2,
    ipat_dancer_2_saph,
    ipat_dancer_3,
    ipat_dancer_3_emerald,
    ipat_darkmagic_blade,
    ipat_defender_0,
    ipat_defender_0_fast,
    ipat_defender_0_ruby,
    ipat_defender_1,
    ipat_defender_1_opal,
    ipat_defender_1_saph,
    ipat_defender_2,
    ipat_defender_2_emerald,
    ipat_defender_3,
    ipat_defender_3_pt2,
    ipat_divine_mirror,
    ipat_druid_0,
    ipat_druid_0_emerald,
    ipat_druid_0_ruby,
    ipat_druid_0_saph,
    ipat_druid_1,
    ipat_druid_1_emerald,
    ipat_druid_1_garnet,
    ipat_druid_1_ruby,
    ipat_druid_2,
    ipat_druid_2_2,
    ipat_druid_2_2_garnet,
    ipat_druid_2_garnet,
    ipat_druid_2_ruby,
    ipat_druid_3,
    ipat_druid_3_emerald,
    ipat_druid_3_opal,
    ipat_druid_3_ruby,
    ipat_druid_3_saph,
    ipat_erase_area_hbs,
    ipat_floral_bow,
    ipat_garnet_staff,
    ipat_hblade_0,
    ipat_hblade_0_garnet,
    ipat_hblade_0_garnet_pt2,
    ipat_hblade_1,
    ipat_hblade_1_garnet,
    ipat_hblade_1_ruby,
    ipat_hblade_1_saph,
    ipat_hblade_2,
    ipat_hblade_2_emerald,
    ipat_hblade_2_pt2,
    ipat_hblade_3,
    ipat_hblade_3_garnet,
    ipat_hblade_3_opal,
    ipat_hblade_3_ruby,
    ipat_heal_light,
    ipat_heal_light_maxhealth,
    ipat_heal_revive,
    ipat_hydrous_blob,
    ipat_lullaby_harp,
    ipat_melee_hit,
    ipat_meteor_staff,
    ipat_moon_pendant,
    ipat_nightstar_grimoire,
    ipat_none_0,
    ipat_none_1,
    ipat_none_2,
    ipat_none_3,
    ipat_ornamental_bell,
    ipat_phoenix_charm,
    ipat_poisonfrog_charm,
    ipat_potion_throw,
    ipat_pulse_damage,
    ipat_reaper_cloak,
    ipat_red_tanzaku,
    ipat_sleeping_greatbow,
    ipat_sniper_0,
    ipat_sniper_0_emerald,
    ipat_sniper_0_garnet,
    ipat_sniper_0_saph,
    ipat_sniper_1,
    ipat_sniper_1_ruby,
    ipat_sniper_2,
    ipat_sniper_2_emerald,
    ipat_sniper_3,
    ipat_sparrow_feather,
    ipat_spsword_0,
    ipat_spsword_0_pt2,
    ipat_spsword_1,
    ipat_spsword_1_emerald,
    ipat_spsword_1_pt2,
    ipat_spsword_2,
    ipat_spsword_2_pt2,
    ipat_spsword_3,
    ipat_spsword_3_pt2,
    ipat_starflash,
    ipat_starflash_failure,
    ipat_thiefs_coat,
    ipat_timewarp_wand,
    ipat_topaz_charm,
    ipat_winged_cap,
    ipat_wizard_0,
    ipat_wizard_0_ruby,
    ipat_wizard_1,
    ipat_wizard_1_garnet,
    ipat_wizard_1_garnet_pt2,
    ipat_wizard_1_opal,
    ipat_wizard_2,
    ipat_wizard_2_saph,
    ipat_wizard_3,
    ipat_wizard_3_emerald,
    ipat_wizard_3_opal,
};

pub fn addPattern(pat: AddPattern, args: anytype) void {
    addPattern2(pat, args) catch |err| @panic(@errorName(err));
}

fn addPattern2(pat: AddPattern, args: anytype) !void {
    try item_csv.print("addPattern,{s}", .{@tagName(pat)});
    try writeArgs(args);
}

fn writeArgs(args: anytype) !void {
    inline for (args) |arg| switch (@TypeOf(arg)) {
        comptime_int => try item_csv.print(",{}", .{arg}),
        else => try item_csv.print(",\"{s}\"", .{arg}),
    };

    try item_csv.writeByteNTimes(',', 4 - args.len);
    try item_csv.writeAll("\n");
}

const std = @import("std");
