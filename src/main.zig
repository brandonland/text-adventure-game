const std = @import("std");
const print = std.debug.print;

//const glfw = @import("zglfw");
//const gl = @import("zopengl");

const raylib = @import("raylib");
const raygui = @import("raygui");

var conf_flags: raylib.ConfigFlags = raylib.ConfigFlags{};

const screen_width: i32 = 690;
const screen_height: i32 = 560;

var textBoxText = std.mem.zeroes([64]u8);
var textBoxEditMode: bool = true;

var exitWindow = false;

const font: raylib.Font = raylib.LoadFontEx(
    "assets/fonts/Fira Code Medium Nerd Font Complete Mono.ttf", // font file
    18, // font size
    null, // null for default
    0, // 0 for default
);

pub fn main() !void {
    conf_flags.FLAG_WINDOW_RESIZABLE = true;

    raylib.InitWindow(screen_width, screen_height, "Text Adventure Game (working title)");
    defer raylib.CloseWindow();

    raylib.SetConfigFlags(conf_flags);
    raylib.SetTargetFPS(60);
    raylib.SetExitKey(.KEY_NULL);

    std.mem.copy(u8, &textBoxText, "");

    while (!raylib.WindowShouldClose()) {

        //raylib.DrawFPS(10, 10);

        exitWindow = raylib.WindowShouldClose();

        //var buf: [4096]u8 = undefined;
        //var fba = std.heap.FixedBufferAllocator.init(&buf);

        raylib.BeginDrawing();
        defer raylib.EndDrawing();

        raylib.ClearBackground(raylib.BLACK);

        raygui.GuiSetStyle(
            @intFromEnum(raygui.GuiControl.TEXTBOX),
            @intFromEnum(raygui.GuiControlProperty.TEXT_ALIGNMENT),
            @intFromEnum(raygui.GuiTextAlignment.TEXT_ALIGN_LEFT),
        );
        const textbox_height = 30;
        const textbox_padding = 5;
        const textbox_rect = .{ .x = textbox_padding, .y = (screen_height - textbox_height - textbox_padding), .width = screen_width - (textbox_padding * 2), .height = textbox_height };
        const textbox_text = @as(?[*:0]u8, @ptrCast(&textBoxText));
        //if (raygui.GuiTextBox(textbox_rect, textbox_text, 256, textBoxEditMode) == 1) {
        //    textBoxEditMode = !textBoxEditMode;
        //}
        _ = raygui.GuiTextBox(textbox_rect, textbox_text, 256, textBoxEditMode);

        //_ = raygui.GuiStatusBar(.{ .x = 0, .y = @as(f32, @floatFromInt(raylib.GetScreenHeight() - 20)), .width = @as(f32, @floatFromInt(raylib.GetScreenWidth())), .height = 20 }, "This is a status bar");
    }
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
