// Validates every workbook in excel/ with Microsoft's Open XML SDK, against the
// Office 2019 file format: the rules Excel applies when it opens a file.
// A workbook that fails here is one Excel would offer to "repair".
using DocumentFormat.OpenXml;
using DocumentFormat.OpenXml.Packaging;
using DocumentFormat.OpenXml.Validation;

var dir = args.Length > 0 ? args[0] : "excel";
var validator = new OpenXmlValidator(FileFormatVersions.Office2019);
int total = 0;
var report = new List<string> { "# Excel file format (Microsoft Open XML SDK, Office 2019 rules)", "",
                                "| Workbook | Errors |", "|---|---:|" };
foreach (var path in Directory.GetFiles(dir, "*.xlsx").OrderBy(p => p))
{
    using var doc = SpreadsheetDocument.Open(path, false);
    var errors = validator.Validate(doc).ToList();
    total += errors.Count;
    report.Add($"| {Path.GetFileName(path)} | {errors.Count} |");
    foreach (var e in errors.Take(20))
        Console.WriteLine($"{Path.GetFileName(path)}: {e.Part?.Uri} {e.Path?.XPath}: {e.Description}");
}
report.Add(""); report.Add($"**Errors in total: {total}**");
Directory.CreateDirectory("tests/output");
File.WriteAllLines("tests/output/OPENXML_REPORT.md", report);
Console.WriteLine(string.Join(Environment.NewLine, report));
return total == 0 ? 0 : 1;
