const std = @import("std");
const handleError = @import("error.zig").handleError;

const pdfium = @cImport({
    @cInclude("fpdfview.h");
    @cInclude("fpdf_edit.h");
});


pub const Bitmap = struct {
    bitmap: pdfium.FPDF_BITMAP,

    pub fn create(width: u31, height: u31, alpha: u31) !Bitmap {
        const bitmap = pdfium.FPDFBitmap_Create(width, height, alpha);
        
        if (bitmap == null) {
            return handleError();
        }

        return Bitmap {
            .bitmap = bitmap,
        };
    }

    pub fn createEx(width: u31, height: u31, first_scan: ?*void, stride: u31) !Bitmap {
        _ = stride;
        _ = first_scan;
        _ = height;
        _ = width;
        
    }

    pub fn getFormat(self: *const Bitmap) BitmapFormat {
        const format = pdfium.FPDFBitmap_GetFormat(self.bitmap);
        return @enumFromInt(format);
    }
};


pub const BitmapFormat = enum(u3) {
    Unknown = pdfium.FPDFBitmap_Unknown,
    Gray = pdfium.FPDFBitmap_Gray,
    BGR = pdfium.FPDFBitmap_BGR,
    BGRx = pdfium.FPDFBitmap_BGRx,
    BGRA = pdfium.FPDFBitmap_BGRA,
};