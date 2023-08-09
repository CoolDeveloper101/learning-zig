const std = @import("std");
const fpdfview = @cImport(@cInclude("fpdfview.h"));


/// Represents a single page in a pdf document.
pub const Page = struct {
    page: fpdfview.FPDF_PAGE,

    const Self = @This();

    /// Closes the page.
    pub fn close(self: *const Self) void {
        fpdfview.FPDF_ClosePage(self.page);
    }

    /// Gets the height of the page.
    pub fn getHeight(self: *const Self) f32 {
        return fpdfview.FPDF_GetPageHeightF(self.page);
    }

    /// Gets the width of the page.
    pub fn getWidth(self: *const Self) f32 {
        return fpdfview.FPDF_GetPageWidthF(self.page);
    }
};
