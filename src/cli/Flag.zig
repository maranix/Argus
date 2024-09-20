const std = @import("std");

const Self = @This();

/// A human-readable description for the flag, typically explaining its purpose.
///
/// This description gives context for what the flag represents in the CLI application.
///
/// Example: "Enable debug logging for troubleshooting"
description: ?[]const u8,

/// The full (long form) name for the flag (prefixed with `--` by default).
///
/// This represents the long name for the flag in command-line interfaces.
///
/// Example: "verbose"
long: ?[]const u8,

/// The short (single-character) name for the flag (prefixed with `-` by default).
///
/// This represents a concise single-character option for the flag in the command-line interface.
///
/// Example: "v"
short: ?[]const u8,

pub fn new() Self {
    return Self{
        .description = null,
        .long = null,
        .short = null,
    };
}
