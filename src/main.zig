const std = @import("std");
const print = std.debug.print;

//const glfw = @import("zglfw");
//const gl = @import("zopengl");

const raylib = @import("raylib");
//const raygui = @import("raygui");

const game = @import("game.zig");
const map = @import("map.zig");

const screen_width: i32 = 800;
const screen_height: i32 = 450;
const max_input_chars: usize = 420;
var letter_count: usize = 0;
var frames_counter: usize = 0;
const textbox_height = 50;
const textbox = raylib.Rectangle{
    .x = 10,
    .y = screen_height - (textbox_height + 10),
    .width = screen_width - 20,
    .height = textbox_height,
};

var conf_flags: raylib.ConfigFlags = raylib.ConfigFlags{};

// NOTE: One extra space required for null terminator char '\0'
var uinput = [_]u8{0} ** (max_input_chars + 1);

var vec_cursor: raylib.Vector2 = undefined;
var cursor_vector: raylib.Vector2 = undefined;

const UserInput = struct {
    const Self = @This();
    str: []u8,

    pub fn reset(self: *Self) void {
        self.str = "";
    }
};

const CmdPayload = struct {
    //input: ?[][]const u8 = null,
    input: *std.mem.TokenIterator(u8, .any),
    player: ?*PlayerState = null,
};

const ItemType = enum {
    basic,
    wieldable,
    wearable,
    consumable,
    currency,
};

pub const Item = struct {
    id: u16, // for retrieval
    name: []const u8, // Printable name
    description: []const u8,
    stackable: bool,
    type: ItemType,
    degradable: bool = false,
    weight: f16, // in lbs
    is_key: bool = false,
};

const PlayerState = struct {
    hp: u32,
    room: *map.Room = &map.rooms[0],
    //status_effects: ?[]StatusEffect,
    inventory: ?[]const Item,
    item_wielded: ?Item,
    gear_equipped: ?[]Item,
    ripperdoc_mods: ?[]Item,
    carrying_capacity: f16,
};

pub const ItemsList = std.MultiArrayList(Item);

var input_font: raylib.Font = undefined;
var input_font_vec: raylib.Vector2 = undefined;

pub fn main() !void {
    conf_flags.FLAG_WINDOW_RESIZABLE = true;

    raylib.InitWindow(screen_width, screen_height, "Text Adventure Game (working title)");
    defer raylib.CloseWindow();

    raylib.SetConfigFlags(conf_flags);
    raylib.SetTargetFPS(60);

    // Font of room descriptions
    const font_path = "assets/fonts/Fira Code Medium Nerd Font Complete Mono.ttf";
    map.desc_font = raylib.LoadFontEx(
        font_path, // font file
        18, // font size
        null, // codepoints - (null for default)
        0, // codepointCount (0 for default)
    );

    // Font vector of room descriptions
    map.desc_font_vec = raylib.Vector2{
        .x = 5.0,
        .y = 8.0,
    };

    // Font of input textbox
    input_font = raylib.LoadFontEx(
        font_path,
        40,
        null,
        0,
    );

    // User input font position
    input_font_vec = raylib.Vector2{
        .x = (textbox.x + 5.0),
        .y = (textbox.y + 8.0),
    };

    raylib.SetExitKey(.KEY_NULL);

    //var user_input = UserInput{ .str = &[_]u8{0} ** (max_input_chars + 1) };
    var user_input = "";

    while (!raylib.WindowShouldClose()) {
        //---------------------------------------------------------------------
        // Update
        //---------------------------------------------------------------------
        //var buf: [4096]u8 = undefined;
        //var fba = std.heap.FixedBufferAllocator.init(&buf);
        //_ = fba;

        var key = raylib.GetCharPressed();

        while (key > 0) {
            if ((key >= 32) and (key <= 125) and (letter_count < max_input_chars)) {
                uinput[letter_count] = @as(u8, @intCast(key));
                uinput[letter_count + 1] = 0; // Add null terminator at end of the string
                letter_count += 1;
            }

            key = raylib.GetCharPressed();
        }

        // TODO: Holing backspace should have an initial delay, just like
        // holding any character key currently does.
        //
        //if (raylib.IsKeyDown(.KEY_BACKSPACE)) {
        if (raylib.IsKeyPressed(.KEY_BACKSPACE)) {
            if (letter_count > 0) {
                letter_count -= 1;
            }
            uinput[letter_count] = 0;
        }

        frames_counter += 1;

        if (raylib.IsKeyPressed(.KEY_ENTER)) {
            frames_counter = 0;
            //user_input = uinput;
            std.debug.print("You pressed Enter.\n\n", .{});
            std.debug.print("User input: {s}\n", .{uinput});
            letter_count = 0;
            uinput[letter_count] = 0;
            for (uinput, 0..) |s, i| {
                _ = s;
                uinput[i] = 0; // write zeros
            }
            //std.debug.print("You pressed enter.\nCaptured input is: {s}", .{captured_input});
        }

        //---------------------------------------------------------------------
        // Draw
        //---------------------------------------------------------------------

        //var buf: [4096]u8 = undefined;
        //var fba = std.heap.FixedBufferAllocator.init(&buf);

        raylib.BeginDrawing();
        defer raylib.EndDrawing();

        raylib.ClearBackground(raylib.BLACK);

        map.rooms[0].drawRoomDesc();

        // This is the actual rectangle of the text input.
        raylib.DrawRectangleRec(textbox, raylib.DARKGRAY);
        raylib.DrawRectangleLines(
            @as(i32, @intFromFloat(textbox.x)),
            @as(i32, @intFromFloat(textbox.y)),
            @as(i32, @intFromFloat(textbox.width)),
            @as(i32, @intFromFloat(textbox.height)),
            raylib.BLACK,
        );

        // This is the text the user actually types in.
        raylib.DrawTextEx(
            input_font,
            @as([*:0]u8, @ptrCast(&uinput)),
            input_font_vec,
            40.0,
            0,
            raylib.WHITE,
        );

        // Blinking cursor vector
        cursor_vector = raylib.Vector2{
            .x = textbox.x + 8.0 + raylib.MeasureTextEx(
                input_font,
                @as([*:0]u8, @ptrCast(&uinput)),
                40,
                0,
            ).x,
            .y = input_font_vec.y,
        };

        // Blinking cursor
        if (letter_count < max_input_chars) {
            if (((frames_counter / 20) % 2) == 0) {
                raylib.DrawTextEx(
                    input_font,
                    "_",
                    cursor_vector,
                    40,
                    0,
                    raylib.WHITE,
                );
                //raylib.DrawText(
                //    "_",
                //    @as(c_int, @intFromFloat(textbox.x)) + 8 + raylib.MeasureText(@as([*:0]u8, @ptrCast(&uinput)), 40),
                //    @as(c_int, @intFromFloat(textbox.y)) + 12,
                //    40,
                //    raylib.WHITE,
                //);
            }
        } else {
            raylib.DrawText("You've reached the character limit.", 230, 300, 20, raylib.GRAY);
        }

        // Check if any input was captured. If so, do something with it,
        // then reset captured_input.
        if (user_input.len > 0) {
            //raylib.DrawText(
            //    "Captured input: " ++ captured_input,

            //);

            std.debug.print("captured input: {s}", .{user_input});
        }

        //_ = raygui.GuiTextBox(textbox_rect, textbox_text, 256, textBoxEditMode);
        //const custom_style = raygui.GuiTextStyle{};
        //_ = custom_style;

        //_ = raygui.GuiStatusBar(.{ .x = 0, .y = @as(f32, @floatFromInt(raylib.GetScreenHeight() - 20)), .width = @as(f32, @floatFromInt(raylib.GetScreenWidth())), .height = 20 }, "This is a status bar");
    }
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
