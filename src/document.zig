const std = @import("std");
const fpdfview = @cImport(@cInclude("fpdfview.h"));
const @"error" = @import("error.zig");
const PdfiumError = @"error".PdfiumError;
const handleError = @"error".handleError;
const Page = @import("page.zig").Page;

pub const Rect = struct {
    x: f32,
    y: f32,
};

/// Represents a single pdf document.
/// It is possible to load external documents
/// as we as create new documents.
pub const Document = struct {
    doc: fpdfview.FPDF_DOCUMENT,
    buffer: ?[]u8,
    allocator: ?std.mem.Allocator,

    const Self = @This();

    /// Initialises the document with an allocator.
    /// The document must then load the document through functions like
    /// `loadDocument`
    pub fn init(allocator: std.mem.Allocator) Document {
        return Document{
            .doc = null,
            .buffer = null,
            .allocator = allocator,
        };
    }

    /// Load a document from the filesystem.
    /// The first argument represents the filename and
    /// the second argument takes the password. The password may
    /// be null if it is not needed.
    pub fn loadDocument(self: *const Self, filename: []const u8, password: ?[*]const u8) !Document {
        const file = try std.fs.cwd().openFile(filename, .{});
        const buf = try file.readToEndAlloc(self.allocator.?, std.math.maxInt(c_int));
        return loadDocumentFromMemory(buf, password);
    }

    /// Loads a document from memory.
    /// The buffer should remain valid throughout the
    /// lifetime of the document.
    pub fn loadDocumentFromMemory(buf: []const u8, password: ?[*]const u8) !Document {
        // const size_u: c_uint = @truncate(buf.len);
        // const size: c_int = @bitCast(size_u);    
        const doc = fpdfview.FPDF_LoadMemDocument64(buf.ptr, buf.len, password);
        if (doc == null) {
            return handleError();
        }
        return Document{
            .doc = doc,
            .buffer = null,
            .allocator = null,
        };
    }

    /// Closes the document.
    /// Also deallocates the any resources owned by the document.
    pub fn close(self: *const Self) void {
        fpdfview.FPDF_CloseDocument(self.doc);
        if (self.buffer) |buffer| {
            if (self.allocator) |allocator| {
                allocator.free(buffer);
            } else {
                @panic("Buffer is non null but allocator is null");
            }
        }
    }

    /// Gets the version of the current pdf document.
    /// For example -
    /// ```zig
    /// 15 => 1.5
    /// 16 => 1.6
    /// ...
    /// ```
    pub fn getVersion(self: *const Self) !i32 {
        var version: i32 = undefined;
        if (fpdfview.FPDF_GetFileVersion(self.doc, &version) != 0) {
            return version;
        }
        return PdfiumError.VersionError;
    }

    /// Gets the number of pages in the document.
    pub fn getPageCount(self: *const Self) i32 {
        return fpdfview.FPDF_GetPageCount(self.doc);
    }

    /// Gets a specific page from the document.
    ///
    /// Must lie in `[0, pageCount)`
    ///
    /// `0` denotes the first page.
    pub fn getPage(self: *const Document, index: u31) !Page {
        const page = fpdfview.FPDF_LoadPage(self.doc, index);
        if (page == null) {
            return handleError();
        }
        return Page{
            .page = page,
        };
    }

    pub fn getPageSizeAtIndex(self: *const Self, index: u31, width: *f64, height: *f64) void {
        fpdfview.FPDF_GetPageSizeByIndex(self.doc, index, width, height);
    }

    /// Experimental api
    pub fn hasValidCrossReferenceTable(self: *const Self) bool {
        if (fpdfview.FPDF_DocumentHasValidCrossReferenceTable(self.doc) > 0) {
            return true;
        }
        return false;
    }
};