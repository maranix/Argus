const std = @import("std");
const c = @cImport({
    @cInclude("CoreServices/CoreServices.h");
});

const CFStringRef = c.CFStringRef;
const CFArrayRef = c.CFArrayRef;

const FSEventStreamRef = c.FSEventStreamRef;

const CFStringCreateWithCString = c.CFStringCreateWithCString;

fn callback(
    streamRef: c.ConstFSEventStreamRef,
    clientCallBackInfo: ?*anyopaque,
    numEvents: usize,
    eventPaths: ?*anyopaque,
    eventFlags: ?[*]const c.FSEventStreamEventFlags,
    eventIds: ?[*]const c.FSEventStreamEventId,
) callconv(.C) void {
    _ = streamRef;
    _ = clientCallBackInfo;
    _ = numEvents;
    _ = eventPaths;
    _ = eventFlags;
    _ = eventIds;

    std.debug.print("File changed\n", .{});
}

const Gpa = std.heap.GeneralPurposeAllocator(.{});

pub fn run() !void {
    const watch = "./";

    var gpa = Gpa{};
    defer _ = gpa.deinit();

    var galloc = &gpa.allocator();
    var path = try galloc.alloc(c.CFStringRef, 1);
    defer galloc.free(path);
    path[0] = CFStringCreateWithCString(null, watch, c.kCFStringEncodingUTF8);

    const pathRef = c.CFArrayCreate(null, @ptrCast(path.ptr), @intCast(path.len), null);
    const latency = 0.5;

    const stream = c.FSEventStreamCreate(
        null,
        &callback,
        null,
        pathRef,
        c.kFSEventStreamEventIdSinceNow,
        latency,
        c.kFSEventStreamCreateFlagNone,
    );

    // Create a serial dispatch queue for handling events
    const queue = c.dispatch_queue_create("event_queue", null);
    defer c.dispatch_release(queue);

    // Set the dispatch queue for the stream
    c.FSEventStreamSetDispatchQueue(stream, queue);

    // Start the stream
    _ = c.FSEventStreamStart(stream);
    defer c.FSEventStreamStop(stream);

    // Main loop (prevent the program from exiting immediately)
    while (true) {
        std.time.sleep(1 * std.time.ns_per_s);
    }
}
