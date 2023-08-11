const std = @import("std");

const pdfium = @cImport({
    @cInclude("fpdfview.h");
    @cInclude("fpdf_edit.h");
});

/// Represents a single page in a pdf document.
pub const Page = struct {
    page: pdfium.FPDF_PAGE,

    const Self = @This();

    /// Closes the page.
    pub fn close(self: *const Self) void {
        pdfium.FPDF_ClosePage(self.page);
    }

    /// Gets the height of the page.
    pub fn getHeight(self: *const Self) f32 {
        return pdfium.FPDF_GetPageHeightF(self.page);
    }

    /// Gets the width of the page.
    pub fn getWidth(self: *const Self) f32 {
        return pdfium.FPDF_GetPageWidthF(self.page);
    }

    /// Gets the page's rotation
    /// ```
    /// 0 - No Rotation
    /// 1 - Rotated 90 degrees clockwise.
    /// 2 - Rotated 180 degrees clockwise.
    /// 3 - Rotated 270 degrees clockwise.
    /// ```
    pub fn getRotation(self: *const Self) u2 {
        // First, get the rotation of the object and its
        const rotation_c: i3 = @truncate(pdfium.FPDFPage_GetRotation(self.page));
        const rotation: u3 = @bitCast(rotation_c);
        //const rotation: i3 = @truncate();
        return @truncate(rotation);
    }
};
