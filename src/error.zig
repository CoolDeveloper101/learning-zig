const fpdfview = @cImport(@cInclude("fpdfview.h"));

pub const PdfiumError = error {
    /// Success
    Success,

    /// Unknown Error
    Unknown,

    /// File not found or could not be opened
    FileNotFound,

    /// Invalid format
    InvalidFormat,

    /// Password required or incorrect
    Password,

    /// Unsuported security scheme
    Security,

    /// Page not found or content error
    PageNotFound,

    /// Invalid version
    VersionError,
};

pub fn handleError() PdfiumError {
    const err = fpdfview.FPDF_GetLastError();

    return switch (err) {
        fpdfview.FPDF_ERR_SUCCESS => PdfiumError.Success,
        fpdfview.FPDF_ERR_UNKNOWN => PdfiumError.Unknown,
        fpdfview.FPDF_ERR_FILE => PdfiumError.FileNotFound,
        fpdfview.FPDF_ERR_FORMAT => PdfiumError.InvalidFormat,
        fpdfview.FPDF_ERR_PASSWORD => PdfiumError.Password,
        fpdfview.FPDF_ERR_SECURITY => PdfiumError.Security,
        fpdfview.FPDF_ERR_PAGE => PdfiumError.PageNotFound,
        else => unreachable,
    };
}
