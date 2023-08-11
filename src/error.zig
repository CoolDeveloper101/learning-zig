const pdfium = @cImport({
    @cInclude("fpdfview.h");
});

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

    /// Creation Error
    CreationError
};

pub fn handleError() PdfiumError {
    const err = pdfium.FPDF_GetLastError();

    return switch (err) {
        pdfium.FPDF_ERR_SUCCESS => PdfiumError.Success,
        pdfium.FPDF_ERR_UNKNOWN => PdfiumError.Unknown,
        pdfium.FPDF_ERR_FILE => PdfiumError.FileNotFound,
        pdfium.FPDF_ERR_FORMAT => PdfiumError.InvalidFormat,
        pdfium.FPDF_ERR_PASSWORD => PdfiumError.Password,
        pdfium.FPDF_ERR_SECURITY => PdfiumError.Security,
        pdfium.FPDF_ERR_PAGE => PdfiumError.PageNotFound,
        else => unreachable,
    };
}
