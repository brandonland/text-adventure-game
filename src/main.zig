const std = @import("std");
const print = std.debug.print;

//const glfw = @import("zglfw");
//const gl = @import("zopengl");

const raylib = @import("raylib");
//const raygui = @import("raygui");

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
var captured_input: []u8 = undefined;

var font: raylib.Font = undefined;
var font_vec: raylib.Vector2 = undefined;
var vec_cursor: raylib.Vector2 = undefined;
var new_vec_cursor: *raylib.Vector2 = undefined;

pub fn main() !void {
    conf_flags.FLAG_WINDOW_RESIZABLE = true;

    raylib.InitWindow(screen_width, screen_height, "Text Adventure Game (working title)");
    defer raylib.CloseWindow();

    raylib.SetConfigFlags(conf_flags);
    raylib.SetTargetFPS(60);

    const font_path = "assets/fonts/Fira Code Medium Nerd Font Complete Mono.ttf";
    font = raylib.LoadFontEx(
        font_path, // font file
        18, // font size
        null, // codepoints - (null for default)
        0, // codepointCount (0 for default)
    );
    font_vec = raylib.Vector2{
        .x = (textbox.x + 5.0),
        .y = (textbox.y + 8.0),
    };

    new_vec_cursor = &font_vec;
    new_vec_cursor.*.x = new_vec_cursor.*.x + 8.0;

    raylib.SetExitKey(.KEY_NULL);

    while (!raylib.WindowShouldClose()) {
        //---------------------------------------------------------------------
        // Update
        //---------------------------------------------------------------------
        var buf: [4096]u8 = undefined;
        var fba = std.heap.FixedBufferAllocator.init(&buf);
        _ = fba;

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
        //if (raylib.IsKeyPressed(raylib.KeyboardKey.KEY_BACKSPACE)) {
        //    if (letter_count > 0) {
        //        letter_count -= 1;
        //    } else {
        //        frames_counter = 0;
        //    }
        //}

        //frames_counter += if (raylib.IsKeyDown(raylib.KEY_SPACE)) 8 else 1;
        //if (raylib.IsKeyDown(raylib.KeyboardKey.KEY_SPACE)) {
        //    frames_counter += 8;
        //} else {
        //    frames_counter += 1;
        //}
        //
        frames_counter += 1;

        if (raylib.IsKeyPressed(.KEY_ENTER)) {
            frames_counter = 0;
            captured_input = @as([]u8, &uinput);
            uinput = [_]u8{0} ** (max_input_chars + 1);
        }

        //---------------------------------------------------------------------
        // Draw
        //---------------------------------------------------------------------

        //var buf: [4096]u8 = undefined;
        //var fba = std.heap.FixedBufferAllocator.init(&buf);

        raylib.BeginDrawing();
        defer raylib.EndDrawing();

        raylib.ClearBackground(raylib.BLACK);

        raylib.DrawText("Hello, World!", 240, 140, 20, raylib.GRAY);
        //raylib.DrawTextEx("");
        //

        raylib.DrawRectangleRec(textbox, raylib.DARKGRAY);
        raylib.DrawRectangleLines(
            @as(i32, @intFromFloat(textbox.x)),
            @as(i32, @intFromFloat(textbox.y)),
            @as(i32, @intFromFloat(textbox.width)),
            @as(i32, @intFromFloat(textbox.height)),
            raylib.BLACK,
        );

        raylib.DrawText(
            @as([*:0]u8, @ptrCast(&uinput)),
            @as(c_int, @intFromFloat(textbox.x)) + 5,
            @as(c_int, @intFromFloat(textbox.y)) + 8,
            40,
            raylib.WHITE,
        );

        // Blinking cursor
        if (letter_count < max_input_chars) {
            if (((frames_counter / 20) % 2) == 0) {
                raylib.DrawText(
                    "_",
                    @as(c_int, @intFromFloat(textbox.x)) + 8 + raylib.MeasureText(@as([*:0]u8, @ptrCast(&uinput)), 40),
                    @as(c_int, @intFromFloat(textbox.y)) + 12,
                    40,
                    raylib.WHITE,
                );
            }
        } else {
            raylib.DrawText("You've reached the character limit.", 230, 300, 20, raylib.GRAY);
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
