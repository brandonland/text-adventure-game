# Untitled Text Adventure Game

A text adventure written in Zig.

This is a learning project—I am very new to Zig, low/systems-level languages, and game development in general. 

## How to build/run
1. Install [Zig 11.0](https://ziglang.org/download/)
    - Currently, if you try to build/run with version 12, it won't compile; this should change in the future.
2. Additional libraries are required in order to build with raylib. Instructions vary by platform:
    - [GNU Linux](https://github.com/raysan5/raylib/wiki/Working-on-GNU-Linux)
    - [Windows](https://github.com/raysan5/raylib/wiki/Working-on-Windows)
    - [macOS](https://github.com/raysan5/raylib/wiki/Working-on-macOS)
3. Once you've done the above, clone the project and run:
    - Clone: `git clone https://github.com/brandonland/text-adventure-game.git`
    - cd into directory: `cd text-adventure-game`
    - Fetch submodules: `git submodule update --init --recursive`
    - Run: `zig build run`
