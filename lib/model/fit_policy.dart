/// Defining the fit policy for the PDF page.
///
/// There are three types of policies:
/// - width: The PDF page will be resized to fit the width.
///
/// - height: The PDF page will be reseized to fit the height.
///
/// - both: If the height is bigger than the width, the PDF page will be resized
///   to fit the height, otherwise the width
enum FitPolicy { width, height, both }
