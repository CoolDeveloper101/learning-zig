const std = @import("std");
const fpdfview = @cImport(@cInclude("fpdfview.h"));
const Document = @import("document.zig").Document;

var gpa = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};
const alloc = gpa.allocator();

pub fn main() !void {
    // var config: fpdfview.FPDF_LIBRARY_CONFIG = undefined;
    // config.version = 2;
    // config.m_pUserFontPaths = null;
    // config.m_pIsolate = null;
    // config.m_v8EmbedderSlot = 0;
    // fpdfview.FPDF_InitLibraryWithConfig(&config);

    initLibrary();
    defer destroyLibrary();

    // const filename = "Simple PDF 2.0 file.pdf";
    const filename = "ISO_32000-2-2020_sponsored.pdf";
    // const pdf_2 = try std.fs.cwd().openFile(filename, .{});
    // const buffer = try pdf_2.readToEndAlloc(alloc, std.math.maxInt(usize));
    // defer pdf_2.close();
    // defer alloc.free(buffer);

    const doc = try Document.init(alloc).loadDocument(filename, null);
    defer doc.close();

    std.debug.print("{}\n", .{try doc.getVersion()});
    std.debug.print("{}\n", .{doc.getPageCount()});

    const page = try doc.getPage(3);
    defer page.close();

    std.debug.print("Page height is {d:.2}in\n", .{page.getHeight() / 72.0});
    std.debug.print("Page width is {d:.2}in\n", .{page.getWidth() / 72.0});
    std.debug.print("Page rotation is {d}°\n", .{@as(usize, page.getRotation()) * 90});
}

/// Initializes the global library state.
/// This function must be called once.
/// After initialising, the `destroyLibrary`
/// must be called to deinitialize the library.
/// ```zig
/// initLibrary();
/// defer destroyLibrary();
/// ...
/// ```
pub fn initLibrary() void {
    const config = fpdfview.FPDF_LIBRARY_CONFIG{
        .version = 2,
        .m_pUserFontPaths = null,
        .m_pIsolate = null,
        .m_v8EmbedderSlot = 0,
        .m_pPlatform = null,
        .m_RendererType = undefined,
    };
    fpdfview.FPDF_InitLibraryWithConfig(&config);
}


/// Destroys the library.
pub fn destroyLibrary() void {
    fpdfview.FPDF_DestroyLibrary();
}


pub fn handle_error() void {
    const err = fpdfview.FPDF_GetLastError();
    switch (err) {
        fpdfview.FPDF_ERR_SUCCESS => std.debug.print("", .{}),
        fpdfview.FPDF_ERR_UNKNOWN => std.debug.print("", .{}),
        fpdfview.FPDF_ERR_FILE => std.debug.print("", .{}),
        fpdfview.FPDF_ERR_FORMAT => std.debug.print("", .{}),
        fpdfview.FPDF_ERR_PASSWORD => std.debug.print("", .{}),
        fpdfview.FPDF_ERR_SECURITY => std.debug.print("", .{}),
        fpdfview.FPDF_ERR_PAGE => std.debug.print("", .{}),
        else => std.debug.print("Unknown Error: {d}", .{err}),
    }
    std.debug.print("\n", .{});
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
