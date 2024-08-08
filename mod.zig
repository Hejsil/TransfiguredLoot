var written_items: usize = 0;

var sheetlist: std.ArrayList(u8) = std.ArrayList(u8).init(std.heap.page_allocator);
var item_csv: std.ArrayList(u8) = std.ArrayList(u8).init(std.heap.page_allocator);
var item_ini: std.ArrayList(u8) = std.ArrayList(u8).init(std.heap.page_allocator);
var item_names: std.ArrayList(u8) = std.ArrayList(u8).init(std.heap.page_allocator);
var item_descriptions: std.ArrayList(u8) = std.ArrayList(u8).init(std.heap.page_allocator);

pub fn start() void {
    start2() catch |err| @panic(@errorName(err));
}

fn start2() !void {
    const cwd = std.fs.cwd();
    var path_buf: [std.fs.max_path_bytes]u8 = undefined;
    const path = try cwd.realpath(".", &path_buf);
    const name = std.fs.path.basename(path);

    try sheetlist.writer().print(
        \\Sheet Type,filename
        \\NameSheet,Mods/{[name]s}/Items_Names
        \\DescriptionSheet,Mods/{[name]s}/items_Descriptions
        \\ItemSheet,Mods/{[name]s}/Items
        \\
    ,
        .{ .name = name },
    );

    try item_names.writer().writeAll(
        \\key,level,English,Japanese,Chinese
        \\
    );
    try item_descriptions.writer().writeAll(
        \\key,level,English,Japanese,Chinese
        \\
    );
}

pub fn end() void {
    end2() catch |err| @panic(@errorName(err));
}

fn end2() !void {
    const cwd = std.fs.cwd();
    try cwd.writeFile(.{
        .sub_path = "SheetList.csv",
        .data = sheetlist.items,
    });
    try cwd.writeFile(.{
        .sub_path = "Items.csv",
        .data = try std.fmt.allocPrint(std.heap.page_allocator,
            \\spriteNumber,{},,,,
            \\{s}
        , .{ written_items, item_csv.items }),
    });
    try cwd.writeFile(.{
        .sub_path = "Items.ini",
        .data = item_ini.items,
    });
    try cwd.writeFile(.{
        .sub_path = "Items_Names.csv",
        .data = item_names.items,
    });
    try cwd.writeFile(.{
        .sub_path = "Items_Descriptions.csv",
        .data = item_descriptions.items,
    });
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

    try item_ini.writer().print("[{s}]\n", .{opt.id});
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
            bool => try item_ini.writer().print("{s}=\"{d}\"\n", .{
                field.name,
                @intFromBool(value),
            }),
            i8, u8, u16, u32, f64 => try item_ini.writer().print("{s}=\"{d}\"\n", .{
                field.name,
                value,
            }),
            []const u8 => try item_ini.writer().print("{s}=\"{s}\"\n", .{
                field.name,
                value,
            }),
            Color => try item_ini.writer().print("{s}=\"#{x:02}{x:02}{x:02}\"\n", .{
                field.name,
                value.r,
                value.g,
                value.b,
            }),
            else => try item_ini.writer().print("{s}=\"{s}\"\n", .{
                field.name,
                @tagName(value),
            }),
        };
    }

    try item_csv.writer().print(
        \\,,,,,
        \\{s},{},,,,
        \\
    ,
        .{ opt.id, written_items },
    );

    written_items += 1;
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
}

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
    cond2(condition, args) catch |err| @panic(@errorName(err));
}

fn cond2(condition: Condition, args: anytype) !void {
    try item_csv.writer().print("condition,{s}", .{condition.toCsvString()});
    try writeArgs(item_csv.writer(), args);
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

    /// "amount" (a number, in milliseconds)
    /// "minimum" (a number, in milliseconds, default 200)
    /// Adds (or subtracts) an amount from targeted hotbarslot's overall GCD.
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

pub fn qpat(pat: QuickPattern, args: anytype) void {
    qpat2(pat, args) catch |err| @panic(@errorName(err));
}

fn qpat2(pat: QuickPattern, args: anytype) !void {
    try item_csv.writer().print("quickPattern,{s}", .{pat.toCsvString()});
    try writeArgs(item_csv.writer(), args);
}

/// "Attack" patterns are things that are placed into the game, to take place over time. They
/// include things like most attacks, healing, or other things that "happen" in the game.
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
pub const AddPattern = enum {
    bleed,
    burn,
    curse,
    poison,
    spark,
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
    apply_hbs,
    apply_hbs_starflash,
    apply_invuln,
    starflash_hbs,
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
    black_wakizashi,
    blackhole_charm,
    blue_rose,
    bruiser_0,
    bruiser_0_saph,
    bruiser_1,
    bruiser_2,
    bruiser_3,
    bruiser_3_pt2,
    bruiser_3_ruby,
    butterly_ocarina,
    crown_of_storms,
    curse_talon,
    dancer_0,
    dancer_0_opal,
    dancer_1,
    dancer_1_emerald,
    dancer_2,
    dancer_2_saph,
    dancer_3,
    dancer_3_emerald,
    darkmagic_blade,
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
    divine_mirror,
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
    erase_area_hbs,
    floral_bow,
    garnet_staff,
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
    heal_light,
    heal_light_maxhealth,
    heal_revive,
    hydrous_blob,
    lullaby_harp,
    melee_hit,
    meteor_staff,
    moon_pendant,
    nightstar_grimoire,
    none_0,
    none_1,
    none_2,
    none_3,
    ornamental_bell,
    phoenix_charm,
    poisonfrog_charm,
    potion_throw,
    pulse_damage,
    reaper_cloak,
    red_tanzaku,
    sleeping_greatbow,
    sniper_0,
    sniper_0_emerald,
    sniper_0_garnet,
    sniper_0_saph,
    sniper_1,
    sniper_1_ruby,
    sniper_2,
    sniper_2_emerald,
    sniper_3,
    sparrow_feather,
    spsword_0,
    spsword_0_pt2,
    spsword_1,
    spsword_1_emerald,
    spsword_1_pt2,
    spsword_2,
    spsword_2_pt2,
    spsword_3,
    spsword_3_pt2,
    starflash,
    starflash_failure,
    thiefs_coat,
    timewarp_wand,
    topaz_charm,
    winged_cap,
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

    pub fn toCsvString(pat: AddPattern) []const u8 {
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

pub fn apat(pat: AddPattern, args: anytype) void {
    apat2(pat, args) catch |err| @panic(@errorName(err));
}

fn apat2(pat: AddPattern, args: anytype) !void {
    try item_csv.writer().print("addPattern,{s}", .{pat.toCsvString()});
    try writeArgs(item_csv.writer(), args);
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
pub const Target = enum {
    /// Clears all lists.
    none,

    // PLAYERS

    /// From a status effect receiving a trigger, target only the player afflicted with this
    /// status.
    player_afflicted,

    /// When a status effect is the SOURCE of the trigger, target the player afflicted by that
    /// status effect.
    player_afflicted_source,

    /// From an "onDamageDone" trigger, target the player that was damaged.
    player_damaged,

    /// flag (a binary number)
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

    /// excludeID (an integer) Targets all players on the same team, excluding KO'd players, and
    /// excluding the playerID passed in.
    players_ally_exclude,

    /// Targets all players on the same team. Includes KO'd players.
    players_ally_include_ko,

    /// Despite the name, this actually targets the player who's MISSING the most HP, not the
    /// actual lowest HP player. I must have written this a long time ago. Also, it excludes KO'd
    /// players.
    players_ally_lowest_hp,

    /// numberOfPlayers (an integer; this is an optional parameter)
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
    /// Targets your enemies based off a binary number.
    /// 1 : 0001 : Just player 0
    /// 2 : 0010 : Just player 1
    /// 3 : 0011 : Player 0 and Player 1
    /// 5 : 0101 : Player 0 and Player 2
    /// etc..
    players_opponent_binary,

    /// excludeID (an integer)
    /// Targets all players on the enemy team, excluding KO'd players, and excluding the playerID
    /// passed in.
    players_opponent_exclude,

    /// Targets whatever player this player is currently targetting.
    players_opponent_focus,

    /// numberOfPlayers (an integer; this is an optional parameter)
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

    ///numberOfPlayers (an integer; this is an optional parameter)
    ///Targets a random selection of the players that are currently in the list. If a number is
    ///passed in, it will try to target that many players. If no number is passed in, it will
    ///target 1.
    players_target_random,

    /// allyBin (a binary number representing player IDs)
    /// enemyBin (a binary number representing player IDs)
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
    /// Prune the current list of hotbar slots to only include items for which a boolean matches.
    hotbarslots_prune_bool,

    /// isBuff (if true, gets slots with buffs, if false, gets slots with debuffs)
    /// Prune the current list of hotbar slots to include items that have a Buff or Debuff they
    /// apply.
    hotbarslots_prune_bufftype,

    /// type (an integer representing a cooldown type)
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
    /// Targets a particular ability of the player receiving this trigger.
    /// 0 : None
    /// 1 : Primary
    /// 2 : Secondary
    /// 3 : Special
    /// 4 : Defensive
    hotbarslots_self_weapontype,

    /// wpType (an integer representing a weapon type)
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
    ttrg2(targ, args) catch |err| @panic(@errorName(err));
}

fn ttrg2(targ: Target, args: anytype) !void {
    try item_csv.writer().print("target,{s}", .{targ.toCsvString()});
    try writeArgs(item_csv.writer(), args);
}

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

    uservar,
    uservar_aflplayer_pos,
    uservar_battletime,
    uservar_blackhole_charm_calc,
    uservar_cond_squarevar_equal,
    uservar_darkflame,
    uservar_each_target_player,
    uservar_gold,
    uservar_random,
    uservar_random_range,
    uservar_slotcount,

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
            .uservar_battletime => "tset_uservar_battletime",
            .uservar_blackhole_charm_calc => "tset_uservar_blackhole_charm_calc",
            .uservar_cond_squarevar_equal => "tset_uservar_cond_squarevar_equal",
            .uservar_darkflame => "tset_uservar_darkflame",
            .uservar_each_target_player => "tset_uservar_each_target_player",
            .uservar_gold => "tset_uservar_gold",
            .uservar_random => "tset_uservar_random",
            .uservar_random_range => "tset_uservar_random_range",
            .uservar_slotcount => "tset_uservar_slotcount",
        };
    }
};

pub fn tset(s: Set, args: anytype) void {
    tset2(s, args) catch |err| @panic(@errorName(err));
}

fn tset2(s: Set, args: anytype) !void {
    try item_csv.writer().print("set,{s}", .{s.toCsvString()});
    try writeArgs(item_csv.writer(), args);
}

fn writeArgs(writer: anytype, args: anytype) !void {
    inline for (args) |arg| switch (@TypeOf(arg)) {
        comptime_int => try writer.print(",{}", .{arg}),
        else => {
            try writer.writeAll(",");
            try writeCsvString(writer, arg);
        },
    };

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

const std = @import("std");
